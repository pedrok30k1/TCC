# Aplicação de Busca de Imagem

Uma aplicação Flutter que permite buscar uma imagem específica pelo nome usando uma API PHP.

## Funcionalidades

- 🔍 **Busca por nome**: Busque uma imagem específica pelo nome original ou nome do arquivo
- 📱 **Interface simples**: Design limpo e focado na busca de uma única imagem
- 🖼️ **Visualização completa**: Imagem exibida em tamanho grande com todas as informações
- ⚡ **Busca rápida**: Resultado imediato sem listas ou paginação
- 📋 **Detalhes completos**: Todas as informações da imagem em um card organizado

## Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/
│   └── image_model.dart     # Modelo de dados para imagens
├── providers/
│   └── image_provider.dart  # Gerenciamento de estado simplificado
├── screens/
│   └── home_screen.dart     # Tela principal de busca
├── services/
│   └── image_service.dart   # Serviço para comunicação com a API
└── widgets/
    └── search_bar_widget.dart    # Barra de busca personalizada
```

## Configuração

### 1. Dependências

A aplicação usa as seguintes dependências principais:

- `http`: Para requisições HTTP à API
- `provider`: Para gerenciamento de estado

### 2. URL da API

No arquivo `lib/services/image_service.dart`, ajuste a URL base para sua configuração:

```dart
static const String baseUrl = 'http://192.168.1.113/textIMg'; // Ajuste para sua URL
```

### 3. API PHP

A aplicação usa a API `search_single_image.php` que deve estar disponível no seu servidor. Esta API:

- Recebe o parâmetro `name` via GET
- Retorna uma única imagem que corresponda ao nome
- Para na primeira correspondência encontrada
- Retorna 404 se nenhuma imagem for encontrada

## Como Usar

### Busca Simples

1. Digite o nome da imagem na barra de busca
2. Pressione Enter ou toque no ícone de busca
3. A imagem será exibida em tamanho grande com todas as informações

### Funcionamento

- A busca é feita pelo nome original da imagem ou nome do arquivo
- A busca é case-insensitive (não diferencia maiúsculas/minúsculas)
- A primeira correspondência encontrada é retornada
- Se nenhuma imagem for encontrada, uma mensagem de erro é exibida

## Executando a Aplicação

1. **Instalar dependências**:
   ```bash
   flutter pub get
   ```

2. **Executar a aplicação**:
   ```bash
   flutter run
   ```

3. **Para web**:
   ```bash
   flutter run -d chrome
   ```

## Personalização

### Tema

O tema pode ser personalizado no arquivo `main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Mude a cor principal
    brightness: Brightness.light,
  ),
  // ... outras configurações
),
```

### Tamanho da Imagem

Ajuste o tamanho da imagem no arquivo `home_screen.dart`:

```dart
Container(
  height: 300, // Mude a altura da imagem
  // ...
)
```

## Requisitos

- Flutter SDK 3.9.0 ou superior
- Dart SDK 3.9.0 ou superior
- Servidor PHP com a API `search_single_image.php` funcionando

## Solução de Problemas

### Erro de Conexão

- Verifique se a URL da API está correta
- Confirme se o servidor PHP está rodando
- Teste a API diretamente no navegador

### Imagem não Encontrada

- Verifique se o nome digitado está correto
- Confirme se a imagem existe no banco de dados
- Teste com nomes parciais (a busca é parcial)

### Performance

- A aplicação busca apenas uma imagem por vez
- Não há cache de múltiplas imagens
- A busca é otimizada para resultados únicos

## Diferenças da Versão Anterior

Esta versão simplificada:

- ✅ Busca apenas uma imagem específica
- ✅ Interface mais limpa e focada
- ✅ Sem paginação ou listas
- ✅ Resultado imediato e direto
- ✅ Menos complexidade no código
- ✅ Melhor performance para busca única

## Contribuição

Para contribuir com o projeto:

1. Faça um fork do repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
