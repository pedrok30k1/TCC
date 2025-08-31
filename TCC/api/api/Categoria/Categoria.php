<?php


if($api == 'categoria'){
    // Método GET - Listar categorias
    if($method == 'GET'){
        if ($acao == "" && $param == ""){
            echo json_encode([
                'status' => 'error',
                'message' => 'Ação não informada'
            ]);
        }

        if($acao == 'listar'){
            try{
                $db = DB::connect();

                if(is_numeric($param)){
                    // Buscar categoria específica por ID
                    $stmt = $db->prepare("SELECT * FROM categorias WHERE id = :id");
                    $stmt->bindParam(':id', $param);
                } else {
                    // Buscar todas as categorias
                    $stmt = $db->prepare("SELECT * FROM categorias");
                }
                
                if ($stmt === false) {
                    throw new Exception("Erro ao preparar a consulta SQL");
                }
                
                $result = $stmt->execute();
                
                if ($result === false) {
                    throw new Exception("Erro ao executar a consulta SQL");
                }
                
                $obj = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                if(empty($obj)){
                    echo json_encode([
                        'status' => 'info',
                        'message' => 'Nenhuma categoria encontrada',
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
        
        // Listar categorias por usuário
        if($acao == 'listar_por_usuario'){
            try{
                $db = DB::connect();
                
                if(!is_numeric($param)){
                    throw new Exception("ID do usuário não informado ou inválido");
                }
                
                // Verificar se o usuário existe
                $checkUser = $db->prepare("SELECT id FROM usuarios WHERE id = :id");
                $checkUser->bindParam(':id', $param);
                $checkUser->execute();
                
                if($checkUser->rowCount() == 0){
                    throw new Exception("Usuário não encontrado");
                }
                
                $stmt = $db->prepare("SELECT * FROM categorias WHERE id_usuario = :id_usuario");
                $stmt->bindParam(':id_usuario', $param);
                
                if ($stmt->execute()) {
                    $obj = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    
                    if(empty($obj)){
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Nenhuma categoria encontrada para este usuário',
                            'data' => []
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'success',
                            'data' => $obj
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao buscar categorias do usuário");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        
        // Contar cards por categoria
        if($acao == 'contar_cards'){
            try{
                $db = DB::connect();
                
                if(!is_numeric($param)){
                    throw new Exception("ID da categoria não informado ou inválido");
                }
                
                // Verificar se a categoria existe
                $checkCategoria = $db->prepare("SELECT id FROM categorias WHERE id = :id");
                $checkCategoria->bindParam(':id', $param);
                $checkCategoria->execute();
                
                if($checkCategoria->rowCount() == 0){
                    throw new Exception("Categoria não encontrada");
                }
                
                $stmt = $db->prepare("SELECT COUNT(*) as total FROM cards WHERE id_categoria = :id_categoria");
                $stmt->bindParam(':id_categoria', $param);
                
                if ($stmt->execute()) {
                    $resultado = $stmt->fetch(PDO::FETCH_ASSOC);
                    
                    echo json_encode([
                        'status' => 'success',
                        'total_cards' => $resultado['total']
                    ]);
                } else {
                    throw new Exception("Erro ao contar cards da categoria");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
    }
    
    // Método POST - Criar categoria
    if($method == 'POST'){
        if($acao == 'criar'){
            try {
                $db = DB::connect();
                
                // Obtenha os dados do corpo da requisição POST
                $dados = json_decode(file_get_contents('php://input'), true);
                
                // Verifique se os campos necessários estão presentes
                if (!isset($dados['nome']) || !isset($dados['id_usuario'])) {
                    throw new Exception("Campos obrigatórios não informados (nome e id_usuario são obrigatórios)");
                }
                
                $nome = $dados['nome'];
                $foto_url = isset($dados['foto_url']) ? $dados['foto_url'] : null;
                $id_usuario = $dados['id_usuario'];
                $tema_cor = isset($dados['tema_cor']) ? $dados['tema_cor'] : null;
                
                // Verificar se o usuário existe
                $checkUser = $db->prepare("SELECT id FROM usuarios WHERE id = :id");
                $checkUser->bindParam(':id', $id_usuario);
                $checkUser->execute();
                
                if($checkUser->rowCount() == 0){
                    throw new Exception("Usuário não encontrado");
                }
                
                $stmt = $db->prepare("INSERT INTO categorias (nome, foto_url, id_usuario, tema_cor) 
                                      VALUES (:nome, :foto_url, :id_usuario, :tema_cor)");
                $stmt->bindParam(':nome', $nome);
                $stmt->bindParam(':foto_url', $foto_url);
                $stmt->bindParam(':id_usuario', $id_usuario);
                $stmt->bindParam(':tema_cor', $tema_cor);
                
                if ($stmt->execute()) {
                    $id = $db->lastInsertId();
                    echo json_encode([
                        'status' => 'success',
                        'message' => 'Categoria criada com sucesso',
                        'id' => $id
                    ]);
                } else {
                    throw new Exception("Erro ao criar categoria");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Ação não reconhecida'
            ]);
        }
    }
    
    // Método POST - Atualizar categoria (antigo PUT)
    if($method == 'POST'){
        if($acao == 'atualizar'){
            try {
                $db = DB::connect();
                
                // Verifique se o ID foi fornecido
                if (!is_numeric($param)) {
                    throw new Exception("ID da categoria não informado");
                }
                
                // Obtenha os dados do corpo da requisição
                $dados = json_decode(file_get_contents('php://input'), true);
                
                // Verifique se há dados para atualizar
                if (empty($dados)) {
                    throw new Exception("Nenhum dado fornecido para atualização");
                }
                
                // Construa a consulta SQL de atualização dinamicamente
                $sql = "UPDATE categorias SET ";
                $params = [];
                
                if (isset($dados['nome'])) {
                    $sql .= "nome = :nome, ";
                    $params[':nome'] = $dados['nome'];
                }
                
                if (isset($dados['foto_url'])) {
                    $sql .= "foto_url = :foto_url, ";
                    $params[':foto_url'] = $dados['foto_url'];
                }
                
                if (isset($dados['tema_cor'])) {
                    $sql .= "tema_cor = :tema_cor, ";
                    $params[':tema_cor'] = $dados['tema_cor'];
                }
                
                // Remova a vírgula extra no final
                $sql = rtrim($sql, ", ");
                
                // Adicione a cláusula WHERE
                $sql .= " WHERE id = :id";
                $params[':id'] = $param;
                
                $stmt = $db->prepare($sql);
                
                // Associe todos os parâmetros
                foreach ($params as $key => $value) {
                    $stmt->bindValue($key, $value);
                }
                
                if ($stmt->execute()) {
                    // Verifique se alguma linha foi afetada
                    if ($stmt->rowCount() > 0) {
                        echo json_encode([
                            'status' => 'success',
                            'message' => 'Categoria atualizada com sucesso'
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Nenhum dado foi alterado ou categoria não encontrada'
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao atualizar categoria");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        // Método POST - Excluir categoria (antigo DELETE)
        else if($acao == 'deletar'){
            try {
                $db = DB::connect();
                
                // Verifique se o ID foi fornecido
                if (!is_numeric($param)) {
                    throw new Exception("ID da categoria não informado");
                }
                
                // Verificar se existem cards associados a esta categoria
                $checkCards = $db->prepare("SELECT COUNT(*) as total FROM cards WHERE id_categoria = :id_categoria");
                $checkCards->bindParam(':id_categoria', $param);
                $checkCards->execute();
                $resultado = $checkCards->fetch(PDO::FETCH_ASSOC);
                
                if ($resultado['total'] > 0) {
                    echo json_encode([
                        'status' => 'warning',
                        'message' => 'Esta categoria possui ' . $resultado['total'] . ' cards associados que também serão excluídos',
                        'proceed' => true,
                        'total_cards' => $resultado['total']
                    ]);
                    return;
                }
                
                // Executar a exclusão
                $stmt = $db->prepare("DELETE FROM categorias WHERE id = :id");
                $stmt->bindParam(':id', $param);
                
                if ($stmt->execute()) {
                    if ($stmt->rowCount() > 0) {
                        echo json_encode([
                            'status' => 'success',
                            'message' => 'Categoria excluída com sucesso'
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Categoria não encontrada'
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao excluir categoria");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
    }
}
?>