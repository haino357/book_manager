import 'dart:convert';

import 'package:book_manager/models/book_search_result.dart';
import 'package:http/http.dart' as http;

/// Google Books APIを使った書籍検索サービス
class BookSearchService {
  BookSearchService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  /// クエリで書籍を検索
  ///
  /// 数字のみ10桁または13桁の場合はISBN検索、それ以外はタイトル検索を行う。
  Future<List<BookSearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // 数字のみ10桁or13桁ならISBN検索
    final isIsbn = RegExp(r'^\d{10}(\d{3})?$').hasMatch(trimmed);
    final searchQuery = isIsbn ? 'isbn:$trimmed' : 'intitle:$trimmed';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': searchQuery,
      'maxResults': '20',
    });

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('書籍の検索に失敗しました (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>?;

    if (items == null) return [];

    return items
        .map((item) => BookSearchResult.fromGoogleBooksJson(
            item as Map<String, dynamic>))
        .toList();
  }
}
