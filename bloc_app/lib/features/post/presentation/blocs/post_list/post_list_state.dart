part of 'post_list_bloc.dart';

enum PostListStatus {
  initial,
  loading,
  loaded,
  failure,
  fetchingNextPage,
  refilling,
  refreshing,
}

class PostListState extends Equatable {
  const PostListState({
    this.status = PostListStatus.initial,
    this.posts = const [],
    this.hasReachedMax = false,
    this.failure,
    this.transientFailure,
    this.scrollToTopEventId,
  });

  final PostListStatus status;
  final List<PostDisplay> posts;
  final bool hasReachedMax;
  final Failure? failure;
  final Failure? transientFailure;
  final int? scrollToTopEventId;

  @override
  List<Object?> get props {
    return [
      status,
      posts,
      hasReachedMax,
      failure,
      transientFailure,
      scrollToTopEventId,
    ];
  }

  PostListState copyWith({
    PostListStatus? status,
    List<PostDisplay>? posts,
    bool? hasReachedMax,
    Failure? Function()? failure,
    Failure? Function()? transientFailure,
    int? Function()? scrollToTopEventId,
  }) {
    return PostListState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      failure: failure != null ? failure() : this.failure,
      transientFailure: transientFailure != null
          ? transientFailure()
          : this.transientFailure,
      scrollToTopEventId: scrollToTopEventId != null
          ? scrollToTopEventId()
          : this.scrollToTopEventId,
    );
  }
}
