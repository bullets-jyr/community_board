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

final class CommentAdded extends CommentListEvent {
  const CommentAdded({required this.postId, required this.content});

  final String postId;
  final String content;

  @override
  List<Object> get props => [postId, content];
}

final class CommentDeleted extends CommentListEvent {
  const CommentDeleted({required this.postId, required this.commentId});

  final String postId;
  final String commentId;

  @override
  List<Object> get props => [postId, commentId];
}

final class CommentEdited extends CommentListEvent {
  const CommentEdited({required this.commentId, required this.newContent});

  final String commentId;
  final String newContent;

  @override
  List<Object> get props => [commentId, newContent];
}

final class _CommentListRefillRequested extends CommentListEvent {
  const _CommentListRefillRequested({required this.postId});

  final String postId;

  @override
  List<Object> get props => [postId];
}