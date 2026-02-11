import 'package:equatable/equatable.dart';

class CommentDisplay extends Equatable {
  const CommentDisplay({
    required this.id,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.authorId,
    required this.authorUsername,
    this.authorAvatarUrl,
  });

  final String id;
  final String postId;
  final String content;
  final DateTime createdAt;
  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;

  @override
  List<Object?> get props {
    return [
      id,
      postId,
      content,
      createdAt,
      authorId,
      authorUsername,
      authorAvatarUrl,
    ];
  }
}
