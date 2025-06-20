import 'dart:convert'; // For jsonEncode, jsonDecode
import 'dart:io'; // For File
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:flutter/material.dart'; // For UI context (e.g., ScaffoldMessenger)

// --- Define your API Gateway Endpoints ---
// 1. Endpoint for requesting pre-signed S3 URLs (Lambda 1)
const String _presignedUrlLambdaEndpoint =
    'YOUR_API_GATEWAY_GET_PRESIGNED_URLS_URL';
//    Example: 'https://xxxxxxx.execute-api.us-east-1.amazonaws.com/prod/getPresignedUrls'

// 2. Endpoint for adding property metadata to DynamoDB (Lambda 2)
const String _addPropertyLambdaEndpoint = 'YOUR_API_GATEWAY_ADD_PROPERTY_URL';
//    Example: 'https://xxxxxxx.execute-api.us-east-1.amazonaws.com/prod/addProperty'

class PropertyService {
  final ImagePicker _picker = ImagePicker();

  // --- Step A.1: Pick Images ---
  Future<List<XFile>?> pickMultipleImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage(
      imageQuality: 70, // Recommended: Adjust quality for web/mobile use
    );
    return selectedImages;
  }

  // --- Step A.2: Request Pre-signed S3 URLs from Lambda ---
  Future<List<String>?> _getPresignedUrlsFromLambda(
    final BuildContext context,
    final List<XFile> imageFiles,
  ) async {
    if (imageFiles.isEmpty) return [];

    try {
      // Prepare data for the Lambda: list of image types (e.g., 'image/jpeg')
      final filesToUpload = imageFiles.map((final file) {
        final mimeType = _getMimeType(file.path);
        return {
          'filename': file.name, // Or a unique ID
          'contentType': mimeType ?? 'application/octet-stream',
        };
      }).toList();

      final response = await http.post(
        Uri.parse(_presignedUrlLambdaEndpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'files': filesToUpload}),
      );

      if (response.statusCode == 200) {
        final urls = List<dynamic>.from(jsonDecode(response.body)['urls'] as List);
        return List<String>.from(urls); // Return the list of pre-signed URLs
      } else {
        _showSnackBar(
          context,
          'Failed to get pre-signed URLs. Status: ${response.statusCode} | ${response.body}',
          Colors.red,
        );
        print('Error getting pre-signed URLs: ${response.body}');
        return null;
      }
    } catch (e) {
      _showSnackBar(
        context,
        'Error requesting pre-signed URLs: $e',
        Colors.red,
      );
      print('Error requesting pre-signed URLs: $e');
      return null;
    }
  }

  // Helper to determine MIME type (basic)
  String? _getMimeType(final String filePath) {
    if (filePath.toLowerCase().endsWith('.jpg') ||
        filePath.toLowerCase().endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (filePath.toLowerCase().endsWith('.png')) {
      return 'image/png';
    } else if (filePath.toLowerCase().endsWith('.gif')) {
      return 'image/gif';
    }
    // Add more types as needed
    return null; // Let S3 try to infer if not specified
  }

  // --- Step A.3: Upload Images Directly to S3 using Pre-signed URLs ---
  Future<List<String>?> _uploadImagesToS3(
    final BuildContext context,
    final List<XFile> imageFiles,
    final List<String> presignedUrls,
  ) async {
    if (imageFiles.isEmpty ||
        presignedUrls.isEmpty ||
        imageFiles.length != presignedUrls.length) {
      _showSnackBar(
        context,
        'Image files and pre-signed URLs mismatch.',
        Colors.red,
      );
      return null;
    }

    final finalS3Urls = <String>[];
    try {
      for (var i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final presignedUrl = presignedUrls[i];

        // Read image bytes
        final List<int> imageBytes = await imageFile.readAsBytes();

        // Perform HTTP PUT directly to S3
        final response = await http.put(
          Uri.parse(presignedUrl),
          headers: {
            'Content-Type':
                _getMimeType(imageFile.path) ?? 'application/octet-stream',
            // No need for 'Authorization' here as the URL is pre-signed
          },
          body: imageBytes,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Extract the actual S3 object URL (the part before the query parameters in the presigned URL)
          // This assumes the presigned URL is like "https://bucket.s3.region.amazonaws.com/path/to/object?AWSAccessKeyId=..."
          final s3ObjectUrl = presignedUrl.split('?')[0];
          finalS3Urls.add(s3ObjectUrl);
          print('Uploaded ${imageFile.name} to S3: $s3ObjectUrl');
        } else {
          _showSnackBar(
            context,
            'Failed to upload image ${imageFile.name} to S3. Status: ${response.statusCode} | ${response.body}',
            Colors.red,
          );
          print('Error uploading image to S3: ${response.body}');
          return null; // Fail if any upload fails
        }
      }
      return finalS3Urls; // Return list of final S3 object URLs
    } catch (e) {
      _showSnackBar(context, 'Error uploading images to S3: $e', Colors.red);
      print('Error uploading images to S3: $e');
      return null;
    }
  }

  // --- Step A.4: Post Property Metadata + S3 URLs to Main Lambda ---
  Future<void> addPropertyMetadata({
    required final BuildContext context,
    required final String title,
    required final String description,
    required final String location,
    required final double price,
    required final List<String> imageUrls, // Now receiving S3 URLs
  }) async {
    try {
      final propertyData = <String, dynamic>{
        'title': title,
        'description': description,
        'location': location,
        'price': price,
        'imageUrls': imageUrls, // List of S3 URLs
      };

      final response = await http.post(
        Uri.parse(_addPropertyLambdaEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add any authentication headers if needed
        },
        body: jsonEncode(propertyData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackBar(
          context,
          'Property metadata added successfully!',
          Colors.green,
        );
        print(
          'Property metadata added successfully! Response: ${response.body}',
        );
      } else {
        _showSnackBar(
          context,
          'Failed to add property metadata. Status: ${response.statusCode} | ${response.body}',
          Colors.red,
        );
        print('Error adding property metadata: ${response.body}');
      }
    } catch (e) {
      _showSnackBar(context, 'Error adding property metadata: $e', Colors.red);
      print('Error adding property metadata: $e');
    }
  }

  // --- Combined Workflow Function ---
  Future<void> addPropertyFullWorkflow(
    final BuildContext context, {
    required final String title,
    required final String description,
    required final String location,
    required final double price,
  }) async {
    // 1. Pick images
    final pickedImages = await pickMultipleImages();
    if (pickedImages == null || pickedImages.isEmpty) {
      _showSnackBar(context, 'No images selected.', Colors.orange);
      return;
    }

    // 2. Get pre-signed URLs from Lambda
    _showSnackBar(context, 'Requesting S3 upload URLs...', Colors.blue);
    final presignedUrls = await _getPresignedUrlsFromLambda(
      context,
      pickedImages,
    );
    if (presignedUrls == null) {
      _showSnackBar(context, 'Failed to get S3 URLs. Aborting.', Colors.red);
      return;
    }

    // 3. Upload images directly to S3
    _showSnackBar(context, 'Uploading images to S3...', Colors.blue);
    final finalS3Urls = await _uploadImagesToS3(
      context,
      pickedImages,
      presignedUrls,
    );
    if (finalS3Urls == null) {
      _showSnackBar(
        context,
        'Failed to upload images to S3. Aborting.',
        Colors.red,
      );
      return;
    }

    // 4. Post property metadata with S3 URLs to main Lambda
    _showSnackBar(
      context,
      'Adding property details to database...',
      Colors.blue,
    );
    await addPropertyMetadata(
      context: context,
      title: title,
      description: description,
      location: location,
      price: price,
      imageUrls: finalS3Urls,
    );
  }

  void _showSnackBar(final BuildContext context, final String message, final Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
