import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/auth.dart';
import 'package:domain/profile.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/sealed_class_state.dart';
import '../../../../auth/presentation/blocs/authentication/authentication_bloc.dart';

part 'profile_event.dart';

part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required AuthenticationBloc authenticationBloc,
  }) : _getProfileUseCase = getProfileUseCase,
       _authenticationBloc = authenticationBloc,
       super(const ProfileInitial()) {
    on<MyProfileFetched>(_onMyProfileFetched);
  }

  final GetProfileUseCase _getProfileUseCase;
  final AuthenticationBloc _authenticationBloc;

  Future<void> _onMyProfileFetched(
    MyProfileFetched event,
    Emitter<ProfileState> emit,
  ) async {
    final userId = _authenticationBloc.state.user?.id;
    if (userId == null) {
      emit(
        const ProfileLoadFailure(
          failure: AuthenticationFailure(message: 'User not logged in'),
        ),
      );
      return;
    }

    final prevData = state.currentOrPreviousData;

    emit(ProfileLoadInProgress(prevData: prevData));
    final result = await _getProfileUseCase(userId);

    result.fold(
      (failure) =>
          emit(ProfileLoadFailure(failure: failure, prevData: prevData)),
      (profile) => emit(ProfileLoadSuccess(data: profile)),
    );
  }
}
