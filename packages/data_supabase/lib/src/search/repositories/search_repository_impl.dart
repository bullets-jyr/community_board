import 'package:core/errors.dart';
import 'package:domain/auth.dart';
import 'package:domain/post.dart';
import 'package:domain/search.dart';
import 'package:fpdart/fpdart.dart';

import '../datasources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required SearchRemoteDataSource searchRemoteDataSource})
    : _searchRemoteDataSource = searchRemoteDataSource;

  final SearchRemoteDataSource _searchRemoteDataSource;

  @override
  Future<Either<Failure, List<PostDisplay>>> searchPosts({
    required String query,
  }) async {
    try {
      final posts = await _searchRemoteDataSource.searchPosts(query: query);
      return Right(posts);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> searchUsers({
    required String query,
  }) async {
    try {
      final users = await _searchRemoteDataSource.searchUsers(query: query);
      return Right(users);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } on DatabaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(message: e.message));
    }
  }
}
