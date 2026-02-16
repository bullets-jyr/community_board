import 'package:core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/post_list/post_list_bloc.dart';
import '../widgets/post_card.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PostView();
  }
}

class PostView extends StatefulWidget {
  const PostView({super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostListBloc>().add(PostListNextPageFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: BlocConsumer<PostListBloc, PostListState>(
        listenWhen: (previous, current) {
          final isTransientFailure =
              previous.transientFailure == null &&
              current.transientFailure != null;

          final prevScrollEventId = previous.scrollToTopEventId;
          final currentScrollEventId = current.scrollToTopEventId;
          final isScrollToTopEvent =
              prevScrollEventId != currentScrollEventId &&
              currentScrollEventId != null;

          return isTransientFailure || isScrollToTopEvent;
        },
        listener: (context, state) {
          if (state.scrollToTopEventId != null) {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            context.read<PostListBloc>().add(PostListScrollEventConsumed());
          } else if (state.transientFailure != null) {
            showErrorSnackbar(
              context,
              message: state.transientFailure!.message,
            );
            context.read<PostListBloc>().add(
              PostListTransientFailureConsumed(),
            );
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case PostListStatus.initial:
            case PostListStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case PostListStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.failure?.message ?? 'Unknown error'}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          context.read<PostListBloc>().add(PostListFetched());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );

            case _:
              if (state.posts.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<PostListBloc>().add(PostListRefreshed());
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: const Center(
                            child: Text(
                              'There are no posts yet.\nLog in with an admin account to create your first post!',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostListBloc>().add(PostListRefreshed());
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.hasReachedMax
                      ? state.posts.length
                      : state.posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.posts.length) {
                      return (state.status == PostListStatus.fetchingNextPage)
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                    final post = state.posts[index];
                    return PostCard(
                      post: post,
                      onToggleLike: () {
                        context.read<PostListBloc>().add(
                          PostLikeToggled(post: post),
                        );
                      },
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
