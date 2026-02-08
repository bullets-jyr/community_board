import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.role,
  });

  final String id;
  final String username;
  final String? avatarUrl;
  final String role;

  @override
  List<Object?> get props => [id, username, avatarUrl, role];
}
