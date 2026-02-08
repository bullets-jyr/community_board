import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Please check your connection...'});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message});
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'You do not have permission for the request.',
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'The data requested not found'});
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error has occurred. Please try again later.',
  });
}
