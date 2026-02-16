import 'dart:async';

import 'package:core/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'realtime_remote_data_source.dart';

class SupabaseRealtimeRemoteDataSource implements RealtimeRemoteDataSource {
  SupabaseRealtimeRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient {
    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen(
      _handleAuthStateChange,
    );
  }

  final SupabaseClient _supabaseClient;

  RealtimeChannel? _channel;
  final _controller = StreamController<String>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;
  Timer? _watchdogTimer;
  bool _isSubscribed = false;

  void _handleAuthStateChange(AuthState authState) {
    final event = authState.event;
    final session = authState.session;

    print('Auth event received: ${event.name}');

    if ((event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed) &&
        session != null) {
      print('Event: ${event.name}. Session is valid, ensuring connection...');
      connect();
    } else if (event == AuthChangeEvent.initialSession && session != null) {
      if (!_isSubscribed) {
        print(
          'Event: initialSession. Channel not subscribed, initiating connection...',
        );
        connect();
      }
    } else if (event == AuthChangeEvent.signedOut) {
      print('Event: signedOut. Disconnecting...');
      disconnect();
    }
  }

  @override
  Stream<String> get newPostIdStream => _controller.stream;

  @override
  Future<void> connect() async {
    if (_isSubscribed) {
      print('Channel is already subscribed. Skipping connection.');
      return;
    }

    if (_channel != null) {
      await _channel!.unsubscribe();
    }

    print('Starting connection attempt...');
    _channel = _supabaseClient.channel('public: ${Tables.posts}');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: Tables.posts,
          callback: (PostgresChangePayload payload) {
            final postId = payload.newRecord['id'];
            if (postId != null && postId is String) {
              _controller.add(postId);
            }
          },
        )
        .subscribe((RealtimeSubscribeStatus status, Object? error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('🎉 Realtime Channel Subscribed Successfully!');
            _isSubscribed = true;
            _watchdogTimer?.cancel();
            _watchdogTimer = null;
          }
          if (status == RealtimeSubscribeStatus.channelError && error != null) {
            print('🚨 Realtime Channel Error: $error');
            _isSubscribed = false;
            _controller.addError(error);
            _startWatchdog();
          }
        });
  }

  void _startWatchdog() {
    if (_watchdogTimer != null && _watchdogTimer!.isActive) return;

    print('Starting watchdog timer...');
    _watchdogTimer = Timer(const Duration(seconds: 15), () async {
      print('Watchdog timer fired. Forcing reconnection...');
      await disconnect();
      unawaited(connect());
    });
  }

  @override
  Future<void> disconnect() async {
    if (_channel != null) {
      print('Disconnecting Realtime Channel...');
      await _supabaseClient.removeChannel(_channel!);
      _channel = null;
      print('Realtime Channel Disconnected');
    }

    _isSubscribed = false;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    disconnect();
    _controller.close();
  }
}
