part of 'my_post_list_bloc.dart';

sealed class MyPostListEvent extends Equatable {
  const MyPostListEvent();

  @override
  List<Object> get props => [];
}

final class MyPostListFetched extends MyPostListEvent {
  const MyPostListFetched({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

final class MyPostListRefreshed extends MyPostListEvent {
  const MyPostListRefreshed({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

final class MyPostListNextPageFetched extends MyPostListEvent {
  const MyPostListNextPageFetched({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

final class MyPostLikeToggled extends MyPostListEvent {
  const MyPostLikeToggled({required this.post});

  final PostDisplay post;

  @override
  List<Object> get props => [post];
}

final class MyPostListTransientFailureConsumed extends MyPostListEvent {}

final class _MyPostListRefillRequested extends MyPostListEvent {}

final class _GlobalEventReceived extends MyPostListEvent {
  const _GlobalEventReceived({required this.event});

  final GlobalEvent event;

  @override
  List<Object> get props => [event];
}
