import 'package:dasypus/common/models/categoria.dart';
import 'package:dasypus/config/services/api_service.dart';
import 'package:dasypus/common/constants/api_constants.dart';
import 'package:dasypus/common/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CriarCategoriaPage extends StatefulWidget {
  const CriarCategoriaPage({Key? key}) : super(key: key);

  @override
  State<CriarCategoriaPage> createState() => _CriarCategoriaPageState();
}

class _CriarCategoriaPageState extends State<CriarCategoriaPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController fotoUrlController = TextEditingController();
  final ApiService _apiService = ApiService();
  int? userId;
  Color temaCor = Colors.red;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await SharedPrefsHelper.getUserFilhoId();
    setState(() {
      userId = id;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Verificar tamanho da imagem
        final File imageFile = File(image.path);
        final int fileSizeInBytes = await imageFile.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        // Limite de 5MB
        if (fileSizeInMB > 5.0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Imagem muito grande! Tamanho máximo permitido: 5MB. '
                'Imagem selecionada: ${fileSizeInMB.toStringAsFixed(2)}MB',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });

        // Mostrar mensagem de sucesso com o tamanho
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imagem selecionada: ${fileSizeInMB.toStringAsFixed(2)}MB',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao selecionar imagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadSelectedImage() async {
    if (_selectedImage == null) {
      return; // Just return without showing error, since this will be called from save
    }
    try {
      final result = await _apiService.uploadImage(
        _selectedImage!,
        userId: userId?.toString() ?? 'app',
        description: 'Category image upload',
      );
      if (result['status'] == 'success') {
        final data = result['data'];
        final String? url = data['url'];
        final String? uploadPath = data['upload_path'];

        // Extrair apenas o nome do arquivo da URL ou caminho
        String fileName = '';
        if (url != null && url.isNotEmpty) {
          fileName = url.split('/').last;
        } else if (uploadPath != null) {
          fileName = uploadPath.split('/').last;
        }

        if (fileName.isNotEmpty) {
          fotoUrlController.text = fileName;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no upload: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro no upload: $e')));
    }
  }

  void escolherCor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Escolha a cor do tema'),
          content: BlockPicker(
            pickerColor: temaCor,
            onColorChanged: (color) {
              setState(() => temaCor = color);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void salvarCategoria() async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Usuário não encontrado!')));
      return;
    }

    // Upload image first if selected
    if (_selectedImage != null) {
      await _uploadSelectedImage();
    }

    final Categoria categoria = Categoria(
      nome: nomeController.text,
      idUsuario: userId!,
      fotoUrl:
          fotoUrlController.text.isNotEmpty ? fotoUrlController.text : null,
      temaCor:
          '#${temaCor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    );

    await _apiService.createCategory(categoria);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // azulClaro
      appBar: AppBar(title: const Text("Criar Categoria")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight -
                  40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    // Card de preview
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFB3E5FC), // azulClaroEscuro
                      ),
                      child: Column(
                        children: [
                          Card(
                            margin: const EdgeInsets.all(12.0),
                            color: temaCor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: double.infinity,
                              child:
                                  _selectedImage != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _selectedImage!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Center(
                                        child: Text(
                                          nomeController.text.isEmpty
                                              ? "Categoria"
                                              : nomeController.text,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 14,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...[
                                    Colors.red,
                                    Colors.blue,
                                    Colors.green,
                                    Colors.orange,
                                    Colors.purple,
                                    Colors.teal,
                                    Colors.brown,
                                    Colors.pink,
                                  ].map(
                                    (color) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: GestureDetector(
                                        onTap:
                                            () =>
                                                setState(() => temaCor = color),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  temaCor == color
                                                      ? Colors.black
                                                      : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo Nome
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFB3E5FC), // azulClaroEscuro
                      ),
                      child: TextField(
                        controller: nomeController,
                        decoration: const InputDecoration(
                          labelText: "Nome da Categoria",
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo Foto da Categoria
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Upload de nova imagem
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFB3E5FC),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upload de imagem (opcional)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tamanho máximo: 5MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedImage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              if (_selectedImage != null)
                                const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Selecionar Imagem'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Botão salvar
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 25,
                        ),
                        backgroundColor: Colors.deepOrangeAccent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.grey,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed:
                          nomeController.text.trim().isEmpty
                              ? null
                              : salvarCategoria,
                      child: const Text("Salvar"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
