import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart' as app;
import '../widgets/search_bar_widget.dart';
import '../models/image_model.dart';
import '../services/image_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Busca de Imagem',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Consumer<app.ImageProvider>(
        builder: (context, imageProvider, child) {
          return Column(
            children: [
              // Barra de busca
              SearchBarWidget(
                onSearch: (query) {
                  imageProvider.searchImage(query);
                },
                onClear: () {
                  imageProvider.clearSearch();
                },
                hintText: 'Digite o nome da imagem...',
              ),

              // Conteúdo principal
              Expanded(child: _buildContent(imageProvider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(app.ImageProvider imageProvider) {
    if (imageProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Buscando imagem...'),
          ],
        ),
      );
    }

    if (imageProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.0, color: Colors.red[300]),
            const SizedBox(height: 16.0),
            Text(
              'Erro na busca',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              imageProvider.error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                imageProvider.clearError();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    if (!imageProvider.hasImage) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_search, size: 64.0, color: Colors.grey[400]),
            const SizedBox(height: 16.0),
            Text(
              'Digite o nome da imagem para buscar',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              'A busca é feita pelo nome original ou nome do arquivo',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Mostrar a imagem encontrada
    return _buildImageDisplay(imageProvider.currentImage!);
  }

  Widget _buildImageDisplay(ImageModel image) {
    final imageService = ImageService();
    final imageUrl = imageService.getImageUrl(image.uploadPath);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagem principal
          Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 40.0),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24.0),

          // Informações da imagem
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações da Imagem',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  _buildInfoRow('Nome:', image.originalName),
                  if (image.description.isNotEmpty)
                    _buildInfoRow('Descrição:', image.description),
                  _buildInfoRow('Tipo:', image.fileType.toUpperCase()),
                  _buildInfoRow('Tamanho:', image.formattedFileSize),
                  _buildInfoRow('Data:', image.formattedDate),
                  _buildInfoRow('ID:', image.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16.0,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16.0))),
        ],
      ),
    );
  }
}
