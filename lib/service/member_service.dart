import 'package:library_project/feature/member/model/member_dashboard_model.dart';
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
        .select('id, copy_id, borrowed_at, due_at, returned_at')
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
      final status = copy?['status'] as String? ?? 'Unknown';
      final bookId = copy?['book_id'] as int?;
      final bookTitle =
          books[bookId]?['title'] as String? ?? 'Book #${bookId ?? '-'}';

      return MemberBorrowingRecord(
        id: row['id'] as int,
        bookTitle: bookTitle,
        copyStatus: status,
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
}
