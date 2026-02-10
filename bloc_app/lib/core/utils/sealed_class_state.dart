import 'package:equatable/equatable.dart';

sealed class SealedClassState<F, T> extends Equatable {
  const SealedClassState();

  const factory SealedClassState.initial() = SealedClassInitial<F, T>;

  const factory SealedClassState.loading({T? prevData}) =
      SealedClassLoadInProgress<F, T>;

  const factory SealedClassState.success({required T data}) =
      SealedClassLoadSuccess<F, T>;

  const factory SealedClassState.failure({required F failure, T? prevData}) =
      SealedClassLoadFailure<F, T>;

  @override
  List<Object?> get props => [];
}

final class SealedClassInitial<F, T> extends SealedClassState<F, T> {
  const SealedClassInitial();

  @override
  String toString() => 'Initial<$F, $T>()';
}

final class SealedClassLoadInProgress<F, T> extends SealedClassState<F, T> {
  const SealedClassLoadInProgress({this.prevData});

  final T? prevData;

  @override
  List<Object?> get props => [prevData];

  @override
  String toString() => 'Loading<$F, $T>(prevData: $prevData)';
}

final class SealedClassLoadSuccess<F, T> extends SealedClassState<F, T> {
  const SealedClassLoadSuccess({required this.data});

  final T data;

  @override
  List<Object?> get props => [data];

  @override
  String toString() => 'Success<$F, $T>(data: $data)';
}

final class SealedClassLoadFailure<F, T> extends SealedClassState<F, T> {
  const SealedClassLoadFailure({required this.failure, this.prevData});

  final F failure;
  final T? prevData;

  @override
  List<Object?> get props => [failure, prevData];

  @override
  String toString() =>
      'Failure<$F, $T>(failure: $failure, prevData: $prevData)';
}

extension SealedClassStateDataUtils<F, T> on SealedClassState<F, T> {
  T? get currentOrPreviousData {
    return switch (this) {
      SealedClassLoadSuccess<F, T>(data: final data) => data,
      SealedClassLoadInProgress<F, T>(prevData: final prevData) => prevData,
      SealedClassLoadFailure<F, T>(prevData: final prevData) => prevData,
      _ => null,
    };
  }

  bool get hasData => currentOrPreviousData != null;
}
