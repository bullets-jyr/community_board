import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bus/global_event.dart';
import '../../../../core/bus/global_event_bus.dart';

class ToggleLikeHandler<S> {
  ToggleLikeHandler({
    required ToggleLikeUseCase toggleLikeUseCase,
    required GlobalEventBus globalEventBus,
  }) : _toggleLikeUseCase = toggleLikeUseCase,
       _globalEventBus = globalEventBus;

  final ToggleLikeUseCase _toggleLikeUseCase;
  final GlobalEventBus _globalEventBus;

  Future<void> execute({
    required Emitter<S> emit,
    required S initialState,
    required PostDisplay postToToggle,
    required S Function() getLatestState,
    required List<PostDisplay> Function(S state) getPosts,
    required S Function(S state, List<PostDisplay> newPosts) copyWithPosts,
    required S Function(S state, Failure? failure) copyWithTransientFailure,
    required S Function(S data) successStateBuilder,
  }) async {
    final originalList = getPosts(initialState);
    final originalIndex = originalList.indexWhere(
      (p) => p.postId == postToToggle.postId,
    );
    if (originalIndex == -1) return;

    final originalPost = originalList[originalIndex];

    final optimisticPost = originalPost.copyWith(
      currentUserLiked: !originalPost.currentUserLiked,
      likesCount: originalPost.currentUserLiked
          ? originalPost.likesCount - 1
          : originalPost.likesCount + 1,
    );
    final optimisticList = List<PostDisplay>.from(originalList);
    optimisticList[originalIndex] = optimisticPost;

    final optimisticState = copyWithPosts(initialState, optimisticList);
    final stateWithoutFailure = copyWithTransientFailure(optimisticState, null);
    emit(successStateBuilder(stateWithoutFailure));

    final result = await _toggleLikeUseCase(postToToggle.postId);

    final latestState = getLatestState();

    result.fold(
      (failure) {
        final rollbackState = copyWithPosts(latestState, originalList);
        final finalState = copyWithTransientFailure(rollbackState, failure);
        emit(successStateBuilder(finalState));
      },
      (likeResult) {
        final authoritativePost = originalPost.copyWith(
          currentUserLiked: likeResult.liked,
          likesCount: likeResult.likesCount,
        );

        final currentListAfterAwait = getPosts(latestState);
        final finalList = List<PostDisplay>.from(currentListAfterAwait);
        final finalIndex = finalList.indexWhere(
          (p) => p.postId == authoritativePost.postId,
        );

        if (finalIndex != -1) {
          finalList[finalIndex] = authoritativePost;
          _globalEventBus.add(PostUpdatedDispatched(post: authoritativePost));

          final finalState = copyWithPosts(latestState, finalList);
          emit(successStateBuilder(finalState));
        } else {
          emit(successStateBuilder(latestState));
        }
      },
    );
  }
}
