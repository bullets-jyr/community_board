import 'dart:io';

import 'package:core/constants.dart';
import 'package:core/errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../auth/models/user_model.dart';
import 'profile_remote_data_source.dart';

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  SupabaseProfileRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final profileMap = await _supabaseClient
          .from(Tables.profiles)
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(profileMap);
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
  Future<String> uploadAvatar({
    required File image,
    required String userId,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final imageExtension = image.path.split('.').last.toLowerCase();
      final imageFileName = '${const Uuid().v4()}.$imageExtension';

      final imagePath = 'public/$userId/avatar/$imageFileName';

      await _supabaseClient.storage
          .from(Storage.avatars)
          .upload(imagePath, image);

      return _supabaseClient.storage
          .from(Storage.avatars)
          .getPublicUrl(imagePath);
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
  Future<UserModel> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }

      final updatedProfileMap = await _supabaseClient
          .rpc(
            DBFunctions.updateUserProfile,
            params: {'new_username': username, 'new_avatar_url': avatarUrl},
          )
          .single();

      return UserModel.fromJson(updatedProfileMap);
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
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      if (_supabaseClient.auth.currentUser == null) {
        throw const AuthenticationException(
          message: 'User is not authenticated',
        );
      }
      final Uri uri = Uri.parse(avatarUrl);

      final path = uri.pathSegments.sublist(3).join('/');

      await _supabaseClient.storage.from(Storage.avatars).remove([path]);
    } catch (e) {
      rethrow;
    }
  }
}
