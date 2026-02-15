import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../repositories/post_repository.dart';

class DeletePostFolderUseCase implements UseCase<void, String> {
  DeletePostFolderUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, void>> call(String params) async {
    return _postRepository.deletePostFolder(postId: params);
  }
}
