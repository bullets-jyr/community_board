part of 'post_list_bloc.dart';

enum PostListStatus {
  // 초기
  initial,
  // 로딩 중
  loading,
  // 로딩 성공
  loaded,
  // 로딩 실패
  failure,
  // 다음 페이지 로딩 중
  fetchingNextPage,
  // 삭제 후 목록을 채우기 위한 로딩 중
  refilling,
  // 새로고침
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
  // 초기 실패
  final Failure? failure;
  // 일시적인 실패
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