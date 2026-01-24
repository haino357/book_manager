# Flutter Lint ガイド

このプロジェクトでは `flutter_lints` パッケージを使用してコード品質を維持しています。

## 設定ファイル

- `analysis_options.yaml` - Lintルールの設定
- `pubspec.yaml` - `flutter_lints: ^6.0.0`

## Analyzer設定

```yaml
analyzer:
  errors:
    missing_return: error           # 戻り値の欠落をエラーに
    missing_required_param: error   # 必須パラメータの欠落をエラーに
  language:
    strict-casts: true              # 暗黙的なキャストを禁止
    strict-raw-types: true          # raw型の使用を警告
```

## 有効なLintルール

### 型の厳格化

| ルール | 値 | 説明 |
|---|---|---|
| `always_declare_return_types` | true | 関数の戻り値の型を常に明示 |
| `always_specify_types` | false | 型推論を許可（冗長な型宣言を避ける） |
| `avoid_dynamic_calls` | true | `dynamic` 型でのメソッド呼び出しを警告 |
| `avoid_returning_null_for_void` | true | `void` 関数で `null` を返さない |
| `avoid_types_on_closure_parameters` | false | クロージャの型注釈を許可 |

> **Note:** ジェネリクスの型引数省略チェックは `analyzer.language.strict-raw-types: true` で有効化されています。

### import統一

| ルール | 値 | 説明 |
|---|---|---|
| `always_use_package_imports` | true | `package:` 形式のimportを使用 |
| `avoid_relative_lib_imports` | true | `lib/` 内での相対importを禁止 |
| `directives_ordering` | true | import文を正しい順序でソート |
| `prefer_relative_imports` | false | 相対importより `package:` を優先 |

### const

| ルール | 値 | 説明 |
|---|---|---|
| `prefer_const_constructors` | true | 可能な場合は `const` コンストラクタを使用 |
| `prefer_const_constructors_in_immutables` | true | immutableクラスで `const` コンストラクタを使用 |
| `prefer_const_declarations` | true | 可能な場合は `const` 宣言を使用 |
| `prefer_const_literals_to_create_immutables` | true | immutableコレクションには `const` を使用 |
| `unnecessary_const` | true | 不要な `const` を削除 |

### スタイル統一

| ルール | 値 | 説明 |
|---|---|---|
| `prefer_single_quotes` | true | 文字列にシングルクォートを使用 |
| `prefer_final_fields` | true | 再代入されないフィールドは `final` を使用 |
| `prefer_final_locals` | true | 再代入されないローカル変数は `final` を使用 |
| `prefer_final_in_for_each` | true | for-eachループ変数は `final` を使用 |
| `curly_braces_in_flow_control_structures` | true | if/for/whileで波括弧を使用 |
| `always_put_required_named_parameters_first` | false | Flutterの慣例（keyを先頭）を優先 |
| `sort_constructors_first` | true | コンストラクタをクラス先頭に配置 |
| `sort_unnamed_constructors_first` | true | 無名コンストラクタを先頭に配置 |

### 非同期安全

| ルール | 値 | 説明 |
|---|---|---|
| `avoid_returning_null_for_future` | true | `Future` を返す関数で `null` を返さない |
| `unawaited_futures` | true | await忘れの `Future` を警告 |
| `avoid_void_async` | true | `void` を返す `async` 関数を警告 |
| `cancel_subscriptions` | true | `StreamSubscription` のキャンセル漏れを検出 |
| `close_sinks` | true | `Sink` のクローズ漏れを検出 |
| `discarded_futures` | true | 破棄された `Future` を警告 |

### ログ抑制

| ルール | 値 | 説明 |
|---|---|---|
| `avoid_print` | true | `print()` の使用を警告（`debugPrint()` やロガーを使用） |

### 無駄削減

| ルール | 値 | 説明 |
|---|---|---|
| `avoid_empty_else` | true | 空の `else` ブロックを禁止 |
| `avoid_unnecessary_containers` | true | 不要な `Container` の使用を警告 |
| `avoid_redundant_argument_values` | true | デフォルト値と同じ引数の指定を警告 |
| `avoid_unused_constructor_parameters` | true | 未使用のコンストラクタ引数を警告 |
| `no_duplicate_case_values` | true | switch文の重複caseを禁止 |
| `prefer_is_empty` | true | `.length == 0` より `.isEmpty` を使用 |
| `prefer_is_not_empty` | true | `.length != 0` より `.isNotEmpty` を使用 |
| `unnecessary_null_checks` | true | 不要なnullチェックを削除 |
| `unnecessary_nullable_for_final_variable_declarations` | true | final変数の不要なnullable宣言を警告 |
| `unnecessary_overrides` | true | 不要なオーバーライドを削除 |
| `unnecessary_parenthesis` | true | 不要な括弧を削除 |
| `unnecessary_statements` | true | 効果のない文を警告 |
| `unnecessary_string_escapes` | true | 不要な文字列エスケープを削除 |
| `unnecessary_string_interpolations` | true | 不要な文字列補間を削除 |
| `unnecessary_this` | true | 不要な `this.` を削除 |
| `unreachable_from_main` | true | mainから到達不能なコードを警告 |
| `use_super_parameters` | true | `super.` パラメータを使用 |

### 可読性

| ルール | 値 | 説明 |
|---|---|---|
| `annotate_overrides` | true | オーバーライドメソッドに `@override` を付与 |
| `sized_box_for_whitespace` | true | 余白には `SizedBox` を使用 |
| `use_full_hex_values_for_flutter_colors` | true | カラーコードは8桁の16進数で指定 |
| `prefer_null_aware_operators` | true | null-aware演算子 `?.` `??` を使用 |
| `prefer_conditional_assignment` | true | `??=` 演算子を使用 |
| `use_colored_box` | true | 単色背景には `ColoredBox` を使用 |
| `use_decorated_box` | true | 装飾のみなら `DecoratedBox` を使用 |

## Lintの実行

```bash
# 静的解析を実行
fvm flutter analyze

# 自動修正可能な問題を修正
fvm dart fix --apply
```

## Lintエラーの対処方法

### 一時的に無効化（非推奨）

```dart
// 1行だけ無効化
// ignore: avoid_print
print('デバッグ用');

// ファイル全体で無効化
// ignore_for_file: avoid_print
```

### ルールの無効化

`analysis_options.yaml` でルールを無効化：

```yaml
linter:
  rules:
    avoid_print: false
```

## よくある警告と修正例

### always_use_package_imports

```dart
// NG
import '../models/user.dart';

// OK
import 'package:book_manager/models/user.dart';
```

### unawaited_futures

```dart
// NG
void fetchData() {
  api.getData(); // awaitなしのFuture
}

// OK
Future<void> fetchData() async {
  await api.getData();
}

// または意図的に無視する場合
import 'package:flutter/foundation.dart';
unawaited(api.getData());
```

### prefer_const_constructors

```dart
// NG
Container(child: Text('Hello'))

// OK
const Container(child: Text('Hello'))
```

### prefer_single_quotes

```dart
// NG
String name = "Flutter";

// OK
String name = 'Flutter';
```

### prefer_final_locals

```dart
// NG
var count = 10;

// OK
final count = 10;
```

### use_super_parameters

```dart
// NG
class MyWidget extends StatelessWidget {
  final String title;
  const MyWidget({Key? key, required this.title}) : super(key: key);
}

// OK
class MyWidget extends StatelessWidget {
  final String title;
  const MyWidget({super.key, required this.title});
}
```

### use_colored_box / use_decorated_box

```dart
// NG
Container(color: Colors.red)

// OK
const ColoredBox(color: Colors.red)

// NG
Container(decoration: BoxDecoration(border: Border.all()))

// OK
DecoratedBox(decoration: BoxDecoration(border: Border.all()))
```

### unnecessary_string_interpolations

```dart
// NG
final message = '$name';

// OK
final message = name;
```

### unnecessary_nullable_for_final_variable_declarations

```dart
// NG
final String? name = 'Flutter';

// OK
final String name = 'Flutter';
```

### curly_braces_in_flow_control_structures

```dart
// NG
if (condition)
  doSomething();

// OK
if (condition) {
  doSomething();
}
```

## 参考リンク

- [flutter_lints パッケージ](https://pub.dev/packages/flutter_lints)
- [Dart Linter ルール一覧](https://dart.dev/lints)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
