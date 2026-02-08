import 'package:data_supabase/auth.dart';
import 'package:domain/auth.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class RegisterModule {
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  // --- Data Layer Registration (LazySingleton) ---
  // auth
  @LazySingleton(as: AuthRemoteDataSource)
  SupabaseAuthRemoteDataSource get authRemoteDataSource;

  @LazySingleton(as: AuthRepository)
  AuthRepositoryImpl get authRepository;

  // post


  // profile


  // search


  // --- Domain Layer (UseCases) Registration (Injectable - factory) ---
  // auth
  @injectable
  SignupUseCase get signupUseCase;

  @injectable
  LoginUseCase get loginUseCase;

  @injectable
  LogoutUseCase get logoutUseCase;

  // post


  // profile


  // search
}