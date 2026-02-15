part of 'comment_list_bloc.dart';

enum CommentListStatus {
  initial,
  loading,
  loaded,
  failure,
  fetchingNextPage,
  submitting,
  // 삭제 후 목록을 채우기 위한 로딩 상태
  refilling,
  refreshing,
}

class CommentListState extends Equatable {
  const CommentListState({
    this.status = CommentListStatus.initial,
    this.comments = const [],
    this.hasReachedMax = false,
    this.failure,
    this.transientFailure,
    this.submittingCommentId,
  });

  final CommentListStatus status;
  final List<CommentDisplay> comments;
  final bool hasReachedMax;
  final Failure? failure;
  final Failure? transientFailure;
  final String? submittingCommentId;

  @override
  List<Object?> get props => [
    status,
    comments,
    hasReachedMax,
    failure,
    transientFailure,
    submittingCommentId,
  ];

  CommentListState copyWith({
    CommentListStatus? status,
    List<CommentDisplay>? comments,
    bool? hasReachedMax,
    Failure? Function()? failure,
    Failure? Function()? transientFailure,
    String? Function()? submittingCommentId,
  }) {
    return CommentListState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      failure: failure != null ? failure() : this.failure,
      transientFailure: transientFailure != null
          ? transientFailure()
          : this.transientFailure,
      submittingCommentId: submittingCommentId != null
          ? submittingCommentId()
          : this.submittingCommentId,
    );
  }
}