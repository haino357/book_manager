import 'package:book_manager/main.dart';
import 'package:book_manager/screens/book_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('App loads with home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BookManagerApp(),
      ),
    );

    // アプリタイトルが表示されることを確認
    expect(find.text('読書管理'), findsOneWidget);
  });

  testWidgets('Navigation bar displays all tab labels',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BookManagerApp(),
      ),
    );

    // ナビゲーションバーのラベルが表示されることを確認
    expect(find.text('本棚'), findsOneWidget);
    expect(find.text('統計'), findsOneWidget);
    expect(find.text('追加'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('Tapping statistics tab shows statistics screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BookManagerApp(),
      ),
    );

    // 統計タブをタップ
    await tester.tap(find.text('統計'));
    await tester.pumpAndSettle();

    // 統計画面のAppBarタイトルが表示されることを確認
    expect(find.widgetWithText(AppBar, '統計'), findsOneWidget);
  });

  testWidgets('Tapping settings tab shows settings screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BookManagerApp(),
      ),
    );

    // 設定タブをタップ
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    // 設定画面の内容が表示されることを確認
    expect(find.widgetWithText(AppBar, '設定'), findsOneWidget);
    // バージョン行が表示されていることを確認（動的取得のため特定の値に依存しない）
    final versionTileFinder = find.ancestor(
      of: find.text('バージョン'),
      matching: find.byType(ListTile),
    );
    expect(versionTileFinder, findsOneWidget);
  });

  testWidgets('Tapping add button navigates to BookFormScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BookManagerApp(),
      ),
    );

    // 追加ボタンをタップ
    await tester.tap(find.text('追加'));
    await tester.pumpAndSettle();

    // BookFormScreenに遷移したことを確認
    expect(find.byType(BookFormScreen), findsOneWidget);
  });

  testWidgets('Tab state is preserved when switching tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BookManagerApp(),
      ),
    );

    // 検索バーにテキストを入力
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'テスト検索');
    await tester.pumpAndSettle();

    // 設定タブに切り替え
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    // 本棚タブに戻る
    await tester.tap(find.text('本棚'));
    await tester.pumpAndSettle();

    // 検索テキストが保持されていることを確認
    final textField =
        tester.widget<TextField>(find.byType(TextField).first);
    expect(textField.controller?.text, 'テスト検索');
  });
}
