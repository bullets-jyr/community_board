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
