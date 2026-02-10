abstract class RoutePaths {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';

  static const String post = '/post';
  static const String search = '/search';
  static const String profile = '/profile';

  // sub-routes
  // /post-detail/:postId/edit
  static const String postEdit = 'edit';

  // /profile/edit
  static const String profileEdit = 'edit';

  static const String postCreate = '/create';
  static const String userDetail = '/user/:userId';
  static const String postDetail = '/post-detail/:postId';
}

abstract class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';

  static const String post = 'post';
  static const String search = 'search';
  static const String profile = 'profile';

  static const String postDetail = 'postDetail';
  static const String postEdit = 'postEdit';
  static const String profileEdit = 'profileEdit';
  static const String postCreate = 'postCreate';
  static const String userDetail = 'userDetail';
}