-- ============================================================================
-- ARQUIVO: 03_otimizacao_indices.sql
-- DESCRIÇÃO: Criação de 3 índices não primários para otimização das consultas DQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ÍNDICE 1: B-Tree Composto na tabela fato (tb_desempenho_jogador_partida)
-- Justificativa: A tabela tb_desempenho_jogador_partida é a mais volumosa do
-- sistema. Como sua chave primária é (idt_jogador, idt_partida), buscas que
-- filtram ou agrupam por partida (idt_partida) ou por indicadores de rendimento
-- (num_gols_pro, num_faltas_cometidas) forçam um Sequential Scan. O índice B-Tree
-- acelera tanto os JOINs por partida quanto as ordenações e filtros de faixa.
-- ----------------------------------------------------------------------------
CREATE INDEX idx_desempenho_partida_gols 
ON tb_desempenho_jogador_partida USING BTREE (idt_partida, num_gols_pro DESC, num_faltas_cometidas DESC);

-- ----------------------------------------------------------------------------
-- ÍNDICE 2: Hash na chave estrangeira de país do jogador (tb_jogador)
-- Justificativa: Quase todas as consultas analíticas cruzam tb_jogador com
-- tb_pais e tb_selecao por igualdade estrita (j.idt_pais = p.idt_pais).
-- O índice HASH no PostgreSQL é otimizado especificamente para operadores de
-- igualdade (=), ocupando menos espaço em disco que uma B-Tree e oferecendo
-- lookup em tempo constante O(1) para joins de igualdade.
-- ----------------------------------------------------------------------------
CREATE INDEX idx_jogador_idt_pais 
ON tb_jogador USING HASH (idt_pais);

-- ----------------------------------------------------------------------------
-- ÍNDICE 3: B-Tree na tabela de partidas (tb_partida) por Fase e Data
-- Justificativa: As consultas de Window Function (LAG/ROW_NUMBER) e os rankings
-- por etapa do torneio filtram por idt_fase e ordenam cronologicamente por
-- dta_partida. O índice B-Tree composto evita operações de Sort em disco/memória
-- e elimina varreduras sequenciais nas junções com tb_fase.
-- ----------------------------------------------------------------------------
CREATE INDEX idx_partida_fase_data 
ON tb_partida USING BTREE (idt_fase, dta_partida ASC);

-- Teste 1 (Alvo: idx_desempenho_partida_gols)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    pt.idt_partida,
    SUM(d.num_gols_pro) AS total_gols,
    SUM(d.num_faltas_cometidas) AS total_faltas
FROM tb_desempenho_jogador_partida d
INNER JOIN tb_partida pt ON d.idt_partida = pt.idt_partida
WHERE d.num_gols_pro > 0
GROUP BY pt.idt_partida;

-- Teste 2 (Alvo: idx_jogador_idt_pais)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    p.nme_pais,
    COUNT(j.idt_jogador) AS total_atletas
FROM tb_jogador j
INNER JOIN tb_pais p ON j.idt_pais = p.idt_pais
WHERE j.idt_pais = 1
GROUP BY p.nme_pais;

-- Teste 3 (Alvo: idx_partida_fase_data)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    idt_partida,
    dta_partida,
    vlr_bilheteria
FROM tb_partida
WHERE idt_fase = 1
ORDER BY dta_partida ASC;