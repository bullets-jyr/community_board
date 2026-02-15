import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/constants.dart';
import 'package:domain/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../auth/presentation/blocs/authentication/authentication_bloc.dart';
import '../blocs/comment_list/comment_list_bloc.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment});

  final CommentDisplay comment;

  void _showEditCommentDialog(BuildContext context) {
    final commentListBloc = context.read<CommentListBloc>();

    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: commentListBloc,
          child: _EditCommentDialog(comment: comment),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthenticationBloc>().state.user;
    final currentUserRole = currentUser?.role;

    final bool canEdit = currentUser?.id == comment.authorId;
    final bool canDelete = canEdit || (currentUserRole == Roles.admin);

    return BlocSelector<CommentListBloc, CommentListState, bool>(
      selector: (state) {
        return state.submittingCommentId == comment.id;
      },
      builder: (context, isSubmitting) {
        if (isSubmitting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

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

              if (canEdit)
                IconButton(
                  onPressed: () => _showEditCommentDialog(context),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit Comment',
                ),

              if (canDelete)
                IconButton(
                  onPressed: () async {
                    final commentListBloc = context.read<CommentListBloc>();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                          'Are you sure you want to delete this comment?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      commentListBloc.add(
                        CommentDeleted(
                          postId: comment.postId,
                          commentId: comment.id,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Delete Comment',
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EditCommentDialog extends StatefulWidget {
  const _EditCommentDialog({required this.comment});

  final CommentDisplay comment;

  @override
  State<_EditCommentDialog> createState() => __EditCommentDialogState();
}

class __EditCommentDialogState extends State<_EditCommentDialog> {
  late final TextEditingController _textController;
  bool _isSaveEnabled = true;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.comment.content);
    _textController.addListener(_updateSaveButtonState);
  }

  void _updateSaveButtonState() {
    final isNotEmpty = _textController.text.trim().isNotEmpty;
    final isChanged = _textController.text != widget.comment.content;
    if (mounted) {
      setState(() {
        _isSaveEnabled = isNotEmpty && isChanged;
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_updateSaveButtonState);
    _textController.dispose();
    super.dispose();
  }

  void _submit(bool isSubmitting) {
    if (!_isSaveEnabled || isSubmitting) return;

    final newContent = _textController.text.trim();

    context.read<CommentListBloc>().add(
      CommentEdited(commentId: widget.comment.id, newContent: newContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentListBloc, CommentListState>(
      listener: (context, state) {
        final wasSubmitting = state.submittingCommentId == widget.comment.id;
        if (!wasSubmitting && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: BlocSelector<CommentListBloc, CommentListState, bool>(
        selector: (state) {
          return state.submittingCommentId == widget.comment.id;
        },
        builder: (context, isSubmitting) {
          return AlertDialog(
            title: const Text('Edit Comment'),
            content: TextField(
              controller: _textController,
              autofocus: true,
              maxLines: null,
              enabled: !isSubmitting,
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    isSubmitting ? null : Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _isSaveEnabled && !isSubmitting
                    ? () => _submit(isSubmitting)
                    : null,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
