part of 'post_list_bloc.dart';

sealed class PostListEvent extends Equatable {
  const PostListEvent();

  @override
  List<Object> get props => [];
}

final class PostListFetched extends PostListEvent {}

final class PostListNextPageFetched extends PostListEvent {}

final class PostListRefreshed extends PostListEvent {}

final class PostListTransientFailureConsumed extends PostListEvent {}

final class PostLikeToggled extends PostListEvent {
  const PostLikeToggled({required this.post});

  final PostDisplay post;

  @override
  List<Object> get props => [post];
}

final class _GlobalEventReceived extends PostListEvent {
  const _GlobalEventReceived({required this.event});

  final GlobalEvent event;

  @override
  List<Object> get props => [event];
}

final class _PostListRefillRequested extends PostListEvent {}

final class PostListNewPostPrepended extends PostListEvent {
  const PostListNewPostPrepended({required this.post});

  final PostDisplay post;

  @override
  List<Object> get props => [post];
}

final class PostListScrollToTopRequested extends PostListEvent {}

final class PostListScrollEventConsumed extends PostListEvent {}

final class PostListResetRequested extends PostListEvent {}
