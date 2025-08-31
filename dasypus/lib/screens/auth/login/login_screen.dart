import 'dart:math';

import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../common/utils/validators.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../config/services/api_service.dart';
import '../../../common/models/usuario.dart';
import '../../../common/routes/app_routes.dart';
import '../../../common/utils/shared_prefs_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // ATIVADO: Validação do formulário
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Chamada real da API
        final resultado = await _apiService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (resultado['status'] == 'success') {
          final rawData = resultado['data'];

          // Lidar com diferentes tipos de resposta da API
          Map<String, dynamic> data;
          if (rawData is List && rawData.isNotEmpty) {
            // Se é uma lista, pegar o primeiro item
            data = Map<String, dynamic>.from(rawData.first);
          } else if (rawData is Map<String, dynamic>) {
            // Se é um Map, usar diretamente
            data = Map<String, dynamic>.from(rawData);
          } else {
            throw Exception('Formato de dados inválido da API');
          }

          // Debug: mostrar os dados antes de criar o objeto
          print('🔍 Dados para criar Usuario:');
          data.forEach((key, value) {
            print('  $key: $value (${value.runtimeType})');
          });

          // Criar objeto Usuario a partir dos dados da API
          final usuario = Usuario(
            id: data['id'],
            nome: data['nome'] ?? 'Nome não informado',
            email: data['email'] ?? 'email@exemplo.com',
            senha: 'senha foi criptografada', // Não armazenar senha no objeto
            cpf: data['cpf'] ?? '',
            dataNasc: DateTime.parse(
              data['data_criacao'] ?? DateTime.now().toIso8601String(),
            ),
            sobre: data['sobre'],
            fotoUrl: data['foto_url'],
            idPai: data['id_pai'],
            tipo: data['tipo_usuario'],
          );

          // Salvar ID do usuário no SharedPreferences
          if (usuario.id != null) {
            final saved = await SharedPrefsHelper.saveUserId(usuario.id!);
            final nome = await SharedPrefsHelper.saveUserName(usuario.nome);
            if(usuario.idPai == null ) {
              AppRoutes.navigateToReplacement(context, AppRoutes.dashboard);
            } else {
              // colocar a tela home filho (ainda nao criada)
              AppRoutes.navigateToReplacement(context, AppRoutes.listeFilho);
            }
            if (saved) {
              print('✅ ID do usuário salvo: ${usuario.id}');
            } else {
              print('❌ Erro ao salvar ID do usuário');
            }
          }

          setState(() {
            _isLoading = false;
          });

          // Navegar para a tela principal após login
          if (mounted) {
            // Mostrar SnackBar com os dados
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Login realizado com sucesso!',
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

            // Mostrar diálogo com os dados do usuário
  


          }
        } else {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro no login: ${resultado['message']}'),
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

  void _showLoginDetailsDialog(Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 24),
              const SizedBox(width: 8),
              const Text('Login Realizado'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dados do usuário:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nome:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(usuario.nome, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Email:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(usuario.email, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.badge,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CPF:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(usuario.cpf, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.cake,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data de Nascimento:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${usuario.dataNasc.day.toString().padLeft(2, '0')}/${usuario.dataNasc.month.toString().padLeft(2, '0')}/${usuario.dataNasc.year}',
                      style: AppTextStyles.bodyMedium,
                    ),
                    if (usuario.tipo != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tipo:',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(usuario.tipo!, style: AppTextStyles.bodyMedium),
                    ],
                    if (usuario.sobre != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sobre:',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(usuario.sobre!, style: AppTextStyles.bodyMedium),
                    ],
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            Icons.lock_outline,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Bem-vindo de volta!',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faça login para continuar',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),

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
                        const SizedBox(height: 8),

                        // Esqueci a senha
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              // Navegar para tela de configurações (exemplo)
                              AppRoutes.navigateTo(context, AppRoutes.settings);
                            },
                            child: Text(
                              'Esqueci a senha?',
                              style: AppTextStyles.link,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botão de login
                        CustomButton(
                          text: 'Entrar',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          backgroundColor: AppColors.primary,
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

                        // Botão de cadastro
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Não tem uma conta?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navegar para tela de cadastro
                                AppRoutes.navigateTo(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: Text(
                                'Cadastre-se',
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
