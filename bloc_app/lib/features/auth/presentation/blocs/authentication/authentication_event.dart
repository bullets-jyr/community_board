part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

final class _AuthenticationStatusChanged extends AuthenticationEvent {
  const _AuthenticationStatusChanged(this.user);

  final UserEntity? user;

  @override
  List<Object?> get props => [user];
}

final class AuthenticationLogoutRequested extends AuthenticationEvent {}