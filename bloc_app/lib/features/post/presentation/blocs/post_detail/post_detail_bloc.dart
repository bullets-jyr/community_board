import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/bus/global_event.dart';
import '../../../../../core/bus/global_event_bus.dart';

part 'post_detail_event.dart';

part 'post_detail_state.dart';

@injectable
class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required GetPostDetailUseCase getPostDetailUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
    required GlobalEventBus globalEventBus,
  }) : _getPostDetailUseCase = getPostDetailUseCase,
       _toggleLikeUseCase = toggleLikeUseCase,
       _globalEventBus = globalEventBus,
       super(const PostDetailState()) {
    on<PostDetailFetched>(_onPostDetailFetched);
    on<PostDetailLikeToggled>(_onPostDetailLikeToggled);
    on<_PostUpdatedFromBus>(_onPostUpdatedFromBus);

    _globalEventBusSubscription = _globalEventBus.stream.listen((event) {
      if (event is PostUpdatedDispatched) {
        if (state.post?.postId == event.post.postId) {
          add(_PostUpdatedFromBus(post: event.post));
        }
      }
    });
  }

  final GetPostDetailUseCase _getPostDetailUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final GlobalEventBus _globalEventBus;

  StreamSubscription<GlobalEvent>? _globalEventBusSubscription;

  bool get _isBusy =>
      state.status == PostDetailStatus.loading ||
      state.status == PostDetailStatus.submitting;

  Future<void> _onPostDetailFetched(
    PostDetailFetched event,
    Emitter<PostDetailState> emit,
  ) async {
    if (_isBusy) return;

    emit(state.copyWith(status: PostDetailStatus.loading));

    final result = await _getPostDetailUseCase(event.postId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PostDetailStatus.failure,
          failure: () => failure,
        ),
      ),
      (post) => emit(
        state.copyWith(status: PostDetailStatus.loaded, post: () => post),
      ),
    );
  }

  Future<void> _onPostDetailLikeToggled(
    PostDetailLikeToggled event,
    Emitter<PostDetailState> emit,
  ) async {
    if (_isBusy || state.post == null) return;

    final originalPost = state.post!;

    final optimisticPost = originalPost.copyWith(
      currentUserLiked: !originalPost.currentUserLiked,
      likesCount: originalPost.currentUserLiked
          ? originalPost.likesCount - 1
          : originalPost.likesCount + 1,
    );

    emit(
      state.copyWith(post: () => optimisticPost, transientFailure: () => null),
    );

    final result = await _toggleLikeUseCase(originalPost.postId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            post: () => originalPost,
            transientFailure: () => failure,
          ),
        );
      },
      (likeResult) {
        final authoritativePost = originalPost.copyWith(
          currentUserLiked: likeResult.liked,
          likesCount: likeResult.likesCount,
        );
        emit(state.copyWith(post: () => authoritativePost));

        _globalEventBus.add(PostUpdatedDispatched(post: authoritativePost));
      },
    );
  }

  void _onPostUpdatedFromBus(
      _PostUpdatedFromBus event,
      Emitter<PostDetailState> emit,
      ) {
    if (state.status == PostDetailStatus.loaded) {
      emit(state.copyWith(post: () => event.post));
    }
  }

  @override
  Future<void> close() {
    _globalEventBusSubscription?.cancel();
    return super.close();
  }
}
