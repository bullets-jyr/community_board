import 'package:cached_network_image/cached_network_image.dart';
import 'package:domain/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../auth/presentation/blocs/authentication/authentication_bloc.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onToggleLike});

  final PostDisplay post;
  final VoidCallback? onToggleLike;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select(
      (AuthenticationBloc bloc) => bloc.state.user?.id,
    );

    return InkWell(
      onTap: () {
        context.pushNamed(
          RouteNames.postDetail,
          pathParameters: {'postId': post.postId},
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (currentUserId != post.authorId) {
                    context.pushNamed(
                      RouteNames.userDetail,
                      pathParameters: {'userId': post.authorId},
                    );
                  }
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                      child: post.authorAvatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.white,
                            )
                          : ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: post.authorAvatarUrl!,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error_outline, size: 20),
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorUsername,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(post.postCreatedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(post.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),

              if (post.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    placeholder: (context, url) =>
                        Container(height: 180, color: Colors.grey[200]),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              Text(post.content, maxLines: 5, overflow: TextOverflow.ellipsis),
              const Divider(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onToggleLike,
                    icon: Icon(
                      post.currentUserLiked
                          ? Icons.thumb_up
                          : Icons.thumb_up_alt_outlined,
                      size: 18,
                      color: post.currentUserLiked
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(post.likesCount.toString()),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.comment_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(post.commentsCount.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
