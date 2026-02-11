part of 'post_list_bloc.dart';

sealed class PostListEvent extends Equatable {
  const PostListEvent();

  @override
  List<Object> get props => [];
}

final class PostListFetched extends PostListEvent {}

final class PostListNextPageFetched extends PostListEvent {}

final class PostListRefreshed extends PostListEvent {}
