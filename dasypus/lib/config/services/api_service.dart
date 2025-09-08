import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../common/constants/api_constants.dart';
import '../../common/models/usuario.dart';
import '../../common/models/categoria.dart';
import '../../common/models/card.dart';
import 'image_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ===========================
  // Métodos - Usuário
  // ===========================

  /// Login do usuário
  Future<Map<String, dynamic>> login(String email, String senha) async {
    // ATIVADO: Chamada real da API
    try {
      // Debug: mostrar a URL que está sendo usada
      print('🔗 Tentando conectar com: ${ApiConstants.loginUrl}');

      final response = await http
          .post(
            Uri.parse(ApiConstants.loginUrl),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({'email': email, 'senha': senha}),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erro na conexão: $e');
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }

    // CÓDIGO DE SIMULAÇÃO (comentado):
    /*
    // DESATIVADO: Validação da API para testar rotas
    // Simulando resposta de sucesso para qualquer email/senha
    await Future.delayed(const Duration(seconds: 1)); // Simular delay da API
    
    return {
      'status': 'success',
      'message': 'Login realizado com sucesso!',
      'data': {
        'id': 1,
        'nome': 'Usuário Teste',
        'email': email,
        'cpf': '123.456.789-00',
        'data_criacao': DateTime.now().toIso8601String(),
        'sobre': 'Usuário de teste para desenvolvimento',
        'foto_url': 'https://via.placeholder.com/150',
        'id_pai': null,
        'tipo_usuario': 'usuario',
      },
    };
    */
  }

  /// Cadastro de usuário
  Future<Map<String, dynamic>> register(Usuario usuario) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.registerUrl),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({
              'nome': usuario.nome,
              'email': usuario.email,
              'senha': usuario.senha,
              'cpf': usuario.cpf,
              'data_nasc': usuario.dataNasc.toIso8601String(),
              'foto_url': usuario.fotoUrl,
              'legenda': usuario.sobre,
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Cadastro de usuario filho
  Future<Map<String, dynamic>> registerFilho(
    Usuario usuario,
    int userId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.registerUrl}/$userId'),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({
              'nome': usuario.nome,
              'email': usuario.email,
              'senha': usuario.senha,
              'cpf': usuario.cpf,
              'data_nasc': usuario.dataNasc.toIso8601String(),
              'foto_url': usuario.fotoUrl,
              'legenda': usuario.sobre,
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Listar perfil do usuário
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.userProfileUrl}/$userId'),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Atualizar usuário
  Future<Map<String, dynamic>> updateUser(Usuario usuario,int userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.updateUserUrl}/$userId'),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({
              'nome': usuario.nome,
              'email': usuario.email,
              'senha': usuario.senha,
              'cpf':usuario.cpf,
              'data_nasc':usuario.dataNasc.toIso8601String(),
              'legenda':usuario.sobre,
              'foto_url':usuario.fotoUrl,
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Ativar usuário
  Future<Map<String, dynamic>> activateUser(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.userAtivadorUrl}/$userId'),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Listar filhos do usuário
  Future<Map<String, dynamic>> getUserChildren(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.userListeFilhoUrl}/$userId'),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Verificar código de verificação
  Future<Map<String, dynamic>> verifyCode() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConstants.userVerificationCodeUrl),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  //delete
  Future<Map<String, dynamic>> delete(int userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.Userdelete}/$userId'),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Listar perfil do usuário filho com categorias e cards
  Future<Map<String, dynamic>> getCategoriaCard (int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.userProfileFilhoUrl}/$userId'),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }
  // ===========================
  // Métodos - Categoria
  // ===========================

  /// Listar categorias por usuário
  Future<Map<String, dynamic>> getCategoriesByUser(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.listCategoriesByUserUrl}/$userId'),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Criar categoria
  Future<Map<String, dynamic>> createCategory(Categoria categoria) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.registerCategoryUrl),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({
              "nome": categoria.nome,
              "id_usuario": categoria.idUsuario,
              "foto_url": categoria.fotoUrl ?? '',
              "tema_cor": categoria.temaCor ?? '#FF5733',
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Atualizar categoria
  Future<Map<String, dynamic>> updateCategory(Categoria categoria) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.updateCategoryUrl}/${categoria.id}'),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({
              'nome': categoria.nome,
              'tema_cor': categoria.temaCor ?? '#FF5733',
              'foto_url': categoria.fotoUrl ?? '',
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Deletar categoria
  Future<Map<String, dynamic>> deleteCategory(int categoryId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.deleteCategoryUrl}/$categoryId'),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  // ===========================
  // Métodos - Card
  // ===========================

  /// Listar cards por categoria
  Future<Map<String, dynamic>> getCardsByCategory(int categoryId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.listCardsByCategoryUrl}/$categoryId'),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Criar card
  Future<Map<String, dynamic>> createCard(Card card) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.registerCardUrl),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({
              "titulo": card.titulo,
              "descricao": card.descricao,
              "imagem_url": card.imagemUrl ?? '',
              "tema_cor": card.temaCor ?? '#FF5733',
              "id_categoria": card.idCategoria,
              "fonte": card.fonte ?? 'A', // Novo campo
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Atualizar card
  Future<Map<String, dynamic>> updateCard(Card card) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.updateCardUrl),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({
              "titulo": card.titulo,
              "descricao": card.descricao,
              "imagem_url": card.imagemUrl ?? '',
              "tema_cor": card.temaCor ?? '#FF5733',
              "id_categoria": card.idCategoria,
            }),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  /// Deletar card
  Future<Map<String, dynamic>> deleteCard(int cardId) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.deleteCardUrl),
            headers: ApiConstants.defaultHeaders,
            body: json.encode({'id': cardId}),
          )
          .timeout(ApiConstants.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Erro na conexão: $e'};
    }
  }

  // ===========================
  // Método auxiliar para tratar respostas
  // ===========================

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      // Debug: mostrar a estrutura da resposta
      print('🔍 Resposta da API: ${response.statusCode}');
      print('📄 Body: ${response.body}');
      print('📊 Data type: ${data.runtimeType}');
      if (data['data'] != null) {
        print('📋 Data type: ${data['data'].runtimeType}');
        print('📋 Data content: ${data['data']}');

        // Debug detalhado dos campos
        if (data['data'] is Map) {
          Map<String, dynamic> dataMap = data['data'];
          print('🔍 Campos detalhados:');
          dataMap.forEach((key, value) {
            print('  $key: $value (${value.runtimeType})');
          });
        } else if (data['data'] is List && data['data'].isNotEmpty) {
          print('🔍 Primeiro item da lista:');
          Map<String, dynamic> firstItem = data['data'][0];
          firstItem.forEach((key, value) {
            print('  $key: $value (${value.runtimeType})');
          });
        }
      }

      // Função auxiliar para converter IDs de String para int quando necessário
      dynamic convertId(dynamic value) {
        if (value is String && value.isNotEmpty) {
          return int.tryParse(value) ?? value;
        }
        return value;
      }

      // Função auxiliar para processar dados (pode ser Map ou List)
      dynamic processData(dynamic rawData) {
        if (rawData == null) return null;

        if (rawData is Map<String, dynamic>) {
          // Se é um Map, processar normalmente
          Map<String, dynamic> processed = Map<String, dynamic>.from(rawData);

          // Converter IDs comuns que podem vir como String
          if (processed['id'] != null) {
            processed['id'] = convertId(processed['id']);
          }
          if (processed['id_pai'] != null) {
            processed['id_pai'] = convertId(processed['id_pai']);
          }
          if (processed['id_categoria'] != null) {
            processed['id_categoria'] = convertId(processed['id_categoria']);
          }

          // Garantir que campos obrigatórios não sejam null
          if (processed['nome'] == null)
            processed['nome'] = 'Nome não informado';
          if (processed['email'] == null)
            processed['email'] = 'email@exemplo.com';
          if (processed['cpf'] == null) processed['cpf'] = '';
          if (processed['data_criacao'] == null)
            processed['data_criacao'] = DateTime.now().toIso8601String();

          return processed;
        } else if (rawData is List) {
          // Se é uma List, processar cada item
          List<dynamic> processedList = [];
          for (var item in rawData) {
            if (item is Map<String, dynamic>) {
              Map<String, dynamic> processedItem = Map<String, dynamic>.from(
                item,
              );

              // Converter IDs comuns que podem vir como String
              if (processedItem['id'] != null) {
                processedItem['id'] = convertId(processedItem['id']);
              }
              if (processedItem['id_pai'] != null) {
                processedItem['id_pai'] = convertId(processedItem['id_pai']);
              }
              if (processedItem['id_categoria'] != null) {
                processedItem['id_categoria'] = convertId(
                  processedItem['id_categoria'],
                );
              }

              // Garantir que campos obrigatórios não sejam null
              if (processedItem['nome'] == null)
                processedItem['nome'] = 'Nome não informado';
              if (processedItem['email'] == null)
                processedItem['email'] = 'email@exemplo.com';
              if (processedItem['cpf'] == null) processedItem['cpf'] = '';
              if (processedItem['data_criacao'] == null)
                processedItem['data_criacao'] =
                    DateTime.now().toIso8601String();

              processedList.add(processedItem);
            } else {
              processedList.add(item);
            }
          }
          return processedList;
        }

        return rawData;
      }

      // Processar dados se existirem
      final processedData = processData(data['data']);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'status': data['status'] ?? 'success',
          'message': data['message'],
          'data': processedData,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'status': data['status'] ?? 'error',
          'message': data['message'] ?? 'Erro na requisição',
          'statusCode': response.statusCode,
          'data': processedData,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erro ao processar resposta: $e',
        'statusCode': response.statusCode,
      };
    }
  }
}

extension ApiServiceImages on ApiService {
  /// Upload de imagem (encaminha para ImageService)
  Future<Map<String, dynamic>> uploadImage(
    File imageFile, {
    String? userId,
    String? description,
  }) {
    return ImageService.uploadImage(
      imageFile,
      userId: userId,
      description: description,
    );
  }

  /// Listar imagens
  Future<Map<String, dynamic>> getImages() {
    return ImageService.getImages();
  }

  /// Deletar imagem
  Future<Map<String, dynamic>> deleteImage(String imageId) {
    return ImageService.deleteImage(imageId);
  }
}
