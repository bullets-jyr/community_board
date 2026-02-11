part of 'post_form_bloc.dart';

typedef PostFormState = SealedClassState<Failure, PostDisplay>;

typedef PostFormInitial = SealedClassInitial<Failure, PostDisplay>;
typedef PostFormLoadInProgress =
    SealedClassLoadInProgress<Failure, PostDisplay>;
typedef PostFormLoadSuccess = SealedClassLoadSuccess<Failure, PostDisplay>;
typedef PostFormLoadFailure = SealedClassLoadFailure<Failure, PostDisplay>;
