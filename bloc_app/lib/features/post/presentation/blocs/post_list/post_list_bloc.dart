import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/bus/global_event.dart';
import '../../../../../core/bus/global_event_bus.dart';

part 'post_list_event.dart';

part 'post_list_state.dart';

const _pageSize = 5;

@injectable
class PostListBloc extends Bloc<PostListEvent, PostListState> {
  PostListBloc({
    required GetPostsUseCase getPostsUseCase,
    required GlobalEventBus globalEventBus,
  }) : _getPostsUseCase = getPostsUseCase,
       _globalEventBus = globalEventBus,
       super(const PostListState()) {
    on<PostListFetched>(_onPostListFetched);
    on<PostListNextPageFetched>(_onPostListNextPageFetched);
    on<PostListRefreshed>(_onPostListRefreshed);
    on<PostListTransientFailureConsumed>(_onPostListTransientFailureConsumed);
    on<_GlobalEventReceived>(_onGlobalEventReceived);

    _globalEventBusSubscription = _globalEventBus.stream.listen((event) {
      add(_GlobalEventReceived(event: event));
    });
  }

  final GetPostsUseCase _getPostsUseCase;
  final GlobalEventBus _globalEventBus;
  StreamSubscription<GlobalEvent>? _globalEventBusSubscription;

  bool get _isBusy =>
      state.status == PostListStatus.loading ||
      state.status == PostListStatus.fetchingNextPage ||
      state.status == PostListStatus.refilling ||
      state.status == PostListStatus.refreshing;

  Future<void> _onPostListFetched(
    PostListFetched event,
    Emitter<PostListState> emit,
  ) async {
    if (_isBusy) return;

    emit(state.copyWith(status: PostListStatus.loading));

    final result = await _getPostsUseCase(
      const GetPostsParams(offset: 0, limit: _pageSize),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: PostListStatus.failure,
            failure: () => failure,
          ),
        );
      },
      (posts) {
        emit(
          state.copyWith(
            status: PostListStatus.loaded,
            posts: posts,
            hasReachedMax: posts.length < _pageSize,
          ),
        );
      },
    );
  }

  Future<void> _onPostListNextPageFetched(
    PostListNextPageFetched event,
    Emitter<PostListState> emit,
  ) async {
    if (_isBusy || state.hasReachedMax) return;

    emit(state.copyWith(status: PostListStatus.fetchingNextPage));

    await Future.delayed(const Duration(seconds: 1));

    final result = await _getPostsUseCase(
      GetPostsParams(offset: state.posts.length, limit: _pageSize),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PostListStatus.loaded,
          transientFailure: () => failure,
        ),
      ),
      (newPosts) {
        emit(
          state.copyWith(
            status: PostListStatus.loaded,
            posts: [...state.posts, ...newPosts],
            hasReachedMax: newPosts.length < _pageSize,
          ),
        );
      },
    );
  }

  Future<void> _onPostListRefreshed(
    PostListRefreshed event,
    Emitter<PostListState> emit,
  ) async {
    if (_isBusy) return;

    emit(state.copyWith(status: PostListStatus.refreshing));

    final result = await _getPostsUseCase(
      const GetPostsParams(offset: 0, limit: _pageSize),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PostListStatus.loaded,
          transientFailure: () => failure,
        ),
      ),
      (posts) => emit(
        PostListState(
          status: PostListStatus.loaded,
          posts: posts,
          hasReachedMax: posts.length < _pageSize,
        ),
      ),
    );
  }

  void _onPostListTransientFailureConsumed(
    PostListTransientFailureConsumed event,
    Emitter<PostListState> emit,
  ) {
    emit(state.copyWith(transientFailure: () => null));
  }

  void _onGlobalEventReceived(
    _GlobalEventReceived event,
    Emitter<PostListState> emit,
  ) {
    if (state.status != PostListStatus.fetchingNextPage && _isBusy) return;

    switch (event.event) {
      case PostCreatedDispatched(post: final newPost):
        final currentPosts = state.posts;
        emit(state.copyWith(posts: [newPost, ...currentPosts]));
    }
  }

  @override
  Future<void> close() {
    _globalEventBusSubscription?.cancel();
    return super.close();
  }
}
