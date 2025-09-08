import 'package:dasypus/common/models/categoria.dart';
import 'package:dasypus/config/services/api_service.dart';
import 'package:dasypus/common/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditarCategoriaPage extends StatefulWidget {
  final Categoria categoria;

  const EditarCategoriaPage({Key? key, required this.categoria}) : super(key: key);

  @override
  State<EditarCategoriaPage> createState() => _EditarCategoriaPageState();
}

class _EditarCategoriaPageState extends State<EditarCategoriaPage> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController fotoUrlController = TextEditingController();

  int? userId;
  Color temaCor = Colors.red;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    // Preencher dados iniciais da categoria recebida
    nomeController.text = widget.categoria.nome;
    fotoUrlController.text = widget.categoria.fotoUrl ?? "";
    temaCor = Color(int.parse("0xFF${widget.categoria.temaCor?.replaceAll('#', '')}"));
  }

  Future<void> _loadUserId() async {
    final id = await SharedPrefsHelper.getUserFilhoId();
    setState(() {
      userId = id;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadSelectedImage() async {
    if (_selectedImage == null) return;
    try {
      final result = await _apiService.uploadImage(
        _selectedImage!,
        userId: userId?.toString() ?? 'app',
        description: 'Category image update',
      );
      if (result['status'] == 'success') {
        final String? url = result['data']['url'];
        if (url != null) {
          fotoUrlController.text = url.split('/').last;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no upload: $e')),
      );
    }
  }

  void escolherCor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha a cor do tema'),
        content: BlockPicker(
          pickerColor: temaCor,
          onColorChanged: (color) => setState(() => temaCor = color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> atualizarCategoria() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não encontrado!')),
      );
      return;
    }

    // Upload da imagem se mudou
    if (_selectedImage != null) {
      await _uploadSelectedImage();
    }
     final idCategoria = SharedPrefsHelper.getCategoriaId();
    final Categoria categoriaAtualizada = Categoria(
      id: await idCategoria, // manter o mesmo ID
      nome: nomeController.text,
      fotoUrl: fotoUrlController.text.isNotEmpty ? fotoUrlController.text : null,
      temaCor: '#${temaCor.value.toRadixString(16).padLeft(8, '0').substring(2)}', 
      idUsuario: 0,
    );

    await _apiService.updateCategory(categoriaAtualizada);
    Navigator.pop(context, true); // retorna true indicando alteração
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(title: const Text("Editar Categoria")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Preview
              Card(
                color: temaCor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : (widget.categoria.fotoUrl != null
                          ? Image.network("${widget.categoria.fotoUrl}", fit: BoxFit.cover)
                          : Center(
                              child: Text(
                                nomeController.text,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            )),
                ),
              ),
              const SizedBox(height: 20),

              // Nome
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome da Categoria"),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Seleção de cor
              ElevatedButton(
                onPressed: escolherCor,
                child: const Text("Escolher Cor"),
              ),
              const SizedBox(height: 20),

              // Upload de imagem
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text("Selecionar Nova Imagem"),
              ),
              const SizedBox(height: 30),

              // Botão atualizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: atualizarCategoria,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  child: const Text(
                    "Atualizar Categoria",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
