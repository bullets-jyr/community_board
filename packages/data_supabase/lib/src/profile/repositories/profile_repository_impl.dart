import 'dart:io';

import 'package:core/errors.dart';
import 'package:domain/auth.dart';
import 'package:domain/profile.dart';
import 'package:fpdart/fpdart.dart';

import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource profileRemoteDataSource,
  }) : _profileRemoteDataSource = profileRemoteDataSource;

  final ProfileRemoteDataSource _profileRemoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> getProfile(String userId) async {
    try {
      final profile = await _profileRemoteDataSource.getProfile(userId);
      return Right(profile);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required File image,
    required String userId,
  }) async {
    try {
      final url = await _profileRemoteDataSource.uploadAvatar(
        image: image,
        userId: userId,
      );
      return Right(url);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on StorageServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    try {
      final updatedProfile = await _profileRemoteDataSource.updateProfile(
        username: username,
        avatarUrl: avatarUrl,
      );
      return Right(updatedProfile);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAvatar(String avatarUrl) async {
    try {
      await _profileRemoteDataSource.deleteAvatar(avatarUrl);
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }
}
