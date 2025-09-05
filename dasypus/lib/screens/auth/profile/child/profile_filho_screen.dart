import 'package:dasypus/config/services/image_search_service.dart';
import 'package:flutter/material.dart';
import 'package:dasypus/common/constants/app_colors.dart';
import 'package:dasypus/common/constants/app_text_styles.dart';
import 'package:dasypus/config/services/api_service.dart';
import 'package:dasypus/common/utils/shared_prefs_helper.dart';
import 'package:dasypus/common/routes/app_routes.dart';

class ProfileScreenFilho extends StatefulWidget {
  const ProfileScreenFilho({super.key});

  @override
  State<ProfileScreenFilho> createState() => _ProfileScreenFilhoState();
}

class _ProfileScreenFilhoState extends State<ProfileScreenFilho> {
  int? _userId;
  String? _userFotoUrl;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;

  final ApiService _apiService = ApiService();
  final ImageSearchService _imageService = ImageSearchService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 🔄 Carregar perfil do filho
  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final userId = await SharedPrefsHelper.getUserFilhoId();
      final fotoUrl = await SharedPrefsHelper.getUserFotoUrl();

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'ID do usuário filho não encontrado. Faça login novamente.';
        });
        return;
      }

      setState(() {
        _userId = userId;
        _userFotoUrl = fotoUrl;
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

  // 🚪 Logout
  Future<void> _logout() async {
    await SharedPrefsHelper.clear();
    AppRoutes.navigateToReplacement(context, AppRoutes.login);
  }

  // ❌ Deletar conta
  Future<void> _deleteAccount() async {
    final confirm = await _showDeleteConfirmationDialog();
    if (confirm == true) {
      try {
        final resultado = await _apiService.delete(_userId!);
        if (resultado['status'] == 'success') {
          AppRoutes.navigateToReplacement(context, AppRoutes.login);
        } else {
          throw Exception(resultado['message'] ?? 'Erro ao deletar conta');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar conta: $e')),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text('Esta ação não pode ser desfeita. Deseja continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deletar')),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    try {
      final date = DateTime.parse(value.toString());
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  // 🔹 Header do perfil
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: ClipOval(
              child: Image.network(
                _imageService.getImageUrl(_userData?['foto_url'] ?? ''),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.grey),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_userData?['nome'] ?? 'Usuário Filho',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                if (_userData?['email'] != null)
                  Text(_userData!['email'],
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                Text('ID: $_userId',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Item de informação
  Widget _buildInfoItem(String title, String value, IconData icon, {Color? iconColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (iconColor ?? Colors.blue).withOpacity(0.1),
          child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // 🔹 Seção de informações
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[800])),
        ),
        ...children,
      ],
    );
  }

  // 🔹 Ações do usuário
  Widget _buildUserActions() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: ()  {
                  SharedPrefsHelper.saveUseralterarId(_userId!);
                  AppRoutes.navigateToReplacement(context, AppRoutes.editarUsuario);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Sair da Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _deleteAccount,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Deletar Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Informações do usuário
  Widget _buildUserInfo() {
    if (_userData == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildInfoSection('Informações Pessoais', [
          _buildInfoItem('Nome Completo', _userData!['nome'] ?? 'Não informado', Icons.person_outline),
          _buildInfoItem('CPF', _userData!['cpf'] ?? 'Não informado', Icons.badge_outlined),
          if (_userData!['data_nasc'] != null)
            _buildInfoItem('Data de Nascimento', _formatDate(_userData!['data_nasc']), Icons.cake_outlined),
          if (_userData!['tipo_usuario'] != null)
            _buildInfoItem('Tipo de Usuário', _userData!['tipo_usuario'], Icons.category_outlined),
        ]),
        _buildInfoSection('Informações de Contato', [
          _buildInfoItem('Email', _userData!['email'] ?? 'Não informado', Icons.email_outlined),
          if (_userData!['id_pai'] != null)
            _buildInfoItem('ID Pai', _userData!['id_pai'].toString(), Icons.family_restroom_outlined),
        ]),
        if (_userData!['sobre']?.isNotEmpty ?? false)
          _buildInfoSection('Sobre', [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 6)],
              ),
              child: Text(_userData!['sobre'], style: const TextStyle(height: 1.5)),
            ),
          ]),
        if (_userData!['data_criacao'] != null)
          _buildInfoSection('Informações da Conta', [
            _buildInfoItem('Data de Criação', _formatDate(_userData!['data_criacao']), Icons.calendar_today_outlined),
          ]),
        _buildUserActions(),
      ],
    );
  }

  // 🔹 Estados
  Widget _buildLoadingState() => const Center(child: CircularProgressIndicator());

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 56, color: Colors.blue[400]),
          const SizedBox(height: 24),
          Text('Erro ao carregar perfil', style: TextStyle(color: Colors.blue[800], fontSize: 18)),
          const SizedBox(height: 16),
          Text(_errorMessage, style: TextStyle(color: Colors.grey[700]), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadUserProfile,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () => AppRoutes.navigateToReplacement(context, AppRoutes.login),
            child: Text('Fazer Login Novamente', style: TextStyle(color: Colors.blue[700])),
          ),
        ],
      ),
    );
  }

  // 🔹 Build principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Filho'),
        backgroundColor: Colors.blue[700],
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
        color: const Color(0xFFF5F9FF),
        child: _isLoading
            ? _buildLoadingState()
            : _hasError
                ? _buildErrorState()
                : Column(
                    children: [
                      _buildProfileHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildUserInfo(),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
