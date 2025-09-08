class ApiConfig {
  // ===========================
  // CONFIGURAÇÃO DA API
  // ===========================

  // Altere esta URL conforme seu ambiente:como colocar o IP do servidor ou domínio
  static const String baseUrl = 'http://192.168.20.133/TCC/api/';

  // URLs para diferentes ambientes:
  static const String localhostUrl = 'http://192.168.20.133/TCC/api/';
  static const String androidEmulatorUrl = 'http://192.168.20.133/TCC/api/';
  static const String productionUrl = 'https://seudominio.com/api/';

  // ===========================
  // CONFIGURAÇÃO DO SERVIÇO DE IMAGENS
  // ===========================

  // URL base para o serviço de imagens (textIMg)
  static const String imageServiceUrl = 'http://192.168.20.133/textIMg';

  // URL para diferentes ambientes do serviço de imagens:
  static const String localhostImageUrl = 'http://192.168.20.133/textIMg';
  static const String androidEmulatorImageUrl = 'http://192.168.20.133/textIMg';
  static const String productionImageUrl = 'https://seudominio.com/textIMg';

  // ===========================
  // INSTRUÇÕES DE CONFIGURAÇÃO
  // ===========================
  // Para alterar a URL da API, modifique a linha abaixo:
  // - Para web: localhostUrl
  // - Para Android emulador: androidEmulatorUrl
  // - Para produção: productionUrl
  // - Para IP específico: 'http://192.168.1.100/TCC/api/'

  static String get currentUrl => localhostUrl;

  // Para alterar a URL do serviço de imagens, modifique a linha abaixo:
  static String get currentImageUrl => localhostImageUrl;

  // ===========================
  // CONFIGURAÇÕES DE DEBUG
  // ===========================
  static const bool enableDebugLogs = true;
  static const Duration requestTimeout = Duration(seconds: 30);

  // ===========================
  // HEADERS PADRÃO
  // ===========================
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
