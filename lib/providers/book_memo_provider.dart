import 'package:book_manager/models/book_memo.dart';
import 'package:book_manager/repositories/book_memo_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// メモリポジトリのプロバイダー
final bookMemoRepositoryProvider = Provider<BookMemoRepository>((ref) {
  return BookMemoRepository();
});

/// 特定の本のメモ一覧を取得するプロバイダー
final bookMemosProvider =
    FutureProvider.family<List<BookMemo>, String>((ref, bookId) async {
  final repository = ref.read(bookMemoRepositoryProvider);
  return await repository.getMemosByBookId(bookId);
});
