import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/post_display.dart';
import '../repositories/post_repository.dart';

class GetMyPostsParams extends Equatable {
  const GetMyPostsParams({
    required this.userId,
    required this.offset,
    required this.limit,
  });

  final String userId;
  final int offset;
  final int limit;

  @override
  List<Object> get props => [userId, offset, limit];
}

class GetMyPostsUseCase
    implements UseCase<List<PostDisplay>, GetMyPostsParams> {
  GetMyPostsUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, List<PostDisplay>>> call(
    GetMyPostsParams params,
  ) async {
    return await _postRepository.getMyPosts(
      userId: params.userId,
      offset: params.offset,
      limit: params.limit,
    );
  }
}
