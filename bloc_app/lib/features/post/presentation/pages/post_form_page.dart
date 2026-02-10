import 'package:flutter/material.dart';

class PostFormPage extends StatelessWidget {
  const PostFormPage({super.key, this.postId});

  final String? postId;

  @override
  Widget build(BuildContext context) {
    return const PostFormView();
  }
}

class PostFormView extends StatelessWidget {
  const PostFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Post Form Page View'),
      ),
    );
  }
}
