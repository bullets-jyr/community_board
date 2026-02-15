import 'dart:io';

import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/post_display.dart';
import '../repositories/post_repository.dart';

class UpdatePostParams extends Equatable {
  const UpdatePostParams({
    required this.originalPost,
    required this.newTitle,
    required this.newContent,
    this.newImageFile,
    this.imageWasRemoved = false,
  });

  final PostDisplay originalPost;
  final String newTitle;
  final String newContent;
  final File? newImageFile;
  final bool imageWasRemoved;

  @override
  List<Object?> get props {
    return [originalPost, newTitle, newContent, newImageFile, imageWasRemoved];
  }
}

class UpdatePostUseCase implements UseCase<PostDisplay, UpdatePostParams> {
  UpdatePostUseCase({required PostRepository postRepository})
    : _postRepository = postRepository;

  final PostRepository _postRepository;

  @override
  Future<Either<Failure, PostDisplay>> call(UpdatePostParams params) async {
    try {
      String? finalImageUrl = params.originalPost.imageUrl;

      if (params.newImageFile != null) {
        if (params.originalPost.imageUrl != null) {
          await _postRepository.deletePostFolder(
            postId: params.originalPost.postId,
          );
        }

        final uploadResult = await _postRepository.uploadPostImage(
          image: params.newImageFile!,
          postId: params.originalPost.postId,
        );

        finalImageUrl = uploadResult
            .getOrElse((failure) => throw failure)
            .imageUrl;
      } else if (params.imageWasRemoved &&
          params.originalPost.imageUrl != null) {
        await _postRepository.deletePostFolder(
          postId: params.originalPost.postId,
        );
        finalImageUrl = null;
      }

      return await _postRepository.updatePost(
        postId: params.originalPost.postId,
        title: params.newTitle,
        content: params.newContent,
        imageUrl: finalImageUrl,
      );
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
