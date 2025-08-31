# Endpoints da API
Base   http://localhost/TCC/api/
## Usuário
GET    usuario/listar                - Lista todos os usuários
GET    usuario/listar/{id}           - Lista um usuário específico
GET    usuario/id_pai/{id}           - Lista todos os filhos de um pai específico
GET    usuario/Ativador/{id}         - Ativa um usuário pelo id
GET    usuario/Verificationcode      - Cria um codigo para a verificar 
POST   usuario/cadastro              - Cadastra um novo usuário
POST   usuario/cadastro/{id}         - Cadastra um novo usuário filho (onde {id} é o ID do pai)
POST   usuario/login                 - Realiza login de um usuário
POST   usuario/atualizar/{id}        - Atualiza dados de um usuário
POST   usuario/deletar/{id}          - Deleta um usuário e seus dados relacionados

## Categoria
GET    categoria/listar              - Lista todas as categorias
GET    categoria/listar/{id}         - Lista uma categoria específica
GET    categoria/listar_por_usuario/{id_usuario} - Lista categorias de um usuário
GET    categoria/contar_cards/{id_categoria}     - Conta cards de uma categoria
POST   categoria/criar               - Cria uma nova categoria
POST   categoria/atualizar/{id}      - Atualiza uma categoria
POST   categoria/deletar/{id}        - Deleta uma categoria

## Card
GET    card/listar                   - Lista todos os cards
GET    card/listar/{id}              - Lista um card específico
GET    card/listar_por_categoria/{id_categoria} - Lista todos os cards de uma categoria específica
POST   card/criar                    - Cria um novo card
POST   card/atualizar/{id}           - Atualiza um card
POST   card/deletar/{id}             - Deleta um card

## Mensagem
GET    mensagem/listar               - Lista todas as mensagens
GET    mensagem/listar/{id}          - Lista uma mensagem específica
GET    mensagem/listar_por_usuario/{id_usuario} - Lista mensagens de um usuário
GET    mensagem/listar_por_periodo/{periodo}    - Lista mensagens por período (dia, semana, mes)
POST   mensagem/criar                - Cria uma nova mensagem
POST   mensagem/atualizar/{id}       - Atualiza uma mensagem
POST   mensagem/deletar/{id}         - Deleta uma mensagem 