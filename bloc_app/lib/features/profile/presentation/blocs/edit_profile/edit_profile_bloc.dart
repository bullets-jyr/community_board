import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/profile.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/bus/global_event.dart';
import '../../../../../core/bus/global_event_bus.dart';
import '../../../../../core/utils/sealed_class_state.dart';

part 'edit_profile_event.dart';

part 'edit_profile_state.dart';

@injectable
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({
    required UpdateProfileUseCase updateProfileUseCase,
    required GlobalEventBus globalEventBus,
  }) : _updateProfileUseCase = updateProfileUseCase,
       _globalEventBus = globalEventBus,
       super(const EditProfileInitial()) {
    on<EditProfileSubmitted>(_onEditProfileSubmitted);
  }

  final UpdateProfileUseCase _updateProfileUseCase;
  final GlobalEventBus _globalEventBus;

  Future<void> _onEditProfileSubmitted(
    EditProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileLoadInProgress());

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        userId: event.userId,
        username: event.username,
        originalAvatarUrl: event.originalAvatarUrl,
        newAvatarFile: event.newAvatarFile,
        avatarWasRemoved: event.avatarWasRemoved,
      ),
    );

    result.fold(
      (failure) {
        emit(EditProfileLoadFailure(failure: failure));
      },
      (updatedProfile) {
        _globalEventBus.add(ProfileUpdatedDispatched(profile: updatedProfile));

        emit(const EditProfileLoadSuccess(data: null));
      },
    );
  }
}
