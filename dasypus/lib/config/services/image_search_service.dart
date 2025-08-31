import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../common/models/image_model.dart';
import '../settings/api_settings.dart';

class ImageSearchService {
  // URL base para o serviço de imagens - usa a configuração centralizada
  static String get imageServiceUrl => ApiConfig.currentImageUrl;
  
  // URL base da API principal (para referência)
  static String get apiBaseUrl => ApiConfig.currentUrl;

  // Buscar uma imagem específica pelo nome
  Future<ImageModel?> searchSingleImage(String imageName) async {
    try {
      if (imageName.trim().isEmpty) {
        throw Exception('Nome da imagem é obrigatório');
      }

      final uri = Uri.parse(
        '$imageServiceUrl/search_single_image.php',
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
      return '$imageServiceUrl/$uploadPath';
    }
    // Se já for uma URL completa, retorna como está
    if (uploadPath.startsWith('http://') || uploadPath.startsWith('https://')) {
      return uploadPath;
    }
    // Se for apenas um nome de arquivo, constrói a URL completa
    return '$imageServiceUrl/uploads/$uploadPath';
  }
}
