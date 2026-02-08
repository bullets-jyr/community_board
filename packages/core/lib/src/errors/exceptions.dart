class AppException implements Exception {
  const AppException({required this.message});

  final String message;

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

class AuthenticationException extends AppException {
  const AuthenticationException({required super.message});
}

class DatabaseException extends AppException {
  const DatabaseException({required super.message});
}

class PermissionException extends DatabaseException {
  const PermissionException({required super.message});
}

class NotFoundException extends DatabaseException {
  const NotFoundException({required super.message});
}

class StorageServerException extends AppException {
  const StorageServerException({required super.message});
}

class NetworkException extends AppException {
  const NetworkException({
    super.message =
        'Network connection failed. '
        'Please check your internet connection',
  });
}

class UnknownException extends AppException {
  const UnknownException({super.message = 'An unknown error occurred.'});
}
