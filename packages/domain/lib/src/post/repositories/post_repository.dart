import 'dart:io';

import 'package:core/errors.dart';
import 'package:fpdart/fpdart.dart';

import '../dto/image_upload_result.dart';
import '../entities/comment_display.dart';
import '../entities/like_result.dart';
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

  Future<Either<Failure, LikeResult>> toggleLike({required String postId});

  Future<Either<Failure, CommentDisplay>> createComment({
    required String postId,
    required String content,
  });

  Future<Either<Failure, void>> deleteComment({required String commentId});

  Future<Either<Failure, CommentDisplay>> updateComment({
    required String commentId,
    required String newContent,
  });

  Future<Either<Failure, void>> deletePost({required String postId});

  Future<Either<Failure, void>> deletePostFolder({required String postId});

  Future<Either<Failure, PostDisplay>> updatePost({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  });

  Future<Either<Failure, List<PostDisplay>>> getMyPosts({
    required String userId,
    required int offset,
    required int limit,
  });
}
