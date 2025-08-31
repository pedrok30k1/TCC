import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../config/services/api_service.dart';
import '../../../../common/utils/shared_prefs_helper.dart';
import '../../../../common/routes/app_routes.dart';
import '../../../../common/models/usuario.dart';

class ProfileScreenFilho extends StatefulWidget {
  const ProfileScreenFilho({super.key});

  @override
  State<ProfileScreenFilho> createState() => _ProfileScreenFilhoState();
}

class _ProfileScreenFilhoState extends State<ProfileScreenFilho> {
  int? _userId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;
  final ApiService _apiService = ApiService();

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

      // Recuperar ID do usuário salvo
      final userId = await SharedPrefsHelper.getUserFilhoId();
      
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

      // Buscar dados do perfil na API
      final resultado = await _apiService.getUserProfile(userId);

      if (resultado['status'] == 'success') {
        // Tratar diferentes tipos de resposta da API
        dynamic rawData = resultado['data'];
        Map<String, dynamic>? processedData;

        // Debug: mostrar o tipo de dados recebido
        print('🔍 Tipo de dados recebido: ${rawData.runtimeType}');
        print('🔍 Conteúdo dos dados: $rawData');

        if (rawData is List && rawData.isNotEmpty) {
          // Se é uma lista, pegar o primeiro item
          print('📋 Processando lista com ${rawData.length} itens');
          processedData = Map<String, dynamic>.from(rawData.first);
        } else if (rawData is Map<String, dynamic>) {
          // Se é um Map, usar diretamente
          print('📋 Processando Map diretamente');
          processedData = Map<String, dynamic>.from(rawData);
        } else {
          print('❌ Tipo de dados não suportado: ${rawData.runtimeType}');
          throw Exception('Formato de dados inválido da API: ${rawData.runtimeType}');
        }

        print('✅ Dados processados com sucesso: $processedData');
        print('✅ Dados processados com sucesso: ${processedData['nome']}');
        print('✅ Dados processados com sucesso: ${processedData['email']}');
        print('✅ Dados processados com sucesso: ${processedData['cpf']}');
        print('✅ Dados processados com sucesso: ${processedData['data_nasc']}');
        print('✅ Dados processados com sucesso: ${processedData['foto_url']}');
        print('✅ Dados processados com sucesso: ${processedData['legenda']}');
        print('✅ Dados processados com sucesso: ${processedData['id_pai']}');
        setState(() {
          _userData = processedData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = resultado['message'] ?? 'Erro ao carregar perfil';
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar perfil: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erro ao carregar perfil: $e';
      });
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon, {Color? iconColor}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonDataCard() {
    if (_userData == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Dados Completos (JSON)',
                  style: AppTextStyles.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _formatJson(_userData!),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatJson(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  Widget _buildUserInfo() {
    if (_userData == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Informações principais
        _buildInfoCard('Nome', _userData!['nome'] ?? 'Não informado', Icons.person),
        _buildInfoCard('Email', _userData!['email'] ?? 'Não informado', Icons.email),
        _buildInfoCard('CPF', _userData!['cpf'] ?? 'Não informado', Icons.badge),
        
        // Data de nascimento
        if (_userData!['data_nasc'] != null)
          _buildInfoCard(
            'Data de Nascimento',
            _formatDate(_userData!['data_nasc']),
            Icons.cake,
            iconColor: Colors.orange,
          ),
        
        // Tipo de usuário
        if (_userData!['tipo_usuario'] != null)
          _buildInfoCard(
            'Tipo de Usuário',
            _userData!['tipo_usuario'],
            Icons.category,
            iconColor: Colors.green,
          ),
        
        // Sobre
        if (_userData!['sobre'] != null && _userData!['sobre'].toString().isNotEmpty)
          _buildInfoCard(
            'Sobre',
            _userData!['sobre'],
            Icons.info,
            iconColor: Colors.blue,
          ),
        
        // Foto URL
        if (_userData!['foto_url'] != null && _userData!['foto_url'].toString().isNotEmpty)
          _buildInfoCard(
            'Foto URL',
            _userData!['foto_url'],
            Icons.photo,
            iconColor: Colors.purple,
          ),
        
        // ID Pai
        if (_userData!['id_pai'] != null)
          _buildInfoCard(
            'ID Pai',
            _userData!['id_pai'].toString(),
            Icons.family_restroom,
            iconColor: Colors.teal,
          ),
        
        // Data de criação
        if (_userData!['data_criacao'] != null)
          _buildInfoCard(
            'Data de Criação',
            _formatDate(_userData!['data_criacao']),
            Icons.schedule,
            iconColor: Colors.indigo,
          ),
      ],
    );
  }

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue is String) {
        final date = DateTime.parse(dateValue);
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
      return dateValue.toString();
    } catch (e) {
      return dateValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Filho'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
            tooltip: 'Atualizar perfil',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Carregando perfil...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              )
            : _hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar perfil',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadUserProfile,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar Novamente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              AppRoutes.navigateToReplacement(
                                context,
                                AppRoutes.login,
                              );
                            },
                            child: const Text(
                              'Fazer Login Novamente',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header com ID do usuário
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Perfil do Usuário',
                                        style: AppTextStyles.headlineSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'ID: $_userId',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Informações do usuário
                        _buildUserInfo(),
                        
                        const SizedBox(height: 16),
                        
                        // Dados JSON completos
                        _buildJsonDataCard(),
                        
                        const SizedBox(height: 32),

                        Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 Categorias',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Visualize categorias do filhos',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        AppRoutes.navigateTo(context, AppRoutes.listeFilho);
                      },
                      icon: const Icon(Icons.person),
                      label: const Text('visializar filhos'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
                      ],
                    ),
                  ),
      ),
    );
  }
} 