USE loja_tech;

-- 1. Listagem básica de clientes
SELECT nome, email 
FROM clientes;

-- 2. Filtro por faixa de preço (menor que R$ 500,00)
SELECT nome, preco 
FROM produtos 
WHERE preco < 500.00;

-- 3. Filtro por status de pedido ('pendente')
SELECT * 
FROM pedidos 
WHERE status = 'pendente';

-- 4. Ordenação de catálogo (do mais caro para o mais barato)
SELECT nome, preco 
FROM produtos 
ORDER BY preco DESC;

-- 5. Busca textual parcial (contém 'Monitor')
SELECT id_produto, nome, preco 
FROM produtos 
WHERE nome LIKE '%Monitor%';

-- 6. Filtro composto (Categoria 3 e estoque > 40)
SELECT nome, estoque 
FROM produtos 
WHERE id_categoria = 3 
  AND estoque > 40;

-- 7. Contagem total de registros
SELECT COUNT(*) AS total_clientes 
FROM clientes;

-- 8. Soma de valores
SELECT SUM(valor_total) AS faturamento_bruto 
FROM pedidos;

-- 9. Junção simples entre duas tabelas (INNER JOIN)
SELECT p.nome AS produto, c.nome AS categoria
FROM produtos p
INNER JOIN categorias c ON p.id_categoria = c.id_categoria;

-- 10. Junção com filtro por cliente (Ana Silva)
SELECT pe.id_pedido, pe.status, pe.valor_total
FROM pedidos pe
INNER JOIN clientes c ON pe.id_cliente = c.id_cliente
WHERE c.nome = 'Ana Silva';
