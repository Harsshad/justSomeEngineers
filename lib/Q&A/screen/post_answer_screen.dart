import 'dart:ui';

import 'package:codefusion/config.dart';
import 'package:codefusion/global_resources/components/animated_shadow_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codefusion/Q&A/services/answer_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class PostAnswerScreen extends StatefulWidget {
  final String questionId;

  const PostAnswerScreen({Key? key, required this.questionId})
      : super(key: key);

  @override
  _PostAnswerScreenState createState() => _PostAnswerScreenState();
}

class _PostAnswerScreenState extends State<PostAnswerScreen> {
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  bool _isPosting = false;
  String? _imageUrl;
  String? _linkPreviewUrl;
  Uint8List? _imageBytes;

  Future<String> _uploadImageToImageKit(Uint8List file) async {
    const String imagekitUrl = Config.imagekitUrl;
    const String publicKey = Config.publicKey;
    const String privateKey = Config.privateKey;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(imagekitUrl));
      request.headers['Authorization'] =
          'Basic ' + base64Encode(utf8.encode(privateKey + ':'));
      request.fields['fileName'] =
          '${FirebaseAuth.instance.currentUser!.uid}.jpg';
      request.fields['publicKey'] = publicKey;
      request.fields['folder'] = '/answers'; // Specify the folder
      request.files.add(
          http.MultipartFile.fromBytes('file', file, filename: 'answer.jpg'));

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

  Future<void> _postAnswer() async {
    if (_answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      await AnswerService().postAnswer(
        _answerController.text,
        userId!,
        widget.questionId,
        imageUrl: _imageUrl,
        link: _linkController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer posted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post answer: $e')),
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
            'Post an Answer',
            style: TextStyle(
              fontFamily: 'SourceCodePro',
              fontWeight: FontWeight.bold,
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
                      controller: _answerController,
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        labelStyle: TextStyle(
                            fontFamily: 'SourceCodePro',
                            color: (isDarkMode ? Colors.white : Colors.black)),
                        filled: true,
                        fillColor:
                            isDarkMode ? Colors.blueGrey[800] : Colors.blueGrey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueGrey[700]!,
                          ),
                        ),
                      ),
                      maxLines: 4,
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
                        fillColor:
                            isDarkMode ? Colors.blueGrey[800] : Colors.blueGrey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueGrey[700]!,
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
                    _isPosting
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              AnimatedShadowButton(
                                onPressed: _pickImage,
                                text: 'Pick Image',
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.blueGrey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimatedShadowButton(
                                onPressed: _postAnswer,
                                text: 'Post Answer',
                                icon: Icon(
                                  Icons.send_rounded,
                                  color: Colors.blueGrey[500],
                                ),
                              ),
                            ],
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
