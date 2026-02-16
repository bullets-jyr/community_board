part of 'realtime_bloc.dart';

sealed class RealtimeState extends Equatable {
  const RealtimeState();

  @override
  List<Object> get props => [];
}

final class RealtimeInitial extends RealtimeState {
  const RealtimeInitial();
}

final class RealtimeNewPostArrived extends RealtimeState {
  const RealtimeNewPostArrived({required this.post});

  final PostDisplay post;

  @override
  List<Object> get props => [post];
}

final class RealtimeConnectionFailure extends RealtimeState {
  const RealtimeConnectionFailure({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}