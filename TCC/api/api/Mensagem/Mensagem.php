<?php


if($api == 'mensagem'){
    // Método GET - Listar mensagens
    if($method == 'GET'){
        if ($acao == "" && $param == ""){
            echo json_encode([
                'status' => 'error',
                'message' => 'Ação não informada'
            ]);
        }

        // Listar todas as mensagens ou uma mensagem específica
        if($acao == 'listar'){
            try{
                $db = DB::connect();

                if(is_numeric($param)){
                    // Buscar mensagem específica por ID
                    $stmt = $db->prepare("SELECT m.*, u.nome as nome_usuario 
                                         FROM mensagens m 
                                         LEFT JOIN usuarios u ON m.id_usuario = u.id 
                                         WHERE m.id = :id");
                    $stmt->bindParam(':id', $param);
                } else {
                    // Buscar todas as mensagens
                    $stmt = $db->prepare("SELECT m.*, u.nome as nome_usuario 
                                         FROM mensagens m 
                                         LEFT JOIN usuarios u ON m.id_usuario = u.id 
                                         ORDER BY m.data_envio DESC");
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
                        'message' => 'Nenhuma mensagem encontrada',
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
        
        // Listar mensagens por usuário
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
                
                $stmt = $db->prepare("SELECT m.*, u.nome as nome_usuario 
                                     FROM mensagens m 
                                     LEFT JOIN usuarios u ON m.id_usuario = u.id 
                                     WHERE m.id_usuario = :id_usuario 
                                     ORDER BY m.data_envio DESC");
                $stmt->bindParam(':id_usuario', $param);
                
                if ($stmt->execute()) {
                    $obj = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    
                    if(empty($obj)){
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Nenhuma mensagem encontrada para este usuário',
                            'data' => []
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'success',
                            'data' => $obj
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao buscar mensagens do usuário");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        
        // Buscar mensagens por data (último dia, semana, mês)
        if($acao == 'listar_por_periodo'){
            try{
                $db = DB::connect();
                
                $periodo = $param; // dia, semana, mes
                $data_inicio = null;
                
                $data_atual = date('Y-m-d H:i:s');
                
                switch($periodo) {
                    case 'dia':
                        $data_inicio = date('Y-m-d H:i:s', strtotime('-1 day'));
                        break;
                    case 'semana':
                        $data_inicio = date('Y-m-d H:i:s', strtotime('-1 week'));
                        break;
                    case 'mes':
                        $data_inicio = date('Y-m-d H:i:s', strtotime('-1 month'));
                        break;
                    default:
                        throw new Exception("Período inválido. Use 'dia', 'semana' ou 'mes'");
                }
                
                $stmt = $db->prepare("SELECT m.*, u.nome as nome_usuario 
                                     FROM mensagens m 
                                     LEFT JOIN usuarios u ON m.id_usuario = u.id 
                                     WHERE m.data_envio BETWEEN :data_inicio AND :data_atual 
                                     ORDER BY m.data_envio DESC");
                $stmt->bindParam(':data_inicio', $data_inicio);
                $stmt->bindParam(':data_atual', $data_atual);
                
                if ($stmt->execute()) {
                    $obj = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    
                    if(empty($obj)){
                        echo json_encode([
                            'status' => 'info',
                            'message' => "Nenhuma mensagem encontrada no último $periodo",
                            'data' => []
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'success',
                            'data' => $obj
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao buscar mensagens por período");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
    }
    
    // Método POST - Criar mensagem
    if($method == 'POST'){
        if($acao == 'criar'){
            try {
                $db = DB::connect();
                
                // Obtenha os dados do corpo da requisição POST
                $dados = json_decode(file_get_contents('php://input'), true);
                
                // Verifique se o texto da mensagem está presente
                if (!isset($dados['texto']) || empty(trim($dados['texto']))) {
                    throw new Exception("O texto da mensagem é obrigatório");
                }
                
                $texto = $dados['texto'];
                $data_envio = date('Y-m-d H:i:s');
                $id_usuario = isset($dados['id_usuario']) ? $dados['id_usuario'] : null;
                
                // Se id_usuario foi fornecido, verificar se o usuário existe
                if (!is_null($id_usuario)) {
                    $checkUser = $db->prepare("SELECT id FROM usuarios WHERE id = :id");
                    $checkUser->bindParam(':id', $id_usuario);
                    $checkUser->execute();
                    
                    if($checkUser->rowCount() == 0){
                        throw new Exception("Usuário não encontrado");
                    }
                }
                
                $stmt = $db->prepare("INSERT INTO mensagens (texto, data_envio, id_usuario) 
                                      VALUES (:texto, :data_envio, :id_usuario)");
                $stmt->bindParam(':texto', $texto);
                $stmt->bindParam(':data_envio', $data_envio);
                $stmt->bindParam(':id_usuario', $id_usuario);
                
                if ($stmt->execute()) {
                    $id = $db->lastInsertId();
                    echo json_encode([
                        'status' => 'success',
                        'message' => 'Mensagem enviada com sucesso',
                        'id' => $id,
                        'data_envio' => $data_envio
                    ]);
                } else {
                    throw new Exception("Erro ao enviar mensagem");
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
    
    // Método POST - Atualizar mensagem (antigo PUT)
    if($method == 'POST'){
        if($acao == 'atualizar'){
            try {
                $db = DB::connect();
                
                // Verifique se o ID foi fornecido
                if (!is_numeric($param)) {
                    throw new Exception("ID da mensagem não informado");
                }
                
                // Obtenha os dados do corpo da requisição
                $dados = json_decode(file_get_contents('php://input'), true);
                
                // Verifique se há dados para atualizar
                if (empty($dados)) {
                    throw new Exception("Nenhum dado fornecido para atualização");
                }
                
                // Verificar se a mensagem existe
                $checkMsg = $db->prepare("SELECT id, data_envio FROM mensagens WHERE id = :id");
                $checkMsg->bindParam(':id', $param);
                $checkMsg->execute();
                
                if($checkMsg->rowCount() == 0){
                    throw new Exception("Mensagem não encontrada");
                }
                
                $mensagem = $checkMsg->fetch(PDO::FETCH_ASSOC);
                $data_original = new DateTime($mensagem['data_envio']);
                $data_atual = new DateTime();
                $diff = $data_atual->diff($data_original);
                
                // Opcional: Impedir edição após um certo período (ex: 24 horas)
                $horas_limite_edicao = 24;
                if ($diff->h > $horas_limite_edicao || $diff->days > 0) {
                    throw new Exception("Não é possível editar mensagens com mais de $horas_limite_edicao horas");
                }
                
                // Construa a consulta SQL de atualização
                $sql = "UPDATE mensagens SET ";
                $params = [];
                
                if (isset($dados['texto'])) {
                    if (empty(trim($dados['texto']))) {
                        throw new Exception("O texto da mensagem não pode ser vazio");
                    }
                    $sql .= "texto = :texto";
                    $params[':texto'] = $dados['texto'];
                }
                
                // Adicionar registro de edição (opcional)
                $sql .= ", texto = CONCAT(texto, ' [editado em " . date('d/m/Y H:i') . "]')";
                
                // Adicione a cláusula WHERE
                $sql .= " WHERE id = :id";
                $params[':id'] = $param;
                
                $stmt = $db->prepare($sql);
                
                // Associe todos os parâmetros
                foreach ($params as $key => $value) {
                    $stmt->bindValue($key, $value);
                }
                
                if ($stmt->execute()) {
                    if ($stmt->rowCount() > 0) {
                        echo json_encode([
                            'status' => 'success',
                            'message' => 'Mensagem atualizada com sucesso'
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Nenhum dado foi alterado'
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao atualizar mensagem");
                }
            } catch (Exception $e) {
                echo json_encode([
                    'status' => 'error',
                    'message' => $e->getMessage()
                ]);
            }
        }
        // Método POST - Excluir mensagem (antigo DELETE)
        else if($acao == 'deletar'){
            try {
                $db = DB::connect();
                
                // Verifique se o ID foi fornecido
                if (!is_numeric($param)) {
                    throw new Exception("ID da mensagem não informado");
                }
                
                $stmt = $db->prepare("DELETE FROM mensagens WHERE id = :id");
                $stmt->bindParam(':id', $param);
                
                if ($stmt->execute()) {
                    if ($stmt->rowCount() > 0) {
                        echo json_encode([
                            'status' => 'success',
                            'message' => 'Mensagem excluída com sucesso'
                        ]);
                    } else {
                        echo json_encode([
                            'status' => 'info',
                            'message' => 'Mensagem não encontrada'
                        ]);
                    }
                } else {
                    throw new Exception("Erro ao excluir mensagem");
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