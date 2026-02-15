import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/utils.dart';
import 'package:domain/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/di.dart';
import '../blocs/post_form/post_form_bloc.dart';

class PostFormPage extends StatelessWidget {
  const PostFormPage({super.key, this.postId});

  final String? postId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<PostFormBloc>();
        if (postId != null) {
          bloc.add(PostFormPrefilled(postId: postId!));
        }
        return bloc;
      },
      child: PostFormView(isEditMode: postId != null),
    );
  }
}

class PostFormView extends StatefulWidget {
  const PostFormView({super.key, required this.isEditMode});

  final bool isEditMode;

  @override
  State<PostFormView> createState() => _PostFormViewState();
}

class _PostFormViewState extends State<PostFormView> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  File? _selectedImage;

  String? _existingImageUrl;
  bool _imageWasRemoved = false;
  PostDisplay? _originalPost;

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageWasRemoved = false;
        });
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    } catch (e) {
      print('Unexpected error occurred: $e');
      if (!mounted) return;
      showErrorSnackbar(context, message: e.toString());
    }
  }

  void _submit(PostDisplay? postToEdit) {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (postToEdit != null) {
      context.read<PostFormBloc>().add(
        PostEdited(
          originalPost: postToEdit,
          newTitle: title,
          newContent: content,
          newImageFile: _selectedImage,
          imageWasRemoved: _imageWasRemoved,
        ),
      );
    } else {
      context.read<PostFormBloc>().add(
        PostSubmitted(
          title: title,
          content: content,
          imageFile: _selectedImage,
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    Widget? imageWidget;

    if (_selectedImage != null) {
      imageWidget = Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (_existingImageUrl != null && !_imageWasRemoved) {
      imageWidget = CachedNetworkImage(
        imageUrl: _existingImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error)),
      );
    }

    if (imageWidget != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          imageWidget,
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _imageWasRemoved = true;
                });
              },
              icon: const Icon(Icons.cancel, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text('Tap to add an image'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostFormBloc, PostFormState>(
      listener: (context, state) {
        if (state is PostFormLoadFailure) {
          showErrorSnackbar(context, message: state.failure.message);
          setState(() {
            _isSaving = false;
          });
        }
        if (state is PostFormLoadSuccess) {
          if (widget.isEditMode && _originalPost == null) {
            _originalPost = state.data;
            _titleController.text = _originalPost!.title;
            _contentController.text = _originalPost!.content;
            _existingImageUrl = _originalPost!.imageUrl;
          } else {
            context.pop();
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is PostFormLoadInProgress;
        final isEditMode = widget.isEditMode;

        return Scaffold(
          appBar: AppBar(title: Text(isEditMode ? 'Edit Post' : 'Create Post')),
          body: _isSaving || (isLoading && _originalPost == null)
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 200,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade100,
                          ),
                          child: InkWell(
                            onTap: isLoading ? null : _pickImage,
                            child: _buildImagePreview(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          enabled: !isLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 10,
                          minLines: 5,
                          enabled: !isLoading,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter content.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.multiline,
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: () => _submit(_originalPost),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(isEditMode ? 'Update' : 'Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
