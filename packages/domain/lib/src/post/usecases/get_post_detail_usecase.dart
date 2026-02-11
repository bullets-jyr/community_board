import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/post_display.dart';
import '../repositories/post_repository.dart';

class GetPostDetailUseCase implements UseCase<PostDisplay, String> {
  GetPostDetailUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, PostDisplay>> call(String params) async {
    return await _postRepository.getPostDetail(postId: params);
  }
}
