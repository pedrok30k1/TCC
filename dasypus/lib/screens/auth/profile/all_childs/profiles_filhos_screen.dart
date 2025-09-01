import 'package:dasypus/config/services/image_search_service.dart';
import 'package:flutter/material.dart';
import 'package:dasypus/common/routes/app_routes.dart';
import 'package:dasypus/common/utils/shared_prefs_helper.dart';
import 'package:dasypus/config/services/api_service.dart';

class ProfilesFilhosScreen extends StatefulWidget {
  final bool showAppBar;

  const ProfilesFilhosScreen({super.key, this.showAppBar = true});

  @override
  State<ProfilesFilhosScreen> createState() => _ProfilesFilhosScreenState();
}

class _ProfilesFilhosScreenState extends State<ProfilesFilhosScreen> {
  late final ApiService _apiService;
  late Future<List<Map<String, dynamic>>> _childrenFuture;
  final ImageSearchService _imageService = ImageSearchService();
  final List<Color> profileColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.green,
    Colors.deepPurple,
    Colors.orangeAccent,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _childrenFuture = _loadUserFilhos();
  }

  Future<List<Map<String, dynamic>>> _loadUserFilhos() async {
    final userId = await SharedPrefsHelper.getUserId();
    if (userId == null) {
      throw Exception('ID do usuário não encontrado. Faça login novamente.');
    }

    final resultado = await _apiService.getUserChildren(userId);

    // Debug: mostrar o resultado da API
    print('🔍 Resultado da API getUserChildren: $resultado');

    // Se não houver filhos ou se for um status de informação, retornar lista vazia
    if (resultado['status'] == 'info' ||
        resultado['status'] == 'warning' ||
        resultado['message']?.contains('não encontrado') == true ||
        resultado['message']?.contains('nenhum') == true ||
        resultado['message']?.contains('vazio') == true) {
      print('ℹ️ Nenhum filho encontrado, retornando lista vazia');
      return [];
    }

    // Se for sucesso, processar os dados
    if (resultado['status'] == 'success') {
      dynamic rawData = resultado['data'];
      if (rawData is List) {
        return List<Map<String, dynamic>>.from(rawData);
      } else if (rawData is Map) {
        return [Map<String, dynamic>.from(rawData)];
      } else {
        return [];
      }
    }

    // Se chegou aqui, é um erro real
    throw Exception(resultado['message'] ?? 'Erro ao carregar perfis');
  }

  void _onChildTap(Map<String, dynamic> child) async {
    await SharedPrefsHelper.saveUserFilhoId(child['id']);
    AppRoutes.navigateTo(context, AppRoutes.listaCategoria);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selecionado: ${child['nome']}'),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getInitials(String? nome) {
    if (nome == null || nome.isEmpty) return "?";
    final partes = nome.split(" ");
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        if (widget.showAppBar) const SizedBox(height: 20),
        if (widget.showAppBar)
          Text(
            "Quem está usando?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        if (widget.showAppBar) const SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _childrenFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 3),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar perfis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tente novamente mais tarde',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _childrenFuture = _loadUserFilhos();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final childrenList = snapshot.data ?? [];

              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                itemCount: childrenList.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  if (index == childrenList.length) {
                    // Botão de adicionar novo filho
                    return GestureDetector(
                      onTap: () {
                        AppRoutes.navigateTo(context, AppRoutes.registerFilho);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 6,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.add_circle_outline,
                                size: 50,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Adicionar perfil",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final child = childrenList[index];
                  final color = profileColors[index % profileColors.length];
                  if (child['imagem_url'] != null &&
                      child['imagem_url'].toString().isNotEmpty)
                    ;
                  return GestureDetector(
                    onTap: () => _onChildTap(child),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.85),
                            color.withOpacity(0.55),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: "profile_${child['id']}",
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.white,
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    _imageService.getImageUrl(
                                      child['foto_url'] ?? '',
                                    ),
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
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
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
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            child['nome'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Toque para acessar",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (widget.showAppBar) const SizedBox(height: 20),
      ],
    );

    return widget.showAppBar
        ? Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text("Perfis"),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: content,
        )
        : SizedBox(height: 500, child: content);
  }
}
