import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gsloution_mobile/src/utils/contstants.dart';
import 'package:image_picker/image_picker.dart';

class UploadImage extends StatefulWidget {
  final String image;

  const UploadImage({super.key, required this.image});

  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade50.withOpacity(0.3),
              radius: 60,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : AssetImage(widget.image) as ImageProvider,
            ),
            const Positioned(
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: ColorSchema.primaryColor,
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
