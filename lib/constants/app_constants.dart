/// アプリ全体で使用する定数
class AppConstants {
  AppConstants._();

  /// GitHub Pages ベースURL
  static const _pagesBaseUrl =
      'https://haino357.github.io/book_manager';

  /// プライバシーポリシーURL
  static const privacyPolicyUrl =
      '$_pagesBaseUrl/privacy-policy.html';

  /// 利用規約URL
  static const termsOfServiceUrl =
      '$_pagesBaseUrl/terms-of-service.html';

  /// お問い合わせメールアドレス
  static const supportEmail = 'support@example.com';

  /// App Store URL（iOS）
  static const appStoreUrl =
      'https://apps.apple.com/app/idXXXXXXXXXX';

  /// Google Play URL（Android）
  static const googlePlayUrl =
      'https://play.google.com/store/apps/details?id=com.example.book_manager';
}
