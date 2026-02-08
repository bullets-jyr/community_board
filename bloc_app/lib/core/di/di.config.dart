// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:data_supabase/auth.dart' as _i561;
import 'package:domain/auth.dart' as _i378;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule(this);
    gh.singleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i561.AuthRemoteDataSource>(
      () => registerModule.authRemoteDataSource,
    );
    gh.lazySingleton<_i378.AuthRepository>(() => registerModule.authRepository);
    gh.factory<_i378.SignupUseCase>(() => registerModule.signupUseCase);
    gh.factory<_i378.LoginUseCase>(() => registerModule.loginUseCase);
    gh.factory<_i378.LogoutUseCase>(() => registerModule.logoutUseCase);
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {
  _$RegisterModule(this._getIt);

  final _i174.GetIt _getIt;

  @override
  _i561.SupabaseAuthRemoteDataSource get authRemoteDataSource =>
      _i561.SupabaseAuthRemoteDataSource(
        supabaseClient: _getIt<_i454.SupabaseClient>(),
      );

  @override
  _i561.AuthRepositoryImpl get authRepository => _i561.AuthRepositoryImpl(
    authRemoteDataSource: _getIt<_i561.AuthRemoteDataSource>(),
  );

  @override
  _i378.SignupUseCase get signupUseCase =>
      _i378.SignupUseCase(authRepository: _getIt<_i378.AuthRepository>());

  @override
  _i378.LoginUseCase get loginUseCase =>
      _i378.LoginUseCase(authRepository: _getIt<_i378.AuthRepository>());

  @override
  _i378.LogoutUseCase get logoutUseCase =>
      _i378.LogoutUseCase(authRepository: _getIt<_i378.AuthRepository>());
}
