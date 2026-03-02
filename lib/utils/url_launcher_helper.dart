import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 外部URLをブラウザで開く
///
/// 失敗時は [context] を使って SnackBar でエラーを表示する。
Future<void> launchExternalUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URLを開けませんでした')),
      );
    }
  }
}

/// メールアプリを起動する（件名・本文付き）
///
/// 失敗時は [context] を使って SnackBar でエラーを表示する。
Future<void> launchEmail(
  BuildContext context, {
  required String to,
  String subject = '',
  String body = '',
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: to,
    queryParameters: {
      if (subject.isNotEmpty) 'subject': subject,
      if (body.isNotEmpty) 'body': body,
    },
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールアプリを起動できませんでした')),
      );
    }
  }
}
