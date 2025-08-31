# Funcionalidade de Busca de Imagens - App Dasypus

## Visão Geral

A funcionalidade de busca de imagens foi implementada na app Dasypus, permitindo que usuários busquem e selecionem imagens existentes ao criar cards e categorias, em vez de sempre fazer upload de novas imagens.

## Como Funciona

### 1. Serviço de Busca de Imagens

O `ImageSearchService` é responsável por:
- Buscar imagens pelo nome no servidor de imagens
- Construir URLs completas para exibição das imagens
- Gerenciar a comunicação com a API de imagens

### 2. Widget de Busca

O `ImageSearchWidget` fornece:
- Campo de busca para digitar o nome da imagem
- Botão de busca
- Exibição da imagem encontrada com prévia
- Botão para selecionar a imagem encontrada
- Tratamento de erros e estados de carregamento

### 3. Integração nas Telas

#### Criação de Card (`register_card.dart`)
- Campo "Buscar Imagem Existente" usando `ImageSearchWidget`
- Opção de upload de nova imagem
- A imagem selecionada é salva no campo `imagem_url`

#### Criação de Categoria (`register_categoria.dart`)
- Campo "Buscar Imagem Existente" usando `ImageSearchWidget`
- Opção de upload de nova imagem
- A imagem selecionada é salva no campo `foto_url`

## Configuração

### URLs do Servidor

As URLs estão configuradas em `lib/config/settings/api_settings.dart`:

```dart
// URL base para o serviço de imagens (textIMg)
static const String imageServiceUrl = 'http://192.168.1.113/textIMg';

// URL para diferentes ambientes
static const String localhostImageUrl = 'http://192.168.1.113/textIMg';
static const String androidEmulatorImageUrl = 'http://10.0.2.2/textIMg';
static const String productionImageUrl = 'https://seudominio.com/textIMg';
```

### Alterando a Configuração

Para alterar a URL do serviço de imagens, modifique a linha:

```dart
static String get currentImageUrl => localhostImageUrl;
```

## Uso

### 1. Buscar Imagem Existente

1. Digite o nome da imagem no campo de busca
2. Clique no botão "Buscar Imagem" ou pressione Enter
3. Se a imagem for encontrada, ela será exibida com uma prévia
4. Clique em "Usar Esta Imagem" para selecioná-la

### 2. Upload de Nova Imagem

1. Clique em "Selecionar Nova Imagem"
2. Escolha uma imagem da galeria
3. A imagem será enviada para o servidor
4. O nome do arquivo será automaticamente preenchido

## Estrutura dos Dados

### Modelo de Imagem (`ImageModel`)

```dart
class ImageModel {
  final String id;
  final String originalName;      // Nome original do arquivo
  final String filename;          // Nome do arquivo no servidor
  final String uploadPath;        // Caminho de upload (usado para URL)
  final String fileType;          // Tipo do arquivo
  final int fileSize;             // Tamanho em bytes
  final String uploadDate;        // Data de upload
  final String userId;            // ID do usuário
  final String description;       // Descrição da imagem
  final String url;               // URL completa
}
```

### Campos nos Cards e Categorias

- **Cards**: Campo `imagem_url` armazena o caminho da imagem
- **Categorias**: Campo `foto_url` armazena o caminho da imagem

## Exibição das Imagens

### Cards (`card_profile.dart`)
- As imagens são exibidas usando `_imageService.getImageUrl(card['imagem_url'])`
- Suporte para fallback em caso de erro de carregamento

### Categorias (`categoria_profile.dart`)
- As imagens são exibidas usando `_imageService.getImageUrl(categoria['foto_url'])`
- Suporte para fallback em caso de erro de carregamento

## Tratamento de Erros

- **Imagem não encontrada**: Exibe mensagem de erro
- **Erro de rede**: Exibe mensagem de erro com opção de tentar novamente
- **Erro de carregamento**: Exibe ícone de erro no lugar da imagem

## Benefícios

1. **Reutilização**: Usuários podem reutilizar imagens já existentes
2. **Eficiência**: Evita uploads desnecessários
3. **Consistência**: Mantém padrão visual consistente
4. **Performance**: Reduz tempo de criação de cards e categorias

## Dependências

- `http`: Para requisições HTTP ao servidor de imagens
- `flutter/material.dart`: Para widgets da interface
- `provider`: Para gerenciamento de estado (se necessário)

## Troubleshooting

### Imagem não aparece
1. Verifique se a URL do servidor está correta
2. Confirme se o arquivo existe no servidor
3. Verifique se o caminho está sendo salvo corretamente

### Erro de busca
1. Verifique a conectividade com o servidor
2. Confirme se o endpoint `search_single_image.php` está funcionando
3. Verifique os logs de erro no console

### Problemas de URL
1. Confirme se `getImageUrl()` está construindo URLs corretas
2. Verifique se o caminho base está configurado corretamente
3. Teste a URL diretamente no navegador
