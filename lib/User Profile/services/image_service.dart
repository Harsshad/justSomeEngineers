import 'dart:typed_data';
import 'package:codefusion/config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ImageService {
  static Future<Uint8List?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile != null ? await pickedFile.readAsBytes() : null;
  }

  static Future<String> uploadImage(Uint8List file, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(Config.imagekitUrl));
      request.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('${Config.privateKey}:'))}';
      request.fields['fileName'] = fileName;
      request.fields['publicKey'] = Config.publicKey;
      request.fields['folder'] = '/user_profile';
      request.files.add(http.MultipartFile.fromBytes('file', file, filename: fileName));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData)['url'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Image upload error: $e');
    }
  }
}
