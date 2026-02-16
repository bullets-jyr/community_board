import 'dart:async';

import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:fpdart/fpdart.dart';

import '../datasources/post_remote_data_source.dart';
import '../datasources/realtime_remote_data_source.dart';

class RealtimeRepositoryImpl implements RealtimeRepository {
  RealtimeRepositoryImpl({
    required RealtimeRemoteDataSource realtimeRemoteDataSource,
    required PostRemoteDataSource postRemoteDataSource,
  }) : _realtimeRemoteDataSource = realtimeRemoteDataSource,
       _postRemoteDataSource = postRemoteDataSource;

  final RealtimeRemoteDataSource _realtimeRemoteDataSource;
  final PostRemoteDataSource _postRemoteDataSource;

  @override
  Stream<Either<Failure, PostDisplay>> get newPostStream {
    final transformer =
        StreamTransformer<String, Either<Failure, PostDisplay>>.fromHandlers(
          handleData:
              (
                String postId,
                EventSink<Either<Failure, PostDisplay>> sink,
              ) async {
                try {
                  final postModel = await _postRemoteDataSource.getPostDetail(
                    postId: postId,
                  );
                  sink.add(Right(postModel));
                } on AppException catch (e) {
                  sink.add(Left(ServerFailure(message: e.toString())));
                }
              },
          handleError:
              (
                Object error,
                StackTrace stackTrace,
                EventSink<Either<Failure, PostDisplay>> sink,
              ) {
                sink.add(Left(ConnectionFailure(message: error.toString())));
              },
        );

    return _realtimeRemoteDataSource.newPostIdStream.transform(transformer);
  }

  @override
  Future<void> disconnect() async {
    await _realtimeRemoteDataSource.disconnect();
  }
}
