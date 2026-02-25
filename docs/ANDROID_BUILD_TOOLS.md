# Android ビルドツール バージョン情報

このドキュメントでは、プロジェクトで使用している Android ビルドツールのバージョンと設定ファイルの場所をまとめています。

## 現在のバージョン

| ツール | バージョン | 最終更新日 |
|--------|-----------|-----------|
| Gradle | 8.10.2 | 2026-02-05 |
| Android Gradle Plugin (AGP) | 8.7.2 | 2026-02-05 |
| Kotlin | 1.9.22 | 2026-02-05 |
| Java Compatibility | 1.8 | - |

## 設定ファイルの場所

### Gradle バージョン

**ファイル**: `android/gradle/wrapper/gradle-wrapper.properties`

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.10.2-all.zip
```

### AGP / Kotlin バージョン

**ファイル**: `android/settings.gradle`

```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.7.2" apply false
    id "org.jetbrains.kotlin.android" version "1.9.22" apply false
}
```

### アプリ固有の設定

**ファイル**: `android/app/build.gradle`

- `namespace`: com.book_manager.book_manager
- `applicationId`: com.book_manager.book_manager
- `compileSdk`: Flutter SDK に依存
- `minSdk`: Flutter SDK に依存
- `targetSdk`: Flutter SDK に依存

## バージョン互換性

Gradle と AGP には互換性の制約があります。アップグレード時は以下の組み合わせを参考にしてください。

| AGP バージョン | 必要な Gradle バージョン |
|---------------|------------------------|
| 8.7.x | 8.9 以上 |
| 8.5.x | 8.7 以上 |
| 8.4.x | 8.6 以上 |
| 8.3.x | 8.4 以上 |
| 8.1.x | 8.0 以上 |

参考: [Android Gradle Plugin リリースノート](https://developer.android.com/build/releases/gradle-plugin)

## アップグレード手順

### 1. Gradle のアップグレード

`android/gradle/wrapper/gradle-wrapper.properties` を編集:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-{VERSION}-all.zip
```

### 2. AGP のアップグレード

`android/settings.gradle` の plugins ブロックを編集:

```gradle
id "com.android.application" version "{VERSION}" apply false
```

### 3. クリーンビルド

```bash
flutter clean
flutter pub get
flutter run
```

## トラブルシューティング

### よくあるエラー

#### 「Gradle version will soon be dropped」

Flutter が要求する最低 Gradle バージョンを満たしていない場合に発生。`gradle-wrapper.properties` の `distributionUrl` を更新してください。

#### 「AGP version is lower than Flutter's minimum」

Flutter が要求する最低 AGP バージョンを満たしていない場合に発生。`settings.gradle` の AGP バージョンを更新してください。

### 参考リンク

- [Gradle Releases](https://gradle.org/releases/)
- [Android Gradle Plugin Releases](https://developer.android.com/build/releases/gradle-plugin)
- [Kotlin Releases](https://kotlinlang.org/docs/releases.html)
- [Flutter Android Setup](https://docs.flutter.dev/get-started/install/macos#android-setup)
