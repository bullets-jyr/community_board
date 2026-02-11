part of 'post_form_bloc.dart';

sealed class PostFormEvent extends Equatable {
  const PostFormEvent();

  @override
  List<Object?> get props => [];
}

final class PostSubmitted extends PostFormEvent {
  const PostSubmitted({
    required this.title,
    required this.content,
    this.imageFile,
  });

  final String title;
  final String content;
  final File? imageFile;

  @override
  List<Object?> get props => [title, content, imageFile];
}
