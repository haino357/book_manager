import 'package:book_manager/models/book.dart';
import 'package:book_manager/providers/books_provider.dart';
import 'package:book_manager/screens/book_detail_screen.dart';
import 'package:book_manager/screens/book_form_screen.dart';
import 'package:book_manager/widgets/book_card.dart';
import 'package:book_manager/widgets/status_filter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ホーム画面（本一覧）
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredBooks = ref.watch(filteredBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('読書管理'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ステータスフィルター
          const StatusFilter(),
          // 本の一覧
          Expanded(
            child: filteredBooks.when(
              data: (books) {
                if (books.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildBookGrid(context, books);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'エラーが発生しました',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddBook(context),
        icon: const Icon(Icons.add),
        label: const Text('本を追加'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '本がまだありません',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '右下のボタンから本を追加してください',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid(BuildContext context, List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          onTap: () => _navigateToDetail(context, book.id),
        );
      },
    );
  }

  void _navigateToAddBook(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BookFormScreen(),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String bookId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(bookId: bookId),
      ),
    );
  }
}
