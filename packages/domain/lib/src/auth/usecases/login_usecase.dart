import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}

class LoginUseCase implements UseCase<void, LoginParams> {
  LoginUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Future<Either<Failure, void>> call(LoginParams params) async {
    return await _authRepository.login(
      email: params.email,
      password: params.password,
    );
  }
}
