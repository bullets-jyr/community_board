import '../../auth/models/user_model.dart';
import '../../post/models/post_display_model.dart';

abstract interface class SearchRemoteDataSource {
  Future<List<PostDisplayModel>> searchPosts({required String query});

  Future<List<UserModel>> searchUsers({required String query});
}
