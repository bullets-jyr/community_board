import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:core/errors.dart';
import 'package:domain/post.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/bus/global_event.dart';
import '../../../../../core/bus/global_event_bus.dart';
import '../../../../../core/utils/sealed_class_state.dart';

part 'post_form_event.dart';

part 'post_form_state.dart';

@injectable
class PostFormBloc extends Bloc<PostFormEvent, PostFormState> {
  PostFormBloc({
    required CreatePostUseCase createPostUseCase,
    required UploadPostImageUseCase uploadPostImageUseCase,
    required UpdatePostUseCase updatePostUseCase,
    required GetPostDetailUseCase getPostDetailUseCase,
    required GlobalEventBus globalEventBus,
  }) : _createPostUseCase = createPostUseCase,
       _uploadPostImageUseCase = uploadPostImageUseCase,
       _updatePostUseCase = updatePostUseCase,
       _getPostDetailUseCase = getPostDetailUseCase,
       _globalEventBus = globalEventBus,
       super(const PostFormInitial()) {
    on<PostSubmitted>(_onPostSubmitted);
    on<PostFormPrefilled>(_onPostFormPrefilled);
    on<PostEdited>(_onPostEdited);
  }

  final CreatePostUseCase _createPostUseCase;
  final UploadPostImageUseCase _uploadPostImageUseCase;
  final UpdatePostUseCase _updatePostUseCase;
  final GetPostDetailUseCase _getPostDetailUseCase;
  final GlobalEventBus _globalEventBus;

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
        _globalEventBus.add(PostCreatedDispatched(post: newPost));
        emit(PostFormLoadSuccess(data: newPost));
      },
    );
  }

  Future<void> _onPostFormPrefilled(
    PostFormPrefilled event,
    Emitter<PostFormState> emit,
  ) async {
    emit(const PostFormLoadInProgress());

    final result = await _getPostDetailUseCase(event.postId);

    result.fold(
      (failure) => emit(PostFormLoadFailure(failure: failure)),
      (post) => emit(PostFormLoadSuccess(data: post)),
    );
  }

  Future<void> _onPostEdited(
    PostEdited event,
    Emitter<PostFormState> emit,
  ) async {
    emit(const PostFormLoadInProgress());

    await Future.delayed(const Duration(seconds: 1));

    final result = await _updatePostUseCase(
      UpdatePostParams(
        originalPost: event.originalPost,
        newTitle: event.newTitle,
        newContent: event.newContent,
        newImageFile: event.newImageFile,
        imageWasRemoved: event.imageWasRemoved,
      ),
    );

    result.fold((failure) => emit(PostFormLoadFailure(failure: failure)), (
      updatedPost,
    ) {
      _globalEventBus.add(PostUpdatedDispatched(post: updatedPost));
      emit(PostFormLoadSuccess(data: updatedPost));
    });
  }
}
