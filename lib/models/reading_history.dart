/// copyWithでnullableフィールドをnullにクリアするためのsentinel値
const _sentinel = Object();

/// 読書履歴モデル
class ReadingHistory {

  const ReadingHistory({
    required this.id,
    required this.bookId,
    this.startedAt,
    this.completedAt,
  });

  /// Mapから読書履歴を作成
  factory ReadingHistory.fromMap(Map<String, dynamic> map) {
    return ReadingHistory(
      id: map['id'] as int,
      bookId: map['book_id'] as String,
      startedAt: map['started_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
    );
  }

  final int id;
  final String bookId;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// データベース用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'started_at': startedAt?.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
    };
  }

  /// コピーを作成（一部のフィールドを変更）
  ReadingHistory copyWith({
    int? id,
    String? bookId,
    Object? startedAt = _sentinel,
    Object? completedAt = _sentinel,
  }) {
    return ReadingHistory(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      startedAt: startedAt == _sentinel
          ? this.startedAt
          : startedAt as DateTime?,
      completedAt: completedAt == _sentinel
          ? this.completedAt
          : completedAt as DateTime?,
    );
  }
}
