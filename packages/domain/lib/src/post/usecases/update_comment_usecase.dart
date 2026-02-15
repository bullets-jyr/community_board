import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/comment_display.dart';
import '../repositories/post_repository.dart';

class UpdateCommentParams extends Equatable {
  const UpdateCommentParams({
    required this.commentId,
    required this.newContent,
  });

  final String commentId;
  final String newContent;

  @override
  List<Object> get props => [commentId, newContent];
}

class UpdateCommentUseCase
    implements UseCase<CommentDisplay, UpdateCommentParams> {
  UpdateCommentUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, CommentDisplay>> call(
    UpdateCommentParams params,
  ) async {
    return await _postRepository.updateComment(
      commentId: params.commentId,
      newContent: params.newContent,
    );
  }
}
