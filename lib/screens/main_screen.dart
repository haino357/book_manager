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

  // 追加ボタン（index 2）を除いたタブインデックスのマッピング
  static const _addIndex = 2;
  static const _navToStack = {0: 0, 1: 1, 3: 2};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);

    return Scaffold(
      body: IndexedStack(
        index: _navToStack[selectedIndex.value] ?? 0,
        children: const [
          HomeScreen(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.value,
        onDestinationSelected: (index) async {
          if (index == _addIndex) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BookFormScreen(),
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
