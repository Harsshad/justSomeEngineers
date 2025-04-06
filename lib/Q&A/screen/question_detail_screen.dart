import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:codefusion/config.dart';
import 'package:codefusion/global_resources/components/animated_shadow_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:codefusion/Q&A/screen/post_answer_screen.dart';
import 'package:codefusion/Q&A/services/answer_service.dart';
import 'package:codefusion/Q&A/services/question_service.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;

  const QuestionDetailScreen({Key? key, required this.questionId})
      : super(key: key);

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final QuestionService questionService = QuestionService();
  final AnswerService answerService = AnswerService();
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Uint8List? _questionImage;
  String? _questionImageUrl;

  Future<void> _pickQuestionImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _questionImage = imageBytes;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

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

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
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
                '/que-ans',
                (route) => false,
              );
            },
          ),
          title: Text(
            'Query Details',
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
        body: Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            widthFactor: 0.9, // Limit the width to 70% of the screen
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream:
                        questionService.getQuestionStream(widget.questionId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final question = snapshot.data!;
                      final answersStream =
                          answerService.getAnswersStream(widget.questionId);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[100],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question['title'],
                                  style: TextStyle(
                                    fontFamily: 'SourceCodePro',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  question['description'],
                                  style: TextStyle(
                                    fontFamily: 'SourceCodePro',
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tags: ${question['tags'].join(', ')}',
                                  style: TextStyle(
                                    fontFamily: 'SourceCodePro',
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (question.data() != null &&
                                    (question.data() as Map<String, dynamic>)
                                        .containsKey('imageUrl') &&
                                    question['imageUrl'].isNotEmpty)
                                  GestureDetector(
                                    onTap: () =>
                                        _showImageDialog(question['imageUrl']),
                                    child: Image.network(question['imageUrl']),
                                  ),
                                const SizedBox(height: 8),
                                if (question.data() != null &&
                                    (question.data() as Map<String, dynamic>)
                                        .containsKey('link') &&
                                    question['link'].isNotEmpty)
                                  LinkPreview(
                                    width: MediaQuery.of(context).size.width,
                                    enableAnimation: true,
                                    onPreviewDataFetched: (data) {},
                                    previewData: null,
                                    text: question['link'],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Solutions:',
                              style: TextStyle(
                                fontFamily: 'SourceCodePro',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: answersStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final answers = snapshot.data!.docs;

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: answers.length,
                                itemBuilder: (context, index) {
                                  final answer = answers[index];
                                  final upvotedBy = List<String>.from(
                                      answer['upvotedBy'] ?? []);
                                  final downvotedBy = List<String>.from(
                                      answer['downvotedBy'] ?? []);
                                  final hasUpvoted = upvotedBy.contains(userId);
                                  final hasDownvoted =
                                      downvotedBy.contains(userId);

                                  return Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    color: Colors.blueGrey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (answer.data() != null &&
                                              (answer.data()
                                                      as Map<String, dynamic>)
                                                  .containsKey('imageUrl') &&
                                              answer['imageUrl'].isNotEmpty)
                                            GestureDetector(
                                              onTap: () => _showImageDialog(
                                                  answer['imageUrl']),
                                              child: Image.network(
                                                  answer['imageUrl']),
                                            ),
                                          const SizedBox(height: 8),
                                          Text(
                                            answer['content'],
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if ((answer.data()
                                                      as Map<String, dynamic>)
                                                  .containsKey('link') &&
                                              answer['link'].isNotEmpty)
                                            LinkPreview(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              enableAnimation: true,
                                              onPreviewDataFetched: (data) {},
                                              previewData: null,
                                              text: answer['link'],
                                            ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.thumb_up,
                                                  color: hasUpvoted
                                                      ? Colors.green
                                                      : Colors.grey,
                                                ),
                                                onPressed: hasUpvoted
                                                    ? null
                                                    : () {
                                                        answerService
                                                            .updateVote(
                                                                answer.id,
                                                                'upvotes',
                                                                userId!);
                                                      },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.thumb_down,
                                                  color: hasDownvoted
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                                onPressed: hasDownvoted
                                                    ? null
                                                    : () {
                                                        answerService
                                                            .updateVote(
                                                                answer.id,
                                                                'downvotes',
                                                                userId!);
                                                      },
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'Upvotes: ${answer['upvotes'] ?? 0}, Downvotes: ${answer['downvotes'] ?? 0}',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedShadowButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PostAnswerScreen(questionId: widget.questionId),
                          ),
                        );
                      },
                      text: 'Post Answer',
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
