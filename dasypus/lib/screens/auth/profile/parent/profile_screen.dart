import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../config/services/api_service.dart';
import '../../../../common/utils/shared_prefs_helper.dart';
import '../../../../common/routes/app_routes.dart';
import '../../../../common/models/usuario.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      final userId = await SharedPrefsHelper.getUserId();
      
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

        if (rawData is List && rawData.isNotEmpty) {
          // Se é uma lista, pegar o primeiro item
          processedData = Map<String, dynamic>.from(rawData.first);
        } else if (rawData is Map<String, dynamic>) {
          // Se é um Map, usar diretamente
          processedData = Map<String, dynamic>.from(rawData);
        } else {
          throw Exception('Formato de dados inválido da API: ${rawData.runtimeType}');
        }

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
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erro ao carregar perfil: $e';
      });
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1976D2),
            const Color(0xFF42A5F5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar do usuário
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: _userData?['foto_url'] != null && _userData!['foto_url'].toString().isNotEmpty
                  ? Image.network(
                      _userData!['foto_url'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Nome e ID ao lado da foto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userData?['nome'] ?? 'Usuário',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Email do usuário
                if (_userData?['email'] != null)
                  Text(
                    _userData!['email'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 6),
                
                // ID do usuário
                Text(
                  'ID: $_userId',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon, {Color? iconColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
            fontSize: 15,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildUserActions() {
    return Column(
      children: [
        // Botão para Sair da Conta
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Sair da Conta'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.red,
          ),
        ),
        const SizedBox(height: 16),

        // Botão para Deletar Conta
        ElevatedButton.icon(
          onPressed: _deleteAccount,
        icon: const Icon(Icons.delete_forever),
        label: const Text('Deletar Conta'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.redAccent,
        ),
      ),
    ],
  );
}

Future<void> _logout() async {
  // Limpar dados do usuário
  await SharedPrefsHelper.clear(); // Se existir um helper para limpar dados
  AppRoutes.navigateToReplacement(context, AppRoutes.login); // Navegar para tela de login
}

Future<void> _deleteAccount() async {
  // Adicionar confirmação com dialog
  bool? shouldDelete = await _showDeleteConfirmationDialog();
  if (shouldDelete == true) {
    try {
      // Chame o serviço para deletar a conta
      await _apiService.delete(_userId!); // Supondo que o ApiService tem um método deleteAccount
      AppRoutes.navigateToReplacement(context, AppRoutes.login); // Navegar para a tela de login após a exclusão
    } catch (e) {
      // Mostrar erro ao deletar conta
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar conta: $e')),
      );
    }
  }
}

Future<bool?> _showDeleteConfirmationDialog() {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text('Esta ação não pode ser desfeita. Deseja continuar?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deletar'),
          ),
        ],
      );
    },
  );
}



  Widget _buildUserInfo() {
    if (_userData == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildInfoSection(
          'Informações Pessoais',
          [
            _buildInfoItem('Nome Completo', _userData!['nome'] ?? 'Não informado', Icons.person_outline),
            _buildInfoItem('CPF', _userData!['cpf'] ?? 'Não informado', Icons.badge_outlined),
            if (_userData!['data_nasc'] != null)
              _buildInfoItem(
                'Data de Nascimento',
                _formatDate(_userData!['data_nasc']),
                Icons.cake_outlined,
                iconColor: const Color(0xFFFD7E14),
              ),
            if (_userData!['tipo_usuario'] != null)
              _buildInfoItem(
                'Tipo de Usuário',
                _userData!['tipo_usuario'],
                Icons.category_outlined,
                iconColor: const Color(0xFF20C997),
              ),
          ],
        ),
        
        _buildInfoSection(
          'Informações de Contato',
          [
            _buildInfoItem('Email', _userData!['email'] ?? 'Não informado', Icons.email_outlined),
            if (_userData!['id_pai'] != null)
              _buildInfoItem(
                'ID Pai',
                _userData!['id_pai'].toString(),
                Icons.family_restroom_outlined,
                iconColor: const Color(0xFF6F42C1),
              ),
          ],
        ),
        
        if (_userData!['sobre'] != null && _userData!['sobre'].toString().isNotEmpty)
          _buildInfoSection(
            'Sobre',
            [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _userData!['sobre'],
                  style: TextStyle(
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        
        if (_userData!['data_criacao'] != null)
          _buildInfoSection(
            'Informações da Conta',
            [
              _buildInfoItem(
                'Data de Criação',
                _formatDate(_userData!['data_criacao']),
                Icons.calendar_today_outlined,
                iconColor: const Color(0xFF6610F2),
              ),
            ],
          ),
        
        const SizedBox(height: 24),
        // Botão de ação
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
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

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          strokeWidth: 2.5,
        ),
        const SizedBox(height: 20),
        Text(
          'Carregando perfil...',
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: Colors.blue[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Erro ao carregar perfil',
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadUserProfile,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
            child: Text(
              'Fazer Login Novamente',
              style: TextStyle(
                color: Colors.blue[700],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            onPressed: _loadUserProfile,
            tooltip: 'Atualizar perfil',
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF5F9FF),
        child: _isLoading
            ? Center(child: _buildLoadingState())
            : _hasError
                ? Center(child: _buildErrorState())
                : Column(
                    children: [
                      _buildProfileHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildUserInfo(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

      ),
    );
  }
}