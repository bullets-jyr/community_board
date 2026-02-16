import 'package:core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/blocs/authentication/authentication_bloc.dart';
import '../../features/post/presentation/blocs/post_list/post_list_bloc.dart';
import '../blocs/realtime/realtime_bloc.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RealtimeBloc, RealtimeState>(
      listener: (context, state) {
        if (state is RealtimeNewPostArrived) {
          final currentUserId = context
              .read<AuthenticationBloc>()
              .state
              .user
              ?.id;
          final newPost = state.post;

          if (newPost.authorId != currentUserId) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('New post has arrived'),
                  action: SnackBarAction(
                    label: 'View',
                    onPressed: () {
                      context.read<PostListBloc>().add(
                        PostListNewPostPrepended(post: newPost),
                      );
                      context.read<PostListBloc>().add(
                        PostListScrollToTopRequested(),
                      );
                    },
                  ),
                ),
              );
          }
          context.read<RealtimeBloc>().add(const RealtimeStateResetRequested());
        }

        if (state is RealtimeConnectionFailure) {
          showErrorSnackbar(
            context,
            message: 'Realtime Error: ${state.message}',
          );
          context.read<RealtimeBloc>().add(const RealtimeStateResetRequested());
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: navigationShell.currentIndex,
          onTap: (int index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
