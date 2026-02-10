import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/usecase.dart';
import 'package:domain/auth.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthRepository authRepository,
    required LogoutUseCase logoutUseCase,
  }) : _authRepository = authRepository,
       _logoutUseCase = logoutUseCase,
       super(const AuthenticationState.unknown()) {
    _authStateSubscription = _authRepository.onAuthStateChanged.listen((
      UserEntity? user,
    ) {
      add(_AuthenticationStatusChanged(user));
    });

    on<_AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;
  final LogoutUseCase _logoutUseCase;
  StreamSubscription<UserEntity?>? _authStateSubscription;

  void _onAuthenticationStatusChanged(
    _AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) {
    if (event.user != null) {
      emit(AuthenticationState.authenticated(event.user!));
    } else {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    await _logoutUseCase(const NoParams());
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
