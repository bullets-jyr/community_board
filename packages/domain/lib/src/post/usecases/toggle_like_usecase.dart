import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/like_result.dart';
import '../repositories/post_repository.dart';

class ToggleLikeUseCase implements UseCase<LikeResult, String> {
  ToggleLikeUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, LikeResult>> call(String params) async {
    return await _postRepository.toggleLike(postId: params);
  }
}
