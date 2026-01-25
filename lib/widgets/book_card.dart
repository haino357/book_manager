import 'package:book_manager/models/book.dart';
import 'package:flutter/material.dart';

/// 本のカードウィジェット
class BookCard extends StatelessWidget {

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
  });
  final Book book;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 表紙画像
            Expanded(
              flex: 3,
              child: _buildCoverImage(),
            ),
            // 本の情報
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 著者
                    if (book.author.isNotEmpty)
                      Text(
                        book.author,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    // ステータスチップ
                    _StatusChip(status: book.status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return Image.network(
        book.coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {

  const _StatusChip({required this.status});
  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          color: _getStatusColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case ReadingStatus.unread:
        return Colors.grey;
      case ReadingStatus.reading:
        return Colors.blue;
      case ReadingStatus.completed:
        return Colors.green;
    }
  }
}
