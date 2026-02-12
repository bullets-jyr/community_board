// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_display_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentDisplayModel _$CommentDisplayModelFromJson(Map<String, dynamic> json) =>
    CommentDisplayModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorId: json['author_id'] as String,
      authorUsername: json['author_username'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
    );
