import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/bus/global_event.dart';
import '../../../../../core/bus/global_event_bus.dart';

part 'comment_list_event.dart';

part 'comment_list_state.dart';

const _commentPageSize = 5;

@injectable
class CommentListBloc extends Bloc<CommentListEvent, CommentListState> {
  CommentListBloc({
    required GetCommentsUseCase getCommentsUseCase,
  }) : _getCommentsUseCase = getCommentsUseCase,
       super(const CommentListState()) {
    on<CommentListFetched>(_onCommentListFetched);
    on<CommentListNextPageFetched>(_onCommentListNextPageFetched);
    on<CommentListRefreshed>(_onCommentListRefreshed);
    on<CommentListTransientFailureConsumed>(
      _onCommentListTransientFailureConsumed,
    );
  }

  final GetCommentsUseCase _getCommentsUseCase;

  bool get _isBusy =>
      state.status == CommentListStatus.loading ||
      state.status == CommentListStatus.fetchingNextPage ||
      state.status == CommentListStatus.submitting ||
      state.status == CommentListStatus.refilling ||
      state.status == CommentListStatus.refreshing ||
      state.submittingCommentId != null;

  Future<void> _onCommentListFetched(
    CommentListFetched event,
    Emitter<CommentListState> emit,
  ) async {
    if (_isBusy) return;

    emit(state.copyWith(status: CommentListStatus.loading));

    final result = await _getCommentsUseCase(
      GetCommentsParams(
        postId: event.postId,
        offset: 0,
        limit: _commentPageSize,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CommentListStatus.failure,
          failure: () => failure,
        ),
      ),
      (comments) => emit(
        state.copyWith(
          status: CommentListStatus.loaded,
          comments: comments,
          hasReachedMax: comments.length < _commentPageSize,
        ),
      ),
    );
  }

  Future<void> _onCommentListNextPageFetched(
    CommentListNextPageFetched event,
    Emitter<CommentListState> emit,
  ) async {
    if (_isBusy || state.hasReachedMax) return;

    emit(state.copyWith(status: CommentListStatus.fetchingNextPage));

    await Future.delayed(const Duration(seconds: 1));

    final result = await _getCommentsUseCase(
      GetCommentsParams(
        postId: event.postId,
        offset: state.comments.length,
        limit: _commentPageSize,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CommentListStatus.loaded,
          transientFailure: () => failure,
        ),
      ),
      (newComments) => emit(
        state.copyWith(
          status: CommentListStatus.loaded,
          comments: state.comments + newComments,
          hasReachedMax: newComments.length < _commentPageSize,
        ),
      ),
    );
  }

  Future<void> _onCommentListRefreshed(
    CommentListRefreshed event,
    Emitter<CommentListState> emit,
  ) async {
    if (_isBusy) return;

    emit(state.copyWith(status: CommentListStatus.refreshing));

    final result = await _getCommentsUseCase(
      GetCommentsParams(
        postId: event.postId,
        offset: 0,
        limit: _commentPageSize,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CommentListStatus.loaded,
          transientFailure: () => failure,
        ),
      ),
      (comments) => emit(
        CommentListState(
          status: CommentListStatus.loaded,
          comments: comments,
          hasReachedMax: comments.length < _commentPageSize,
        ),
      ),
    );
  }

  void _onCommentListTransientFailureConsumed(
    CommentListTransientFailureConsumed event,
    Emitter<CommentListState> emit,
  ) {
    emit(state.copyWith(transientFailure: () => null));
  }
}
