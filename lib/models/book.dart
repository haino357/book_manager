/// copyWithでnullableフィールドをnullにクリアするためのsentinel値
const _sentinel = Object();

/// 読書ステータス
enum ReadingStatus {
  unread,   // 未読
  reading,  // 読書中
  completed // 読了
}

/// 読書ステータスの表示名を取得
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

  int get value {
    switch (this) {
      case ReadingStatus.unread:
        return 0;
      case ReadingStatus.reading:
        return 1;
      case ReadingStatus.completed:
        return 2;
    }
  }

  static ReadingStatus fromValue(int value) {
    switch (value) {
      case 0:
        return ReadingStatus.unread;
      case 1:
        return ReadingStatus.reading;
      case 2:
        return ReadingStatus.completed;
      default:
        return ReadingStatus.unread;
    }
  }
}

/// 本のモデル
class Book {

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.coverUrl,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  /// Mapから本を作成
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String? ?? '',
      isbn: map['isbn'] as String?,
      coverUrl: map['cover_url'] as String?,
      status: ReadingStatusExtension.fromValue(map['status'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      startedAt: map['started_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
    );
  }
  final String id;
  final String title;
  final String author;
  final String? isbn;
  final String? coverUrl;
  final ReadingStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// データベース用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'cover_url': coverUrl,
      'status': status.value,
      'created_at': createdAt.millisecondsSinceEpoch,
      'started_at': startedAt?.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
    };
  }

  /// コピーを作成（一部のフィールドを変更）
  ///
  /// nullableフィールド（isbn, coverUrl, completedAt）は明示的にnullを渡すことで
  /// 値をクリアできます。引数を省略した場合は既存の値が維持されます。
  Book copyWith({
    String? id,
    String? title,
    String? author,
    Object? isbn = _sentinel,
    Object? coverUrl = _sentinel,
    ReadingStatus? status,
    DateTime? createdAt,
    Object? startedAt = _sentinel,
    Object? completedAt = _sentinel,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn == _sentinel ? this.isbn : isbn as String?,
      coverUrl: coverUrl == _sentinel ? this.coverUrl : coverUrl as String?,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt == _sentinel
          ? this.startedAt
          : startedAt as DateTime?,
      completedAt: completedAt == _sentinel
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
