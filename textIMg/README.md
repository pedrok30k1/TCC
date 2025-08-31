# 📸 Sistema de Upload de Imagens - Flutter + PHP

Este projeto consiste em um aplicativo Flutter que envia imagens e uma API PHP que as recebe e salva em uma pasta do servidor.

## 🚀 Funcionalidades

### Aplicativo Flutter
- ✅ Seleção de imagens da galeria do dispositivo
- ✅ Envio de imagens via HTTP multipart/form-data
- ✅ Interface intuitiva com preview da imagem
- ✅ Indicador de progresso durante o upload
- ✅ Tratamento de erros e feedback visual

### API PHP
- ✅ Recebimento de imagens via POST
- ✅ Validação de tipo e tamanho de arquivo
- ✅ Salvamento seguro em pasta específica
- ✅ Geração de nomes únicos para evitar conflitos
- ✅ Armazenamento de metadados em JSON
- ✅ Suporte a CORS para requisições cross-origin
- ✅ Limpeza automática de arquivos antigos

## 📁 Estrutura do Projeto

```
├── texte/                          # Aplicativo Flutter
│   ├── lib/
│   │   └── main.dart              # App principal
│   └── pubspec.yaml               # Dependências Flutter
├── upload_image.php               # API PHP para upload
├── view_images.php                # Página para visualizar imagens
├── test_upload.html               # Interface web para testes
├── uploads/                       # Pasta onde as imagens são salvas
├── image_database.json            # Banco de dados JSON
└── README.md                      # Este arquivo
```

## 🛠️ Instalação e Configuração

### 1. Configurar o Servidor PHP

1. **Coloque os arquivos PHP na pasta do seu servidor web** (ex: `htdocs`, `www`, etc.)
2. **Verifique as permissões da pasta**:
   ```bash
   chmod 755 uploads/
   chmod 644 *.php
   ```

### 2. Configurar o Aplicativo Flutter

1. **Instalar dependências**:
   ```bash
   cd texte
   flutter pub get
   ```

2. **Executar o aplicativo**:
   ```bash
   flutter run
   ```

## 🔧 Configuração da URL da API

### Para desenvolvimento local:
- URL: `http://localhost/upload_image.php`
- URL: `http://10.0.2.2/upload_image.php` (Android Emulator)

### Para produção:
- Substitua `localhost` pelo seu domínio real
- Exemplo: `https://seudominio.com/upload_image.php`

## 📱 Como Usar

### 1. Aplicativo Flutter
1. Abra o aplicativo Flutter
2. Toque em "Selecionar Imagem" para escolher uma imagem da galeria
3. Visualize o preview da imagem selecionada
4. Toque em "Enviar Imagem" para fazer o upload
5. Aguarde o feedback de sucesso ou erro

### 2. Interface Web
1. Acesse `test_upload.html` no navegador
2. Arraste e solte uma imagem ou clique para selecionar
3. Visualize o preview
4. Clique em "Enviar Imagem"
5. Veja o resultado na tela

### 3. Visualizar Imagens
1. Acesse `view_images.php` no navegador
2. Veja todas as imagens enviadas
3. Clique em "Ver Original" para baixar a imagem
4. Use "Atualizar" para ver novas imagens

## 🔒 Segurança

### Validações Implementadas:
- ✅ Verificação de tipo de arquivo (apenas imagens)
- ✅ Limite de tamanho (máximo 10MB)
- ✅ Geração de nomes únicos para evitar sobrescrita
- ✅ Sanitização de dados de entrada
- ✅ Headers de segurança CORS

### Recomendações Adicionais:
- 🔐 Implementar autenticação de usuários
- 🔐 Adicionar rate limiting
- 🔐 Configurar HTTPS em produção
- 🔐 Implementar watermark ou redimensionamento automático

## 📊 Banco de Dados

O sistema usa um arquivo JSON (`image_database.json`) para armazenar metadados das imagens:

```json
[
  {
    "id": "unique_id",
    "filename": "filename.jpg",
    "original_name": "original_name.jpg",
    "file_size": 123456,
    "file_type": "image/jpeg",
    "upload_path": "uploads/filename.jpg",
    "user_id": "123",
    "description": "Descrição da imagem",
    "upload_date": "2024-01-01 12:00:00",
    "url": "http://localhost/uploads/filename.jpg"
  }
]
```

## 🧹 Manutenção

### Limpeza Automática
- O sistema remove automaticamente arquivos com mais de 30 dias
- A limpeza é executada uma vez por dia
- Arquivos de log de limpeza são salvos em `last_cleanup.txt`

### Backup Recomendado
```bash
# Fazer backup das imagens
tar -czf backups/images_$(date +%Y%m%d).tar.gz uploads/

# Fazer backup do banco de dados
cp image_database.json backups/database_$(date +%Y%m%d).json
```

## 🐛 Troubleshooting

### Problemas Comuns:

1. **Erro 403 Forbidden**:
   - Verifique as permissões da pasta `uploads/`
   - Execute: `chmod 755 uploads/`

2. **Erro de Upload**:
   - Verifique o limite de upload no PHP (`upload_max_filesize`, `post_max_size`)
   - Verifique se a pasta `uploads/` existe e tem permissões

3. **Erro de CORS**:
   - Verifique se os headers CORS estão corretos
   - Adicione seu domínio aos headers permitidos

4. **Aplicativo Flutter não conecta**:
   - Verifique se a URL da API está correta
   - Teste a conexão usando `test_upload.html`

### Logs de Debug:
Adicione ao início de `upload_image.php`:
```php
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

## 📈 Melhorias Futuras

- 🔄 Upload em lote de múltiplas imagens
- 🖼️ Redimensionamento automático de imagens
- 📱 Aplicativo nativo para iOS/Android
- 🔐 Sistema de autenticação
- 📊 Dashboard com estatísticas
- 🔍 Busca e filtros na galeria
- 📤 Integração com cloud storage (AWS S3, Google Cloud)

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique a seção Troubleshooting
2. Teste com a interface web primeiro
3. Verifique os logs do servidor
4. Consulte a documentação do PHP e Flutter

## 📄 Licença

Este projeto é de código aberto e pode ser usado livremente para fins educacionais e comerciais.

---

**Desenvolvido com ❤️ usando Flutter + PHP**
