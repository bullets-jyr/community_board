part of 'login_bloc.dart';

typedef LoginState = SealedClassState<Failure, void>;

typedef LoginInitial = SealedClassInitial<Failure, void>;
typedef LoginLoadInProgress = SealedClassLoadInProgress<Failure, void>;
typedef LoginLoadSuccess = SealedClassLoadSuccess<Failure, void>;
typedef LoginLoadFailure = SealedClassLoadFailure<Failure, void>;