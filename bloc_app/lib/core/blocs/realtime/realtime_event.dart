part of 'realtime_bloc.dart';

sealed class RealtimeEvent extends Equatable {
  const RealtimeEvent();

  @override
  List<Object> get props => [];
}

final class RealtimeSubscribed extends RealtimeEvent {
  const RealtimeSubscribed();
}

final class RealtimeUnsubscribed extends RealtimeEvent {
  const RealtimeUnsubscribed();
}

final class RealtimeStateResetRequested extends RealtimeEvent {
  const RealtimeStateResetRequested();
}

final class _RealtimePostReceived extends RealtimeEvent {
  const _RealtimePostReceived({required this.post});

  final PostDisplay post;

  @override
  List<Object> get props => [post];
}

final class _RealtimeConnectionFailed extends RealtimeEvent {
  const _RealtimeConnectionFailed({required this.error});

  final Failure error;

  @override
  List<Object> get props => [error];
}