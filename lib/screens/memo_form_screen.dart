import 'package:book_manager/models/book_memo.dart';
import 'package:book_manager/providers/book_memo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// メモの追加・編集画面
class MemoFormScreen extends HookConsumerWidget {
  const MemoFormScreen({
    super.key,
    required this.bookId,
    this.memo,
  });

  final String bookId;
  final BookMemo? memo;

  bool get isEditing => memo != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final contentController =
        useTextEditingController(text: memo?.content ?? '');
    final pageController =
        useTextEditingController(text: memo?.page?.toString() ?? '');
    final sectionController =
        useTextEditingController(text: memo?.section ?? '');

    final selectedType = useState(memo?.type ?? MemoType.note);
    final isCompleted = useState(memo?.isCompleted ?? false);
    final isLoading = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'メモを編集' : 'メモを追加'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // メモタイプ選択
            Text(
              'メモの種類',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MemoType.values.map((type) {
                final isSelected = selectedType.value == type;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      selectedType.value = type;
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ページ番号（任意）
            if (selectedType.value != MemoType.review)
              TextFormField(
                controller: pageController,
                decoration: const InputDecoration(
                  labelText: 'ページ番号',
                  hintText: 'ページ番号を入力（任意）',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            if (selectedType.value != MemoType.review)
              const SizedBox(height: 16),

            // セクション名（要約メモの場合）
            if (selectedType.value == MemoType.summary)
              TextFormField(
                controller: sectionController,
                decoration: const InputDecoration(
                  labelText: '章・セクション名',
                  hintText: '章やセクション名を入力（任意）',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
            if (selectedType.value == MemoType.summary)
              const SizedBox(height: 16),

            // メモ本文（必須）
            TextFormField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: _contentLabel(selectedType.value),
                hintText: _contentHint(selectedType.value),
                border: const OutlineInputBorder(),
              ),
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '内容を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 保存ボタン
            FilledButton.icon(
              onPressed: isLoading.value
                  ? null
                  : () => _saveMemo(
                        context,
                        ref,
                        formKey,
                        selectedType.value,
                        contentController.text,
                        pageController.text,
                        sectionController.text,
                        isCompleted.value,
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

  String _contentLabel(MemoType type) {
    switch (type) {
      case MemoType.note:
        return 'メモ *';
      case MemoType.quote:
        return 'フレーズ・引用 *';
      case MemoType.summary:
        return '要約 *';
      case MemoType.review:
        return '感想 *';
      case MemoType.vocabulary:
        return '用語・意味 *';
      case MemoType.action:
        return 'アクション内容 *';
    }
  }

  String _contentHint(MemoType type) {
    switch (type) {
      case MemoType.note:
        return '気になった箇所や気づきを入力';
      case MemoType.quote:
        return '心に残った文章やセリフを入力';
      case MemoType.summary:
        return '内容の要約を入力';
      case MemoType.review:
        return '感想やおすすめポイントを入力';
      case MemoType.vocabulary:
        return '用語とその意味を入力';
      case MemoType.action:
        return 'やってみたいことを入力';
    }
  }

  Future<void> _saveMemo(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormState> formKey,
    MemoType type,
    String content,
    String page,
    String section,
    bool isCompleted,
    ValueNotifier<bool> isLoading,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final repository = ref.read(bookMemoRepositoryProvider);
      final parsedPage =
          page.trim().isNotEmpty ? int.tryParse(page.trim()) : null;
      final trimmedSection =
          section.trim().isNotEmpty ? section.trim() : null;

      if (isEditing) {
        await repository.updateMemo(
          memo!.copyWith(
            type: type,
            content: content.trim(),
            page: parsedPage,
            section: trimmedSection,
            isCompleted: type == MemoType.action ? isCompleted : null,
          ),
        );
      } else {
        await repository.addMemo(
          bookId: bookId,
          type: type,
          content: content.trim(),
          page: parsedPage,
          section: trimmedSection,
          isCompleted: type == MemoType.action ? false : null,
        );
      }

      ref.invalidate(bookMemosProvider(bookId));

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'メモを更新しました' : 'メモを追加しました'),
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
