USE loja_tech;

-- Exercício 1: atualizar_preco_categoria
DROP PROCEDURE IF EXISTS atualizar_preco_categoria;
DELIMITER //
CREATE PROCEDURE atualizar_preco_categoria(
    IN p_id_categoria INT,
    IN p_percentual DECIMAL(5,2),
    OUT p_qtd_alterados INT,
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_categoria_existe INT DEFAULT 0;

    -- Handler para eventual falha de banco
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: Falha interna ao atualizar os preços.';
    END;

    -- Verifica se a categoria existe e está ativa
    SELECT COUNT(*) INTO v_categoria_existe
    FROM categorias
    WHERE id_categoria = p_id_categoria AND ativo = TRUE;

    IF v_categoria_existe = 0 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: Categoria não encontrada ou inativa.';
    ELSEIF p_percentual < -50.00 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: O desconto máximo permitido é de 50%.';
    ELSEIF p_percentual > 100.00 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'ERRO: O aumento máximo permitido é de 100%.';
    ELSEIF p_percentual = 0 THEN
        SET p_qtd_alterados = 0;
        SET p_mensagem = 'AVISO: Percentual informado é 0%. Nenhum preço foi alterado.';
    ELSE
        START TRANSACTION;

        UPDATE produtos
        SET preco = preco + (preco * (p_percentual / 100))
        WHERE id_categoria = p_id_categoria AND ativo = TRUE;

        SET p_qtd_alterados = ROW_COUNT();

        INSERT INTO log_operacoes (tabela_afetada, operacao, descricao)
        VALUES (
            'produtos',
            'UPDATE',
            CONCAT('Reajuste de ', p_percentual, '% na categoria ID ', p_id_categoria, '. Produtos afetados: ', p_qtd_alterados)
        );

        COMMIT;

        SET p_mensagem = CONCAT('Sucesso! ', p_qtd_alterados, ' produto(s) atualizado(s).');
    END IF;
END //
DELIMITER ;

-- Exemplo de chamada:
-- CALL atualizar_preco_categoria(3, 10.00, @qtd, @msg);
-- SELECT @qtd AS produtos_alterados, @msg AS mensagem;


-- Exercício 2: consultar_extrato_cliente
DROP PROCEDURE IF EXISTS consultar_extrato_cliente;
DELIMITER //
CREATE PROCEDURE consultar_extrato_cliente(
    IN p_id_cliente INT
)
BEGIN
    DECLARE v_cliente_existe INT DEFAULT 0;

    SELECT COUNT(*) INTO v_cliente_existe
    FROM clientes
    WHERE id_cliente = p_id_cliente;

    IF v_cliente_existe = 0 THEN
        SELECT 'ERRO: Cliente não encontrado na base de dados.' AS mensagem_erro;
    ELSE
        -- Result Set 1: Dados do cliente
        SELECT nome, email, telefone, criado_em AS data_cadastro
        FROM clientes
        WHERE id_cliente = p_id_cliente;

        -- Result Set 2: Todos os pedidos do cliente
        SELECT id_pedido AS numero, data_pedido AS data, status, valor_total
        FROM pedidos
        WHERE id_cliente = p_id_cliente
        ORDER BY data_pedido DESC;

        -- Result Set 3: Resumo financeiro e de pedidos (desconsiderando cancelados ou considerando todos)
        SELECT 
            COUNT(id_pedido) AS total_pedidos,
            IFNULL(SUM(valor_total), 0.00) AS valor_total_gasto,
            IFNULL(AVG(valor_total), 0.00) AS ticket_medio,
            MAX(data_pedido) AS ultimo_pedido
        FROM pedidos
        WHERE id_cliente = p_id_cliente;
    END IF;
END //
DELIMITER ;

-- Exemplo de chamada:
-- CALL consultar_extrato_cliente(1);
