# book_manager

書籍管理アプリケーション

## 開発環境

| 項目 | バージョン |
|---|---|
| Flutter | 3.38.7 (stable) |
| Dart | 3.10.7 |

## 対応OS

| プラットフォーム | 最低バージョン             |
|---|---------------------|
| Android | 7.0 Nougat (API 24) |
| iOS | 15.0                |

## セットアップ

### 1. FVMのインストール

このプロジェクトは[FVM](https://fvm.app/)でFlutterバージョンを管理しています。

```bash
# macOS
brew tap leoafarias/fvm
brew install fvm
```

### 2. Flutterのセットアップ

```bash
# プロジェクトで指定されたFlutterバージョンをインストール
fvm install

# 依存パッケージを取得
fvm flutter pub get
```

### 3. アプリの実行

```bash
fvm flutter run
```

## ドキュメント

- [FVMガイド](docs/fvm-guide.md) - FVMの詳細な使い方
