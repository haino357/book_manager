# FVM (Flutter Version Management) ガイド

## FVMとは

FVMはFlutterのバージョンをプロジェクトごとに管理できるツールです。

## 現在のプロジェクト設定

- **Flutter**: 3.38.7 (stable)
- **Dart**: 3.10.7

## インストール

```bash
# Homebrewでインストール（macOS）
brew tap leoafarias/fvm
brew install fvm

# または dart pub でインストール
dart pub global activate fvm
```

## 基本的な使い方

### プロジェクトにFlutterバージョンを設定

```bash
# 特定のバージョンを設定（未インストールの場合は自動インストール）
fvm use 3.38.7

# 強制インストール（確認プロンプトをスキップ）
fvm use 3.38.7 --force

# 最新の安定版を使用
fvm use stable

# ベータ版を使用
fvm use beta

# 開発版を使用
fvm use dev
```

### バージョンの確認

```bash
# 現在のプロジェクトで使用中のバージョン
fvm current

# インストール済みバージョン一覧
fvm list

# 利用可能なすべてのリリース一覧
fvm releases
```

### Flutterコマンドの実行

```bash
# FVM経由でFlutterコマンドを実行
fvm flutter run
fvm flutter build apk
fvm flutter pub get

# FVM経由でDartコマンドを実行
fvm dart analyze
```

## バージョンの追加・削除

### 新しいバージョンをインストール

```bash
# 特定のバージョンをインストール
fvm install 3.38.7

# 複数バージョンをインストール
fvm install 3.38.7
fvm install 3.32.0
```

### バージョンを削除

```bash
# 特定のバージョンを削除
fvm remove 3.32.0
```

## 生成されるファイル

| ファイル/フォルダ | 説明 |
|---|---|
| `.fvmrc` | プロジェクトのFlutterバージョン設定 |
| `.fvm/` | FVM管理フォルダ（SDKへのシンボリックリンク含む） |
| `.fvm/flutter_sdk` | Flutter SDKへのシンボリックリンク |

## .gitignore設定

`.fvm/` をgitignoreに追加してください：

```
# FVM
.fvm/
```

## IDEの設定

### VS Code

`.vscode/settings.json` に追加：

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk"
}
```

### Android Studio / IntelliJ

1. `Preferences` > `Languages & Frameworks` > `Flutter` を開く
2. `Flutter SDK path` に以下を設定：
   ```
   /プロジェクトのパス/.fvm/flutter_sdk
   ```

## グローバル設定

```bash
# デフォルトのFlutterバージョンを設定（全プロジェクト共通）
fvm global 3.38.7

# グローバル設定を解除
fvm global --unlink
```

## トラブルシューティング

### キャッシュのクリア

```bash
# FVMのキャッシュをクリア
fvm doctor
```

### SDKのパスを確認

```bash
# 現在使用中のSDKパスを表示
fvm which
```
