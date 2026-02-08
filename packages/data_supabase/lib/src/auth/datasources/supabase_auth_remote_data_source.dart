import 'dart:io';

import 'package:core/constants.dart';
import 'package:core/errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  SupabaseAuthRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return _supabaseClient.auth.onAuthStateChange.map((AuthState state) {
      final user = state.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'role': Roles.user},
      );

      final User? user = response.user;

      if (user == null) {
        throw const AuthenticationException(
          message:
          'Registration was successful, '
              'but user information could not be retrieved. (User is null)',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } on AuthenticationException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred while signup: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabaseClient.auth
          .signInWithPassword(email: email, password: password);

      final User? user = response.user;

      if (user == null) {
        throw const AuthenticationException(
          message:
          'Sign in was successful, '
              'but user information could not be retrieved. (User is null)',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } on AuthenticationException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred while login: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw AuthenticationException(message: e.message);
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      throw UnknownException(
        message:
        'An unexpected error occurred while logging out: ${e.toString()}',
      );
    }
  }
}