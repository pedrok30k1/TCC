import 'dart:io';

import 'package:dasypus/common/models/card.dart' as models;
import 'package:dasypus/common/utils/shared_prefs_helper.dart';
import 'package:dasypus/config/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

class CardEditar extends StatefulWidget {
  const CardEditar({super.key});

  @override
  State<CardEditar> createState() => _State();
}

class _State extends State<CardEditar> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController imagemUrlController = TextEditingController();
  final TextEditingController fonteController = TextEditingController();

  final ApiService _apiService = ApiService();
  int? categoriaId;
  Color temaCor = Colors.red;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploadingImage = false;
  final FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    _loadCategoriaId();
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
        userId: 'app',
        description: 'Card image upload',
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
          imagemUrlController.text = fileName;
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

  Future<void> _loadCategoriaId() async {
    final id = await SharedPrefsHelper.getIdCard();
    setState(() {
      categoriaId = id;
    });
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

  void salvarCard() async {
    if (categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria não encontrada!')),
      );
      return;
    }

    // Upload image first if selected
    if (_selectedImage != null) {
      await _uploadSelectedImage();
    }

    final models.Card novoCard = models.Card(
      titulo: tituloController.text,
      descricao: descricaoController.text,
      imagemUrl:
          imagemUrlController.text.isNotEmpty ? imagemUrlController.text : null,
      temaCor:
          '#${temaCor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
      fonte: fonteController.text,
      id: categoriaId!, 
      idCategoria: 0,
    );

    await _apiService.updateCard(novoCard);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // azulClaro
      appBar: AppBar(title: const Text("Criar Card")),
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
                    // Pré-visualização do Card
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
                              height: MediaQuery.of(context).size.height * 0.25,
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
                                      : Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              tituloController.text.isEmpty
                                                  ? "Título"
                                                  : tituloController.text,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              descricaoController.text.isEmpty
                                                  ? "Descrição..."
                                                  : descricaoController.text,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
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

                    // Campo Título
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFB3E5FC),
                      ),
                      child: TextField(
                        controller: tituloController,
                        decoration: const InputDecoration(
                          labelText: "Título do Card",
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo Descrição
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFB3E5FC),
                      ),
                      child: TextField(
                        controller: descricaoController,
                        decoration: InputDecoration(
                          labelText: "Insira sua frase",
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.campaign,
                            ), // ícone de megafone
                            onPressed: () {
                              speak(descricaoController.text);
                            },
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo/Seção Imagem
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
                                    height: 160,
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
                    const SizedBox(height: 16),

                    // Campo Fonte
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFB3E5FC),
                      ),
                      child: TextField(
                        controller: fonteController,
                        decoration: const InputDecoration(
                          labelText: "Fonte (A, B, C...)",
                        ),
                      ),
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
                          tituloController.text.trim().isEmpty
                              ? null
                              : salvarCard,
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