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
  ///
  /// 空文字の場合は未設定として扱い、問い合わせ導線を「準備中」表示にする。
  /// リリース前に実値を設定すること。
  static const supportEmail = '';

  /// App Store URL（iOS）
  ///
  /// 空文字の場合は未設定として扱い、ストア遷移フォールバックを行わない。
  /// リリース前に実値を設定すること。
  static const appStoreUrl = '';

  /// Google Play URL（Android）
  ///
  /// 空文字の場合は未設定として扱い、ストア遷移フォールバックを行わない。
  /// リリース前に実値を設定すること。
  static const googlePlayUrl = '';
}
