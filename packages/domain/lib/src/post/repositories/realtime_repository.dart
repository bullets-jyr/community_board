import 'package:core/errors.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/post_display.dart';

abstract interface class RealtimeRepository {
  Stream<Either<Failure, PostDisplay>> get newPostStream;

  Future<void> disconnect();
}
