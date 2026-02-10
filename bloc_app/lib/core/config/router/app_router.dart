import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/blocs/authentication/authentication_bloc.dart';
import 'go_router_refresh_stream.dart';
import 'route_constants.dart';

GoRouter createRouter(AuthenticationBloc authBloc) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authBloc.state.status;
      // 사용자가 가려고 하는 경로
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

      // 요청받은 페이지 표시
      return null;
    },
    routes: [],
  );
}
