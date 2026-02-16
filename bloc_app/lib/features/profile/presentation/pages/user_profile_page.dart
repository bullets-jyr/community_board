import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/constants.dart';
import 'package:core/utils.dart';
import 'package:domain/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/utils/sealed_class_state.dart';
import '../../../post/presentation/blocs/my_post_list/my_post_list_bloc.dart';
import '../../../post/presentation/widgets/my_post_list.dart';
import '../blocs/user_profile/user_profile_bloc.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<UserProfileBloc>()..add(UserProfileFetched(userId: userId)),
        ),
        BlocProvider(
          create: (context) =>
              getIt<MyPostListBloc>()..add(MyPostListFetched(userId: userId)),
        ),
      ],
      child: BlocListener<MyPostListBloc, MyPostListState>(
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
        child: const UserProfileView(),
      ),
    );
  }
}

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<UserProfileBloc, UserProfileState>(
          builder: (context, state) {
            final username = state.currentOrPreviousData?.username;
            return Text(username ?? 'User Profile');
          },
        ),
      ),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          return switch (state) {
            UserProfileInitial() || UserProfileLoadInProgress(prevData: null) =>
              const Center(child: CircularProgressIndicator()),

            UserProfileLoadFailure(failure: final f) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error: ${f.message}', textAlign: TextAlign.center),
              ),
            ),

            _ => _ProfileContent(profile: state.currentOrPreviousData!),
          };
        },
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
        context.read<UserProfileBloc>().add(
          UserProfileFetched(userId: profile.id),
        );
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
                                const CircularProgressIndicator(strokeWidth: 2),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error_outline, size: 18),
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
                      "${profile.username}'s Posts",
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
