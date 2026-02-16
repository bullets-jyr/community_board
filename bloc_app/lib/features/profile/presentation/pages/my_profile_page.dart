import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/constants.dart';
import 'package:core/utils.dart';
import 'package:domain/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../../core/di/di.dart';
import '../../../../core/utils/sealed_class_state.dart';
import '../../../auth/presentation/blocs/authentication/authentication_bloc.dart';
import '../../../post/presentation/blocs/my_post_list/my_post_list_bloc.dart';
import '../../../post/presentation/widgets/my_post_list.dart';
import '../blocs/profile/profile_bloc.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select(
      (AuthenticationBloc bloc) => bloc.state.user?.id,
    );

    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProfileBloc>()..add(MyProfileFetched()),
        ),
        BlocProvider(
          create: (context) =>
              getIt<MyPostListBloc>()..add(MyPostListFetched(userId: userId)),
        ),
      ],
      child: const MyProfileView(),
    );
  }
}

class MyProfileView extends StatelessWidget {
  const MyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyPostListBloc, MyPostListState>(
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
        context.read<MyPostListBloc>().add(
          MyPostListTransientFailureConsumed(),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed(
                  RouteNames.profileEdit,
                  extra: context.read<ProfileBloc>(),
                );
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                context.read<AuthenticationBloc>().add(
                  AuthenticationLogoutRequested(),
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() || ProfileLoadInProgress(prevData: null) =>
                const Center(child: CircularProgressIndicator()),

              ProfileLoadFailure(:final failure, prevData: null) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${failure.message}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProfileBloc>().add(MyProfileFetched());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

              _ => _ProfileContent(profile: state.currentOrPreviousData!),
            };
          },
        ),
        floatingActionButton:
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state.user?.role == Roles.admin) {
                  return FloatingActionButton(
                    heroTag: null,
                    onPressed: () {
                      context.push(RoutePaths.postCreate);
                    },
                    tooltip: 'Create Post',
                    child: const Icon(Icons.add),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final UserEntity profile;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(MyProfileFetched());
        if (profile.role == Roles.admin) {
          context.read<MyPostListBloc>().add(
            MyPostListRefreshed(userId: profile.id),
          );
        }
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            if (profile.role == Roles.admin) {
              context.read<MyPostListBloc>().add(
                MyPostListNextPageFetched(userId: profile.id),
              );
            }
          }
          return false;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  child: profile.avatarUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: profile.avatarUrl!,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error_outline),
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  profile.username,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${profile.role}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (profile.role == Roles.admin) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'My Posts',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  MyPostList(userId: profile.id),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
