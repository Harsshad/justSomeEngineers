
import 'dart:io';
import 'package:codefusion/global_resources/constants/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<pw.ImageProvider> downloadNetworkImage(String url) async {
  final image = await networkImage(url);
  return image;
}

Future<void> generateAndPreviewPdf({
  required String fullName,
  required String currentPosition,
  required String bio,
  required String address,
  required List<String> experiences,
  required List<String> educationDetails,
  required List<String> languages,
  required List<String> hobbies,
  required String email,
  required String profileImage,
  required Function(bool success) onComplete,
}) async {
  final pdf = pw.Document();
  pw.ImageProvider? imageProvider;

  try {
    if (profileImage.isNotEmpty) {
      if (kIsWeb) {
        imageProvider = await networkImage(profileImage);
      } else {
        final imageBytes = await File(profileImage).readAsBytes();
        imageProvider = pw.MemoryImage(imageBytes);
      }
    } else {
      final imageData = await rootBundle.load(Constants.default_profile);
      imageProvider = pw.MemoryImage(imageData.buffer.asUint8List());
    }
  } catch (_) {
    imageProvider = null;
  }

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        if (imageProvider != null)
          pw.Center(
            child: pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                shape: pw.BoxShape.circle,
                image: pw.DecorationImage(image: imageProvider, fit: pw.BoxFit.cover),
              ),
            ),
          ),
        pw.SizedBox(height: 20),
        pw.Text(fullName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text(currentPosition, style: pw.TextStyle(fontSize: 18)),
        pw.Text(email),
        pw.Text(address),
        pw.SizedBox(height: 10),
        pw.Text("Bio", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(bio),
        pw.SizedBox(height: 10),
        pw.Text("Experience", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ...experiences.map((e) => pw.Bullet(text: e)),
        pw.SizedBox(height: 10),
        pw.Text("Education", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ...educationDetails.map((e) => pw.Bullet(text: e)),
        pw.SizedBox(height: 10),
        pw.Text("Languages", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(languages.join(", ")),
        pw.SizedBox(height: 10),
        pw.Text("Hobbies", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(hobbies.join(", ")),
      ],
    ),
  );

  try {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    onComplete(true);
  } catch (e) {
    onComplete(false);
  }
}