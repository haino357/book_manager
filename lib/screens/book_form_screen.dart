import 'package:book_manager/models/book.dart';
import 'package:book_manager/providers/books_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 本の登録・編集画面
class BookFormScreen extends HookConsumerWidget {

  const BookFormScreen({super.key, this.book});
  final Book? book;

  bool get isEditing => book != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final titleController = useTextEditingController(text: book?.title ?? '');
    final authorController = useTextEditingController(text: book?.author ?? '');
    final isbnController = useTextEditingController(text: book?.isbn ?? '');
    final coverUrlController =
        useTextEditingController(text: book?.coverUrl ?? '');

    final selectedStatus = useState(book?.status ?? ReadingStatus.unread);
    final isLoading = useState(false);

    // coverUrlControllerの変更を監視してリビルドをトリガー
    useListenable(coverUrlController);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '本を編集' : '本を追加'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // タイトル（必須）
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル *',
                hintText: '本のタイトルを入力',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 著者
            TextFormField(
              controller: authorController,
              decoration: const InputDecoration(
                labelText: '著者',
                hintText: '著者名を入力',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // ISBN
            TextFormField(
              controller: isbnController,
              decoration: const InputDecoration(
                labelText: 'ISBN',
                hintText: 'ISBN番号を入力',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // 表紙画像URL
            TextFormField(
              controller: coverUrlController,
              decoration: const InputDecoration(
                labelText: '表紙画像URL',
                hintText: '画像のURLを入力',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            // ステータス選択
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
              selected: {selectedStatus.value},
              onSelectionChanged: (Set<ReadingStatus> newSelection) {
                selectedStatus.value = newSelection.first;
              },
            ),
            const SizedBox(height: 32),

            // 表紙プレビュー
            if (coverUrlController.text.isNotEmpty) ...[
              Text(
                '表紙プレビュー',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _CoverPreview(url: coverUrlController.text),
              const SizedBox(height: 24),
            ],

            // 保存ボタン
            FilledButton.icon(
              onPressed: isLoading.value
                  ? null
                  : () => _saveBook(
                        context,
                        ref,
                        formKey,
                        titleController.text,
                        authorController.text,
                        isbnController.text,
                        coverUrlController.text,
                        selectedStatus.value,
                        isLoading,
                      ),
              icon: isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(isEditing ? '更新' : '保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBook(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    String title,
    String author,
    String isbn,
    String coverUrl,
    ReadingStatus status,
    ValueNotifier<bool> isLoading,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final notifier = ref.read(booksProvider.notifier);

      if (isEditing) {
        await notifier.updateBook(
          book!.copyWith(
            title: title.trim(),
            author: author.trim(),
            isbn: isbn.trim().isEmpty ? null : isbn.trim(),
            coverUrl: coverUrl.trim().isEmpty ? null : coverUrl.trim(),
            status: status,
          ),
        );
      } else {
        await notifier.addBook(
          title: title.trim(),
          author: author.trim(),
          isbn: isbn.trim().isEmpty ? null : isbn.trim(),
          coverUrl: coverUrl.trim().isEmpty ? null : coverUrl.trim(),
          status: status,
        );
      }

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '本を更新しました' : '本を追加しました'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class _CoverPreview extends HookWidget {

  const _CoverPreview({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final hasError = useState(false);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: hasError.value
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey[400], size: 48),
                  const SizedBox(height: 8),
                  Text(
                    '画像を読み込めません',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    hasError.value = true;
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
    );
  }
}
