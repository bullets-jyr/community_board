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
    required CreateCommentUseCase createCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
    required UpdateCommentUseCase updateCommentUseCase,
    required GetPostDetailUseCase getPostDetailUseCase,
    required GlobalEventBus globalEventBus,
  }) : _getCommentsUseCase = getCommentsUseCase,
       _createCommentUseCase = createCommentUseCase,
       _deleteCommentUseCase = deleteCommentUseCase,
       _updateCommentUseCase = updateCommentUseCase,
       _getPostDetailUseCase = getPostDetailUseCase,
       _globalEventBus = globalEventBus,
       super(const CommentListState()) {
    on<CommentListFetched>(_onCommentListFetched);
    on<CommentListNextPageFetched>(_onCommentListNextPageFetched);
    on<CommentListRefreshed>(_onCommentListRefreshed);
    on<CommentListTransientFailureConsumed>(
      _onCommentListTransientFailureConsumed,
    );
    on<CommentAdded>(_onCommentAdded);
    on<CommentDeleted>(_onCommentDeleted);
    on<_CommentListRefillRequested>(_onCommentListRefillRequested);
    on<CommentEdited>(_onCommentEdited);
  }

  final GetCommentsUseCase _getCommentsUseCase;
  final CreateCommentUseCase _createCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;
  final UpdateCommentUseCase _updateCommentUseCase;
  final GetPostDetailUseCase _getPostDetailUseCase;
  final GlobalEventBus _globalEventBus;

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

  Future<void> _onCommentAdded(
    CommentAdded event,
    Emitter<CommentListState> emit,
  ) async {
    if (_isBusy) return;

    emit(
      state.copyWith(
        status: CommentListStatus.submitting,
        transientFailure: () => null,
      ),
    );

    final result = await _createCommentUseCase(
      CreateCommentParams(postId: event.postId, content: event.content),
    );

    await result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: CommentListStatus.loaded,
            transientFailure: () => failure,
          ),
        );
      },
      (newComment) async {
        final updatedComments = [newComment, ...state.comments];
        emit(
          state.copyWith(
            status: CommentListStatus.loaded,
            comments: updatedComments,
          ),
        );

        final postResult = await _getPostDetailUseCase(event.postId);
        postResult.fold((l) => null, (updatedPost) {
          _globalEventBus.add(PostUpdatedDispatched(post: updatedPost));
        });
      },
    );
  }

  Future<void> _onCommentDeleted(
    CommentDeleted event,
    Emitter<CommentListState> emit,
  ) async {
    if (_isBusy) return;

    emit(
      state.copyWith(
        submittingCommentId: () => event.commentId,
        transientFailure: () => null,
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    final result = await _deleteCommentUseCase(event.commentId);

    await result.fold(
      (failure) {
        emit(
          state.copyWith(
            submittingCommentId: () => null,
            transientFailure: () => failure,
          ),
        );
      },
      (_) async {
        final updatedComments = List<CommentDisplay>.from(state.comments)
          ..removeWhere((c) => c.id == event.commentId);

        emit(
          state.copyWith(
            comments: updatedComments,
            submittingCommentId: () => null,
          ),
        );

        add(_CommentListRefillRequested(postId: event.postId));

        final postResult = await _getPostDetailUseCase(event.postId);
        postResult.fold((l) => null, (updatedPost) {
          _globalEventBus.add(PostUpdatedDispatched(post: updatedPost));
        });
      },
    );
  }

  Future<void> _onCommentListRefillRequested(
    _CommentListRefillRequested event,
    Emitter<CommentListState> emit,
  ) async {
    if (_isBusy || state.hasReachedMax) return;

    emit(state.copyWith(status: CommentListStatus.refilling));

    final result = await _getCommentsUseCase(
      GetCommentsParams(
        postId: event.postId,
        offset: state.comments.length,
        limit: 1,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: CommentListStatus.loaded,
            transientFailure: () => failure,
          ),
        );
      },
      (newComments) {
        if (newComments.isNotEmpty) {
          emit(
            state.copyWith(
              status: CommentListStatus.loaded,
              comments: [...state.comments, ...newComments],
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: CommentListStatus.loaded,
              hasReachedMax: true,
            ),
          );
        }
      },
    );
  }

  Future<void> _onCommentEdited(
    CommentEdited event,
    Emitter<CommentListState> emit,
  ) async {
    if (_isBusy) return;

    emit(
      state.copyWith(
        submittingCommentId: () => event.commentId,
        transientFailure: () => null,
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    final result = await _updateCommentUseCase(
      UpdateCommentParams(
        commentId: event.commentId,
        newContent: event.newContent,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            submittingCommentId: () => null,
            transientFailure: () => failure,
          ),
        );
      },
      (updatedComment) {
        final updatedList = state.comments.map((comment) {
          return comment.id == updatedComment.id ? updatedComment : comment;
        }).toList();

        emit(
          state.copyWith(
            comments: updatedList,
            submittingCommentId: () => null,
          ),
        );
      },
    );
  }
}
