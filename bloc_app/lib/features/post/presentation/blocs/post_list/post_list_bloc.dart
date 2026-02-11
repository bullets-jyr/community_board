import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'post_list_event.dart';

part 'post_list_state.dart';

const _pageSize = 5;

@injectable
class PostListBloc extends Bloc<PostListEvent, PostListState> {
  PostListBloc({
    required GetPostsUseCase getPostsUseCase,
  }) : _getPostsUseCase = getPostsUseCase,
       super(const PostListState()) {
    on<PostListFetched>(_onPostListFetched);
    on<PostListNextPageFetched>(_onPostListNextPageFetched);
    on<PostListRefreshed>(_onPostListRefreshed);
  }

  final GetPostsUseCase _getPostsUseCase;

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
}
