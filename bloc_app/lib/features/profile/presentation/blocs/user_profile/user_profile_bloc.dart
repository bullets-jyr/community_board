import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/auth.dart';
import 'package:domain/profile.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/sealed_class_state.dart';

part 'user_profile_event.dart';

part 'user_profile_state.dart';

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc({required GetProfileUseCase getProfileUseCase})
    : _getProfileUseCase = getProfileUseCase,
      super(const UserProfileInitial()) {
    on<UserProfileFetched>(_onUserProfileFetched);
  }

  final GetProfileUseCase _getProfileUseCase;

  Future<void> _onUserProfileFetched(
    UserProfileFetched event,
    Emitter<UserProfileState> emit,
  ) async {
    final prevData = state.currentOrPreviousData;

    emit(UserProfileLoadInProgress(prevData: prevData));
    final result = await _getProfileUseCase(event.userId);

    result.fold(
      (failure) =>
          emit(UserProfileLoadFailure(failure: failure, prevData: prevData)),
      (profile) => emit(UserProfileLoadSuccess(data: profile)),
    );
  }
}
