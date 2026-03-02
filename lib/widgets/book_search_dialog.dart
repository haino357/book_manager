import 'package:book_manager/models/book_search_result.dart';
import 'package:book_manager/providers/book_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 書籍検索ボトムシートを表示し、選択結果を返す
Future<BookSearchResult?> showBookSearchDialog(BuildContext context) {
  return showModalBottomSheet<BookSearchResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => _BookSearchSheet(
        scrollController: scrollController,
      ),
    ),
  );
}

class _BookSearchSheet extends HookConsumerWidget {
  const _BookSearchSheet({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchResults = ref.watch(bookSearchProvider);

    return Column(
      children: [
        // ドラッグハンドル
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // タイトル
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '書籍を検索',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // 検索バー
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'ISBNまたはタイトルで検索',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  ref.read(bookSearchProvider.notifier).clear();
                },
              ),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) async {
              if (value.trim().isNotEmpty) {
                await ref.read(bookSearchProvider.notifier).search(value);
              }
            },
          ),
        ),
        const SizedBox(height: 8),

        // 検索結果
        Expanded(
          child: searchResults.when(
            data: (results) {
              if (results.isEmpty) {
                return Center(
                  child: Text(
                    searchController.text.isEmpty
                        ? 'ISBNまたはタイトルを入力して検索'
                        : '検索結果がありません',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }
              return ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: results.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = results[index];
                  return _SearchResultTile(
                    result: result,
                    onTap: () {
                      ref.read(bookSearchProvider.notifier).clear();
                      Navigator.of(context).pop(result);
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '検索エラー: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.onTap,
  });

  final BookSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: SizedBox(
        width: 48,
        child: result.coverUrl != null
            ? Image.network(
                result.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.book,
                  size: 32,
                  color: Colors.grey,
                ),
              )
            : const Icon(Icons.book, size: 32, color: Colors.grey),
      ),
      title: Text(
        result.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.authors.isNotEmpty)
            Text(
              result.authors,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
          if (result.isbn != null)
            Text(
              'ISBN: ${result.isbn}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
