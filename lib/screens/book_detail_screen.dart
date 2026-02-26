import 'package:book_manager/models/book.dart';
import 'package:book_manager/providers/books_provider.dart';
import 'package:book_manager/screens/book_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 本の詳細画面
class BookDetailScreen extends ConsumerWidget {

  const BookDetailScreen({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookByIdProvider(bookId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('本の詳細'),
        centerTitle: true,
        actions: [
          bookAsync.whenOrNull(
                data: (book) => book != null
                    ? PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await _navigateToEdit(context, book);
                          } else if (value == 'delete') {
                            await _showDeleteDialog(context, ref, book);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('編集'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '削除',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(child: Text('本が見つかりません'));
          }
          return _buildContent(context, ref, book);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('エラー: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Book book) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 表紙画像
          _buildCoverImage(book),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // 著者
                if (book.author.isNotEmpty)
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                const SizedBox(height: 16),

                // ステータス変更
                Text(
                  '読書ステータス',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<ReadingStatus>(
                  segments: ReadingStatus.values
                      .map(
                        (status) => ButtonSegment<ReadingStatus>(
                          value: status,
                          label: Text(status.displayName),
                        ),
                      )
                      .toList(),
                  selected: {book.status},
                  onSelectionChanged: (Set<ReadingStatus> newSelection) async {
                    await _updateStatus(ref, book.id, newSelection.first);
                  },
                ),
                const SizedBox(height: 16),

                // もう一度読むボタン（completedステータス時のみ）
                if (book.status == ReadingStatus.completed)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showReReadDialog(context, ref, book),
                      icon: const Icon(Icons.replay),
                      label: const Text('もう一度読む'),
                    ),
                  ),
                const SizedBox(height: 24),

                // 詳細情報
                _buildInfoSection(context, ref, book),

                const SizedBox(height: 16),

                // 読書履歴セクション
                _buildHistorySection(context, ref, book),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(Book book) {
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return SizedBox(
        width: double.infinity,
        height: 250,
        child: Image.network(
          book.coverUrl!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 80,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, WidgetRef ref, Book book) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '詳細情報',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            _buildInfoRow(context, 'ISBN', book.isbn ?? '未設定'),
            _buildInfoRow(
              context,
              '登録日',
              _formatDate(book.createdAt),
            ),
            if (book.startedAt != null)
              _buildEditableDateRow(
                context,
                ref,
                book,
                '読書開始日',
                book.startedAt!,
                (date) async {
                  final updatedBook = book.copyWith(startedAt: date);
                  await ref.read(booksProvider.notifier).updateBook(updatedBook);
                  ref.invalidate(bookByIdProvider(bookId));
                },
              ),
            if (book.completedAt != null)
              _buildEditableDateRow(
                context,
                ref,
                book,
                '読了日',
                book.completedAt!,
                (date) async {
                  final updatedBook = book.copyWith(completedAt: date);
                  await ref.read(booksProvider.notifier).updateBook(updatedBook);
                  ref.invalidate(bookByIdProvider(bookId));
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableDateRow(
    BuildContext context,
    WidgetRef ref,
    Book book,
    String label,
    DateTime date,
    Future<void> Function(DateTime) onDateChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                await onDateChanged(picked);
              }
            },
            child: Icon(
              Icons.edit_calendar,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) {
    final historiesAsync = ref.watch(readingHistoriesProvider(bookId));
    final hasCurrentSession = book.startedAt != null;

    return historiesAsync.when(
      data: (histories) {
        if (histories.isEmpty && !hasCurrentSession) {
          return const SizedBox.shrink();
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '読書履歴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(),
                // 過去の履歴
                ...histories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final history = entry.value;
                  return _buildHistoryRow(
                    context,
                    index + 1,
                    startedAt: history.startedAt,
                    completedAt: history.completedAt,
                  );
                }),
                // 現在の読書セッション
                if (hasCurrentSession)
                  _buildHistoryRow(
                    context,
                    histories.length + 1,
                    startedAt: book.startedAt,
                    completedAt: book.completedAt,
                    isCurrent: true,
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHistoryRow(
    BuildContext context,
    int readCount, {
    required DateTime? startedAt,
    required DateTime? completedAt,
    bool isCurrent = false,
  }) {
    final startStr =
        startedAt != null ? _formatDate(startedAt) : '不明';
    final endStr = completedAt != null
        ? _formatDate(completedAt)
        : '読書中';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$readCount回目: $startStr 〜 $endStr',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isCurrent ? FontWeight.bold : null,
            ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _updateStatus(
    WidgetRef ref,
    String bookId,
    ReadingStatus status,
  ) async {
    await ref.read(booksProvider.notifier).updateBookStatus(bookId, status);
    ref.invalidate(bookByIdProvider(bookId));
  }

  Future<void> _navigateToEdit(BuildContext context, Book book) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookFormScreen(book: book),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('本を削除'),
        content: Text('「${book.title}」を削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(booksProvider.notifier).deleteBook(book.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('本を削除しました')),
        );
      }
    }
  }

  Future<void> _showReReadDialog(
    BuildContext context,
    WidgetRef ref,
    Book book,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('もう一度読む'),
        content: Text(
          '「${book.title}」をもう一度読みますか？\n'
          '現在の読書記録は履歴に保存されます。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('もう一度読む'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(booksProvider.notifier).reReadBook(book.id);
      ref.invalidate(bookByIdProvider(bookId));
      ref.invalidate(readingHistoriesProvider(bookId));
    }
  }
}
