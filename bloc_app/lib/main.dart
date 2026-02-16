import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/blocs/realtime/realtime_bloc.dart';
import 'core/di/di.dart';
import 'features/auth/presentation/blocs/authentication/authentication_bloc.dart';
import 'features/post/presentation/blocs/post_list/post_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthenticationBloc>()),
        BlocProvider(
          create: (context) => getIt<PostListBloc>()..add(PostListFetched()),
        ),
        BlocProvider(
          create: (context) =>
          getIt<RealtimeBloc>()..add(const RealtimeSubscribed()),
        ),
      ],
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            final postListBloc = context.read<PostListBloc>();

            if (postListBloc.state.posts.isEmpty ||
                postListBloc.state.status == PostListStatus.failure) {
              postListBloc.add(PostListFetched());
            }

            context.read<RealtimeBloc>().add(const RealtimeSubscribed());
          } else if (state.status == AuthenticationStatus.unauthenticated) {
            context.read<PostListBloc>().add(PostListResetRequested());
            context.read<RealtimeBloc>().add(const RealtimeUnsubscribed());
          }
        },
        child: MaterialApp.router(
          title: 'Community Board Bloc',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          routerConfig: getIt<GoRouter>(),
        ),
      ),
    );
  }
}
