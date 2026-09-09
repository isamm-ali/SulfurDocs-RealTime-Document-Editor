import 'dart:convert';
import 'package:frontend/config/environment.dart';
import 'package:frontend/models/document_model.dart';
import 'package:http/http.dart' as http;

class DocumentService {
  static String get baseUrl => Environment.apiUrl;

  Future<Map<String, dynamic>> createDocument(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/doc/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Something went wrong',
        'document': response.statusCode == 200 ? responseData : null,
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Unable to connect to the server',
        'document': null,
      };
    }
  }

  Future<Map<String, dynamic>> getDocuments(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doc/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);
      final List<DocumentModel> documents = [];
      if (response.statusCode == 200 && responseData is List) {
        for (final document in responseData) {
          documents.add(
            DocumentModel.fromJson(document),
          );
        }
      }
      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200
            ? 'Documents fetched successfully'
            : 'Something went wrong',
        'documents': documents,
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Unable to connect to the server',
        'documents': <DocumentModel>[],
      };
    }
  }

  Future<Map<String, dynamic>> getDocument(
    String token,
    String id,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doc/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200
            ? 'Document fetched successfully'
            : responseData['message'] ?? 'Something went wrong',
        'document': response.statusCode == 200
            ? DocumentModel.fromJson(responseData)
            : null,
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Unable to connect to the server',
        'document': null,
      };
    }
  }
  Future<Map<String, dynamic>> nameDocuments({
    required String token,
    required String id,
    required String title,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/doc/name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id': id,
          'title': title,
        }),
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? 'Something went wrong',
        'document': response.statusCode == 200
            ? DocumentModel.fromJson(responseData)
            : null,
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Unable to connect to the server',
        'document': null,
      };
    }
  }
}