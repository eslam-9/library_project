import 'package:library_project/feature/member/model/member_dashboard_model.dart';
import 'package:library_project/feature/member/model/member_books_model.dart';
import 'package:library_project/feature/member/model/available_book_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<MemberDashboardData> fetchDashboardData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw AuthException('User not authenticated');
      }

      final memberRow = await _getOrCreateMember(user);
      final memberId = memberRow['id'] as int;

      final totalBorrowedFuture = _countRows(
        _supabase.from('borrowing').select('id').eq('member_id', memberId),
      );

      final activeBorrowingsFuture = _countRows(
        _supabase
            .from('borrowing')
            .select('id')
            .eq('member_id', memberId)
            .isFilter('returned_at', null),
      );

      final overdueBorrowingsFuture = _countRows(
        _supabase
            .from('borrowing')
            .select('id')
            .eq('member_id', memberId)
            .isFilter('returned_at', null)
            .lt('due_at', DateTime.now().toIso8601String()),
      );

      final recentBorrowingsFuture = _fetchRecentBorrowings(memberId);

      final results = await Future.wait<int>([
        totalBorrowedFuture,
        activeBorrowingsFuture,
        overdueBorrowingsFuture,
      ]);

      final stats = MemberStats(
        totalBorrowed: results[0],
        activeBorrowings: results[1],
        overdueBorrowings: results[2],
      );

      final recentBorrowings = await recentBorrowingsFuture;

      return MemberDashboardData(
        stats: stats,
        recentBorrowings: recentBorrowings,
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<int> _countRows(
    PostgrestFilterBuilder<PostgrestList> query,
  ) async {
    final response = await query.count();
    return response.count;
  }

  static Future<List<MemberBorrowingRecord>> _fetchRecentBorrowings(
    int memberId,
  ) async {
    final borrowingRows = await _supabase
        .from('borrowing')
        .select('id, copy_id, borrowed_at, due_at, returned_at, status')
        .eq('member_id', memberId)
        .order('borrowed_at', ascending: false)
        .limit(6);

    if (borrowingRows.isEmpty) {
      return [];
    }

    final copyIds = borrowingRows
        .map((row) => row['copy_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    final copies = await _fetchCopiesByIds(copyIds);

    final bookIds = copies.values
        .map((copy) => copy['book_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    final books = await _fetchBooksByIds(bookIds);

    return borrowingRows.map((row) {
      final copyId = row['copy_id'] as int?;
      final copy = copies[copyId];
      final status = row['status'] as String? ?? 'Unknown';
      final bookId = copy?['book_id'] as int?;
      final bookTitle =
          books[bookId]?['title'] as String? ?? 'Book #${bookId ?? '-'}';

      return MemberBorrowingRecord(
        id: row['id'] as int,
        bookTitle: bookTitle,
        status: status,
        borrowedAt: _parseDate(row['borrowed_at']) ?? DateTime.now(),
        dueAt: _parseDate(row['due_at']),
        returnedAt: _parseDate(row['returned_at']),
      );
    }).toList();
  }

  static Future<Map<int, Map<String, dynamic>>> _fetchCopiesByIds(
    List<int> ids,
  ) async {
    if (ids.isEmpty) return {};
    final rows = await _supabase
        .from('book_copies')
        .select('id, status, book_id')
        .inFilter('id', ids);

    return {for (final row in rows) row['id'] as int: row};
  }

  static Future<Map<int, Map<String, dynamic>>> _fetchBooksByIds(
    List<int> ids,
  ) async {
    if (ids.isEmpty) return {};
    final rows = await _supabase
        .from('books')
        .select('id, title, author')
        .inFilter('id', ids);

    return {for (final row in rows) row['id'] as int: row};
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

  static Future<Map<String, dynamic>> _getOrCreateMember(User user) async {
    final existing = await _supabase
        .from('members')
        .select('id, email')
        .eq('profile_id', user.id)
        .maybeSingle();

    if (existing != null) {
      return existing;
    }

    final inserted = await _supabase
        .from('members')
        .insert({'profile_id': user.id, 'email': user.email})
        .select('id, email')
        .single();

    return inserted;
  }

  static Future<List<MemberBook>> fetchAllBooks() async {
    final booksRows = await _supabase
        .from('books')
        .select('id, title, author, description, daily_price');

    if (booksRows.isEmpty) {
      return [];
    }

    final bookIds = booksRows
        .map((row) => row['id'] as int?)
        .whereType<int>()
        .toList();

    final copiesRows = await _supabase
        .from('book_copies')
        .select('book_id, status')
        .inFilter('book_id', bookIds);

    final Map<int, int> availableCounts = {};
    for (final row in copiesRows) {
      final bookId = row['book_id'] as int?;
      final status = row['status'] as String?;
      if (bookId == null) continue;
      if (status == 'Available') {
        availableCounts[bookId] = (availableCounts[bookId] ?? 0) + 1;
      }
    }

    return booksRows.map<MemberBook>((row) {
      final id = row['id'] as int;
      final title = row['title'] as String? ?? 'Untitled';
      final author = row['author'] as String?;
      final description = row['description'] as String?;
      final available = availableCounts[id] ?? 0;
      final dailyPrice = (row['daily_price'] as num?)?.toDouble() ?? 0.0;

      return MemberBook(
        id: id,
        title: title,
        author: author,
        description: description,
        availableCopies: available,
        dailyPrice: dailyPrice,
      );
    }).toList();
  }

  static Future<List<AvailableBook>> fetchAvailableBooks() async {
    try {
      final response = await _supabase
          .from('books')
          .select(
            'id, title, author, description, daily_price, category_id, categories(name), book_copies(id, status)',
          )
          .order('title', ascending: true);

      return List<Map<String, dynamic>>.from(response).map((book) {
        final copies = (book['book_copies'] as List?) ?? [];
        final availableCount = copies
            .where((c) => c['status'] == 'Available')
            .length;

        final categoryData = book['categories'];
        final categoryName = categoryData != null
            ? (categoryData is Map ? categoryData['name'] as String? : null)
            : null;

        return AvailableBook(
          id: book['id'] as int,
          title: book['title'] as String,
          author: book['author'] as String?,
          description: book['description'] as String?,
          categoryName: categoryName,
          dailyPrice: (book['daily_price'] as num?)?.toDouble() ?? 0.0,
          availableCopies: availableCount,
        );
      }).toList();
    } catch (error) {
      rethrow;
    }
  }

  static Future<bool> checkIfAlreadyBorrowed(int memberId, int bookId) async {
    try {
      // Get all copies of this book
      final copies = await _supabase
          .from('book_copies')
          .select('id')
          .eq('book_id', bookId);

      if (copies.isEmpty) {
        return false;
      }

      final copyIds = copies.map((c) => c['id'] as int).toList();

      // Check if member has any pending or approved borrowing for any copy of this book
      final borrowings = await _supabase
          .from('borrowing')
          .select('id')
          .eq('member_id', memberId)
          .inFilter('copy_id', copyIds)
          .inFilter('status', ['pending', 'approved']);

      return borrowings.isNotEmpty;
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> requestBorrowing({
    required int memberId,
    required int bookId,
    required int days,
    required double dailyPrice,
  }) async {
    try {
      // Get an available copy
      final availableCopy = await _supabase
          .from('book_copies')
          .select('id')
          .eq('book_id', bookId)
          .eq('status', 'Available')
          .limit(1)
          .maybeSingle();

      if (availableCopy == null) {
        throw Exception('No available copies found for this book');
      }

      final copyId = availableCopy['id'] as int;
      final totalCost = dailyPrice * days;

      // Create borrowing request
      await _supabase.from('borrowing').insert({
        'copy_id': copyId,
        'member_id': memberId,
        'days_requested': days,
        'total_cost': totalCost,
        'status': 'pending',
      });
    } catch (error) {
      rethrow;
    }
  }

  static Future<int?> getMemberIdByProfileId(String profileId) async {
    try {
      final response = await _supabase
          .from('members')
          .select('id')
          .eq('profile_id', profileId)
          .maybeSingle();

      return response?['id'] as int?;
    } catch (error) {
      rethrow;
    }
  }
}
