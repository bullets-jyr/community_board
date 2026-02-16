import 'package:core/errors.dart';
import 'package:fpdart/fpdart.dart';

import '../../auth/entities/user_entity.dart';
import '../../post/entities/post_display.dart';

abstract interface class SearchRepository {
  Future<Either<Failure, List<PostDisplay>>> searchPosts({
    required String query,
  });

  Future<Either<Failure, List<UserEntity>>> searchUsers({
    required String query,
  });
}