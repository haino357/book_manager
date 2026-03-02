import 'dart:async';

import 'package:book_manager/constants/app_constants.dart';
import 'package:book_manager/providers/package_info_provider.dart';
import 'package:book_manager/utils/url_launcher_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

/// 設定画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // ── アプリ情報 ──
          _buildSectionHeader(context, 'アプリ情報'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('バージョン情報'),
            trailing: Text(
              packageInfoAsync.when(
                data: (info) => 'v${info.version}',
                loading: () => '',
                error: (_, _) => '取得失敗',
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('ライセンス情報'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: '読書管理',
                applicationVersion: packageInfoAsync.whenOrNull(
                  data: (info) => 'v${info.version}',
                ),
              );
            },
          ),

          // ── 法的情報 ──
          _buildSectionHeader(context, '法的情報'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              unawaited(
                launchExternalUrl(
                  context,
                  AppConstants.privacyPolicyUrl,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('利用規約'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              unawaited(
                launchExternalUrl(
                  context,
                  AppConstants.termsOfServiceUrl,
                ),
              );
            },
          ),

          // ── サポート ──
          _buildSectionHeader(context, 'サポート'),
          ListTile(
            leading: const Icon(Icons.mail_outlined),
            title: const Text('お問い合わせ'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              final version = packageInfoAsync.whenOrNull(
                data: (info) => info.version,
              );
              final os = _platformName();
              unawaited(
                launchEmail(
                  context,
                  to: AppConstants.supportEmail,
                  subject: '【読書管理】お問い合わせ',
                  body: '\n\n---\n'
                      'アプリバージョン: ${version ?? '不明'}\n'
                      'OS: $os\n',
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.rate_review_outlined),
            title: const Text('レビューを書く'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              unawaited(_requestReview(context));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  /// プラットフォーム名を返す（dart:io に依存しない）
  static String _platformName() {
    if (kIsWeb) {
      return 'Web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

  Future<void> _requestReview(BuildContext context) async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      if (!context.mounted) {
        return;
      }

      String? storeUrl;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        storeUrl = AppConstants.appStoreUrl;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        storeUrl = AppConstants.googlePlayUrl;
      }

      if (storeUrl != null) {
        await launchExternalUrl(context, storeUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('このプラットフォームではレビュー機能は未対応です'),
          ),
        );
      }
    }
  }
}
