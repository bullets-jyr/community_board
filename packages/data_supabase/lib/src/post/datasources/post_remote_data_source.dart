import 'dart:io';

import 'package:domain/post.dart';

import '../models/comment_display_model.dart';
import '../models/like_result_model.dart';
import '../models/post_display_model.dart';

abstract interface class PostRemoteDataSource {
  Future<List<PostDisplayModel>> getPosts({
    required int offset,
    required int limit,
  });

  Future<PostDisplayModel> createPost({
    String? postId,
    required String title,
    required String content,
    String? imageUrl,
  });

  Future<ImageUploadResult> uploadPostImage({
    required File image,
    String? postId,
  });

  Future<PostDisplayModel> getPostDetail({required String postId});

  Future<List<CommentDisplayModel>> getComments({
    required String postId,
    required int offset,
    required int limit,
  });

  Future<LikeResultModel> toggleLike({required String postId});

  Future<CommentDisplayModel> createComment({
    required String postId,
    required String content,
  });

  Future<void> deleteComment({required String commentId});

  Future<CommentDisplayModel> updateComment({
    required String commentId,
    required String newContent,
  });

  Future<void> deletePost({required String postId});

  Future<void> deletePostFolder({required String postId});

  Future<PostDisplayModel> updatePost({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  });

  Future<List<PostDisplayModel>> getMyPosts({
    required String userId,
    required int offset,
    required int limit,
  });
}
