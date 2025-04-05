import 'dart:ui';

import 'package:codefusion/global_resources/components/animated_shadow_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codefusion/Q&A/services/question_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class PostQuestionScreen extends StatefulWidget {
  @override
  _PostQuestionScreenState createState() => _PostQuestionScreenState();
}

class _PostQuestionScreenState extends State<PostQuestionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  bool _isPosting = false;
  String? _imageUrl;
  String? _linkPreviewUrl;
  Uint8List? _imageBytes;

  Future<String> _uploadImageToImageKit(Uint8List file) async {
    const String imagekitUrl = 'https://upload.imagekit.io/api/v1/files/upload';
    const String publicKey = 'public_LWSZ9j/yFXM2LoFPod9qfzBEFow=';
    const String privateKey = 'private_rG5Lp3157I1V+9yV+EIkVfHnCoA=';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(imagekitUrl));
      request.headers['Authorization'] =
          'Basic ' + base64Encode(utf8.encode(privateKey + ':'));
      request.fields['fileName'] =
          '${FirebaseAuth.instance.currentUser!.uid}.jpg';
      request.fields['publicKey'] = publicKey;
      request.fields['folder'] = '/questions';
      request.files.add(
          http.MultipartFile.fromBytes('file', file, filename: 'question.jpg'));

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final imageUrl = await _uploadImageToImageKit(bytes);
      setState(() {
        _imageUrl = imageUrl;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _postQuestion() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _tagsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final tags =
          _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      await QuestionService().postQuestion(
        _titleController.text,
        _descriptionController.text,
        tags,
        userId!,
        imageUrl: _imageUrl,
        link: _linkController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question posted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post question: $e')),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black87, Colors.blueGrey.shade900] // Dark mode gradient
              : [
                  const Color(0xFFDFD7C2),
                  const Color(0xFFF7DB4C)
                ], // Light mode gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparent to show gradient
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Transparent AppBar
          elevation: 0, // No elevation for a clean look
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/main-home',
                (route) => false,
              );
            },
          ),
          title: Text(
            'Post a Question',
            style: TextStyle(
              fontFamily: 'SourceCodePro',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
            ),
          ),
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Blur effect
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                            Colors.black87,
                            Colors.blueGrey.shade900
                          ] // Dark mode gradient
                        : [
                            const Color(0xFFDFD7C2),
                            const Color(0xFFF7DB4C)
                          ], // Light mode gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double maxWidth =
              screenWidth > 1000 ? screenWidth * 0.7 : screenWidth;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(
                            fontFamily: 'SourceCodePro',
                            color: (isDarkMode ? Colors.white : Colors.black)),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.blueGrey[800]
                            : Colors.blueGrey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.blueGrey[300]!
                                : Colors.blueGrey[700]!,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                            fontFamily: 'SourceCodePro',
                            color: (isDarkMode ? Colors.white : Colors.black)),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.blueGrey[800]
                            : Colors.blueGrey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.blueGrey[300]!
                                : Colors.blueGrey[700]!,
                          ),
                        ),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        labelText: 'Tags (comma-separated)',
                        labelStyle: TextStyle(
                            fontFamily: 'SourceCodePro',
                            color: (isDarkMode ? Colors.white : Colors.black)),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.blueGrey[800]
                            : Colors.blueGrey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.blueGrey[300]!
                                : Colors.blueGrey[700]!,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        labelText: 'Link (optional)',
                        labelStyle: TextStyle(
                            fontFamily: 'SourceCodePro',
                            color: (isDarkMode ? Colors.white : Colors.black)),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.blueGrey[800]
                            : Colors.blueGrey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.blueGrey[300]!
                                : Colors.blueGrey[700]!,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _linkPreviewUrl = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_linkPreviewUrl != null && _linkPreviewUrl!.isNotEmpty)
                      LinkPreview(
                        width: MediaQuery.of(context).size.width,
                        enableAnimation: true,
                        onPreviewDataFetched: (data) {},
                        previewData: null,
                        text: _linkPreviewUrl!,
                      ),
                    const SizedBox(height: 16),
                    if (_imageBytes != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_imageBytes!),
                        ),
                      ),
                    const SizedBox(height: 16),
                    AnimatedShadowButton(
                      text: 'Pick Image',
                      icon: Icon(
                        Icons.image_rounded,
                        color: isDarkMode
                            ? Colors.blueGrey[300]
                            : Colors.blueGrey[500],
                      ),
                      onPressed: _pickImage,
                    ),
                    const SizedBox(height: 16),
                    _isPosting
                        ? const CircularProgressIndicator()
                        : AnimatedShadowButton(
                            text: 'Post Question',
                            onPressed: _postQuestion,
                            icon: Icon(
                              Icons.send_rounded,
                              color: isDarkMode
                                  ? Colors.blueGrey[300]
                                  : Colors.blueGrey[500],
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
