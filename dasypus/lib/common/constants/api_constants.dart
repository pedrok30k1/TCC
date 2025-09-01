import '../../config/settings/api_settings.dart';

class ApiConstants {
  // ===========================
  // CONFIGURAÇÃO DA URL DA API
  // ===========================
  
  // URL base da API - usa a configuração centralizada
  static String get apiUrl => ApiConfig.currentUrl;

  // Headers padrão
  static Map<String, String> get defaultHeaders => ApiConfig.defaultHeaders;

  // Timeout da requisição
  static Duration get requestTimeout => ApiConfig.requestTimeout;

  // ===========================
  // Endpoints - Usuário
  // ===========================
  static const String loginEndpoint = 'usuario/login';
  static const String registerEndpoint = 'usuario/cadastro';
  static const String userProfileEndpoint = 'usuario/listar';
  static const String updateUserEndpoint = 'usuario/atualizar/';
  static const String userAtivadorEndpoint = 'usuario/ativador/';
  static const String userListeFilhoEndpoint = 'usuario/id_pai/';
  static const String userVerificationCodeEndpoint = 'usuario/verificationcode/';
  static const String userProfileFilhoEndpoint = 'usuario/categorias_cards/';
  static const String delectUser = "usuario/deletar/";

  // ===========================
  // Endpoints - Categoria
  // ===========================
  static const String listCategoriesByUserEndpoint = 'categoria/listar_por_usuario/';
  static const String registerCategoryEndpoint = 'categoria/criar/';
  static const String updateCategoryEndpoint = 'categoria/atualizar/';
  static const String deleteCategoryEndpoint = 'categoria/deletar/';

  // ===========================
  // Endpoints - Card
  // ===========================
  static const String listCardsByCategoryEndpoint = 'card/listar_por_categoria/';
  static const String registerCardEndpoint = 'card/criar/';
  static const String updateCardEndpoint = 'card/atualizar/';
  static const String deleteCardEndpoint = 'card/deletar/';

  // ===========================
  // Endpoints - Imagem
  // ===========================
  static const String uploadImageEndpoint = 'imagem/upload/';
  static const String listImagesEndpoint = 'imagem/listar/';
  static const String deleteImageEndpoint = 'imagem/deletar/';

  // ===========================
  // Métodos para URLs completas
  // ===========================
  
  // Usuário
  static String get loginUrl => '$apiUrl$loginEndpoint';
  static String get registerUrl => '$apiUrl$registerEndpoint';
  static String get userProfileUrl => '$apiUrl$userProfileEndpoint';
  static String get updateUserUrl => '$apiUrl$updateUserEndpoint';
  static String get userAtivadorUrl => '$apiUrl$userAtivadorEndpoint';
  static String get userListeFilhoUrl => '$apiUrl$userListeFilhoEndpoint';
  static String get userVerificationCodeUrl => '$apiUrl$userVerificationCodeEndpoint';
  static String get  Userdelete => '$apiUrl$delectUser';
  static String get userProfileFilhoUrl => '$apiUrl$userProfileFilhoEndpoint';

  // Categoria
  static String get listCategoriesByUserUrl => '$apiUrl$listCategoriesByUserEndpoint';
  static String get registerCategoryUrl => '$apiUrl$registerCategoryEndpoint';
  static String get updateCategoryUrl => '$apiUrl$updateCategoryEndpoint';
  static String get deleteCategoryUrl => '$apiUrl$deleteCategoryEndpoint';

  // Card
  static String get listCardsByCategoryUrl => '$apiUrl$listCardsByCategoryEndpoint';
  static String get registerCardUrl => '$apiUrl$registerCardEndpoint';
  static String get updateCardUrl => '$apiUrl$updateCardEndpoint';
  static String get deleteCardUrl => '$apiUrl$deleteCardEndpoint';

  // Imagem
  static String get uploadImageUrl => '$apiUrl$uploadImageEndpoint';
  static String get listImagesUrl => '$apiUrl$listImagesEndpoint';
  static String get deleteImageUrl => '$apiUrl$deleteImageEndpoint';
}
