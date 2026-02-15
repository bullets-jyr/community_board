part of 'post_detail_bloc.dart';

sealed class PostDetailEvent extends Equatable {
  const PostDetailEvent();

  @override
  List<Object> get props => [];
}

final class PostDetailFetched extends PostDetailEvent {
  const PostDetailFetched({required this.postId});

  final String postId;

  @override
  List<Object> get props => [postId];
}

final class PostDetailLikeToggled extends PostDetailEvent {
  const PostDetailLikeToggled();
}

final class _PostUpdatedFromBus extends PostDetailEvent {
  const _PostUpdatedFromBus({required this.post});

  final PostDisplay post;

  @override
  List<Object> get props => [post];
}