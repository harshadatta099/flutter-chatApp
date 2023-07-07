import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePickerState extends StatefulWidget {
  const UserImagePickerState({super.key, required this.onPickImage});
  final Function(File pickedImage) onPickImage;
  @override
  State<UserImagePickerState> createState() => _UserImageState();
}

class _UserImageState extends State<UserImagePickerState> {
  File? _packedImage;
  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 150,
        maxHeight: 150);
    if (pickedImage == null) {
      return null;
    }
    setState(() {
      _packedImage = File(pickedImage.path);
    });
    widget.onPickImage(_packedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _packedImage != null ? FileImage(_packedImage!) : null,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            "Add Image",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
