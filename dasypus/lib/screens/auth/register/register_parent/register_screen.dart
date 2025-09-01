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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cpfController = TextEditingController();
  final _birthDateController = TextEditingController();
final TextEditingController imagemUrlController = TextEditingController();
  // Variáveis para upload de imagem
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploadingImage = false;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Função para escolher imagem
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

  // Função para upload da imagem
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

  // Formatar CPF
  void _formatCPF(String value) {
    if (value.isEmpty) return;
    
    // Remove caracteres não numéricos
    String numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limita a 11 dígitos
    if (numbers.length > 11) {
      numbers = numbers.substring(0, 11);
    }
    
    // Aplica a máscara
    String formatted = '';
    for (int i = 0; i < numbers.length; i++) {
      if (i == 3 || i == 6) {
        formatted += '.';
      }
      if (i == 9) {
        formatted += '-';
      }
      formatted += numbers[i];
    }
    
    _cpfController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  // Máscara de data (DD/MM/AAAA)
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

  // Validar confirmação de senha
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
    final userId = await SharedPrefsHelper.getUserId();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? fotoUrl;
        if (_selectedImage != null) {
          fotoUrl = await _uploadSelectedImage();
        }

        // Criar objeto Usuario
        final usuario = Usuario(
          nome: _nameController.text.trim(),
          email: _emailController.text.trim(),
          senha: _passwordController.text,
          cpf: _cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
          dataNasc: Validators.parseBrazilianDate(_birthDateController.text) ?? DateTime.now(),
          sobre: " ",
          fotoUrl: imagemUrlController.text, // <- aqui vai a imagem
        );

        // Chamada da API
        final resultado = await _apiService.register(usuario);

        if (resultado['status'] == 'success') {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            // Mostrar SnackBar de sucesso
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Conta criada com sucesso!\nVerifique seu email para ativar sua conta.',
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );

            // Navegar para a tela de login
            AppRoutes.navigateToReplacement(context, AppRoutes.login);
          }
        } else {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro no cadastro: ${resultado['message']}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
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
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo/Ícone
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Criar Conta',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 25),
                        // Campo de nome
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Nome Completo',
                          hintText: 'Digite seu nome completo',
                          keyboardType: TextInputType.name,
                          prefixIcon: Icons.person_outlined,
                          validator: Validators.validateName,
                        ),
                        const SizedBox(height: 16),

                        // Campo de email
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Digite seu email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Campo de CPF
                        CustomTextField(
                          controller: _cpfController,
                          labelText: 'CPF',
                          hintText: '000.000.000-00',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.badge_outlined,
                          validator: Validators.validateCPF,
                          onChanged: _formatCPF,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          
                        ),
                        const SizedBox(height: 16),

                        // Campo de data de nascimento (com máscara e digitação opcional)
                        CustomTextField(
                          controller: _birthDateController,
                          labelText: 'Data de Nascimento',
                          hintText: 'DD/MM/AAAA',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.cake_outlined,
                          validator: (value) => Validators.validateBrazilianDate(value, required: true),
                          onChanged: _formatDate,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          suffixIcon: FutureBuilder<IconButton>(
                          future: calendarIconButton(
                            context: context,
                            controller: _birthDateController,
                            onDatePicked: () => setState(() {}),
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return const Icon(Icons.calendar_today_outlined);
                            }
                          },
                        ),
                        ),
                        const SizedBox(height: 16),

                        // Campo de senha
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Senha',
                          hintText: 'Digite sua senha',
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 16),

                        // Campo de confirmar senha
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirmar Senha',
                          hintText: 'Confirme sua senha',
                          obscureText: !_isConfirmPasswordVisible,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: _validateConfirmPassword,
                        ),
                        
                        const SizedBox(height: 16),

                        // Upload de foto do filho
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Foto do filho (opcional)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 8),
                            if (_isUploadingImage)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: LinearProgressIndicator(),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo),
                                label: const Text("Selecionar Foto"),
                              ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Botão de cadastro
                        CustomButton(
                          text: 'Criar Conta',
                          onPressed: _handleRegister,
                          isLoading: _isLoading,
                          backgroundColor: AppColors.primary,
                          icon: Icons.person_add,
                        ),
                        const SizedBox(height: 24),
                        // Divisor
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: AppColors.textLight),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text('ou', style: AppTextStyles.bodySmall),
                            ),
                            Expanded(
                              child: Divider(color: AppColors.textLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Botão de voltar para login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já tem uma conta? ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                AppRoutes.navigateToReplacement(
                                  context,
                                  AppRoutes.login,
                                );
                              },
                              child: Text(
                                'Faça login',
                                style: AppTextStyles.link.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
        ),
      ),
    );
  }
}