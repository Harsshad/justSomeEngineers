//not used this in project 

import 'dart:convert';
import 'dart:typed_data';
import 'package:codefusion/profile%20&%20Q&A/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class ProfileImagePicker extends StatefulWidget {
  final Function(String) onImagePicked;

  const ProfileImagePicker({Key? key, required this.onImagePicked}) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  Uint8List? _profileImage;

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImage = imageBytes;
        });

        final imageUrl = await _uploadImageToImageKit(imageBytes);
        widget.onImagePicked(imageUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No image selected')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<String> _uploadImageToImageKit(Uint8List file) async {
    const String imagekitUrl = 'https://upload.imagekit.io/api/v1/files/upload';
    const String publicKey = 'public_LWSZ9j/yFXM2LoFPod9qfzBEFow=';
    const String privateKey = 'private_rG5Lp3157I1V+9yV+EIkVfHnCoA=';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(imagekitUrl));
      request.headers['Authorization'] = 'Basic ' + base64Encode(utf8.encode(privateKey + ':'));
      request.fields['fileName'] = 'profile_image.jpg';
      request.fields['publicKey'] = publicKey;
      request.files.add(http.MultipartFile.fromBytes('file', file, filename: 'profile.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = jsonDecode(responseData);
        return decodedData['url'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Image upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: CircleAvatar(
        radius: 60,
        backgroundImage: _profileImage != null
            ? MemoryImage(_profileImage!)
            : const AssetImage(Constants.default_profile) as ImageProvider,
        child: _profileImage == null
            ? const Icon(Icons.add_a_photo, size: 30)
            : null,
      ),
    );
  }
}
