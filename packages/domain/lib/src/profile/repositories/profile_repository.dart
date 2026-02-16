import 'dart:io';

import 'package:core/errors.dart';
import 'package:fpdart/fpdart.dart';

import '../../auth/entities/user_entity.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, UserEntity>> getProfile(String userId);

  Future<Either<Failure, UserEntity>> updateProfile({
    required String username,
    String? avatarUrl,
  });

  Future<Either<Failure, String>> uploadAvatar({
    required File image,
    required String userId,
  });

  Future<Either<Failure, void>> deleteAvatar(String avatarUrl);
}
