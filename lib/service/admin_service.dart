import 'package:library_project/feature/admin/model/admin_dashboard_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<AdminDashboardData> fetchDashboardData() async {
    try {
      final totalMembersFuture = _countRows(
        _supabase.from('members').select('id'),
      );

      final totalBooksFuture = _countRows(_supabase.from('books').select('id'));

      final totalCategoriesFuture = _countRows(
        _supabase.from('categories').select('id'),
      );

      final totalCopiesFuture = _countRows(
        _supabase.from('book_copies').select('id'),
      );

      final activeBorrowingsFuture = _countRows(
        _supabase.from('borrowing').select('id').isFilter('returned_at', null),
      );

      final availableCopiesFuture = _countRows(
        _supabase.from('book_copies').select('id').eq('status', 'Available'),
      );

      final categoriesFuture = _fetchCategories();
      final borrowingsFuture = _fetchRecentBorrowings();

      final results = await Future.wait<int>([
        totalMembersFuture,
        totalBooksFuture,
        totalCategoriesFuture,
        totalCopiesFuture,
        activeBorrowingsFuture,
        availableCopiesFuture,
      ]);

      final stats = AdminStats(
        totalMembers: results[0],
        totalBooks: results[1],
        totalCategories: results[2],
        totalCopies: results[3],
        activeBorrowings: results[4],
        availableCopies: results[5],
      );

      final categories = await categoriesFuture;
      final borrowings = await borrowingsFuture;

      return AdminDashboardData(
        stats: stats,
        categories: categories,
        recentBorrowings: borrowings,
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> addBook({
    required String title,
    String? author,
    String? description,
    int copiesCount = 1,
  }) async {
    try {
      final insertedBook = await _supabase
          .from('books')
          .insert({
            'title': title,
            if (author != null) 'author': author,
            if (description != null) 'description': description,
          })
          .select('id')
          .single();

      final bookId = insertedBook['id'] as int;

      if (copiesCount < 1) {
        copiesCount = 1;
      }

      final copies = List.generate(copiesCount, (_) => {'book_id': bookId});

      await _supabase.from('book_copies').insert(copies);
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

  static Future<List<CategorySummary>> _fetchCategories() async {
    final response = await _supabase
        .from('categories')
        .select('id, name, created_at')
        .order('created_at', ascending: false)
        .limit(6);

    return response
        .map(
          (row) => CategorySummary(
            id: row['id'] as int,
            name: (row['name'] as String?) ?? 'Unnamed',
            createdAt: _parseDate(row['created_at']) ?? DateTime.now(),
          ),
        )
        .toList();
  }

  static Future<List<BorrowingRecord>> _fetchRecentBorrowings() async {
    final borrowingRows = await _supabase
        .from('borrowing')
        .select('id, member_id, copy_id, borrowed_at, due_at, returned_at')
        .order('borrowed_at', ascending: false)
        .limit(6);

    if (borrowingRows.isEmpty) {
      return [];
    }

    final memberIds = borrowingRows
        .map((row) => row['member_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    final copyIds = borrowingRows
        .map((row) => row['copy_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    final members = await _fetchMembersByIds(memberIds);
    final copies = await _fetchCopiesByIds(copyIds);

    final bookIds = copies.values
        .map((copy) => copy['book_id'] as int?)
        .whereType<int>()
        .toSet()
        .toList();

    final books = await _fetchBooksByIds(bookIds);

    return borrowingRows.map((row) {
      final memberId = row['member_id'] as int?;
      final copyId = row['copy_id'] as int?;

      final memberEmail =
          members[memberId]?['email'] as String? ?? 'Member #$memberId';
      final copy = copies[copyId];
      final status = copy?['status'] as String? ?? 'Unknown';
      final bookId = copy?['book_id'] as int?;
      final bookTitle =
          books[bookId]?['title'] as String? ?? 'Book #${bookId ?? '-'}';

      return BorrowingRecord(
        id: row['id'] as int,
        memberLabel: memberEmail,
        bookTitle: bookTitle,
        copyStatus: status,
        borrowedAt: _parseDate(row['borrowed_at']) ?? DateTime.now(),
        dueAt: _parseDate(row['due_at']),
        returnedAt: _parseDate(row['returned_at']),
      );
    }).toList();
  }

  static Future<Map<int, Map<String, dynamic>>> _fetchMembersByIds(
    List<int> ids,
  ) async {
    if (ids.isEmpty) return {};
    final rows = await _supabase
        .from('members')
        .select('id, email')
        .inFilter('id', ids);

    return {for (final row in rows) row['id'] as int: row};
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
}
