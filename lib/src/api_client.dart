import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  String baseUrl = "https://api.feedbacknest.app";

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
          'POST request failed with status: ${response.statusCode}',
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
    List<File>? files,
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

      //covert files to http.MultipartFile
      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          // Check if file exists
          if (!await file.exists()) {
            throw Exception('Screenshot file does not exist: ${file.path}');
          }
          final multipartFile = await http.MultipartFile.fromPath(
            'screenshots', // The name of the field in the form data
            file.path,
          );
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
