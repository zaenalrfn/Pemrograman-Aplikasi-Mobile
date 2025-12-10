import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FaceRecognitionService {
  FaceRecognitionService();

  Future<Map<String, dynamic>> predict({
    required File imageFile,
    required String name, // Format: NIM_NAMA
  }) async {
    final String? baseUrl = dotenv.env['FACE_RECOGNITION_URL'];

    if (baseUrl == null) {
      debugPrint("FACE_RECOGNITION_URL not found in .env");
      return {'success': false, 'message': 'Configuration error'};
    }

    final uri = Uri.parse(baseUrl);

    try {
      final request = http.MultipartRequest('POST', uri);

      // Add the file
      // NOTE: The Python API expects the key 'file'
      // We rename the file to match the required format: NIM_Nama.jpg
      // This is crucial because the API might use the filename for recognition matching if needed,
      // or simply for logging. The user specified "nama filenya itu nim_namausernya".

      final newPath = imageFile.path.replaceAll(RegExp(r'[^/]+$'), '$name.jpg');
      final renamedFile = await imageFile.copy(newPath);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          renamedFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Expecting { "success": true, "data": [...], "message": ... }
      } else {
        debugPrint(
          "Face Recog Error: ${response.statusCode} - ${response.body}",
        );
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint("Face Recog Exception: $e");
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
