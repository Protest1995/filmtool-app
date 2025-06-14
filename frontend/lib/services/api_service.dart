import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/moodboard.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';

class ApiService {
  final String baseUrl = "http://localhost:8080/api";

  Future<List<Moodboard>> getMoodboards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/moodboards'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<Moodboard> moodboards = body.map((dynamic item) => Moodboard.fromJson(item)).toList();
        return moodboards;
      } else {
        throw Exception('Failed to load moodboards. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server or process data: $e');
    }
  }

  Future<Moodboard> getMoodboardDetails(int moodboardId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/moodboards/$moodboardId'));

      if (response.statusCode == 200) {
        return Moodboard.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to load moodboard details. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server or process data: $e');
    }
  }

  Future<Moodboard> createMoodboard(String title, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/moodboards'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'description': description,
        // coverImageUrl is not sent on creation, it's updated later
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Moodboard.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create moodboard. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<void> uploadCoverImage(int moodboardId, XFile imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/moodboards/$moodboardId/uploadCoverImage'),
    );

    http.MultipartFile multipartFile;

    if (kIsWeb) {
      final imageBytes = await imageFile.readAsBytes();
      final mimeType = imageFile.mimeType ?? lookupMimeType(imageFile.name) ?? 'application/octet-stream';
      multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: imageFile.name,
        contentType: MediaType.parse(mimeType),
      );
    } else {
      final mimeType = lookupMimeType(imageFile.path) ?? 'application/octet-stream';
      multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: imageFile.name,
        contentType: MediaType.parse(mimeType),
      );
    }

    request.files.add(multipartFile);

    try {
        final response = await request.send();
        if (response.statusCode != 200) {
          final responseBody = await response.stream.bytesToString();
          throw Exception('Failed to upload cover image. Status code: ${response.statusCode}, Body: $responseBody');
        }
    } catch (e) {
        throw Exception('Failed to upload cover image: $e');
    }
  }

  Future<void> addImageToMoodboard(int moodboardId, XFile imageFile) async {
     var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/moodboards/$moodboardId/images'),
    );

    http.MultipartFile multipartFile;

    if (kIsWeb) {
      final imageBytes = await imageFile.readAsBytes();
      final mimeType = imageFile.mimeType ?? lookupMimeType(imageFile.name) ?? 'application/octet-stream';
      multipartFile = http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: imageFile.name,
        contentType: MediaType.parse(mimeType),
      );
    } else {
      final mimeType = lookupMimeType(imageFile.path) ?? 'application/octet-stream';
      multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: imageFile.name,
        contentType: MediaType.parse(mimeType),
      );
    }

    request.files.add(multipartFile);

    try {
        final response = await request.send();
        if (response.statusCode != 200) {
          final responseBody = await response.stream.bytesToString();
          throw Exception('Failed to add image. Status code: ${response.statusCode}, Body: $responseBody');
        }
    } catch (e) {
        throw Exception('Failed to add image: $e');
    }
  }
} 