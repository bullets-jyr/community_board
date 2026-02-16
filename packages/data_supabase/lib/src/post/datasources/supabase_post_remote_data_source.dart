import 'dart:io';

import 'package:core/constants.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/comment_display_model.dart';
import '../models/like_result_model.dart';
import '../models/post_display_model.dart';
import 'post_remote_data_source.dart';

class SupabasePostRemoteDataSource implements PostRemoteDataSource {
  SupabasePostRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<List<PostDisplayModel>> getPosts({
    required int offset,
    required int limit,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }
      final to = offset + limit - 1;

      final postMaps = await _supabaseClient
          .from(Views.postDisplayView)
          .select()
          .order('post_created_at', ascending: false)
          .range(offset, to);
      return postMaps.map((p) => PostDisplayModel.fromJson(p)).toList();
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<PostDisplayModel> createPost({
    String? postId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final finalPostId = postId ?? const Uuid().v4();

      final result = await _supabaseClient
          .rpc(
            DBFunctions.createPostAndReturnPostDisplayView,
            params: {
              'p_post_id': finalPostId,
              'p_title': title,
              'p_content': content,
              'p_image_url': imageUrl,
            },
          )
          .single();

      return PostDisplayModel.fromJson(result);
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      if (e.code == PostgresErrors.moreThanOneOrNoItemsReturned) {
        throw NotFoundException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<ImageUploadResult> uploadPostImage({
    required File image,
    String? postId,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(
          message: 'User not authenticated for image upload.',
        );
      }

      final finalPostId = postId ?? const Uuid().v4();

      final imageExtension = image.path.split('.').last.toLowerCase();
      final imageFileName = '${const Uuid().v4()}.$imageExtension';
      final imagePath = 'public/$userId/$finalPostId/$imageFileName';

      await _supabaseClient.storage
          .from(Storage.postImages)
          .upload(imagePath, image);

      final imageUrl = _supabaseClient.storage
          .from(Storage.postImages)
          .getPublicUrl(imagePath);

      return ImageUploadResult(postId: finalPostId, imageUrl: imageUrl);
    } on AuthenticationException {
      rethrow;
    } on StorageException catch (e) {
      throw StorageServerException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<PostDisplayModel> getPostDetail({required String postId}) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final postDisplayModelMap = await _supabaseClient
          .from(Views.postDisplayView)
          .select()
          .eq('post_id', postId)
          .single();

      return PostDisplayModel.fromJson(postDisplayModelMap);
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      if (e.code == PostgresErrors.moreThanOneOrNoItemsReturned) {
        throw NotFoundException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<List<CommentDisplayModel>> getComments({
    required String postId,
    required int offset,
    required int limit,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final to = offset + limit - 1;

      final commentMaps = await _supabaseClient
          .from(Views.commentDisplayView)
          .select()
          .eq('post_id', postId)
          .range(offset, to);
      return commentMaps
          .map((map) => CommentDisplayModel.fromJson(map))
          .toList();
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<LikeResultModel> toggleLike({required String postId}) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }
      final result = await _supabaseClient.rpc(
        DBFunctions.handleLike,
        params: {'p_post_id': postId},
      );
      return LikeResultModel.fromJson(result as Map<String, dynamic>);
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<CommentDisplayModel> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User not authenticated for creating comment.',
        );
      }

      final result = await _supabaseClient
          .rpc(
            DBFunctions.createCommentAndReturnCommentDisplayView,
            params: {'p_post_id': postId, 'p_content': content},
          )
          .single();

      return CommentDisplayModel.fromJson(result);
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      if (e.code == PostgresErrors.moreThanOneOrNoItemsReturned) {
        throw NotFoundException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<void> deleteComment({required String commentId}) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }
      await _supabaseClient.from(Tables.comments).delete().match({
        'id': commentId,
      });
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<CommentDisplayModel> updateComment({
    required String commentId,
    required String newContent,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final updatedCommentMap = await _supabaseClient
          .rpc(
            DBFunctions.updateCommentAndReturnCommentDisplayView,
            params: {'p_comment_id': commentId, 'p_new_content': newContent},
          )
          .single();

      return CommentDisplayModel.fromJson(updatedCommentMap);
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      if (e.code == PostgresErrors.moreThanOneOrNoItemsReturned) {
        throw NotFoundException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<void> deletePost({required String postId}) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      await _supabaseClient.from(Tables.posts).delete().match({'id': postId});
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<void> deletePostFolder({required String postId}) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException(
          message: 'User not authenticated for image deletion.',
        );
      }
      final folderPath = 'public/$userId/$postId';

      final fileList = await _supabaseClient.storage
          .from(Storage.postImages)
          .list(path: folderPath);
      if (fileList.isEmpty) {
        return;
      }

      final filesToRemove = fileList
          .map((file) => '$folderPath/${file.name}')
          .toList();

      await _supabaseClient.storage
          .from(Storage.postImages)
          .remove(filesToRemove);
    } on AuthenticationException {
      rethrow;
    } on StorageException catch (e) {
      throw StorageServerException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<PostDisplayModel> updatePost({
    required String postId,
    required String title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final result = await _supabaseClient
          .rpc(
            DBFunctions.updatePostAndReturnPostDisplayView,
            params: {
              'p_post_id': postId,
              'p_title': title,
              'p_content': content,
              'p_image_url': imageUrl,
            },
          )
          .single();

      return PostDisplayModel.fromJson(result);
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      if (e.code == PostgresErrors.moreThanOneOrNoItemsReturned) {
        throw NotFoundException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<List<PostDisplayModel>> getMyPosts({
    required String userId,
    required int offset,
    required int limit,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final result = await _supabaseClient.rpc(
        DBFunctions.getMyPosts,
        params: {'p_author_id': userId, 'p_offset': offset, 'p_limit': limit},
      );
      final postMaps = List<Map<String, dynamic>>.from(result as List);
      return postMaps.map((json) => PostDisplayModel.fromJson(json)).toList();
    } on AuthenticationException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.code == PostgresErrors.insufficientPrivilege) {
        throw PermissionException(message: e.message);
      }
      throw DatabaseException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(message: e.toString());
    }
  }
}
