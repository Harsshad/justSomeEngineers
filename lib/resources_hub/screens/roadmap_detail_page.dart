import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codefusion/resources_hub/widgets/roadmap_widget.dart';
import 'package:flutter/material.dart';

class RoadmapDetailPage extends StatelessWidget {
  final String roadmapId;

  const RoadmapDetailPage({Key? key, required this.roadmapId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.black87, Colors.blueGrey.shade900]
              : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Roadmap Detail',
            style: TextStyle(
              fontFamily: 'SourceCodePro',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
            ),
          ),
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.black87, Colors.blueGrey.shade900]
                        : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('roadmaps')
              .doc(roadmapId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return  Center(
                child: Text(
                  'Roadmap not found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: (isDarkMode ? Colors.white :  Colors.black),),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: RoadmapWidget(roadmap: snapshot.data!['roadmap']),
            );
          },
        ),
      ),
    );
  }
}