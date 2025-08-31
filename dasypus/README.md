# App01 - Flutter Login App

Um aplicativo Flutter com uma tela de login moderna e bem organizada.

## 📁 Estrutura do Projeto

```
lib/
├── constants/
│   ├── app_colors.dart      # Cores do aplicativo
│   ├── app_text_styles.dart # Estilos de texto
│   └── api_constants.dart   # Constantes da API
├── models/
│   └── usuario.dart         # Modelo de dados do usuário
├── screens/
│   └── login_screen.dart    # Tela de login
├── services/
│   └── auth_service.dart    # Serviço de autenticação
├── utils/
│   └── validators.dart      # Validações de formulário
├── widgets/
│   ├── custom_button.dart   # Widget de botão customizado
│   └── custom_text_field.dart # Widget de campo de texto customizado
└── main.dart               # Arquivo principal
```

## 🚀 Como Executar

1. Certifique-se de ter o Flutter instalado
2. Clone o repositório
3. Execute no terminal:
   ```bash
   flutter pub get
   flutter run
   ```

## ✨ Funcionalidades

- **Tela de Login Moderna**: Design responsivo com gradiente
- **Validação de Formulário**: Validação de email, senha, CPF e data de nascimento
- **Integração com API**: Chamadas HTTP para autenticação real
- **Modelo de Dados Completo**: Classe Usuario com CPF, data de nascimento, tipo e outros campos
- **Tratamento de Erros**: Feedback visual para erros de login
- **Componentes Reutilizáveis**: Widgets customizados para botões e campos
- **Organização de Código**: Estrutura de pastas bem definida
- **Constantes Centralizadas**: Cores, estilos e configurações de API organizados

## 🎨 Design

- Gradiente de fundo roxo/azul
- Card com elevação e bordas arredondadas
- Campos de texto com validação
- Botão com estado de loading
- Design Material 3

## 📱 Telas

### Login Screen
- Campo de email com validação
- Campo de senha com toggle de visibilidade
- Exibição de dados completos do usuário (nome, email, CPF, data de nascimento, tipo)
- Botão "Esqueci a senha"
- Botão de login com loading
- Link para cadastro

## 🔧 Tecnologias

- Flutter 3.x
- Dart
- Material Design 3
- HTTP package para chamadas de API

## ⚙️ Configuração da API

1. **Edite o arquivo `lib/constants/api_constants.dart`**
2. **Altere a URL base da API**:
   ```dart
   static const String apiUrl = 'https://sua-api.com/api';
   ```
3. **Configure os endpoints** conforme sua API

## 📱 Telas
