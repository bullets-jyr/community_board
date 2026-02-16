part of 'user_profile_bloc.dart';

typedef UserProfileState = SealedClassState<Failure, UserEntity>;

typedef UserProfileInitial = SealedClassInitial<Failure, UserEntity>;
typedef UserProfileLoadInProgress =
    SealedClassLoadInProgress<Failure, UserEntity>;
typedef UserProfileLoadSuccess = SealedClassLoadSuccess<Failure, UserEntity>;
typedef UserProfileLoadFailure = SealedClassLoadFailure<Failure, UserEntity>;
