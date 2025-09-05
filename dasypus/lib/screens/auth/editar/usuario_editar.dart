import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dasypus/widgets/calendary_icon.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/models/usuario.dart';
import '../../../../common/routes/app_routes.dart';
import '../../../../config/services/api_service.dart';
import '../../../../common/utils/shared_prefs_helper.dart';
import '../../../../common/utils/validators.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';

class UsuarioEditar extends StatefulWidget {
  const UsuarioEditar({super.key });
  @override
  State<UsuarioEditar> createState() => _UsuarioEditarState();
}

class _UsuarioEditarState extends State<UsuarioEditar> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController imagemUrlController = TextEditingController();
  final TextEditingController sobreController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploadingImage = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;
  int? _userId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    imagemUrlController.dispose();
    sobreController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final userId = await SharedPrefsHelper.getUseralterarId();
      final fotoUrl = await SharedPrefsHelper.getUserFotoUrl();

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'ID do usuário não encontrado. Faça login novamente.';
        });
        return;
      }

      setState(() {
        _userId = userId;
      });

      final resultado = await _apiService.getUserProfile(userId);

      if (resultado['status'] == 'success') {
        final rawData = resultado['data'];
        Map<String, dynamic>? processedData;

        if (rawData is List && rawData.isNotEmpty) {
          processedData = Map<String, dynamic>.from(rawData.first);
        } else if (rawData is Map<String, dynamic>) {
          processedData = Map<String, dynamic>.from(rawData);
        }

        if (processedData != null) {
          setState(() {
            _userData = processedData;
            _isLoading = false;
          });
        } else {
          throw Exception('Dados do perfil inválidos');
        }
      } else {
        throw Exception(resultado['message'] ?? 'Erro ao carregar perfil');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erro ao carregar perfil: $e';
      });
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File imageFile = File(image.path);
        final int fileSizeInBytes = await imageFile.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Imagem muito grande! Máximo permitido: 5MB. '
                  'Imagem: ${fileSizeInMB.toStringAsFixed(2)}MB',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: $e')),
        );
      }
    }
  }

  Future<String?> _uploadSelectedImage() async {
    if (_selectedImage == null) return null;

    try {
      setState(() {
        _isUploadingImage = true;
      });

      final result = await _apiService.uploadImage(
        _selectedImage!,
        userId: 'filho',
        description: 'Foto do filho',
      );

      setState(() {
        _isUploadingImage = false;
      });

      if (result['status'] == 'success') {
        final data = result['data'];
        final String? url = data['url'];
        final String? uploadPath = data['upload_path'];

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no upload: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no upload: $e')),
        );
      }
    }
    return null;
  }

  void _formatCPF(String value) {
    if (value.isEmpty) return;

    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.length > 11) numbers = numbers.substring(0, 11);

    String formatted = '';
    for (int i = 0; i < numbers.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += numbers[i];
    }

    _cpfController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _formatDate(String value) {
    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.length > 8) numbers = numbers.substring(0, 8);
    String formatted = '';
    for (int i = 0; i < numbers.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += numbers[i];
    }
    _birthDateController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }

    if (value != _passwordController.text) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  void _handleRegister() async {
    final userId = await SharedPrefsHelper.getUseralterarId();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? fotoUrl;
        if (_selectedImage != null) {
          fotoUrl = await _uploadSelectedImage();
        }

        final usuario = Usuario(
  nome: _nameController.text.trim().isEmpty ? _userData!['nome'] : _nameController.text.trim(),
  email: _emailController.text.trim().isEmpty ? _userData!['email'] : _emailController.text.trim(),
   senha: _passwordController.text.isEmpty ? '' : _passwordController.text,
  cpf: _cpfController.text.replaceAll(RegExp(r'[^\d]'), '').isEmpty ? _userData!['cpf'] : _cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
  dataNasc: _birthDateController.text.isEmpty 
      ? (Validators.parseBrazilianDate(_userData!['data_nasc'].toString()) ?? DateTime.now())
      : (Validators.parseBrazilianDate(_birthDateController.text) ?? DateTime.now()),
  sobre: sobreController.text.trim().isEmpty ? _userData!['sobre'] : sobreController.text.trim(),
  fotoUrl: imagemUrlController.text.isEmpty ? _userData!['foto_url'] : imagemUrlController.text,
);


        final resultado = await _apiService.updateUser(usuario, userId!);

        if (resultado['status'] == 'success') {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Conta atualizada com sucesso!'),
                backgroundColor: AppColors.success,
              ),
            );

            AppRoutes.navigateToReplacement(context, AppRoutes.dashboard);
          }
        } else {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro na atualização: ${resultado['message']}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro na conexão: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Editar Usuário', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  radius: 32,
                                  child: Icon(Icons.person_add_outlined, size: 36, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(child: Text('Alterar conta', style: AppTextStyles.headlineSmall)),
                              const SizedBox(height: 24),

                              CustomTextField(
                                controller: _nameController,
                                labelText: _userData!['nome'],
                                hintText: 'Digite seu nome',
                                keyboardType: TextInputType.name,
                                prefixIcon: Icons.person_outlined,
                                
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                controller: _emailController,
                                labelText: _userData!['email'],
                                hintText: 'Digite seu email',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                controller: _cpfController,
                                labelText: _userData!['cpf'],
                                hintText: '000.000.000-00',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.badge_outlined,
                                
                                onChanged: _formatCPF,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                controller: _birthDateController,
                                labelText: _userData!['data_nasc'],
                                hintText: 'DD/MM/AAAA',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.cake_outlined,
                                
                                onChanged: _formatDate,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                suffixIcon: FutureBuilder<IconButton>(
                                  future: calendarIconButton(
                                    context: context,
                                    controller: _birthDateController,
                                    onDatePicked: () => setState(() {}),
                                  ),
                                  builder: (context, snapshot) {
                                    return snapshot.connectionState == ConnectionState.done && snapshot.hasData
                                        ? snapshot.data!
                                        : const Icon(Icons.calendar_today_outlined);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                controller: _passwordController,
                                labelText: _userData!['senha'] != null ? 'Senha atual' : 'Senha',
                                hintText: 'Digite sua senha',
                                obscureText: !_isPasswordVisible,
                                prefixIcon: Icons.lock_outlined,
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                                
                              ),
                              const SizedBox(height: 16),

                              CustomTextField(
                                controller: _confirmPasswordController,
                                labelText: _userData!['senha']  != null ? 'Confirme a senha atual' : 'Confirme a senha',
                                hintText: 'Confirme sua senha',
                                obscureText: !_isConfirmPasswordVisible,
                                prefixIcon: Icons.lock_outlined,
                                suffixIcon: IconButton(
                                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                ),
                                
                              ),
                              const SizedBox(height: 24),
                              CustomTextField(
                                controller: sobreController,
                                labelText: _userData!['sobre'] ?? 'Sobre o filho (opcional)',
                              ),
                              const SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Foto do filho (opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  if (_selectedImage != null)
                                    Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _selectedImage!,
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  _isUploadingImage
                                      ? const LinearProgressIndicator()
                                      : OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
                                          onPressed: _pickImage,
                                          icon: const Icon(Icons.photo),
                                          label: const Text("Selecionar Foto"),
                                        ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              CustomButton(
                                text: 'Alterar conta',
                                onPressed: _handleRegister,
                                isLoading: _isLoading,
                                backgroundColor: AppColors.primary,
                                icon: Icons.person_add,
                              ),

                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: AppColors.textLight)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('ou', style: AppTextStyles.bodySmall),
                                  ),
                                  Expanded(child: Divider(color: AppColors.textLight)),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                 
                                  TextButton(
                                    onPressed: () => AppRoutes.navigateToReplacement(context, AppRoutes.home),
                                    child: Text('Voltar para login', style: AppTextStyles.link.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
