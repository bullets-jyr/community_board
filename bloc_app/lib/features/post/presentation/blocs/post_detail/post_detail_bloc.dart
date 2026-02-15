import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/bus/global_event.dart';
import '../../../../../core/bus/global_event_bus.dart';

part 'post_detail_event.dart';

part 'post_detail_state.dart';

@injectable
class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc({
    required GetPostDetailUseCase getPostDetailUseCase,
  }) : _getPostDetailUseCase = getPostDetailUseCase,
       super(const PostDetailState()) {
    on<PostDetailFetched>(_onPostDetailFetched);
  }

  final GetPostDetailUseCase _getPostDetailUseCase;

  bool get _isBusy =>
      state.status == PostDetailStatus.loading ||
      state.status == PostDetailStatus.submitting;

  Future<void> _onPostDetailFetched(
    PostDetailFetched event,
    Emitter<PostDetailState> emit,
  ) async {
    if (_isBusy) return;

    emit(state.copyWith(status: PostDetailStatus.loading));

    final result = await _getPostDetailUseCase(event.postId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PostDetailStatus.failure,
          failure: () => failure,
        ),
      ),
      (post) => emit(
        state.copyWith(status: PostDetailStatus.loaded, post: () => post),
      ),
    );
  }
}
