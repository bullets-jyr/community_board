import 'package:domain/post.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_display_model.g.dart';

@JsonSerializable(createToJson: false)
class CommentDisplayModel extends CommentDisplay {
  const CommentDisplayModel({
    required super.id,
    required super.postId,
    required super.content,
    required super.createdAt,
    required super.authorId,
    required super.authorUsername,
    super.authorAvatarUrl,
  });

  factory CommentDisplayModel.fromJson(Map<String, dynamic> json) =>
      _$CommentDisplayModelFromJson(json);

  @JsonKey(name: 'post_id')
  @override
  String get postId;

  @JsonKey(name: 'created_at')
  @override
  DateTime get createdAt;

  @JsonKey(name: 'author_id')
  @override
  String get authorId;

  @JsonKey(name: 'author_username')
  @override
  String get authorUsername;

  @JsonKey(name: 'author_avatar_url')
  @override
  String? get authorAvatarUrl;
}
