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

      // The new API just needs the file bytes with key 'file'.
      // It does NOT use the filename for recognition.

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // New API Response:
        // Success: { "name": "...", "similarity": 99.9, "status": "recognized" }
        // Fail: { "name": "...", "similarity": ..., "status": "unknown" } or { "name": "Tidak ditemukan wajah", ... }

        bool isSuccess = data['status'] == 'recognized';

        return {
          'success': isSuccess,
          'data': data, // Pass the whole object
          'message': isSuccess
              ? 'Face detected'
              : (data['name'] ?? 'Wajah tidak dikenali'),
        };
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
