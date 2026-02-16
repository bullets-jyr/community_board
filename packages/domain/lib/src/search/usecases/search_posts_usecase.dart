import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../post/entities/post_display.dart';
import '../repositories/search_repository.dart';

class SearchPostsUseCase implements UseCase<List<PostDisplay>, String> {
  SearchPostsUseCase({required SearchRepository searchRepository})
      : _searchRepository = searchRepository;

  final SearchRepository _searchRepository;

  @override
  Future<Either<Failure, List<PostDisplay>>> call(String params) async {
    return await _searchRepository.searchPosts(query: params);
  }
}