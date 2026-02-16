import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/my_post_list/my_post_list_bloc.dart';
import 'post_card.dart';

class MyPostList extends StatelessWidget {
  const MyPostList({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyPostListBloc, MyPostListState>(
      builder: (context, state) {
        return switch (state.status) {
          MyPostListStatus.initial || MyPostListStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MyPostListStatus.failure => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error: ${state.failure?.message ?? 'Unknown error'}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _ => _buildList(context, state),
        };
      },
    );
  }

  Widget _buildList(BuildContext context, MyPostListState state) {
    if (state.posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('No posts yet!'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.hasReachedMax
          ? state.posts.length
          : state.posts.length + 1,
      itemBuilder: (context, index) {
        if (index >= state.posts.length) {
          return state.status == MyPostListStatus.fetchingNextPage
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }

        final post = state.posts[index];
        return PostCard(
          post: post,
          onToggleLike: () {
            context.read<MyPostListBloc>().add(MyPostLikeToggled(post: post));
          },
        );
      },
    );
  }
}
