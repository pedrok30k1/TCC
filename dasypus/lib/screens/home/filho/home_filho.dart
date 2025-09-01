import 'package:dasypus/common/constants/app_colors.dart';
import 'package:dasypus/config/services/api_service.dart';
import 'package:dasypus/config/services/image_search_service.dart';
import 'package:dasypus/common/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeFilho extends StatefulWidget {
  const HomeFilho({super.key});

  @override
  State<HomeFilho> createState() => _HomeFilhoState();
}

class _HomeFilhoState extends State<HomeFilho> {
  int _selectedIndex = 0;
  int? _userId;
  int? _usurCategoriaId;
  List<dynamic> _cards = [];
  List<dynamic> _barra = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String fala = '';
  List<Map<String, dynamic>> _categorias = [];
  final ApiService _apiService = ApiService();
  final ImageSearchService _imageService = ImageSearchService();
  final FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

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

      // Buscar categorias
      final categoriasRes = await _apiService.getCategoriesByUser(userId);
      if (categoriasRes['status'] == 'success') {
        setState(() {
          _categorias = List<Map<String, dynamic>>.from(categoriasRes['data'] ?? []);
        });
      } else {
        setState(() {
          _categorias = [];
          if (categoriasRes['status'] != 'info') {
            _hasError = true;
            _errorMessage = categoriasRes['message'] ?? 'Erro ao carregar categorias';
          }
        });
      }

      // Buscar cards
      final cardsRes = await _apiService.getCardsByCategory(userId);
      if (cardsRes['status'] == 'success') {
        setState(() {
          _cards = cardsRes['data'];
        });
      } else {
        setState(() {
          _cards = [];
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Erro ao carregar perfil: $e';
      });
    }
  }

  Future<void> _onCategoriaTap(int index) async {
    setState(() {
      _selectedIndex = index;
      _usurCategoriaId = _categorias[index]['id'];
    });

    final cardsRes = await _apiService.getCardsByCategory(_categorias[index]['id']);
    if (cardsRes['status'] == 'success') {
      setState(() {
        _cards = cardsRes['data'];
      });
    } else {
      setState(() {
        _cards = [];
      });
    }
  }

  void _onCardTap(dynamic card) {
    setState(() {
      _barra.add(card);
      fala += card['descricao'] ?? '';
    });
  }

  void _removeCardFromBarra(int index) {
    setState(() {
      _barra.removeAt(index);
    });
  }

  void _falar(Map<String, dynamic> card) {
    speak(fala);
    setState(() {
      _barra = [];
      fala = '';
    });
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
      body: Stack(
        children: [
          Column(
            children: [
              // HEADER
              Container(
                height: MediaQuery.of(context).size.height * 0.18,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Colors.blueAccent.shade700 != null
                        ? [Colors.blueAccent.shade700, Colors.blueAccent.shade400]
                        : [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
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
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.azulEscuro,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.collections, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Meus Cards",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BARRA SUPERIOR DE CARDS SELECIONADOS
              if (_barra.isNotEmpty)
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.azulClaro,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _barra.length,
                    itemBuilder: (context, index) {
                      final card = _barra[index];
                      return GestureDetector(
                        onTap: () => _removeCardFromBarra(index),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: _hexToColor(card['tema_cor'] ?? "#CCCCCC"),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (card['imagem_url'] != null && card['imagem_url'].toString().isNotEmpty)
                                Container(
                                  height: 50,
                                  width: 50,
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _imageService.getImageUrl(card['imagem_url']),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.image_not_supported, size: 30),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  card['titulo'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // LISTA DE CARDS
              Expanded(
                child: _cards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.inbox, size: 80, color: Colors.black26),
                            SizedBox(height: 12),
                            Text(
                              "Nenhum card encontrado",
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
                        padding: const EdgeInsets.all(16),
                        itemCount: _cards.length,
                        itemBuilder: (context, index) {
                          final card = _cards[index];
                          return InkWell(
                            onTap: () => _onCardTap(card),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _hexToColor(card['tema_cor'] ?? "#CCCCCC"),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    if (card['imagem_url'] != null && card['imagem_url'].toString().isNotEmpty)
                                      Image.network(
                                        _imageService.getImageUrl(card['imagem_url']),
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Text(
                                        card['titulo'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 80), // Espaço para botão flutuante
            ],
          ),

          // BOTÃO FALAR FLOTA
          if (_barra.isNotEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: () => _falar(_barra.last),
                backgroundColor: AppColors.azulEscuro,
                label: const Text("Falar", style: TextStyle(fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.volume_up),
              ),
            ),
        ],
      ),

      // CATEGORIAS
      bottomNavigationBar: _categorias.isEmpty
          ? null
          : SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final categoria = _categorias[index];
                  final color = _hexToColor(categoria['tema_cor'] ?? "#CCCCCC");
                  return GestureDetector(
                    onTap: () => _onCategoriaTap(index),
                    child: Container(
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == index ? color : color.withOpacity(0.5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_selectedIndex == index)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: categoria['foto_url'] != null && categoria['foto_url'].toString().isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(35),
                                child: Image.network(
                                  _imageService.getImageUrl(categoria['foto_url']),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                                ),
                              )
                            : Text(
                                categoria['nome']?.substring(0, 1) ?? "?",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
