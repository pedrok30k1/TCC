import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../common/constants/api_constants.dart';

class ImageService {
  /// Upload de imagem usando multipart/form-data
  static Future<Map<String, dynamic>> uploadImage(
    File imageFile, {
    String? userId,
    String? description,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.uploadImageUrl),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType.parse(_getMimeType(imageFile.path)),
        ),
      );

      if (userId != null) request.fields['user_id'] = userId;
      if (description != null) request.fields['description'] = description;

      final streamed = await request.send().timeout(ApiConstants.requestTimeout);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Listar imagens
  static Future<Map<String, dynamic>> getImages() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.listImagesUrl))
          .timeout(ApiConstants.requestTimeout);
      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Deletar imagem por ID
  static Future<Map<String, dynamic>> deleteImage(String imageId) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.deleteImageUrl),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({'image_id': imageId}),
          )
          .timeout(ApiConstants.requestTimeout);
      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'status': data['status'] ?? 'success',
          'message': data['message'] ?? 'Operação realizada com sucesso',
          'data': data['data'] ?? data['images'] ?? data,
        };
      } else {
        return {
          'status': data['status'] ?? 'error',
          'message': data['message'] ?? 'Erro ao processar requisição',
          'data': data['data'] ?? data,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro ao processar resposta: $e',
      };
    }
  }

  static String _getMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}


