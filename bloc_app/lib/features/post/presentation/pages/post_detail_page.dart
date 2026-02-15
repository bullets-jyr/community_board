import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/constants.dart';
import 'package:core/utils.dart';
import 'package:domain/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../../core/di/di.dart';
import '../../../auth/presentation/blocs/authentication/authentication_bloc.dart';
import '../blocs/comment_list/comment_list_bloc.dart';
import '../blocs/post_detail/post_detail_bloc.dart';
import '../widgets/comment_input_field.dart';
import '../widgets/comment_list_view.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<PostDetailBloc>()..add(PostDetailFetched(postId: postId)),
        ),
        BlocProvider(
          create: (context) =>
              getIt<CommentListBloc>()..add(CommentListFetched(postId: postId)),
        ),
      ],
      child: BlocListener<PostDetailBloc, PostDetailState>(
        listenWhen: (previous, current) {
          final didDelete =
              !previous.deletionSuccess && current.deletionSuccess;
          final didFail =
              previous.transientFailure == null &&
              current.transientFailure != null;

          return didDelete || didFail;
        },
        listener: (context, state) {
          if (state.deletionSuccess) {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) navigator.pop();
            if (navigator.canPop()) navigator.pop();
            return;
          }

          if (state.transientFailure != null) {
            showErrorSnackbar(
              context,
              message: state.transientFailure!.message,
            );
            context.read<PostDetailBloc>().add(
              PostDetailTransientFailureConsumed(),
            );
          }
        },
        child: PostDetailView(postId: postId),
      ),
    );
  }
}

class PostDetailView extends StatefulWidget {
  const PostDetailView({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
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
      context.read<CommentListBloc>().add(
        CommentListNextPageFetched(postId: widget.postId),
      );
    }
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final postDetailBloc = context.read<PostDetailBloc>();

    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: postDetailBloc,
          child: BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              final isSubmitting = state.status == PostDetailStatus.submitting;

              return PopScope(
                canPop: !isSubmitting,
                child: AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text(
                    'Are you sure you want to delete this post?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              postDetailBloc.add(const PostDeleted());
                            },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      barrierDismissible:
          postDetailBloc.state.status != PostDetailStatus.submitting,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );
    final currentUserRole = currentUser?.role;

    return BlocBuilder<PostDetailBloc, PostDetailState>(
      builder: (context, state) {
        switch (state.status) {
          case PostDetailStatus.initial || PostDetailStatus.loading:
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );

          case PostDetailStatus.failure:
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'Error: ${state.failure?.message ?? 'Unknown error'}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );

          case _:
            final post = state.post!;
            final canModify =
                (currentUser?.id == post.authorId) &&
                (currentUserRole == Roles.admin);

            return Scaffold(
              appBar: AppBar(
                title: Text(post.title, style: const TextStyle(fontSize: 18)),
                actions: [
                  if (canModify)
                    IconButton(
                      onPressed: () {
                        context.pushNamed(
                          RouteNames.postEdit,
                          pathParameters: {'postId': post.postId},
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Post',
                    ),
                  if (canModify)
                    IconButton(
                      onPressed: () {
                        _showDeleteConfirmDialog(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete Post',
                    ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(child: _buildContent(context, post)),
                  CommentInputField(
                    postId: widget.postId,
                    scrollController: _scrollController,
                  ),
                ],
              ),
            );
        }
      },
    );
  }

  Widget _buildContent(BuildContext context, PostDisplay post) {
    return BlocListener<CommentListBloc, CommentListState>(
      listenWhen: (p, c) {
        final prevTransientFailure = p.transientFailure;
        final currentTransientFailure = c.transientFailure;
        final isTransientFailure =
            prevTransientFailure == null && currentTransientFailure != null;

        return isTransientFailure;
      },
      listener: (context, state) {
        showErrorSnackbar(context, message: state.transientFailure!.message);
        context.read<CommentListBloc>().add(
          CommentListTransientFailureConsumed(),
        );
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<PostDetailBloc>().add(
            PostDetailFetched(postId: widget.postId),
          );
          context.read<CommentListBloc>().add(
            CommentListRefreshed(postId: widget.postId),
          );
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildPostDetail(context, post)),
            const SliverToBoxAdapter(child: Divider(height: 1)),
            const SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: CommentListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostDetail(BuildContext context, PostDisplay post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  final currentUserId = context
                      .read<AuthenticationBloc>()
                      .state
                      .user
                      ?.id;
                  if (currentUserId != post.authorId) {
                    context.pushNamed(
                      RouteNames.userDetail,
                      pathParameters: {'userId': post.authorId},
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade300,
                  child: post.authorAvatarUrl == null
                      ? const Icon(Icons.person, size: 22, color: Colors.white)
                      : ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: post.authorAvatarUrl!,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(strokeWidth: 2),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error_outline, size: 22),
                            fit: BoxFit.cover,
                            width: 44,
                            height: 44,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorUsername),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(post.postCreatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                placeholder: (context, url) => AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: Colors.grey.shade200),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.image_not_supported_outlined),
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 24),
          Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),

          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.read<PostDetailBloc>().add(
                    const PostDetailLikeToggled(),
                  );
                },
                icon: Icon(
                  post.currentUserLiked
                      ? Icons.thumb_up
                      : Icons.thumb_up_alt_outlined,
                  color: post.currentUserLiked
                      ? Theme.of(context).primaryColor
                      : null,
                ),
              ),
              Text(post.likesCount.toString()),
              const SizedBox(width: 16),
              const Icon(Icons.mode_comment_outlined, size: 24),
              const SizedBox(width: 12),
              Text(post.commentsCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}
