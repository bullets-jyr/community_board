import 'dart:async';

import 'package:injectable/injectable.dart';

import 'global_event.dart';

@singleton
class GlobalEventBus {
  final _controller = StreamController<GlobalEvent>.broadcast();

  Stream<GlobalEvent> get stream => _controller.stream;

  void add(GlobalEvent event) {
    _controller.add(event);
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}