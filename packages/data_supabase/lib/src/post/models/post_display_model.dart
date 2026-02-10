import 'package:domain/post.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_display_model.g.dart';

@JsonSerializable(createToJson: false)
class PostDisplayModel extends PostDisplay {
  const PostDisplayModel({
    required super.postId,
    required super.title,
    required super.content,
    super.imageUrl,
    required super.postCreatedAt,
    required super.postUpdatedAt,
    required super.authorId,
    required super.authorUsername,
    super.authorAvatarUrl,
    required super.authorRole,
    required super.likesCount,
    required super.commentsCount,
    required super.currentUserLiked,
  });

  factory PostDisplayModel.fromJson(Map<String, dynamic> json) =>
      _$PostDisplayModelFromJson(json);

  @JsonKey(name: 'post_id')
  @override
  String get postId;

  @JsonKey(name: 'image_url')
  @override
  String? get imageUrl;

  @JsonKey(name: 'post_created_at')
  @override
  DateTime get postCreatedAt;

  @JsonKey(name: 'post_updated_at')
  @override
  DateTime get postUpdatedAt;

  @JsonKey(name: 'author_id')
  @override
  String get authorId;

  @JsonKey(name: 'author_username')
  @override
  String get authorUsername;

  @JsonKey(name: 'author_avatar_url')
  @override
  String? get authorAvatarUrl;

  @JsonKey(name: 'author_role')
  @override
  String get authorRole;

  @JsonKey(name: 'likes_count')
  @override
  int get likesCount;

  @JsonKey(name: 'comments_count')
  @override
  int get commentsCount;

  @JsonKey(name: 'current_user_liked')
  @override
  bool get currentUserLiked;
}