import 'dart:io';

import 'package:core/errors.dart';
import 'package:fpdart/fpdart.dart';

import '../dto/image_upload_result.dart';
import '../entities/comment_display.dart';
import '../entities/post_display.dart';

abstract interface class PostRepository {
  Future<Either<Failure, List<PostDisplay>>> getPosts({
    required int offset,
    required int limit,
  });

  Future<Either<Failure, PostDisplay>> createPost({
    String? postId,
    required String title,
    required String content,
    String? imageUrl,
  });

  Future<Either<Failure, ImageUploadResult>> uploadPostImage({
    required File image,
    String? postId,
  });

  Future<Either<Failure, PostDisplay>> getPostDetail({required String postId});

  Future<Either<Failure, List<CommentDisplay>>> getComments({
    required String postId,
    required int offset,
    required int limit,
  });
}
