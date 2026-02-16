import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

part 'realtime_event.dart';
part 'realtime_state.dart';

@injectable
class RealtimeBloc extends Bloc<RealtimeEvent, RealtimeState> {
  RealtimeBloc({required RealtimeRepository realtimeRepository})
      : _realtimeRepository = realtimeRepository,
        super(const RealtimeInitial()) {
    on<RealtimeSubscribed>(_onRealtimeSubscribed);
    on<RealtimeUnsubscribed>(_onRealtimeUnsubscribed);
    on<_RealtimePostReceived>(_onRealtimePostReceived);
    on<_RealtimeConnectionFailed>(_onRealtimeConnectionFailed);
    on<RealtimeStateResetRequested>(_onRealtimeStateResetRequested);
  }

  final RealtimeRepository _realtimeRepository;

  StreamSubscription<Either<Failure, PostDisplay>>? _postSubscription;

  void _onRealtimeSubscribed(
      RealtimeSubscribed event,
      Emitter<RealtimeState> emit,
      ) {
    _postSubscription?.cancel();

    _postSubscription = _realtimeRepository.newPostStream.listen((result) {
      result.fold((failure) {
        if (failure is ConnectionFailure) {
          add(_RealtimeConnectionFailed(error: failure));
        } else {
          print('Realtime Error: ${failure.message}');
        }
      }, (post) => add(_RealtimePostReceived(post: post)));
    });
  }

  void _onRealtimeUnsubscribed(
      RealtimeUnsubscribed event,
      Emitter<RealtimeState> emit,
      ) {
    _postSubscription?.cancel();
    _postSubscription = null;
    _realtimeRepository.disconnect();
    emit(const RealtimeInitial());
  }

  void _onRealtimePostReceived(
      _RealtimePostReceived event,
      Emitter<RealtimeState> emit,
      ) {
    emit(RealtimeNewPostArrived(post: event.post));
  }

  void _onRealtimeConnectionFailed(
      _RealtimeConnectionFailed event,
      Emitter<RealtimeState> emit,
      ) {
    emit(RealtimeConnectionFailure(message: event.error.message));
  }

  void _onRealtimeStateResetRequested(
      RealtimeStateResetRequested event,
      Emitter<RealtimeState> emit,
      ) {
    emit(const RealtimeInitial());
  }

  @override
  Future<void> close() {
    _postSubscription?.cancel();
    _realtimeRepository.disconnect();
    return super.close();
  }
}