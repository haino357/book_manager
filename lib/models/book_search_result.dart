/// 書籍検索結果のモデル
class BookSearchResult {
  const BookSearchResult({
    required this.title,
    required this.authors,
    this.isbn,
    this.coverUrl,
  });

  /// Google Books APIのレスポンスから生成
  factory BookSearchResult.fromGoogleBooksJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};

    // タイトル
    final title = volumeInfo['title'] as String? ?? '';

    // 著者（リストをカンマ区切りで結合）
    final authorsList = volumeInfo['authors'] as List<dynamic>?;
    final authors = authorsList?.map((a) => a as String).join(', ') ?? '';

    // ISBN（ISBN-13を優先、なければISBN-10）
    String? isbn;
    final identifiers =
        volumeInfo['industryIdentifiers'] as List<dynamic>? ?? [];
    for (final id in identifiers) {
      final idMap = id as Map<String, dynamic>;
      if (idMap['type'] == 'ISBN_13') {
        isbn = idMap['identifier'] as String?;
        break;
      }
    }
    if (isbn == null) {
      for (final id in identifiers) {
        final idMap = id as Map<String, dynamic>;
        if (idMap['type'] == 'ISBN_10') {
          isbn = idMap['identifier'] as String?;
          break;
        }
      }
    }

    // 表紙画像URL（http → https変換）
    String? coverUrl;
    final imageLinks =
        volumeInfo['imageLinks'] as Map<String, dynamic>?;
    if (imageLinks != null) {
      final thumbnail = imageLinks['thumbnail'] as String? ??
          imageLinks['smallThumbnail'] as String?;
      if (thumbnail != null) {
        coverUrl = thumbnail.replaceFirst('http://', 'https://');
      }
    }

    return BookSearchResult(
      title: title,
      authors: authors,
      isbn: isbn,
      coverUrl: coverUrl,
    );
  }

  final String title;
  final String authors;
  final String? isbn;
  final String? coverUrl;
}
