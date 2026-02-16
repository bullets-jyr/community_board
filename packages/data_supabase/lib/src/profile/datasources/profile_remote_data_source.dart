import 'dart:io';

import '../../auth/models/user_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String userId);

  Future<UserModel> updateProfile({
    required String username,
    String? avatarUrl,
  });

  Future<String> uploadAvatar({required File image, required String userId});

  Future<void> deleteAvatar(String avatarUrl);
}
