// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:data_supabase/auth.dart' as _i561;
import 'package:data_supabase/post.dart' as _i816;
import 'package:data_supabase/profile.dart' as _i661;
import 'package:data_supabase/search.dart' as _i66;
import 'package:domain/auth.dart' as _i378;
import 'package:domain/post.dart' as _i456;
import 'package:domain/profile.dart' as _i503;
import 'package:domain/search.dart' as _i93;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/auth/presentation/blocs/authentication/authentication_bloc.dart'
    as _i652;
import '../../features/auth/presentation/blocs/login/login_bloc.dart' as _i1018;
import '../../features/auth/presentation/blocs/signup/signup_bloc.dart' as _i41;
import '../../features/post/presentation/blocs/comment_list/comment_list_bloc.dart'
    as _i1009;
import '../../features/post/presentation/blocs/my_post_list/my_post_list_bloc.dart'
    as _i146;
import '../../features/post/presentation/blocs/post_detail/post_detail_bloc.dart'
    as _i169;
import '../../features/post/presentation/blocs/post_form/post_form_bloc.dart'
    as _i79;
import '../../features/post/presentation/blocs/post_list/post_list_bloc.dart'
    as _i409;
import '../../features/profile/presentation/blocs/edit_profile/edit_profile_bloc.dart'
    as _i1033;
import '../../features/profile/presentation/blocs/profile/profile_bloc.dart'
    as _i349;
import '../../features/profile/presentation/blocs/user_profile/user_profile_bloc.dart'
    as _i634;
import '../../features/search/presentation/blocs/search/search_bloc.dart'
    as _i608;
import '../blocs/realtime/realtime_bloc.dart' as _i743;
import '../bus/global_event_bus.dart' as _i91;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule(this);
    gh.singleton<_i91.GlobalEventBus>(
      () => _i91.GlobalEventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i561.AuthRemoteDataSource>(
      () => registerModule.authRemoteDataSource,
    );
    gh.lazySingleton<_i816.RealtimeRemoteDataSource>(
      () => registerModule.realtimeRemoteDataSource,
      dispose: _i291.disposeRealtimeDataSource,
    );
    gh.lazySingleton<_i816.PostRemoteDataSource>(
      () => registerModule.postRemoteDataSource,
    );
    gh.lazySingleton<_i378.AuthRepository>(() => registerModule.authRepository);
    gh.lazySingleton<_i66.SearchRemoteDataSource>(
      () => registerModule.searchRemoteDataSource,
    );
    gh.lazySingleton<_i661.ProfileRemoteDataSource>(
      () => registerModule.profileRemoteDataSource,
    );
    gh.lazySingleton<_i456.PostRepository>(() => registerModule.postRepository);
    gh.factory<_i378.SignupUseCase>(() => registerModule.signupUseCase);
    gh.factory<_i378.LoginUseCase>(() => registerModule.loginUseCase);
    gh.factory<_i378.LogoutUseCase>(() => registerModule.logoutUseCase);
    gh.lazySingleton<_i456.RealtimeRepository>(
      () => registerModule.realtimeRepository,
    );
    gh.factory<_i41.SignupBloc>(
      () => _i41.SignupBloc(signupUseCase: gh<_i378.SignupUseCase>()),
    );
    gh.singleton<_i652.AuthenticationBloc>(
      () => _i652.AuthenticationBloc(
        authRepository: gh<_i378.AuthRepository>(),
        logoutUseCase: gh<_i378.LogoutUseCase>(),
      ),
      dispose: (i) => i.close(),
    );
    gh.factory<_i743.RealtimeBloc>(
      () => _i743.RealtimeBloc(
        realtimeRepository: gh<_i456.RealtimeRepository>(),
      ),
    );
    gh.factory<_i1018.LoginBloc>(
      () => _i1018.LoginBloc(loginUseCase: gh<_i378.LoginUseCase>()),
    );
    gh.lazySingleton<_i93.SearchRepository>(
      () => registerModule.searchRepository,
    );
    gh.factory<_i456.GetPostsUseCase>(() => registerModule.getPostsUseCase);
    gh.factory<_i456.CreatePostUseCase>(() => registerModule.createPostUseCase);
    gh.factory<_i456.UploadPostImageUseCase>(
      () => registerModule.uploadPostImageUseCase,
    );
    gh.factory<_i456.GetPostDetailUseCase>(
      () => registerModule.getPostDetailUseCase,
    );
    gh.factory<_i456.GetCommentsUseCase>(
      () => registerModule.getCommentsUseCase,
    );
    gh.factory<_i456.ToggleLikeUseCase>(() => registerModule.toggleLikeUseCase);
    gh.factory<_i456.CreateCommentUseCase>(
      () => registerModule.createCommentUseCase,
    );
    gh.factory<_i456.DeleteCommentUseCase>(
      () => registerModule.deleteCommentUseCase,
    );
    gh.factory<_i456.UpdateCommentUseCase>(
      () => registerModule.updateCommentUseCase,
    );
    gh.factory<_i456.DeletePostUseCase>(() => registerModule.deletePostUseCase);
    gh.factory<_i456.DeletePostFolderUseCase>(
      () => registerModule.deletePostFolderUseCase,
    );
    gh.factory<_i456.UpdatePostUseCase>(() => registerModule.updatePostUseCase);
    gh.factory<_i456.GetMyPostsUseCase>(() => registerModule.getMyPostsUseCase);
    gh.lazySingleton<_i503.ProfileRepository>(
      () => registerModule.profileRepository,
    );
    gh.factory<_i79.PostFormBloc>(
      () => _i79.PostFormBloc(
        createPostUseCase: gh<_i456.CreatePostUseCase>(),
        uploadPostImageUseCase: gh<_i456.UploadPostImageUseCase>(),
        updatePostUseCase: gh<_i456.UpdatePostUseCase>(),
        getPostDetailUseCase: gh<_i456.GetPostDetailUseCase>(),
        globalEventBus: gh<_i91.GlobalEventBus>(),
      ),
    );
    gh.factory<_i409.PostListBloc>(
      () => _i409.PostListBloc(
        getPostsUseCase: gh<_i456.GetPostsUseCase>(),
        toggleLikeUseCase: gh<_i456.ToggleLikeUseCase>(),
        globalEventBus: gh<_i91.GlobalEventBus>(),
      ),
    );
    gh.factory<_i1009.CommentListBloc>(
      () => _i1009.CommentListBloc(
        getCommentsUseCase: gh<_i456.GetCommentsUseCase>(),
        createCommentUseCase: gh<_i456.CreateCommentUseCase>(),
        deleteCommentUseCase: gh<_i456.DeleteCommentUseCase>(),
        updateCommentUseCase: gh<_i456.UpdateCommentUseCase>(),
        getPostDetailUseCase: gh<_i456.GetPostDetailUseCase>(),
        globalEventBus: gh<_i91.GlobalEventBus>(),
      ),
    );
    gh.singleton<_i583.GoRouter>(
      () => registerModule.router(gh<_i652.AuthenticationBloc>()),
    );
    gh.factory<_i169.PostDetailBloc>(
      () => _i169.PostDetailBloc(
        getPostDetailUseCase: gh<_i456.GetPostDetailUseCase>(),
        toggleLikeUseCase: gh<_i456.ToggleLikeUseCase>(),
        deletePostUseCase: gh<_i456.DeletePostUseCase>(),
        deletePostFolderUseCase: gh<_i456.DeletePostFolderUseCase>(),
        globalEventBus: gh<_i91.GlobalEventBus>(),
      ),
    );
    gh.factory<_i93.SearchPostsUseCase>(
      () => registerModule.searchPostsUseCase,
    );
    gh.factory<_i93.SearchUsersUseCase>(
      () => registerModule.searchUsersUseCase,
    );
    gh.factory<_i146.MyPostListBloc>(
      () => _i146.MyPostListBloc(
        getMyPostsUseCase: gh<_i456.GetMyPostsUseCase>(),
        toggleLikeUseCase: gh<_i456.ToggleLikeUseCase>(),
        globalEventBus: gh<_i91.GlobalEventBus>(),
      ),
    );
    gh.factory<_i503.GetProfileUseCase>(() => registerModule.getProfileUseCase);
    gh.factory<_i503.UpdateProfileUseCase>(
      () => registerModule.upateProfileUseCase,
    );
    gh.factory<_i634.UserProfileBloc>(
      () => _i634.UserProfileBloc(
        getProfileUseCase: gh<_i503.GetProfileUseCase>(),
      ),
    );
    gh.factory<_i608.SearchBloc>(
      () => _i608.SearchBloc(
        searchUsersUseCase: gh<_i93.SearchUsersUseCase>(),
        searchPostsUseCase: gh<_i93.SearchPostsUseCase>(),
        toggleLikeUseCase: gh<_i456.ToggleLikeUseCase>(),
        globalEventBus: gh<_i91.GlobalEventBus>(),
      ),
    );
    gh.factory<_i349.ProfileBloc>(
      () => _i349.ProfileBloc(
        getProfileUseCase: gh<_i503.GetProfileUseCase>(),
        authenticationBloc: gh<_i652.AuthenticationBloc>(),
      ),
    );
    gh.factory<_i1033.EditProfileBloc>(
      () => _i1033.EditProfileBloc(
        updateProfileUseCase: gh<_i503.UpdateProfileUseCase>(),
        globalEventBus: gh<_i91.GlobalEventBus>(),
      ),
    );
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
  _i816.SupabaseRealtimeRemoteDataSource get realtimeRemoteDataSource =>
      _i816.SupabaseRealtimeRemoteDataSource(
        supabaseClient: _getIt<_i454.SupabaseClient>(),
      );

  @override
  _i816.SupabasePostRemoteDataSource get postRemoteDataSource =>
      _i816.SupabasePostRemoteDataSource(
        supabaseClient: _getIt<_i454.SupabaseClient>(),
      );

  @override
  _i561.AuthRepositoryImpl get authRepository => _i561.AuthRepositoryImpl(
    authRemoteDataSource: _getIt<_i561.AuthRemoteDataSource>(),
  );

  @override
  _i66.SupabaseSearchRemoteDataSource get searchRemoteDataSource =>
      _i66.SupabaseSearchRemoteDataSource(
        supabaseClient: _getIt<_i454.SupabaseClient>(),
      );

  @override
  _i661.SupabaseProfileRemoteDataSource get profileRemoteDataSource =>
      _i661.SupabaseProfileRemoteDataSource(
        supabaseClient: _getIt<_i454.SupabaseClient>(),
      );

  @override
  _i816.PostRepositoryImpl get postRepository => _i816.PostRepositoryImpl(
    postRemoteDataSource: _getIt<_i816.PostRemoteDataSource>(),
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

  @override
  _i816.RealtimeRepositoryImpl get realtimeRepository =>
      _i816.RealtimeRepositoryImpl(
        realtimeRemoteDataSource: _getIt<_i816.RealtimeRemoteDataSource>(),
        postRemoteDataSource: _getIt<_i816.PostRemoteDataSource>(),
      );

  @override
  _i66.SearchRepositoryImpl get searchRepository => _i66.SearchRepositoryImpl(
    searchRemoteDataSource: _getIt<_i66.SearchRemoteDataSource>(),
  );

  @override
  _i456.GetPostsUseCase get getPostsUseCase =>
      _i456.GetPostsUseCase(postRepository: _getIt<_i456.PostRepository>());

  @override
  _i456.CreatePostUseCase get createPostUseCase =>
      _i456.CreatePostUseCase(postRepository: _getIt<_i456.PostRepository>());

  @override
  _i456.UploadPostImageUseCase get uploadPostImageUseCase =>
      _i456.UploadPostImageUseCase(
        postRepository: _getIt<_i456.PostRepository>(),
      );

  @override
  _i456.GetPostDetailUseCase get getPostDetailUseCase =>
      _i456.GetPostDetailUseCase(
        postRepository: _getIt<_i456.PostRepository>(),
      );

  @override
  _i456.GetCommentsUseCase get getCommentsUseCase =>
      _i456.GetCommentsUseCase(postRepository: _getIt<_i456.PostRepository>());

  @override
  _i456.ToggleLikeUseCase get toggleLikeUseCase =>
      _i456.ToggleLikeUseCase(postRepository: _getIt<_i456.PostRepository>());

  @override
  _i456.CreateCommentUseCase get createCommentUseCase =>
      _i456.CreateCommentUseCase(
        postRepository: _getIt<_i456.PostRepository>(),
      );

  @override
  _i456.DeleteCommentUseCase get deleteCommentUseCase =>
      _i456.DeleteCommentUseCase(
        postRepository: _getIt<_i456.PostRepository>(),
      );

  @override
  _i456.UpdateCommentUseCase get updateCommentUseCase =>
      _i456.UpdateCommentUseCase(
        postRepository: _getIt<_i456.PostRepository>(),
      );

  @override
  _i456.DeletePostUseCase get deletePostUseCase =>
      _i456.DeletePostUseCase(postRepository: _getIt<_i456.PostRepository>());

  @override
  _i456.DeletePostFolderUseCase get deletePostFolderUseCase =>
      _i456.DeletePostFolderUseCase(
        postRepository: _getIt<_i456.PostRepository>(),
      );

  @override
  _i456.UpdatePostUseCase get updatePostUseCase =>
      _i456.UpdatePostUseCase(postRepository: _getIt<_i456.PostRepository>());

  @override
  _i456.GetMyPostsUseCase get getMyPostsUseCase =>
      _i456.GetMyPostsUseCase(postRepository: _getIt<_i456.PostRepository>());

  @override
  _i661.ProfileRepositoryImpl get profileRepository =>
      _i661.ProfileRepositoryImpl(
        profileRemoteDataSource: _getIt<_i661.ProfileRemoteDataSource>(),
      );

  @override
  _i93.SearchPostsUseCase get searchPostsUseCase => _i93.SearchPostsUseCase(
    searchRepository: _getIt<_i93.SearchRepository>(),
  );

  @override
  _i93.SearchUsersUseCase get searchUsersUseCase => _i93.SearchUsersUseCase(
    searchRepository: _getIt<_i93.SearchRepository>(),
  );

  @override
  _i503.GetProfileUseCase get getProfileUseCase => _i503.GetProfileUseCase(
    profileRepository: _getIt<_i503.ProfileRepository>(),
  );

  @override
  _i503.UpdateProfileUseCase get upateProfileUseCase =>
      _i503.UpdateProfileUseCase(
        profileRepository: _getIt<_i503.ProfileRepository>(),
      );
}
