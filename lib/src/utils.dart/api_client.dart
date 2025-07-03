import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

// Cross-platform file handling
class CrossPlatformFile {
  final String? path;
  final String? name;
  final Uint8List? bytes;

  CrossPlatformFile({this.path, this.name, this.bytes});

  // Create from dart:io File (mobile/desktop) or XFile (cross-platform)
  static Future<CrossPlatformFile> fromFile(dynamic file) async {
    if (file.runtimeType.toString().contains('File')) {
      // For dart:io File
      return CrossPlatformFile(
        path: file.path,
        name: file.path.split('/').last,
      );
    } else if (file.runtimeType.toString().contains('XFile')) {
      // For XFile (image_picker)
      final bytes = await file.readAsBytes();
      return CrossPlatformFile(
        name: file.name,
        bytes: bytes,
      );
    }
    // Fallback
    return CrossPlatformFile(name: 'file', bytes: Uint8List(0));
  }

  Future<bool> exists() async {
    if (path != null) {
      // For mobile/desktop platforms
      try {
        final File file = File(path!);
        return await file.exists();
      } catch (e) {
        return false;
      }
    }
    return bytes != null;
  }
}

class ApiClient {
  String baseUrl = "https://feedbacknest-backend-dev.neloy-nr2.workers.dev";

  Future<String> post(
    String endpoint,
    String apiKey,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: {'Content-Type': 'application/json', 'api-key': apiKey},
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        throw Exception(
          'POST request failed with status: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }

  Future<String> postWithMultipart({
    required String endpoint,
    required String apiKey,
    required Map<String, String> fields,
    List<CrossPlatformFile>? files,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(baseUrl + endpoint),
      );

      // Add headers
      request.headers.addAll({'api-key': apiKey});

      // Add text fields
      request.fields.addAll(fields);

      //convert files to http.MultipartFile
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          // Check if file exists
          if (!await file.exists()) {
            throw Exception(
                'Screenshot file does not exist: ${file.name ?? 'unknown'}');
          }

          http.MultipartFile multipartFile;
          if (file.path != null) {
            // For mobile/desktop platforms
            multipartFile = await http.MultipartFile.fromPath(
              'screenshots', // The name of the field in the form data
              file.path!,
            );
          } else if (file.bytes != null) {
            // For web platform
            multipartFile = http.MultipartFile.fromBytes(
              'screenshots',
              file.bytes!,
              filename: file.name ?? 'screenshot.png',
            );
          } else {
            throw Exception('Invalid file: no path or bytes available');
          }
          request.files.add(multipartFile);
        }
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        // Provide more specific error message for file upload failures
        String errorMessage =
            'Multipart POST request failed with status: ${response.statusCode}';
        if (files != null && files.isNotEmpty) {
          errorMessage += ' (Screenshot upload may have failed)';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to perform multipart POST request: $e');
    }
  }
}
