import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';

sealed class GlobalEvent extends Equatable {
  const GlobalEvent();

  @override
  List<Object?> get props => [];
}

final class PostCreatedDispatched extends GlobalEvent {
  const PostCreatedDispatched({required this.post});

  final PostDisplay post;

  @override
  List<Object?> get props => [post];
}
