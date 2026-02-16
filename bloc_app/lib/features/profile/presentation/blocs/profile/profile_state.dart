part of 'profile_bloc.dart';

typedef ProfileState = SealedClassState<Failure, UserEntity>;

typedef ProfileInitial = SealedClassInitial<Failure, UserEntity>;
typedef ProfileLoadInProgress = SealedClassLoadInProgress<Failure, UserEntity>;
typedef ProfileLoadSuccess = SealedClassLoadSuccess<Failure, UserEntity>;
typedef ProfileLoadFailure = SealedClassLoadFailure<Failure, UserEntity>;