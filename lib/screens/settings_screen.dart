import 'package:book_manager/providers/package_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 設定画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // アプリ情報セクション
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'アプリ情報',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('アプリ名'),
            subtitle: Text('読書管理'),
          ),
          ListTile(
            leading: const Icon(Icons.new_releases_outlined),
            title: const Text('バージョン'),
            subtitle: Text(
              packageInfoAsync.when(
                data: (info) => info.version,
                loading: () => '',
                error: (_, _) => '取得失敗',
              ),
            ),
          ),
        ],
      ),
    );
  }
}