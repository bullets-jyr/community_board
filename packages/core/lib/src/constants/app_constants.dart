abstract class Roles {
  static const String admin = 'admin';
  static const String user = 'user';
}

abstract class Tables {
  static const String posts = 'posts';
  static const String comments = 'comments';
  static const String profiles = 'profiles';
  static const String likes = 'likes';
}

abstract class Views {
  static const String postDisplayView = 'post_display_view';
  static const String commentDisplayView = 'comment_display_view';
}

abstract class Storage {
  static const String postImages = 'post-images';
  static const String avatars = 'avatars';
}

abstract class DBFunctions {
  static const String getMyPosts = 'get_my_posts';
  static const String handleLike = 'handle_like';
  static const String searchPosts = 'search_posts';
  static const String updateUserProfile = 'update_user_profile';
  static const String createPostAndReturnPostDisplayView =
      'create_post_and_return_post_display_view';
  static const String updatePostAndReturnPostDisplayView =
      'update_post_and_return_post_display_view';
  static const String createCommentAndReturnCommentDisplayView =
      'create_comment_and_return_comment_display_view';
  static const String updateCommentAndReturnCommentDisplayView =
      'update_comment_and_return_comment_display_view';
}

abstract class PostgresErrors {
  static const String insufficientPrivilege = '42501';
  static const String moreThanOneOrNoItemsReturned = 'PGRST116';
}