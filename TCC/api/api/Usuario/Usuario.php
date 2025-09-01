<?php
function sanitizeInput($data) {
    if (is_array($data)) {
        foreach ($data as $key => $value) {
            $data[$key] = sanitizeInput($value);
        }
        return $data;
    } else {
        return htmlspecialchars(trim($data));
    }
}

if ($api == 'usuario') {
    if ($method == "GET") {
        if (empty($acao)) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Ação não informada'
            ]);
            exit;
        }
        
        if ($acao == "listar") {
            try {
                $db = DB::connect();
                
                $query = "SELECT id, nome, email, cpf, data_nasc, foto_url, legenda, ativo ,id_pai FROM usuarios";
                $params = [];
                
                if (is_numeric($param)) {
                    $query .= " WHERE id = :id";
                    $params[':id'] = $param;
                } 
                
                $stmt = $db->prepare($query);
                
                if ($stmt === false) {
                    throw new Exception("Erro ao preparar a consulta SQL");
                }
                
                foreach ($params as $key => $value) {
                    $stmt->bindValue($key, $value);
                }
                
                if (!$stmt->execute()) {
                    throw new Exception("Erro ao executar a consulta SQL");
                }
                
                $obj = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                if (empty($obj)) {
                    echo json_encode([
                        'status' => 'info',
                        'message' => 'Nenhum registro encontrado',
                        'data' => []
                    ]);
                } else {
                    echo json_encode([
                        'status' => 'success',
                        'data' => $obj
                    ]);
                }
                
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        
        if ($acao == "id_pai") {
            if (!is_numeric($param)) {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'ID do pai inválido'
                ]);
                exit;
            }
            
            try {
                $db = DB::connect();
                
                $stmt = $db->prepare("SELECT id FROM usuarios WHERE id = :id ");
                $stmt->bindParam(':id', $param);
                
                if (!$stmt->execute()) {
                    throw new Exception("Erro ao verificar usuário pai");
                }
                
                if ($stmt->rowCount() === 0) {
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Usuário não é um pai'
                    ]);
                    exit;
                }
                
                $stmt = $db->prepare("SELECT * FROM usuarios WHERE id_pai = :id_pai");
                $stmt->bindParam(':id_pai', $param);
                
                if (!$stmt->execute()) {
                    throw new Exception("Erro ao buscar filhos");
                }
                
                $filhos = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                if (empty($filhos)) {
                    echo json_encode([
                        'status' => 'info',
                        'message' => 'Nenhum filho encontrado',
                        'data' => []
                    ]);
                } else {
                    echo json_encode([
                        'status' => 'success',
                        'data' => $filhos
                    ]);
                }
                
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        if ($acao == "Verificationcode") {
            $numero = rand(0, 999999);
            $numero_com_zeros = str_pad($numero, 6, '0', STR_PAD_LEFT);
            echo json_encode([
                'status' => 'codigo de verificação',
                'data' => $numero 
            ]);
        }
        if($acao == "Ativador"){
            if (!is_numeric($param)) {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'ID inválido'
                ]);
                exit;
            }
            try {
                $db = DB::connect();
                $stmt = $db->prepare("UPDATE usuarios SET ativo = true WHERE id = :id");
                $stmt->bindParam(':id', $param);
                $stmt->execute();
                if ($stmt->rowCount() === 0) {
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Usuário não encontrado ou já está ativo'
                    ]);
                } else {
                    echo json_encode([
                        'status' => 'success',
                        'message' => 'Usuário ativado com sucesso'
                    ]);
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
            exit;
        }
       if ($acao == "categorias_cards") {
    if (!is_numeric($param)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'ID do usuário inválido'
        ]);
        exit;
    }

    try {
        $db = DB::connect();

        // Pega todas as categorias do usuário
        $stmt = $db->prepare("SELECT id, nome, foto_url, tema_cor FROM categorias WHERE id_usuario = :id_usuario");
        $stmt->bindParam(':id_usuario', $param);
        $stmt->execute();
        $categorias = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($categorias)) {
            echo json_encode([
                'status' => 'info',
                'message' => 'Nenhuma categoria encontrada',
                'data' => []
            ]);
            exit;
        }

        // Para cada categoria, pega os cards
        foreach ($categorias as &$categoria) {
            $stmt = $db->prepare("SELECT id AS card_id, titulo, descricao, imagem_url, tema_cor FROM cards WHERE id_categoria = :id_categoria");
            $stmt->bindParam(':id_categoria', $categoria['id']);
            $stmt->execute();
            $cards = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $categoria['cards'] = $cards;
        }

        echo json_encode([
            'status' => 'success',
            'data' => $categorias
        ]);

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
    }
    exit;
}


        
    }
    
    if ($method == "POST") {
        $data = json_decode(file_get_contents('php://input'), true);
        $data = sanitizeInput($data);
        
        if ($acao == "cadastro") {
            $required_fields = ['nome', 'email', 'senha', 'cpf', 'data_nasc'];
            $missing = [];
           
            foreach ($required_fields as $field) {
                if (!isset($data[$field]) || empty($data[$field])) {
                    $missing[] = $field;
                }
            }
            
            if (!empty($missing)) {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Campos obrigatórios faltando: ' . implode(', ', $missing)
                ]);
                exit;
            }
            
            if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Email inválido'
                ]);
                exit;
            }
            
            if (!preg_match('/^\d{11}$/', $data['cpf'])) {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'CPF inválido'
                ]);
                exit;
            }
            
            try {
                $db = DB::connect();
                
                $stmt = $db->prepare("SELECT id FROM usuarios WHERE email = :email");
                $stmt->bindParam(':email', $data['email']);
                $stmt->execute();
                
                if ($stmt->rowCount() > 0) {
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Email já cadastrado'
                    ]);
                    exit;
                }
                
                $stmt = $db->prepare("SELECT id FROM usuarios WHERE cpf = :cpf");
                $stmt->bindParam(':cpf', $data['cpf']);
                $stmt->execute();
                
                if ($stmt->rowCount() > 0) {
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'CPF já cadastrado'
                    ]);
                    exit;
                }
                
                $senha_hash = password_hash($data['senha'], PASSWORD_DEFAULT);
               
                
                $nome = $data['nome'];
                $email = $data['email'];
                $senha = $senha_hash;
                $cpf = $data['cpf'];
                $data_nasc = $data['data_nasc'];
                $foto_url = $data['foto_url'] ?? null;
                $legenda = $data['legenda'] ?? null;
                $id_pai = is_numeric($param) ? $param : null;
                
                $sql = "INSERT INTO usuarios (nome, email, senha, cpf, data_nasc, foto_url, legenda";
                $sql_values = ":nome, :email, :senha, :cpf, :data_nasc, :foto_url, :legenda";
                if ($id_pai !== null) {
                    $sql .= ", id_pai";
                    $sql_values .= ", :id_pai";
                }
                $sql .= ") VALUES (" . $sql_values . ")";
                
                $stmt = $db->prepare($sql);
                $stmt->bindParam(':nome', $nome);
                $stmt->bindParam(':email', $email);
                $stmt->bindParam(':senha', $senha);
                $stmt->bindParam(':cpf', $cpf);
                $stmt->bindParam(':data_nasc', $data_nasc);
                $stmt->bindParam(':foto_url', $foto_url);
                $stmt->bindParam(':legenda', $legenda);
                if ($id_pai !== null) {
                    $stmt->bindParam(':id_pai', $id_pai);
                }
                
                if (!$stmt->execute()) {
                    throw new Exception("Erro ao cadastrar usuário");
                }
                
                $lastId = $db->lastInsertId();
                
                echo json_encode([
                    'status' => 'success',
                    'message' => 'Usuário cadastrado com sucesso',
                    'id' => $lastId
                ]);
                
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        if($acao == "login"){
            try {
                $db = DB::connect();
                $data = json_decode(file_get_contents('php://input'), true);
                $email = $data['email'];
                $senha = $data['senha'];
                
                $stmt = $db->prepare("SELECT id,ativo,nome,id_pai,foto_url, senha FROM `usuarios` WHERE `email` = :email");
                $stmt->bindParam(':email', $email);
                $result = $stmt->execute();
                
                if ($result === false) {
                    throw new Exception("Erro ao executar a consulta SQL");
                }
                
                $obj = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                if(empty($obj) || !password_verify($senha, $obj[0]['senha'])) {
                    echo json_encode([
                        'status' => 'error',
                        'message' => 'Usuário ou senha inválidos'
                    ]);
                    exit;
                }
                
                unset($obj[0]['senha']);
                
                echo json_encode([
                    'status' => 'success',
                    'message' => 'Login realizado com sucesso',
                    'data' => $obj
                ]);
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        if($acao == "atualizar"){
            try {
                if(!is_numeric($param)){
                    throw new Exception("ID do usuário inválido");
                }

                $db = DB::connect();
                $data = json_decode(file_get_contents('php://input'), true);
                
                $required_fields = ['nome', 'email', 'senha', 'cpf', 'data_nasc', 'legenda', 'ativo'];
                foreach ($required_fields as $field) {
                    if (!isset($data[$field]) || empty($data[$field])) {
                        throw new Exception("Campo {$field} é obrigatório");
                    }
                }

                if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
                    throw new Exception("Email inválido");
                }

                if (!preg_match('/^\d{11}$/', $data['cpf'])) {
                    throw new Exception("Formato de CPF inválido");
                }

                $nome = $data['nome'];
                $email = $data['email'];
                $senha = $data['senha'];
                $senha = password_hash($senha, PASSWORD_DEFAULT);
                $cpf = $data['cpf'];
                $data_nasc = $data['data_nasc'];
                $legenda = $data['legenda'];
                $ativo = $data['ativo'];
                $foto_url = isset($data['foto_url']) ? $data['foto_url'] : null;

                $stmt = $db->prepare("SELECT id FROM usuarios WHERE id = :id");
                $stmt->bindParam(':id', $param);
                $stmt->execute();
                if ($stmt->rowCount() === 0) {
                    throw new Exception("Usuário não encontrado");
                }

                $stmt = $db->prepare("SELECT id FROM usuarios WHERE email = :email AND id != :id");
                $stmt->bindParam(':email', $email);
                $stmt->bindParam(':id', $param);
                $stmt->execute();
                if ($stmt->rowCount() > 0) {
                    throw new Exception("Email já cadastrado para outro usuário");
                }

                $stmt = $db->prepare("UPDATE `usuarios` SET `nome` = :nome, `email` = :email, `senha` = :senha, 
                                    `cpf` = :cpf, `data_nasc` = :data_nasc, `foto_url` = :foto_url, 
                                    `legenda` = :legenda, `ativo` = :ativo 
                                    WHERE `id` = :id");
                $stmt->bindParam(':nome', $nome);
                $stmt->bindParam(':email', $email);
                $stmt->bindParam(':senha', $senha);
                $stmt->bindParam(':cpf', $cpf);
                $stmt->bindParam(':data_nasc', $data_nasc);
                $stmt->bindParam(':foto_url', $foto_url);
                $stmt->bindParam(':legenda', $legenda);
                $stmt->bindParam(':ativo', $ativo);
                $stmt->bindParam(':id', $param);
                
                $result = $stmt->execute();
                if ($result === false) {
                    throw new Exception("Erro ao executar a consulta SQL");
                }

                echo json_encode([
                    'status' => 'success',
                    'message' => 'Usuário atualizado com sucesso'
                ]);

            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        if ($acao == "deletar") {
    try {
        if (!is_numeric($param)) {
            throw new Exception("ID do usuário inválido");
        }

        $db = DB::connect();

        // Verifica usuário
        $stmt = $db->prepare("SELECT id, id_pai FROM usuarios WHERE id = :id");
        $stmt->bindParam(':id', $param);
        $stmt->execute();

        if ($stmt->rowCount() === 0) {
            throw new Exception("Usuário não encontrado");
        }

        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        $db->beginTransaction();

        try {
            // Se for pai (id_pai NULL), deleta filhos primeiro
            if (is_null($user['id_pai'])) {
                $stmt = $db->prepare("SELECT id FROM usuarios WHERE id_pai = :idPai");
                $stmt->bindParam(':idPai', $user['id']);
                $stmt->execute();
                $filhos = $stmt->fetchAll(PDO::FETCH_COLUMN);

                if (!empty($filhos)) {
                    foreach ($filhos as $idFilho) {
                        deletarUsuario($db, $idFilho);
                    }
                }
            }

            // Agora deleta o próprio usuário
            deletarUsuario($db, $user['id']);

            $db->commit();

            echo json_encode([
                'status' => 'success',
                'message' => 'Usuário e todos os dados relacionados foram deletados com sucesso'
            ]);
        } catch (Exception $e) {
            $db->rollBack();
            throw new Exception("Erro ao deletar usuário: " . $e->getMessage());
        }

    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => $e->getMessage()
        ]);
    }
}

/**
 * Função auxiliar para deletar usuário e seus dados vinculados
 */
function deletarUsuario($db, $idUsuario)
{
    // Endereços
    $stmt = $db->prepare("DELETE FROM enderecos_usuario WHERE id_usuario = :id");
    $stmt->bindParam(':id', $idUsuario);
    $stmt->execute();

    // Telefones
    $stmt = $db->prepare("DELETE FROM telefones_usuario WHERE id_usuario = :id");
    $stmt->bindParam(':id', $idUsuario);
    $stmt->execute();

    // Mensagens
    $stmt = $db->prepare("DELETE FROM mensagens WHERE id_usuario = :id");
    $stmt->bindParam(':id', $idUsuario);
    $stmt->execute();

    // Categorias e cards
    $stmt = $db->prepare("SELECT id FROM categorias WHERE id_usuario = :id");
    $stmt->bindParam(':id', $idUsuario);
    $stmt->execute();
    $categorias = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (!empty($categorias)) {
        $stmt = $db->prepare("DELETE FROM cards WHERE id_categoria IN (" . implode(',', $categorias) . ")");
        $stmt->execute();

        $stmt = $db->prepare("DELETE FROM categorias WHERE id_usuario = :id");
        $stmt->bindParam(':id', $idUsuario);
        $stmt->execute();
    }

    // Finalmente, deleta o usuário
    $stmt = $db->prepare("DELETE FROM usuarios WHERE id = :id");
    $stmt->bindParam(':id', $idUsuario);
    $stmt->execute();
   }

    }
}
?>