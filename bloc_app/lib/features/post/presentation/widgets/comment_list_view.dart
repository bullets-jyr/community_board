import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/comment_list/comment_list_bloc.dart';
import 'comment_card.dart';

class CommentListView extends StatelessWidget {
  const CommentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentListBloc, CommentListState>(
      builder: (context, state) {
        switch (state.status) {
          case CommentListStatus.initial || CommentListStatus.loading:
            return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );

          case CommentListStatus.failure:
            return SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error: ${state.failure?.message ?? 'Unknown error'}',
                  ),
                ),
              ),
            );

          case _:
            if (state.comments.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No comments yet')),
                ),
              );
            }
            return SliverList.builder(
              itemCount: state.hasReachedMax
                  ? state.comments.length
                  : state.comments.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.comments.length) {
                  return state.status == CommentListStatus.fetchingNextPage
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox.shrink();
                }
                return CommentCard(comment: state.comments[index]);
              },
            );
        }
      },
    );
  }
}
