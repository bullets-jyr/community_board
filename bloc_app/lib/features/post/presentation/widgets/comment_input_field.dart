import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/comment_list/comment_list_bloc.dart';

class CommentInputField extends StatefulWidget {
  const CommentInputField({
    super.key,
    required this.postId,
    required this.scrollController,
  });

  final String postId;
  final ScrollController scrollController;

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    context.read<CommentListBloc>().add(
      CommentAdded(postId: widget.postId, content: content),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) widget.scrollController.jumpTo(0);
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CommentListBloc, CommentListState, bool>(
      selector: (state) {
        return state.status == CommentListStatus.submitting;
      },
      builder: (context, isSubmitting) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                    ),
                    enabled: !isSubmitting,
                    onSubmitted: isSubmitting ? null : (_) => _submitComment(),
                  ),
                ),
                isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : IconButton(
                        onPressed: _submitComment,
                        icon: const Icon(Icons.send),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
