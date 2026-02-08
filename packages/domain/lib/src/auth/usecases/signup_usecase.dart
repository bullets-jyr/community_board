import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../repositories/auth_repository.dart';

class SignupParams extends Equatable {
  const SignupParams({
    required this.email,
    required this.password,
    required this.username,
  });

  final String email;
  final String password;
  final String username;

  @override
  List<Object> get props => [email, password, username];
}

class SignupUseCase implements UseCase<void, SignupParams> {
  SignupUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, void>> call(SignupParams params) async {
    return await _authRepository.signup(
      email: params.email,
      password: params.password,
      username: params.username,
    );
  }
}