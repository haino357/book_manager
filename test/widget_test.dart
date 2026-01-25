import 'package:book_manager/main.dart';
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

    // 本を追加ボタンが表示されることを確認
    expect(find.text('本を追加'), findsOneWidget);
  });
}
