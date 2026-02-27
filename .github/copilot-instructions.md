# Copilot Instructions

このプロジェクトはFlutter製の書籍管理アプリ（book_manager）です。
AIアシスタントがコード生成・補完を行う際は、以下の規約に従ってください。

## 開発環境

- Flutter stable（FVMで管理、バージョンは `.fvmrc` に従う）
- コマンドは `fvm flutter ...` / `fvm dart ...` で実行
- 対応OS: Android（`flutter.minSdkVersion` に従う） / iOS 17.6+

## アーキテクチャ

Riverpod + Flutter Hooks を採用。主要4層 + 補助ディレクトリで構成。

```
lib/
├── screens/       # 画面（HookConsumerWidget）        ┐
├── providers/     # 状態管理（AsyncNotifier等）         │ 主要4層
├── repositories/  # データアクセス層                     │
├── models/        # データモデル（不変オブジェクト）       ┘
├── widgets/       # 再利用可能なウィジェット              ┐
├── services/      # 外部API連携                         │ 補助
├── database/      # SQLite（DatabaseHelper）            │
└── utils/         # ユーティリティ                       ┘
```

### データフロー

```
Screen (HookConsumerWidget)
  → ref.watch(provider) で状態を監視
Provider (AsyncNotifier)
  → ref.read(bookRepositoryProvider) でリポジトリ呼び出し
Repository
  → DatabaseHelper でSQLite操作
```

## コーディング規約

### 必須ルール

- **シングルクォート** を使用（`'text'`）
- **package import** のみ使用（`import 'package:book_manager/...'`、相対importは禁止）
- **変数は `final` を優先**（`final locals`, `final fields`, `final in for-each`）
- **`const` コンストラクタを優先**（Widget生成時は常に `const` を検討）
- **戻り値型を常に宣言**（`void`, `Future<void>` 等を省略しない）
- **`@override` アノテーション** を必ず付与
- **`super` パラメータ** を使用（`super.key` 等）
- **`print()` 禁止** — デバッグ出力は `debugPrint()` を使用
- **strict-casts / strict-raw-types 有効** — 暗黙の型変換・raw型は禁止

### 非同期処理

- **`avoid_void_async`**: コールバック等で `async void` を書かない。戻り値が不要でも `Future<void>` を返す
- **`unawaited_futures`**: await不要なFutureは `unawaited()` で明示的にラップ
- **`discarded_futures`**: Futureを無視しない
- **`cancel_subscriptions` / `close_sinks`**: StreamSubscription/Sinkは必ず解放

### スタイル

- `curly_braces_in_flow_control_structures: true` — if/for/while に常に `{}`
- `sort_constructors_first: true` — クラス内でコンストラクタを最初に配置
- `sized_box_for_whitespace` / `use_colored_box` / `use_decorated_box` — 適切なウィジェットを使い分け
- importは `directives_ordering` に従い整列

## 状態管理パターン

### Widgetの基底クラス

```dart
// Hooks + Riverpod を組み合わせる場合
class MyScreen extends HookConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks で局所状態
    final controller = useTextEditingController();
    final isLoading = useState(false);

    // Riverpod でグローバル状態を監視
    final booksAsync = ref.watch(booksProvider);

    return booksAsync.when(
      data: (books) => ...,
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ...,
    );
  }
}
```

### Provider定義

```dart
// リポジトリ
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

// 非同期状態（CRUD操作あり）
class BooksNotifier extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() async { ... }

  Future<void> addBook(...) async {
    // 処理後にデータを再取得
    ref.invalidateSelf();
  }
}
final booksProvider = AsyncNotifierProvider<BooksNotifier, List<Book>>(...);

// 派生プロバイダ（フィルタリング等）
final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final books = ref.watch(booksProvider);
  final query = ref.watch(searchQueryProvider);
  // フィルタロジック
  return ...;
});

// 単純なUI状態
final searchQueryProvider = StateProvider<String>((ref) => '');

// IDで個別データ取得
final bookByIdProvider = FutureProvider.family<Book?, String>((ref, id) async { ... });
```

## モデル定義パターン

```dart
class Book {
  const Book({
    required this.id,
    required this.title,
    this.author,
  });

  // コンストラクタを先頭に配置
  factory Book.fromMap(Map<String, dynamic> map) { ... }

  final String id;
  final String title;
  final String? author;

  Map<String, dynamic> toMap() { ... }

  // nullable フィールドの copyWith にはセンチネルパターンを使用
  // _sentinel はファイル先頭にトップレベルで定義: const _sentinel = Object();
  Book copyWith({
    String? title,
    Object? author = _sentinel,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author == _sentinel ? this.author : author as String?,
    );
  }
}
```

### Enumパターン

```dart
enum ReadingStatus {
  unread,
  reading,
  completed,
}

// extension で displayName / value / fromValue を提供
extension ReadingStatusExtension on ReadingStatus {
  String get displayName {
    switch (this) {
      case ReadingStatus.unread:
        return '未読';
      case ReadingStatus.reading:
        return '読書中';
      case ReadingStatus.completed:
        return '読了';
    }
  }

  int get value => index;

  static ReadingStatus fromValue(int value) {
    return ReadingStatus.values[value];
  }
}
```

## データベース

- **SQLite**（sqfliteパッケージ）を使用
- `DatabaseHelper` はシングルトンパターン
- スキーマバージョン管理: `_onUpgrade()` でマイグレーション実施
- IDは **UUID**（uuidパッケージ）で生成

## テスト

```dart
testWidgets('説明', (WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(child: BookManagerApp()),
  );
  await tester.pumpAndSettle();

  // 検証
  expect(find.text('本棚'), findsOneWidget);
});
```

- ProviderScope でラップしてテスト
- `pumpAndSettle()` でアニメーション完了を待つ

## Git規約

- ベースブランチ: `develop`
- ブランチ命名: `feature/機能名`, `fix/バグ内容`, `refactor/対象`, `docs/内容`
- コミットメッセージ: `種別: 変更内容の要約`（種別: feat / fix / docs / refactor / test / chore）

## 言語

- コード中の変数名・関数名・クラス名: **英語**
- UIテキスト・コメント・ドキュメント: **日本語**
- **PRレビューコメント: 日本語** で記述すること
