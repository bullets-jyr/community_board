import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Stream<UserModel?> get onAuthStateChanged;

  Future<UserModel> signup({
    required String email,
    required String password,
    required String username,
  });

  Future<UserModel> login({required String email, required String password});

  Future<void> logout();
}