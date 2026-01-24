# Riverpod + Hooks ガイド

このプロジェクトでは状態管理に Riverpod と Flutter Hooks を使用しています。

## パッケージ

| パッケージ | 用途 |
|---|---|
| `hooks_riverpod` | Riverpod + Hooks統合 |
| `flutter_hooks` | React風のHooks |
| `riverpod_annotation` | コード生成用アノテーション |
| `riverpod_generator` | Provider自動生成 |
| `build_runner` | コード生成実行 |

## 基本的な使い方

### 1. HookConsumerWidget

`StatelessWidget` の代わりに `HookConsumerWidget` を使用：

```dart
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyWidget extends HookConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooksを使用
    final counter = useState(0);

    // Providerを使用
    final user = ref.watch(userProvider);

    return Text('Count: ${counter.value}');
  }
}
```

### 2. Provider定義（コード生成）

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@riverpod
class User extends _$User {
  @override
  String build() {
    return 'Guest';
  }

  void updateName(String name) {
    state = name;
  }
}
```

### 3. Provider定義（手動）

```dart
// シンプルなProvider
final counterProvider = StateProvider<int>((ref) => 0);

// 非同期Provider
final userProvider = FutureProvider<User>((ref) async {
  return await fetchUser();
});

// Notifier
final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);
```

## よく使うHooks

| Hook | 用途 |
|---|---|
| `useState` | ローカルステート管理 |
| `useEffect` | 副作用（初期化・クリーンアップ） |
| `useMemoized` | 値のメモ化 |
| `useCallback` | コールバックのメモ化 |
| `useTextEditingController` | TextFieldのコントローラー |
| `useAnimationController` | アニメーションコントローラー |
| `useFocusNode` | フォーカス管理 |

## Hooks使用例

### useState

```dart
class CounterWidget extends HookConsumerWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = useState(0);

    return ElevatedButton(
      onPressed: () => count.value++,
      child: Text('Count: ${count.value}'),
    );
  }
}
```

### useEffect

```dart
class TimerWidget extends HookConsumerWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds = useState(0);

    useEffect(() {
      final timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => seconds.value++,
      );
      return timer.cancel; // クリーンアップ
    }, const []); // 空配列 = 初回のみ実行

    return Text('Seconds: ${seconds.value}');
  }
}
```

### useTextEditingController

```dart
class SearchWidget extends HookConsumerWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();

    return TextField(
      controller: controller,
      decoration: const InputDecoration(hintText: 'Search...'),
    );
  }
}
```

## コード生成

Providerを自動生成するには以下のコマンドを実行：

```bash
# 一度だけ生成
fvm dart run build_runner build --delete-conflicting-outputs

# ファイル変更を監視して自動生成
fvm dart run build_runner watch --delete-conflicting-outputs
```

## ディレクトリ構成例

```
lib/
├── main.dart
├── providers/
│   ├── user_provider.dart
│   └── book_provider.dart
├── models/
│   ├── user.dart
│   └── book.dart
├── pages/
│   ├── home_page.dart
│   └── detail_page.dart
└── widgets/
    └── common/
```

## 参考リンク

- [Riverpod 公式ドキュメント](https://riverpod.dev/)
- [Flutter Hooks](https://pub.dev/packages/flutter_hooks)
- [hooks_riverpod](https://pub.dev/packages/hooks_riverpod)
