<?php

if($api == 'card'){
    // Método GET - Listar cards
    if($method == 'GET'){
        if ($acao == "" && $param == ""){
            echo json_encode([
                'status' => 'error',
                'message' => 'Ação não informada'
            ]);
            exit;
        }

        if($acao == 'listar'){
            try{
                $db = DB::connect();

                if(is_numeric($param)){
                    $stmt = $db->prepare("SELECT * FROM cards WHERE id = :id");
                    $stmt->bindParam(':id', $param);
                }else{
                    $stmt = $db->prepare("SELECT * FROM cards");
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
        // Novo endpoint: listar cards por categoria
        if($acao == 'listar_por_categoria'){
            try{
                $db = DB::connect();
                if(!is_numeric($param)){
                    throw new Exception("ID da categoria não informado ou inválido");
                }
                $stmt = $db->prepare("SELECT * FROM cards WHERE id_categoria = :id_categoria");
                $stmt->bindParam(':id_categoria', $param);
                if ($stmt->execute()) {
                    $obj = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    if(empty($obj)){
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Nenhum card encontrado para esta categoria',
                            'data' => []
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'success',
                            'data' => $obj
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao buscar cards da categoria");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
    }
           
    // Método POST - Criar card
    if($method == 'POST'){
        if($acao == 'criar'){
            try {
                $db = DB::connect();
                
                $dados = json_decode(file_get_contents('php://input'), true);
                
                if (!isset($dados['titulo']) || !isset($dados['id_categoria'])) {
                    throw new Exception("Campos obrigatórios não informados (título e id_categoria são obrigatórios)");
                }
                
                $titulo = $dados['titulo'];
                $descricao = isset($dados['descricao']) ? $dados['descricao'] : null;
                $imagem_url = isset($dados['imagem_url']) ? $dados['imagem_url'] : null;
                $tema_cor = isset($dados['tema_cor']) ? $dados['tema_cor'] : null;
                $fonte = isset($dados['fonte']) ? $dados['fonte'] : 'M';
                $id_categoria = $dados['id_categoria'];
                
                $stmtCheck = $db->prepare("SELECT id FROM categorias WHERE id = :id");
                $stmtCheck->bindParam(':id', $id_categoria);
                $stmtCheck->execute();
                
                if ($stmtCheck->rowCount() == 0) {
                    throw new Exception("A categoria informada não existe");
                }
                
                $stmt = $db->prepare("INSERT INTO cards (titulo, descricao, imagem_url, tema_cor, id_categoria) 
                                      VALUES (:titulo, :descricao, :imagem_url, :tema_cor, :id_categoria)");
                $stmt->bindParam(':titulo', $titulo);
                $stmt->bindParam(':descricao', $descricao);
                $stmt->bindParam(':imagem_url', $imagem_url);
                $stmt->bindParam(':tema_cor', $tema_cor);
                $stmt->bindParam(':id_categoria', $id_categoria);
                
                if ($stmt->execute()) {
                    $id = $db->lastInsertId();
                    echo json_encode([
                        'status' => 'success',
                        'message' => 'Card criado com sucesso',
                        'id' => $id
                    ]);
                } else {
                    throw new Exception("Erro ao criar card");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        // Método POST - Atualizar card (antigo PUT)
        else if($acao == 'atualizar'){
            try {
                $db = DB::connect();
                
                if (!is_numeric($param)) {
                    throw new Exception("ID do card não informado");
                }
                
                $dados = json_decode(file_get_contents('php://input'), true);
                
                if (empty($dados)) {
                    throw new Exception("Nenhum dado fornecido para atualização");
                }
                
                $sql = "UPDATE cards SET ";
                $params = [];
                
                if (isset($dados['titulo'])) {
                    $sql .= "titulo = :titulo, ";
                    $params[':titulo'] = $dados['titulo'];
                }
                
                if (isset($dados['descricao'])) {
                    $sql .= "descricao = :descricao, ";
                    $params[':descricao'] = $dados['descricao'];
                }
                
                if (isset($dados['imagem_url'])) {
                    $sql .= "imagem_url = :imagem_url, ";
                    $params[':imagem_url'] = $dados['imagem_url'];
                }
                
                if (isset($dados['tema_cor'])) {
                    $sql .= "tema_cor = :tema_cor, ";
                    $params[':tema_cor'] = $dados['tema_cor'];
                }
                
                
                $sql = rtrim($sql, ", ");
                
                $sql .= " WHERE id = :id";
                $params[':id'] = $param;
                
                $stmt = $db->prepare($sql);
                
                foreach ($params as $key => $value) {
                    $stmt->bindValue($key, $value);
                }
                
                if ($stmt->execute()) {
                    if ($stmt->rowCount() > 0) {
                        echo json_encode([
                            'status' => 'success',
                            'message' => 'Card atualizado com sucesso'
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Nenhum dado foi alterado ou card não encontrado'
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao atualizar card");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        // Método POST - Excluir card (antigo DELETE)
        else if($acao == 'deletar'){
            try {
                $db = DB::connect();
                
                if (!is_numeric($param)) {
                    throw new Exception("ID do card não informado");
                }
                
                $stmt = $db->prepare("DELETE FROM cards WHERE id = :id");
                $stmt->bindParam(':id', $param);
                
                if ($stmt->execute()) {
                    if ($stmt->rowCount() > 0) {
                        echo json_encode([
                            'status' => 'success',
                            'message' => 'Card excluído com sucesso'
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Card não encontrado'
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao excluir card");
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