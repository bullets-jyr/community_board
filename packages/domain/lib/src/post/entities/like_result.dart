import 'package:equatable/equatable.dart';

class LikeResult extends Equatable {
  const LikeResult({required this.liked, required this.likesCount});

  final bool liked;
  final int likesCount;

  @override
  List<Object> get props => [liked, likesCount];
}
