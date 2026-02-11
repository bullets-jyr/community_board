import 'dart:io';

import 'package:domain/post.dart';

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
}