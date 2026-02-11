import 'dart:io';

import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../dto/image_upload_result.dart';
import '../repositories/post_repository.dart';

class UploadPostImageParams extends Equatable {
  const UploadPostImageParams({required this.image, this.postId});

  final File image;
  final String? postId;

  @override
  List<Object?> get props => [image, postId];
}

class UploadPostImageUseCase
    implements UseCase<ImageUploadResult, UploadPostImageParams> {
  UploadPostImageUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, ImageUploadResult>> call(
    UploadPostImageParams params,
  ) async {
    return await _postRepository.uploadPostImage(
      image: params.image,
      postId: params.postId,
    );
  }
}
