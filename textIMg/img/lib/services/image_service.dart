import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image_model.dart';

class ImageService {
  static const String baseUrl =
      'http://192.168.1.113/textIMg'; // Ajuste para sua URL local

  // Buscar uma imagem específica pelo nome
  Future<ImageModel?> searchSingleImage(String imageName) async {
    try {
      if (imageName.trim().isEmpty) {
        throw Exception('Nome da imagem é obrigatório');
      }

      final uri = Uri.parse(
        '$baseUrl/search_single_image.php',
      ).replace(queryParameters: {'name': imageName.trim()});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return ImageModel.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Erro desconhecido');
        }
      } else if (response.statusCode == 404) {
        // Imagem não encontrada
        return null;
      } else {
        throw Exception('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar imagem: $e');
    }
  }

  String getImageUrl(String uploadPath) {
    // Converte o caminho do upload para uma URL acessível
    if (uploadPath.startsWith('uploads/')) {
      return '$baseUrl/$uploadPath';
    }
    return uploadPath;
  }
}
