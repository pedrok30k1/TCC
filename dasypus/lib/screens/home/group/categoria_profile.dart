import 'package:dasypus/common/constants/app_colors.dart';
import 'package:dasypus/common/routes/app_routes.dart';
import 'package:dasypus/config/services/api_service.dart';
import 'package:dasypus/config/services/image_search_service.dart';
import 'package:dasypus/common/utils/shared_prefs_helper.dart';

import 'package:flutter/material.dart';

class CategoriaProfileScreen extends StatefulWidget {
  const CategoriaProfileScreen({super.key});

  @override
  State<CategoriaProfileScreen> createState() => _CategoriaProfileScreenState();
}

class _CategoriaProfileScreenState extends State<CategoriaProfileScreen> {
  int? _userId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _categorias = [];
  final ApiService _apiService = ApiService();
  final ImageSearchService _imageService = ImageSearchService();

  @override
  void initState() {
    super.initState();
    _loadUserFilho();
  }

  Future<void> _loadUserFilho() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      int? userId = await SharedPrefsHelper.getUserFilhoId();
      userId ??= await SharedPrefsHelper.getUserId();

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

      final resultado = await _apiService.getCategoriesByUser(userId);

      if (resultado['status'] == 'success') {
        setState(() {
          _categorias = List<Map<String, dynamic>>.from(
            resultado['data'] ?? [],
          );
          _isLoading = false;
        });
        // ignore: avoid_print
        print('Categorias carregadas: ' + _categorias.length.toString());
      } else if (resultado['status'] == 'info') {
        setState(() {
          _categorias = [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = resultado['message'] ?? 'Erro ao carregar categorias';
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

  void _onCategoriaTap(Map<String, dynamic> categoria) {
    SharedPrefsHelper.saveCategoriaId(categoria['id']);
    AppRoutes.navigateTo(context, AppRoutes.listaCard);
  }

  void _onAddButtonPressed() {
    AppRoutes.navigateTo(context, AppRoutes.criarCategoria);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError) {
      return Scaffold(body: Center(child: Text(_errorMessage)));
    }

    return Scaffold(
      backgroundColor: AppColors.azulClaro,
      body: Column(
        children: [
          // HEADER estilizado
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(color: AppColors.azulMuitoClaro),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.06,
              vertical: MediaQuery.of(context).size.height * 0.010,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.09,
                        width: MediaQuery.of(context).size.width * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.03,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                            size: MediaQuery.of(context).size.width * 0.06,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.09,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width * 0.05,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.azulEscuro,
                                  borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width * 0.05,
                                  ),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.contain,
                                  child: Icon(
                                    Icons.collections,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                                child: Text(
                                  "Minhas Categorias",
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                        0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LISTA DE CATEGORIAS ou PLACEHOLDER
          Expanded(
            child:
                _categorias.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.black26),
                          const SizedBox(height: 12),
                          const Text(
                            "Nenhuma categoria encontrada para este usuário.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _categorias.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> categoria =
                            _categorias[index];
                        return InkWell(
                          onTap: () => _onCategoriaTap(categoria),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _hexToColor(
                                categoria['tema_cor'] ?? "#CCCCCC",
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image section
                                if (categoria['foto_url'] != null && categoria['foto_url'].toString().isNotEmpty)
                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        _imageService.getImageUrl(categoria['foto_url']),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 120,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            height: 120,
                                            width: double.infinity,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                // Title section
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    categoria['nome'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      // BOTÃO +
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddButtonPressed,
        backgroundColor: AppColors.azulEscuro,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
