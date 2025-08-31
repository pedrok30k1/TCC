import 'package:flutter/foundation.dart';
import '../models/image_model.dart';
import '../services/image_service.dart';

class ImageProvider with ChangeNotifier {
  final ImageService _imageService = ImageService();
  
  ImageModel? _currentImage;
  bool _isLoading = false;
  String _error = '';
  String _searchTerm = '';

  // Getters
  ImageModel? get currentImage => _currentImage;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchTerm => _searchTerm;
  bool get hasImage => _currentImage != null;

  // Buscar uma imagem específica
  Future<void> searchImage(String imageName) async {
    if (imageName.trim().isEmpty) {
      _error = 'Digite o nome da imagem';
      _currentImage = null;
      notifyListeners();
      return;
    }

    _searchTerm = imageName.trim();
    _error = '';
    _isLoading = true;
    _currentImage = null;
    notifyListeners();

    try {
      final image = await _imageService.searchSingleImage(imageName);
      
      if (image != null) {
        _currentImage = image;
        _error = '';
      } else {
        _error = 'Imagem não encontrada';
        _currentImage = null;
      }
    } catch (e) {
      _error = e.toString();
      _currentImage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpar busca
  void clearSearch() {
    _searchTerm = '';
    _error = '';
    _currentImage = null;
    notifyListeners();
  }

  // Limpar erro
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
