part of 'comment_list_bloc.dart';

sealed class CommentListEvent extends Equatable {
  const CommentListEvent();

  @override
  List<Object> get props => [];
}

final class CommentListFetched extends CommentListEvent {
  const CommentListFetched({required this.postId});

  final String postId;

  @override
  List<Object> get props => [postId];
}

final class CommentListNextPageFetched extends CommentListEvent {
  const CommentListNextPageFetched({required this.postId});

  final String postId;

  @override
  List<Object> get props => [postId];
}

final class CommentListRefreshed extends CommentListEvent {
  const CommentListRefreshed({required this.postId});

  final String postId;

  @override
  List<Object> get props => [postId];
}

final class CommentListTransientFailureConsumed extends CommentListEvent {}