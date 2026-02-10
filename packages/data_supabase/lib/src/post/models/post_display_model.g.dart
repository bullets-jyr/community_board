// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_display_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDisplayModel _$PostDisplayModelFromJson(Map<String, dynamic> json) =>
    PostDisplayModel(
      postId: json['post_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      postCreatedAt: DateTime.parse(json['post_created_at'] as String),
      postUpdatedAt: DateTime.parse(json['post_updated_at'] as String),
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      authorRole: json['author_role'] as String,
      likesCount: (json['likes_count'] as num).toInt(),
      commentsCount: (json['comments_count'] as num).toInt(),
      currentUserLiked: json['current_user_liked'] as bool,
    );
