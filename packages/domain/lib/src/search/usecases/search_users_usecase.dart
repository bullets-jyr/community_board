import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../auth/entities/user_entity.dart';
import '../repositories/search_repository.dart';

class SearchUsersUseCase implements UseCase<List<UserEntity>, String> {
  SearchUsersUseCase({required SearchRepository searchRepository})
      : _searchRepository = searchRepository;

  final SearchRepository _searchRepository;

  @override
  Future<Either<Failure, List<UserEntity>>> call(String params) async {
    return await _searchRepository.searchUsers(query: params);
  }
}