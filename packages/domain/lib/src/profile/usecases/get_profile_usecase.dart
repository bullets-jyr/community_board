import 'package:core/errors.dart';
import 'package:core/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../../auth/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<UserEntity, String> {
  GetProfileUseCase({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  final ProfileRepository _profileRepository;

  @override
  Future<Either<Failure, UserEntity>> call(String params) async {
    return await _profileRepository.getProfile(params);
  }
}
