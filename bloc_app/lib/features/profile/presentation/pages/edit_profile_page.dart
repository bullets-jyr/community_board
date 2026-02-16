import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/di.dart';
import '../../../../core/utils/sealed_class_state.dart';
import '../blocs/edit_profile/edit_profile_bloc.dart';
import '../blocs/profile/profile_bloc.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EditProfileBloc>(),
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final _usernameController = TextEditingController();

  File? _selectedImage;
  String? _existingImageUrl;
  bool _imageWasRemoved = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.currentOrPreviousData;
    if (profile != null) {
      _usernameController.text = profile.username;
      _existingImageUrl = profile.avatarUrl;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();

    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

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

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final profile = context.read<ProfileBloc>().state.currentOrPreviousData!;

    context.read<EditProfileBloc>().add(
      EditProfileSubmitted(
        userId: profile.id,
        originalAvatarUrl: profile.avatarUrl,
        username: _usernameController.text.trim(),
        newAvatarFile: _selectedImage,
        avatarWasRemoved: _imageWasRemoved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileLoadFailure) {
          showErrorSnackbar(context, message: state.failure.message);
        }
        if (state is EditProfileLoadSuccess) {
          context.read<ProfileBloc>().add(MyProfileFetched());
          if (context.canPop()) context.pop();
        }
      },
      builder: (context, state) {
        final isLoading = state is EditProfileLoadInProgress;

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAvatar(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: isLoading ? null : _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Change'),
                      ),
                      TextButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => setState(() {
                                _selectedImage = null;
                                _imageWasRemoved = true;
                              }),
                        icon: const Icon(Icons.delete),
                        label: const Text('Remove'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    Widget imageWidget;

    if (_selectedImage != null) {
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (_existingImageUrl != null && !_imageWasRemoved) {
      imageWidget = CachedNetworkImage(
        imageUrl: _existingImageUrl!,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = const Icon(Icons.person, size: 60, color: Colors.grey);
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: SizedBox.fromSize(
          size: const Size.fromRadius(60),
          child: imageWidget,
        ),
      ),
    );
  }
}
