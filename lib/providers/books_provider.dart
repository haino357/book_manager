import 'package:book_manager/models/book.dart';
import 'package:book_manager/repositories/book_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// リポジトリのプロバイダー
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

/// 選択中のフィルターステータス（nullは全て）
final selectedStatusFilterProvider = StateProvider<ReadingStatus?>((ref) {
  return null;
});

/// 本のリストを管理するNotifier
class BooksNotifier extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() async {
    return await _fetchBooks();
  }

  Future<List<Book>> _fetchBooks() async {
    final repository = ref.read(bookRepositoryProvider);
    return await repository.getAllBooks();
  }

  /// 本を追加
  Future<void> addBook({
    required String title,
    required String author,
    String? isbn,
    String? coverUrl,
    ReadingStatus status = ReadingStatus.unread,
  }) async {
    final repository = ref.read(bookRepositoryProvider);
    await repository.addBook(
      title: title,
      author: author,
      isbn: isbn,
      coverUrl: coverUrl,
      status: status,
    );
    ref.invalidateSelf();
  }

  /// 本を更新
  Future<void> updateBook(Book book) async {
    final repository = ref.read(bookRepositoryProvider);
    await repository.updateBook(book);
    ref.invalidateSelf();
  }

  /// 本のステータスを更新
  Future<void> updateBookStatus(String bookId, ReadingStatus status) async {
    final repository = ref.read(bookRepositoryProvider);
    final book = await repository.getBookById(bookId);
    if (book != null) {
      await repository.updateBook(book.copyWith(status: status));
      ref.invalidateSelf();
    }
  }

  /// 本を削除
  Future<void> deleteBook(String id) async {
    final repository = ref.read(bookRepositoryProvider);
    await repository.deleteBook(id);
    ref.invalidateSelf();
  }
}

/// 本のリストプロバイダー
final booksProvider = AsyncNotifierProvider<BooksNotifier, List<Book>>(() {
  return BooksNotifier();
});

/// フィルタリングされた本のリスト
final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final booksAsync = ref.watch(booksProvider);
  final selectedStatus = ref.watch(selectedStatusFilterProvider);

  return booksAsync.whenData((books) {
    if (selectedStatus == null) {
      return books;
    }
    return books.where((book) => book.status == selectedStatus).toList();
  });
});

/// 特定の本を取得するプロバイダー
final bookByIdProvider = FutureProvider.family<Book?, String>((ref, id) async {
  final repository = ref.read(bookRepositoryProvider);
  return await repository.getBookById(id);
});
