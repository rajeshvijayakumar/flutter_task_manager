import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? imagePath;
  final Function(File) onImageSelected;

  const ProfileImagePicker({
    super.key,
    this.imagePath,
    required this.onImageSelected,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _newlyPickedFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      setState(() {
        _newlyPickedFile = file;
      });

      widget.onImageSelected(file);
    }
  }

  ImageProvider? _getDisplayImage() {
    if (_newlyPickedFile != null) {
      return FileImage(_newlyPickedFile!);
    }

    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      if (widget.imagePath!.startsWith('http')) {
        return NetworkImage(widget.imagePath!);
      } else {
        return FileImage(File(widget.imagePath!));
      }
    }
    log("Inside get display image");

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getDisplayImage();

    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageProvider,
            // Shows a person icon only if no image provider is found
            child: imageProvider == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          // A decorative floating action button style icon for "Edit"
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
