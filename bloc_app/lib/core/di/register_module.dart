import 'dart:async';

import 'package:data_supabase/auth.dart';
import 'package:data_supabase/post.dart';
import 'package:data_supabase/profile.dart';
import 'package:data_supabase/search.dart';
import 'package:domain/auth.dart';
import 'package:domain/post.dart';
import 'package:domain/profile.dart';
import 'package:domain/search.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/blocs/authentication/authentication_bloc.dart';
import '../config/router/app_router.dart';

FutureOr<void> disposeRealtimeDataSource(RealtimeRemoteDataSource instance) {
  instance.dispose();
}

@module
abstract class RegisterModule {
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @singleton
  GoRouter router(AuthenticationBloc authBloc) => createRouter(authBloc);

  // --- Data Layer Registration (LazySingleton) ---
  // auth
  @LazySingleton(as: AuthRemoteDataSource)
  SupabaseAuthRemoteDataSource get authRemoteDataSource;

  @LazySingleton(as: AuthRepository)
  AuthRepositoryImpl get authRepository;

  // post
  @LazySingleton(as: PostRemoteDataSource)
  SupabasePostRemoteDataSource get postRemoteDataSource;

  @LazySingleton(as: PostRepository)
  PostRepositoryImpl get postRepository;

  // post - realtime
  @LazySingleton(
    as: RealtimeRemoteDataSource,
    dispose: disposeRealtimeDataSource,
  )
  SupabaseRealtimeRemoteDataSource get realtimeRemoteDataSource;

  @LazySingleton(as: RealtimeRepository)
  RealtimeRepositoryImpl get realtimeRepository;

  // profile
  @LazySingleton(as: ProfileRemoteDataSource)
  SupabaseProfileRemoteDataSource get profileRemoteDataSource;

  @LazySingleton(as: ProfileRepository)
  ProfileRepositoryImpl get profileRepository;

  // search
  @LazySingleton(as: SearchRemoteDataSource)
  SupabaseSearchRemoteDataSource get searchRemoteDataSource;

  @LazySingleton(as: SearchRepository)
  SearchRepositoryImpl get searchRepository;

  // --- Domain Layer (UseCases) Registration (Injectable - factory) ---
  // auth
  @injectable
  SignupUseCase get signupUseCase;

  @injectable
  LoginUseCase get loginUseCase;

  @injectable
  LogoutUseCase get logoutUseCase;

  // post
  @injectable
  GetPostsUseCase get getPostsUseCase;

  @injectable
  CreatePostUseCase get createPostUseCase;

  @injectable
  UploadPostImageUseCase get uploadPostImageUseCase;

  @injectable
  GetPostDetailUseCase get getPostDetailUseCase;

  @injectable
  GetCommentsUseCase get getCommentsUseCase;

  @injectable
  ToggleLikeUseCase get toggleLikeUseCase;

  @injectable
  CreateCommentUseCase get createCommentUseCase;

  @injectable
  DeleteCommentUseCase get deleteCommentUseCase;

  @injectable
  UpdateCommentUseCase get updateCommentUseCase;

  @injectable
  DeletePostUseCase get deletePostUseCase;

  @injectable
  DeletePostFolderUseCase get deletePostFolderUseCase;

  @injectable
  UpdatePostUseCase get updatePostUseCase;

  // profile
  @injectable
  GetProfileUseCase get getProfileUseCase;

  @injectable
  UpdateProfileUseCase get upateProfileUseCase;

  @injectable
  GetMyPostsUseCase get getMyPostsUseCase;

  // search
  @injectable
  SearchPostsUseCase get searchPostsUseCase;

  @injectable
  SearchUsersUseCase get searchUsersUseCase;
}