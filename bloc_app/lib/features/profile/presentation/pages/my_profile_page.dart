import 'package:core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/route_constants.dart';
import '../../../auth/presentation/blocs/authentication/authentication_bloc.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyProfileView();
  }
}

class MyProfileView extends StatelessWidget {
  const MyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
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
      body: const Center(
        child: Text('My Profile Page View'),
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
    );
  }
}
