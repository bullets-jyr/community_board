import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../../core/di/di.dart';
import '../../../auth/presentation/blocs/authentication/authentication_bloc.dart';
import '../../../post/presentation/widgets/post_card.dart';
import '../blocs/search/search_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SearchBloc>(),
      child: const SearchView(),
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabListener);
    _searchController.addListener(_searchListener);
  }

  void _tabListener() {
    if (_tabController.indexIsChanging) {
      context.read<SearchBloc>().add(
        SearchTabChanged(tabIndex: _tabController.index),
      );
    }
  }

  void _searchListener() {
    context.read<SearchBloc>().add(
      SearchQueryChanged(query: _searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchListener);
    _tabController.removeListener(_tabListener);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
      listenWhen: (previous, current) {
        final prevTransientFailure = previous.transientFailure;
        final currentTransientFailure = current.transientFailure;
        final isTransientFailure =
            prevTransientFailure == null && currentTransientFailure != null;

        return isTransientFailure;
      },
      listener: (context, state) {
        showErrorSnackbar(
          context,
          message: state.transientFailure?.message ?? 'Unknown error',
        );
        context.read<SearchBloc>().add(SearchTransientFailureConsumed());
      },
      builder: (context, state) {
        final isLoading =
            state.status == SearchStatus.loadingUsers ||
            state.status == SearchStatus.loadingPosts;

        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search users or posts...',
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.clear, size: 20),
                      )
                    : null,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kTextTabBarHeight + 3),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Users'),
                      Tab(text: 'Posts'),
                    ],
                  ),
                  SizedBox(
                    height: 3,
                    child: isLoading ? const LinearProgressIndicator() : null,
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildUserResultsTab(context, state),
              _buildPostResultsTab(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserResultsTab(BuildContext context, SearchState state) {
    if (state.status == SearchStatus.loadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == SearchStatus.failure) {
      return Center(child: Text('Failed to search: ${state.failure?.message}'));
    }

    if (state.query.trim().isEmpty) {
      return const Center(child: Text('Search for users by their username.'));
    }

    if (state.users.isEmpty && state.status == SearchStatus.loaded) {
      return Center(child: Text('No users found for "${state.query}"'));
    }

    final currentUserId = context.select(
      (AuthenticationBloc bloc) => bloc.state.user?.id,
    );

    return ListView.builder(
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? CachedNetworkImageProvider(user.avatarUrl!)
                : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(user.username),
          onTap: () {
            if (currentUserId != user.id) {
              context.pushNamed(
                RouteNames.userDetail,
                pathParameters: {'userId': user.id},
              );
            }
          },
        );
      },
    );
  }

  Widget _buildPostResultsTab(BuildContext context, SearchState state) {
    if (state.status == SearchStatus.loadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == SearchStatus.failure) {
      return Center(child: Text('Failed to search: ${state.failure?.message}'));
    }

    final query = state.query.trim();

    if (query.isEmpty || query.length < 2) {
      return const Center(
        child: Text('Enter at least 2 characters to search for posts.'),
      );
    }

    if (state.posts.isEmpty && state.status == SearchStatus.loaded) {
      return Center(child: Text('No posts found for "${state.query}".'));
    }

    return ListView.builder(
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return PostCard(
          post: post,
          onToggleLike: () {
            context.read<SearchBloc>().add(SearchPostLikeToggled(post: post));
          },
        );
      },
    );
  }
}
