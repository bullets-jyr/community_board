part of 'signup_bloc.dart';

typedef SignupState = SealedClassState<Failure, void>;

typedef SignupInitial = SealedClassInitial<Failure, void>;
typedef SignupLoadInProgress = SealedClassLoadInProgress<Failure, void>;
typedef SignupLoadSuccess = SealedClassLoadSuccess<Failure, void>;
typedef SignupLoadFailure = SealedClassLoadFailure<Failure, void>;