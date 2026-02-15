import 'package:cached_network_image/cached_network_image.dart';
import 'package:domain/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../auth/presentation/blocs/authentication/authentication_bloc.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment});

  final CommentDisplay comment;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthenticationBloc>().state.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (currentUser?.id != comment.authorId) {
                context.pushNamed(
                  RouteNames.userDetail,
                  pathParameters: {'userId': comment.authorId},
                );
              }
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              child: comment.authorAvatarUrl == null
                  ? const Icon(Icons.person, size: 18, color: Colors.white)
                  : ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: comment.authorAvatarUrl!,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(strokeWidth: 2),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error_outline, size: 18),
                        fit: BoxFit.cover,
                        width: 36,
                        height: 36,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorUsername,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MM-dd HH:mm').format(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Text(comment.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
