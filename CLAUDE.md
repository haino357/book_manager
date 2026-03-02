# CLAUDE.md

このファイルはClaude Codeがプロジェクトを理解するためのガイドです。

## プロジェクト概要

Flutter製の書籍管理アプリ。本の登録・ステータス管理・メモ・統計機能を提供する。

## 開発環境

- Flutter stable（FVMで管理、バージョンは `.fvmrc` に従う）
- バージョン管理: FVM
- コマンドは必ず `fvm flutter ...` / `fvm dart ...` で実行すること

## よく使うコマンド

```bash
fvm flutter pub get           # 依存パッケージ取得
fvm flutter analyze           # 静的解析
fvm flutter test              # 全テスト実行
fvm flutter test test/widget_test.dart  # 個別テスト実行
fvm dart run build_runner build --delete-conflicting-outputs  # コード生成
fvm flutter run               # アプリ実行
```

## アーキテクチャ

Riverpod + Flutter Hooks を採用。主要4層 + 補助ディレクトリで構成:

```
lib/
├── screens/       → 画面（ConsumerWidget / HookConsumerWidget） ┐
├── providers/     → 状態管理（AsyncNotifier等）         │ 主要4層
├── repositories/  → データアクセス層                     │
├── models/        → 不変データモデル（fromMap/toMap等）  ┘
├── widgets/       → 再利用可能なウィジェット              ┐
├── services/      → 外部API連携                         │ 補助
├── database/      → SQLite（DatabaseHelper）            │
└── utils/         → ユーティリティ                       ┘
```

### データフロー

Screen → `ref.watch(provider)` → Provider → `ref.read(xxxRepositoryProvider)` → Repository → DatabaseHelper

### 状態更新

データ変更後は `ref.invalidateSelf()` で再取得する。

## コーディング規約

### 厳守ルール

- シングルクォート（`'text'`）
- package importのみ（`import 'package:book_manager/...'`、相対import禁止）
- 変数は `final` を優先
- Widget生成時は `const` を検討
- 戻り値型を常に宣言
- `@override` アノテーション必須
- `super` パラメータを使用（`super.key`）
- `print()` 禁止 → `debugPrint()` を使用
- strict-casts / strict-raw-types 有効

### 非同期処理

- `async void` 禁止 → `Future<void>` を返す
- await不要なFutureは `unawaited()` でラップ
- Futureを無視しない（`discarded_futures`）
- StreamSubscription / Sink は必ず解放

### スタイル

- if/for/while に常に `{}`
- クラス内でコンストラクタを最初に配置
- importは `directives_ordering` に従い整列

## 主要パターン

### Widget

```dart
// Hooksが不要な場合は ConsumerWidget を使用
class MyScreen extends HookConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final booksAsync = ref.watch(booksProvider);
    return booksAsync.when(
      data: (books) => ...,
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ...,
    );
  }
}
```

### Model（nullableフィールドのcopyWithにはセンチネルパターン）

```dart
// ファイル先頭にトップレベルで定義
const _sentinel = Object();

// クラス内の copyWith メソッド
Book copyWith({Object? memo = _sentinel}) {
  return Book(memo: memo == _sentinel ? this.memo : memo as String?);
}
```

## データベース

- SQLite（sqflite）+ UUID
- DatabaseHelperはシングルトン
- スキーマバージョン管理で `_onUpgrade()` によるマイグレーション

## Git規約

- ベースブランチ: `develop`
- ブランチ命名: `feature/機能名`, `fix/バグ内容`, `refactor/対象`, `docs/内容`
- コミットメッセージ: `種別: 変更内容の要約`（feat / fix / docs / refactor / test / chore）

## 言語

- コード（変数名・関数名・クラス名）: **英語**
- UIテキスト・コメント・ドキュメント・PRレビュー: **日本語**
