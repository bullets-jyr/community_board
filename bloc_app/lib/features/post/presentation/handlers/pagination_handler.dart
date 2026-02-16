import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:fpdart/fpdart.dart';

typedef FetchPostsStrategy =
    Future<Either<Failure, List<PostDisplay>>> Function({
      required int offset,
      required int limit,
    });

class PaginationHandler<S> {
  Future<S> fetchNextPage({
    required S currentState,
    required FetchPostsStrategy fetchStrategy,
    required int pageSize,
    required S Function() getLatestState,
    required List<PostDisplay> Function(S state) getPosts,
    required S Function(S state, List<PostDisplay> newPosts) copyWithPosts,
    required S Function(S state, bool hasReachedMax) copyWithHasReachedMax,
    required S Function(S state, Failure failure) copyWithTransientFailure,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final result = await fetchStrategy(
      offset: getPosts(currentState).length,
      limit: pageSize,
    );

    final latestState = getLatestState();

    return result.fold(
      (failure) => copyWithTransientFailure(latestState, failure),
      (newPosts) {
        final updatedPosts = getPosts(latestState) + newPosts;
        final newState = copyWithPosts(latestState, updatedPosts);
        if (newPosts.length < pageSize) {
          return copyWithHasReachedMax(newState, true);
        }
        return newState;
      },
    );
  }

  Future<S> fetchOneToRefill({
    required S currentState,
    required FetchPostsStrategy fetchStrategy,
    required S Function() getLatestState,
    required List<PostDisplay> Function(S state) getPosts,
    required S Function(S state, List<PostDisplay> newPosts) copyWithPosts,
    required S Function(S state, bool hasReachedMax) copyWithHasReachedMax,
    required S Function(S state, Failure failure) copyWithTransientFailure,
  }) async {
    final result = await fetchStrategy(
      offset: getPosts(currentState).length,
      limit: 1,
    );

    final latestState = getLatestState();

    return result.fold(
      (failure) => copyWithTransientFailure(latestState, failure),
      (newPosts) {
        if (newPosts.isNotEmpty) {
          final updatedPosts = [...getPosts(latestState), ...newPosts];
          return copyWithPosts(latestState, updatedPosts);
        } else {
          return copyWithHasReachedMax(latestState, true);
        }
      },
    );
  }
}
