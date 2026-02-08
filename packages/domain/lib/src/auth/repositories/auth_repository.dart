import 'package:core/errors.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Stream<UserEntity?> get onAuthStateChanged;

  Future<Either<Failure, void>> signup({
    required String email,
    required String password,
    required String username,
  });

  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();
}
