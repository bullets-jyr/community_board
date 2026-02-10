import 'dart:io';

import 'package:core/constants.dart';
import 'package:core/errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
}
