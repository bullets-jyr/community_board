import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/auth.dart';
import 'package:domain/post.dart';
import 'package:domain/search.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../../../core/bus/global_event.dart';
import '../../../../../core/bus/global_event_bus.dart';

part 'search_event.dart';

part 'search_state.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchUsersUseCase searchUsersUseCase,
    required SearchPostsUseCase searchPostsUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
    required GlobalEventBus globalEventBus,
  }) : _searchUsersUseCase = searchUsersUseCase,
       _searchPostsUseCase = searchPostsUseCase,
       _toggleLikeUseCase = toggleLikeUseCase,
       _globalEventBus = globalEventBus,
       super(const SearchState()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchTabChanged>(_onSearchTabChanged);
    on<_SearchExecutionTriggered>(
      _onSearchExecutionTriggered,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<SearchPostLikeToggled>(_onSearchPostLikeToggled);
    on<SearchTransientFailureConsumed>(_onSearchTransientFailureConsumed);
    on<_GlobalEventReceived>(_onGlobalEventReceived);

    _globalEventSubscription = _globalEventBus.stream.listen((event) {
      add(_GlobalEventReceived(event: event));
    });
  }

  final SearchUsersUseCase _searchUsersUseCase;
  final SearchPostsUseCase _searchPostsUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final GlobalEventBus _globalEventBus;

  StreamSubscription<GlobalEvent>? _globalEventSubscription;

  bool get _isBusy =>
      state.status == SearchStatus.loadingUsers ||
      state.status == SearchStatus.loadingPosts;

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(query: event.query));
    add(_SearchExecutionTriggered(query: event.query));
  }

  void _onSearchTabChanged(SearchTabChanged event, Emitter<SearchState> emit) {
    emit(state.copyWith(currentTabIndex: event.tabIndex));
    if (state.query.trim().isNotEmpty) {
      add(_SearchExecutionTriggered(query: state.query));
    }
  }

  Future<void> _onSearchExecutionTriggered(
    _SearchExecutionTriggered event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(state.copyWith(status: SearchStatus.loaded, users: [], posts: []));
      return;
    }

    final currentTabIndex = state.currentTabIndex;
    if (currentTabIndex == 0) {
      emit(state.copyWith(status: SearchStatus.loadingUsers, users: []));
      final result = await _searchUsersUseCase(query);

      result.fold(
        (failure) => emit(
          state.copyWith(status: SearchStatus.failure, failure: () => failure),
        ),
        (users) =>
            emit(state.copyWith(status: SearchStatus.loaded, users: users)),
      );
    } else {
      if (query.length < 2) {
        emit(state.copyWith(status: SearchStatus.loaded, posts: []));
        return;
      }
      emit(state.copyWith(status: SearchStatus.loadingPosts, posts: []));
      final result = await _searchPostsUseCase(query);

      result.fold(
        (failure) => emit(
          state.copyWith(status: SearchStatus.failure, failure: () => failure),
        ),
        (posts) =>
            emit(state.copyWith(status: SearchStatus.loaded, posts: posts)),
      );
    }
  }

  Future<void> _onSearchPostLikeToggled(
    SearchPostLikeToggled event,
    Emitter<SearchState> emit,
  ) async {
    if (_isBusy) return;

    final originalList = state.posts;
    final originalPost = event.post;
    final originalIndex = originalList.indexWhere(
      (p) => p.postId == originalPost.postId,
    );
    if (originalIndex == -1) return;

    final optimisticPost = originalPost.copyWith(
      currentUserLiked: !originalPost.currentUserLiked,
      likesCount: originalPost.currentUserLiked
          ? originalPost.likesCount - 1
          : originalPost.likesCount + 1,
    );
    final optimisticList = List<PostDisplay>.from(originalList);
    optimisticList[originalIndex] = optimisticPost;

    emit(state.copyWith(posts: optimisticList, transientFailure: () => null));

    final result = await _toggleLikeUseCase(originalPost.postId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(posts: originalList, transientFailure: () => failure),
        );
      },
      (likeResult) {
        final authoritativePost = originalPost.copyWith(
          currentUserLiked: likeResult.liked,
          likesCount: likeResult.likesCount,
        );
        final finalList = List<PostDisplay>.from(state.posts);
        final finalIndex = finalList.indexWhere(
          (p) => p.postId == authoritativePost.postId,
        );

        if (finalIndex != -1) {
          finalList[finalIndex] = authoritativePost;

          _globalEventBus.add(PostUpdatedDispatched(post: authoritativePost));

          emit(state.copyWith(posts: finalList));
        } else {
          emit(state);
        }
      },
    );
  }

  void _onSearchTransientFailureConsumed(
    SearchTransientFailureConsumed event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(transientFailure: () => null));
  }

  void _onGlobalEventReceived(
    _GlobalEventReceived event,
    Emitter<SearchState> emit,
  ) {
    if (state.status != SearchStatus.loaded) return;

    switch (event.event) {
      case PostUpdatedDispatched(post: final updatedPost):
        final currentPosts = state.posts;
        final newPosts = currentPosts.map((p) {
          return p.postId == updatedPost.postId ? updatedPost : p;
        }).toList();
        emit(state.copyWith(posts: newPosts));

      case PostDeletedDispatched(postId: final deletedPostId):
        final currentPosts = state.posts;
        final newPosts = currentPosts
            .where((p) => p.postId != deletedPostId)
            .toList();
        emit(state.copyWith(posts: newPosts));

      case ProfileUpdatedDispatched(profile: final updatedProfile):
        final currentPosts = state.posts;
        final newPosts = currentPosts.map((post) {
          if (post.authorId == updatedProfile.id) {
            return post.copyWith(
              authorUsername: updatedProfile.username,
              authorAvatarUrl: () => updatedProfile.avatarUrl,
            );
          }
          return post;
        }).toList();

        final currentUsers = state.users;
        final newUsers = currentUsers.map((user) {
          if (user.id == updatedProfile.id) {
            return updatedProfile;
          }
          return user;
        }).toList();

        emit(state.copyWith(posts: newPosts, users: newUsers));

      case _:
    }
  }

  @override
  Future<void> close() {
    _globalEventSubscription?.cancel();
    return super.close();
  }
}
