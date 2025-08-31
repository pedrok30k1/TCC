import 'package:flutter/material.dart';
import '../common/models/image_model.dart';
import '../config/services/image_search_service.dart';

class ImageSearchWidget extends StatefulWidget {
  final Function(String) onImageSelected;
  final String? currentImageName;
  final String label;
  final String hintText;

  const ImageSearchWidget({
    Key? key,
    required this.onImageSelected,
    this.currentImageName,
    this.label = 'Buscar Imagem',
    this.hintText = 'Digite o nome da imagem...',
  }) : super(key: key);

  @override
  State<ImageSearchWidget> createState() => _ImageSearchWidgetState();
}

class _ImageSearchWidgetState extends State<ImageSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ImageSearchService _imageService = ImageSearchService();

  ImageModel? _currentImage;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    if (widget.currentImageName != null) {
      _searchController.text = widget.currentImageName!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchImage() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _error = 'Digite o nome da imagem';
        _currentImage = null;
      });
      return;
    }

    setState(() {
      _error = '';
      _isLoading = true;
      _currentImage = null;
    });

    try {
      final image = await _imageService.searchSingleImage(
        _searchController.text.trim(),
      );

      setState(() {
        if (image != null) {
          _currentImage = image;
          _error = '';
        } else {
          _error = 'Imagem não encontrada';
          _currentImage = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _currentImage = null;
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _error = '';
      _currentImage = null;
    });
  }

  void _clearError() {
    setState(() {
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFB3E5FC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          // Campo de busca
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _searchImage,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (value) => _searchImage(),
          ),

          const SizedBox(height: 8),

          // Botão de busca
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _searchController.text.trim().isEmpty ? null : _searchImage,
              icon: const Icon(Icons.search),
              label: const Text('Buscar Imagem'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Status da busca
          if (_isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Buscando imagem...'),
                ],
              ),
            ),

          // Erro na busca
          if (_error.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearError,
                    color: Colors.red[700],
                  ),
                ],
              ),
            ),

          // Imagem encontrada
          if (_currentImage != null) _buildImageResult(_currentImage!),
        ],
      ),
    );
  }

  Widget _buildImageResult(ImageModel image) {
    final imageUrl = _imageService.getImageUrl(image.uploadPath);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Imagem encontrada: ${image.originalName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Prévia da imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red, size: 40),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Informações da imagem
          Text(
            'Tipo: ${image.fileType.toUpperCase()} | Tamanho: ${image.formattedFileSize}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),

          const SizedBox(height: 12),

          // Botões de ação
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Usar o uploadPath para construir a URL completa
                    widget.onImageSelected(image.uploadPath);
                    _clearSearch();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Usar Esta Imagem'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
