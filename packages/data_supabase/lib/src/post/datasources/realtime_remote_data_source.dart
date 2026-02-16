abstract interface class RealtimeRemoteDataSource {
  Stream<String> get newPostIdStream;

  void connect();

  Future<void> disconnect();

  void dispose();
}
