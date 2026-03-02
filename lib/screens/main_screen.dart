import 'dart:async';

import 'package:book_manager/screens/book_form_screen.dart';
import 'package:book_manager/screens/home_screen.dart';
import 'package:book_manager/screens/settings_screen.dart';
import 'package:book_manager/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// メイン画面（ボトムナビゲーション付き）
class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  // 追加ボタン（index 2）は画面遷移専用でIndexedStackに含まない
  static const _addIndex = 2;

  /// ナビゲーションバーのインデックスをIndexedStackのインデックスに変換
  static int _toStackIndex(int navIndex) {
    assert(navIndex != _addIndex, '追加ボタンはIndexedStackに対応しません');
    return navIndex > _addIndex ? navIndex - 1 : navIndex;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);

    return Scaffold(
      body: IndexedStack(
        index: _toStackIndex(selectedIndex.value),
        children: const [
          HomeScreen(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.value,
        onDestinationSelected: (index) {
          if (index == _addIndex) {
            unawaited(
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BookFormScreen(),
                ),
              ),
            );
            return;
          }
          selectedIndex.value = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: '本棚',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '統計',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, size: 32),
            selectedIcon: Icon(Icons.add_circle_outline, size: 32),
            label: '追加',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
