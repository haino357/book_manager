import 'package:book_manager/models/book_search_result.dart';
import 'package:book_manager/services/book_search_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// BookSearchServiceのプロバイダー
final bookSearchServiceProvider = Provider<BookSearchService>((ref) {
  return BookSearchService();
});

/// 書籍検索の状態を管理するNotifier
class BookSearchNotifier extends AsyncNotifier<List<BookSearchResult>> {
  @override
  Future<List<BookSearchResult>> build() async {
    return [];
  }

  /// 書籍を検索
  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(bookSearchServiceProvider);
      return await service.search(query);
    });
  }

  /// 検索結果をクリア
  void clear() {
    state = const AsyncValue.data([]);
  }
}

/// 書籍検索のプロバイダー
final bookSearchProvider =
    AsyncNotifierProvider<BookSearchNotifier, List<BookSearchResult>>(() {
  return BookSearchNotifier();
});
