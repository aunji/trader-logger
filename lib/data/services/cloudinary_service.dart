import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/cloudinary_config.dart';

/// Service for uploading images to Cloudinary
class CloudinaryService {
  /// Upload an image file to Cloudinary
  ///
  /// Returns a Map containing Cloudinary response data including:
  /// - secure_url: The HTTPS URL of the uploaded image
  /// - public_id: The unique identifier for the image in Cloudinary
  Future<Map<String, dynamic>> uploadImage(
    File file, {
    String? folder,
  }) async {
    final uri = Uri.parse(CloudinaryConfig.uploadUrl);

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset;

    // Set folder path if provided
    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }

    // Add image file to request
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    // Send request
    final response = await request.send();
    final respBody = await response.stream.bytesToString();

    // Check for errors
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Cloudinary upload failed: ${response.statusCode} $respBody',
      );
    }

    // Parse and return response
    return Map<String, dynamic>.from(jsonDecode(respBody) as Map);
  }

  /// Delete an image from Cloudinary using its public_id
  /// Note: This requires a signed request with API credentials
  /// For now, we'll skip deletion to keep the app simple
  Future<void> deleteImage(String publicId) async {
    // TODO: Implement delete via Cloud Function or backend service
    // Cannot be done directly from client without exposing API secret
    throw UnimplementedError(
      'Image deletion should be handled via Cloud Function or backend service',
    );
  }
}
