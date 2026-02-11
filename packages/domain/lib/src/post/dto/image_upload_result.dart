import 'package:equatable/equatable.dart';

class ImageUploadResult extends Equatable {
  const ImageUploadResult({required this.postId, required this.imageUrl});

  final String postId;
  final String imageUrl;

  @override
  List<Object> get props => [postId, imageUrl];
}