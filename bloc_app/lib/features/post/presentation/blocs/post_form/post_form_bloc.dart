import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/sealed_class_state.dart';

part 'post_form_event.dart';

part 'post_form_state.dart';

@injectable
class PostFormBloc extends Bloc<PostFormEvent, PostFormState> {
  PostFormBloc({
    required CreatePostUseCase createPostUseCase,
    required UploadPostImageUseCase uploadPostImageUseCase,
  }) : _createPostUseCase = createPostUseCase,
       _uploadPostImageUseCase = uploadPostImageUseCase,
       super(const PostFormInitial()) {
    on<PostSubmitted>(_onPostSubmitted);
  }

  final CreatePostUseCase _createPostUseCase;
  final UploadPostImageUseCase _uploadPostImageUseCase;

  Future<void> _onPostSubmitted(
    PostSubmitted event,
    Emitter<PostFormState> emit,
  ) async {
    emit(const PostFormLoadInProgress());

    String? imageUrl;
    String? postId;

    if (event.imageFile != null) {
      final uploadResult = await _uploadPostImageUseCase(
        UploadPostImageParams(image: event.imageFile!, postId: null),
      );

      final success = uploadResult.fold(
        (failure) {
          emit(PostFormLoadFailure(failure: failure));
          return false;
        },
        (result) {
          postId = result.postId;
          imageUrl = result.imageUrl;
          return true;
        },
      );
      if (!success) return;
    }

    final createResult = await _createPostUseCase(
      CreatePostParams(
        postId: postId,
        title: event.title,
        content: event.content,
        imageUrl: imageUrl,
      ),
    );

    createResult.fold(
      (failure) {
        emit(PostFormLoadFailure(failure: failure));
      },
      (newPost) {
        emit(PostFormLoadSuccess(data: newPost));
      },
    );
  }
}
