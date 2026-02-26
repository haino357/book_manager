/// copyWithでnullableフィールドをnullにクリアするためのsentinel値
const _sentinel = Object();

/// メモの種類
enum MemoType {
  note,       // 読書メモ
  quote,      // 気になったフレーズ・引用
  summary,    // 要約・あらすじ
  review,     // 感想・レビュー
  vocabulary, // 語彙・用語
  action,     // TODO・アクション
}

/// メモ種類の表示名・アイコンを取得
extension MemoTypeExtension on MemoType {
  String get displayName {
    switch (this) {
      case MemoType.note:
        return '読書メモ';
      case MemoType.quote:
        return 'フレーズ';
      case MemoType.summary:
        return '要約';
      case MemoType.review:
        return '感想';
      case MemoType.vocabulary:
        return '語彙・用語';
      case MemoType.action:
        return 'TODO';
    }
  }

  String get icon {
    switch (this) {
      case MemoType.note:
        return '📝';
      case MemoType.quote:
        return '💬';
      case MemoType.summary:
        return '📖';
      case MemoType.review:
        return '⭐';
      case MemoType.vocabulary:
        return '📚';
      case MemoType.action:
        return '☑';
    }
  }

  int get value {
    switch (this) {
      case MemoType.note:
        return 0;
      case MemoType.quote:
        return 1;
      case MemoType.summary:
        return 2;
      case MemoType.review:
        return 3;
      case MemoType.vocabulary:
        return 4;
      case MemoType.action:
        return 5;
    }
  }

  static MemoType fromValue(int value) {
    switch (value) {
      case 0:
        return MemoType.note;
      case 1:
        return MemoType.quote;
      case 2:
        return MemoType.summary;
      case 3:
        return MemoType.review;
      case 4:
        return MemoType.vocabulary;
      case 5:
        return MemoType.action;
      default:
        return MemoType.note;
    }
  }
}

/// 書籍メモのモデル
class BookMemo {
  const BookMemo({
    required this.id,
    required this.bookId,
    required this.type,
    required this.content,
    this.page,
    this.section,
    this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Mapからメモを作成
  factory BookMemo.fromMap(Map<String, dynamic> map) {
    return BookMemo(
      id: map['id'] as int,
      bookId: map['book_id'] as String,
      type: MemoTypeExtension.fromValue(map['type'] as int),
      content: map['content'] as String,
      page: map['page'] as int?,
      section: map['section'] as String?,
      isCompleted: map['is_completed'] != null
          ? (map['is_completed'] as int) == 1
          : null,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  final int id;
  final String bookId;
  final MemoType type;
  final String content;
  final int? page;
  final String? section;
  final bool? isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// データベース用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'type': type.value,
      'content': content,
      'page': page,
      'section': section,
      'is_completed': isCompleted != null ? (isCompleted! ? 1 : 0) : null,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// コピーを作成（一部のフィールドを変更）
  BookMemo copyWith({
    int? id,
    String? bookId,
    MemoType? type,
    String? content,
    Object? page = _sentinel,
    Object? section = _sentinel,
    Object? isCompleted = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookMemo(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      type: type ?? this.type,
      content: content ?? this.content,
      page: page == _sentinel ? this.page : page as int?,
      section: section == _sentinel ? this.section : section as String?,
      isCompleted:
          isCompleted == _sentinel ? this.isCompleted : isCompleted as bool?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookMemo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
