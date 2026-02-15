import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/comment_display.dart';
import '../repositories/post_repository.dart';

class CreateCommentParams extends Equatable {
  const CreateCommentParams({required this.postId, required this.content});

  final String postId;
  final String content;

  @override
  List<Object> get props => [postId, content];
}

class CreateCommentUseCase
    implements UseCase<CommentDisplay, CreateCommentParams> {
  CreateCommentUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, CommentDisplay>> call(
    CreateCommentParams params,
  ) async {
    return await _postRepository.createComment(
      postId: params.postId,
      content: params.content,
    );
  }
}
