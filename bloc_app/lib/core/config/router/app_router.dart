import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/blocs/authentication/authentication_bloc.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/signup_page.dart';
import '../../../features/post/presentation/pages/post_detail_page.dart';
import '../../../features/post/presentation/pages/post_form_page.dart';
import '../../../features/post/presentation/pages/post_page.dart';
import '../../../features/profile/presentation/blocs/profile/profile_bloc.dart';
import '../../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../../features/profile/presentation/pages/my_profile_page.dart';
import '../../../features/profile/presentation/pages/user_profile_page.dart';
import '../../../features/search/presentation/pages/search_page.dart';
import '../../../features/splash/presentation/pages/splash_page.dart';
import '../../widgets/error_page.dart';
import '../../widgets/scaffold_with_nav_bar.dart';
import 'go_router_refresh_stream.dart';
import 'route_constants.dart';

GoRouter createRouter(AuthenticationBloc authBloc) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authBloc.state.status;
      final String location = state.matchedLocation;

      final isSplash = location == RoutePaths.splash;
      final isAuthRoute =
          location == RoutePaths.login || location == RoutePaths.signup;

      if (authStatus == AuthenticationStatus.unknown) {
        return isSplash ? null : RoutePaths.splash;
      }

      if (authStatus == AuthenticationStatus.authenticated) {
        if (isSplash || isAuthRoute) return RoutePaths.post;
      } else {
        if (!isAuthRoute) return RoutePaths.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: RouteNames.signup,
        builder: (BuildContext context, GoRouterState state) {
          return const SignupPage();
        },
      ),
      GoRoute(
        path: RoutePaths.postCreate,
        name: RouteNames.postCreate,
        builder: (BuildContext context, GoRouterState state) {
          return const PostFormPage();
        },
      ),
      GoRoute(
        path: RoutePaths.userDetail,
        name: RouteNames.userDetail,
        builder: (BuildContext context, GoRouterState state) {
          final userId = state.pathParameters['userId']!;
          return UserProfilePage(userId: userId);
        },
      ),
      GoRoute(
        path: RoutePaths.postDetail,
        name: RouteNames.postDetail,
        builder: (BuildContext context, GoRouterState state) {
          final postId = state.pathParameters['postId']!;
          return PostDetailPage(postId: postId);
        },
        routes: [
          GoRoute(
            path: RoutePaths.postEdit,
            name: RouteNames.postEdit,
            builder: (BuildContext context, GoRouterState state) {
              final postId = state.pathParameters['postId'];
              return PostFormPage(postId: postId);
            },
          ),
        ],
      ),

      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return ScaffoldWithNavBar(navigationShell: navigationShell);
            },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.post,
                name: RouteNames.post,
                builder: (BuildContext context, GoRouterState state) {
                  return const PostPage();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.search,
                name: RouteNames.search,
                builder: (BuildContext context, GoRouterState state) {
                  return const SearchPage();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (BuildContext context, GoRouterState state) {
                  return const MyProfilePage();
                },
                routes: [
                  GoRoute(
                    path: RoutePaths.profileEdit,
                    name: RouteNames.profileEdit,
                    builder: (BuildContext context, GoRouterState state) {
                      final profileBloc = state.extra as ProfileBloc;
                      return BlocProvider.value(
                        value: profileBloc,
                        child: const EditProfilePage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return ErrorPage(error: state.error);
    },
  );
}
