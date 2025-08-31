import 'package:dasypus/common/utils/shared_prefs_helper.dart';
import 'package:dasypus/config/services/api_service.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
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

      final userId = await SharedPrefsHelper.getUserId();

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'ID do usuário não encontrado. Faça login novamente.';
        });
         Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      setState(() {
        _userId = userId;
      });

      final resultado = await _apiService.getUserProfile(userId);

      if (resultado['status'] == 'success') {
        dynamic rawData = resultado['data'];
        Map<String, dynamic>? processedData;

        if (rawData is List && rawData.isNotEmpty) {
          processedData = Map<String, dynamic>.from(rawData.first);
        } else if (rawData is Map<String, dynamic>) {
          processedData = Map<String, dynamic>.from(rawData);
        } else {
          throw Exception('Formato de dados inválido da API: ${rawData.runtimeType}');
        }
         if(processedData['id_pai'] == null){
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/registerFilho');
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF667eea),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text("Tentar novamente"),
              ),
            ],
          ),
        ),
      );
    }

    // Aqui você pode navegar ou mostrar os dados
    return Scaffold(
      body: Center(
        child: Text("Usuário carregado: ${_userData?['id_pai'] }"),
      ),
    );
  }
}
