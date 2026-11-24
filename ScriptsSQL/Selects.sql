-- Consulta 1: Artilharia por Seleção
--Lista as seleções que marcaram mais de 10 gols no histórico registrado, 
--exibindo total de gols pró, assistências, cartões amarelos e média de minutos jogados.
SELECT 
    p.nme_pais AS selecao,
    COUNT(DISTINCT d.idt_partida) AS total_partidas_disputadas,
    SUM(d.num_gols_pro) AS total_gols,
    SUM(d.num_assistencias) AS total_assistencias,
    SUM(d.num_cartoes_amarelos) AS total_amarelos,
    ROUND(AVG(d.num_min_jogados), 1) AS media_minutos_por_atleta
FROM tb_desempenho_jogador_partida d
INNER JOIN tb_jogador j ON d.idt_jogador = j.idt_jogador
INNER JOIN tb_pais p ON j.idt_pais = p.idt_pais
INNER JOIN tb_partida pt ON d.idt_partida = pt.idt_partida
GROUP BY p.nme_pais
HAVING SUM(d.num_gols_pro) > 10
ORDER BY total_gols DESC, total_assistencias DESC;


--Consulta 2: Faturamento de Bilheteria por Estádio e Cidade
--Calcula a arrecadação total, 
--a média de bilheteria e o total de jogos realizados em estádios que receberam pelo 
--menos 3 partidas e faturaram acima de 1.000.000,00.
SELECT 
    c.nme_cidade AS cidade,
    e.nme_estadio AS estadio,
    COUNT(pt.idt_partida) AS qtd_partidas,
    SUM(pt.vlr_bilheteria) AS bilheteria_total,
    ROUND(AVG(pt.vlr_bilheteria), 2) AS media_bilheteria
FROM tb_partida pt
INNER JOIN tb_estadio e ON pt.idt_estadio = e.idt_estadio
INNER JOIN tb_cidade c ON e.idt_cidade = c.idt_cidade
INNER JOIN tb_copa cp ON pt.idt_copa = cp.idt_copa
GROUP BY c.nme_cidade, e.nme_estadio
HAVING COUNT(pt.idt_partida) >= 3 
   AND SUM(pt.vlr_bilheteria) > 450000.00
ORDER BY bilheteria_total DESC;




--3. Eficiência Ofensiva e Minutagem por Jogador e Posição
--Analisa atletas que atuaram em pelo menos 3 partidas e somaram mais de 2 participações diretas em gols (gols + assistências), 
--exibindo a média de minutos em campo e a taxa de titularidade.
SELECT 
    j.nme_jogador AS jogador,
    p.nme_pais AS selecao,
    pos.nme_descricao AS posicao,
    COUNT(d.idt_partida) AS qtd_partidas,
    SUM(CASE WHEN d.flg_titular THEN 1 ELSE 0 END) AS jogos_como_titular,
    SUM(d.num_gols_pro) AS total_gols,
    SUM(d.num_assistencias) AS total_assistencias,
    ROUND(AVG(d.num_min_jogados), 1) AS media_minutos_jogados
FROM tb_desempenho_jogador_partida d
INNER JOIN tb_jogador j 
    ON d.idt_jogador = j.idt_jogador
INNER JOIN tb_pais p 
    ON j.idt_pais = p.idt_pais
INNER JOIN tb_posicao pos 
    ON j.idt_posicao = pos.idt_posicao
INNER JOIN tb_partida pt 
    ON d.idt_partida = pt.idt_partida
GROUP BY 
    j.idt_jogador, 
    j.nme_jogador, 
    p.nme_pais, 
    pos.nme_descricao
HAVING COUNT(d.idt_partida) >= 3 
   AND SUM(d.num_gols_pro + d.num_assistencias) > 2
ORDER BY 
    total_gols DESC, 
    total_assistencias DESC, 
    media_minutos_jogados DESC;



--
--selecoes com mais faltas top 10
--
SELECT 
    p.nme_pais AS selecao,
    s.nme_tecnico AS tecnico,
    COUNT(DISTINCT d.idt_partida) AS jogos_disputados,
    SUM(d.num_faltas_cometidas) AS total_faltas_cometidas,
    ROUND(SUM(d.num_faltas_cometidas)::DECIMAL / COUNT(DISTINCT d.idt_partida), 2) AS media_faltas_por_jogo,
    SUM(d.num_cartoes_amarelos) AS total_amarelos,
    SUM(d.num_cartoes_vermelhos) AS total_vermelhos
FROM tb_desempenho_jogador_partida d
INNER JOIN tb_jogador j 
    ON d.idt_jogador = j.idt_jogador
INNER JOIN tb_pais p 
    ON j.idt_pais = p.idt_pais
INNER JOIN tb_selecao s 
    ON p.idt_pais = s.idt_pais
GROUP BY 
    s.idt_selecao, 
    p.nme_pais, 
    s.nme_tecnico
HAVING SUM(d.num_faltas_cometidas) > 0
ORDER BY 
    total_faltas_cometidas DESC, 
    total_vermelhos DESC, 
    total_amarelos DESC
LIMIT 10;



---CTE para pegar top 5 jogadores com mais faltas em cada fase
---

WITH cte_faltas_por_fase AS (
    SELECT 
        f.idt_fase,
        f.nme_descricao_fase AS fase,
        j.nme_jogador AS jogador,
        p.nme_pais AS selecao,
        COUNT(d.idt_partida) AS partidas_na_fase,
        SUM(d.num_faltas_cometidas) AS total_faltas_cometidas,
        SUM(d.num_cartoes_amarelos) AS total_amarelos,
        SUM(d.num_cartoes_vermelhos) AS total_vermelhos,
        ROUND(AVG(d.num_faltas_cometidas), 2) AS media_faltas_jogo,
        ROW_NUMBER() OVER (
            PARTITION BY f.idt_fase 
            ORDER BY 
                SUM(d.num_faltas_cometidas) DESC, 
                SUM(d.num_cartoes_vermelhos) DESC, 
                SUM(d.num_cartoes_amarelos) DESC
        ) AS posicao_ranking
    FROM tb_desempenho_jogador_partida d
    INNER JOIN tb_jogador j 
        ON d.idt_jogador = j.idt_jogador
    INNER JOIN tb_pais p 
        ON j.idt_pais = p.idt_pais
    INNER JOIN tb_partida pt 
        ON d.idt_partida = pt.idt_partida
    INNER JOIN tb_fase f 
        ON pt.idt_fase = f.idt_fase
    GROUP BY 
        f.idt_fase, 
        f.nme_descricao_fase, 
        j.idt_jogador, 
        j.nme_jogador, 
        p.nme_pais
    HAVING SUM(d.num_faltas_cometidas) > 0
)
SELECT 
    fase,
    posicao_ranking AS top_fase,
    jogador,
    selecao,
    partidas_na_fase,
    total_faltas_cometidas,
    media_faltas_jogo,
    total_amarelos,
    total_vermelhos
FROM cte_faltas_por_fase
WHERE posicao_ranking <= 5
ORDER BY 
    idt_fase ASC, 
    posicao_ranking ASC;



--1. Impacto dos "Super-Subs" (Gols e Assistências Vindo do Banco)
--Compara o rendimento ofensivo de cada jogador quando entra como reserva (flg_titular = FALSE) versus quando começa jogando (flg_titular = TRUE), 
--filtrando aqueles que têm uma taxa de participação em gols por minuto melhor vindo do banco.
WITH cte_rendimento_condicao AS (
    SELECT 
        j.idt_jogador,
        j.nme_jogador AS jogador,
        p.nme_pais AS selecao,
        pos.nme_sigla_posicao AS posicao,
        SUM(CASE WHEN d.flg_titular = FALSE THEN d.num_gols_pro + d.num_assistencias ELSE 0 END) AS part_gols_reserva,
        SUM(CASE WHEN d.flg_titular = FALSE THEN d.num_min_jogados ELSE 0 END) AS min_reserva,
        SUM(CASE WHEN d.flg_titular = TRUE THEN d.num_gols_pro + d.num_assistencias ELSE 0 END) AS part_gols_titular,
        SUM(CASE WHEN d.flg_titular = TRUE THEN d.num_min_jogados ELSE 0 END) AS min_titular
    FROM tb_desempenho_jogador_partida d
    INNER JOIN tb_jogador j ON d.idt_jogador = j.idt_jogador
    INNER JOIN tb_pais p ON j.idt_pais = p.idt_pais
    INNER JOIN tb_posicao pos ON j.idt_posicao = pos.idt_posicao
    GROUP BY j.idt_jogador, j.nme_jogador, p.nme_pais, pos.nme_sigla_posicao
)
SELECT 
    jogador,
    selecao,
    posicao,
    part_gols_reserva,
    min_reserva,
    ROUND(COALESCE((part_gols_reserva::DECIMAL / NULLIF(min_reserva, 0)) * 90, 0), 2) AS participacoes_por_90min_reserva,
    part_gols_titular,
    min_titular,
    ROUND(COALESCE((part_gols_titular::DECIMAL / NULLIF(min_titular, 0)) * 90, 0), 2) AS participacoes_por_90min_titular
FROM cte_rendimento_condicao
WHERE part_gols_reserva >= 2 
  AND min_reserva > 0
  AND (part_gols_reserva::DECIMAL / NULLIF(min_reserva, 0)) > COALESCE(part_gols_titular::DECIMAL / NULLIF(min_titular, 0), 0)
ORDER BY participacoes_por_90min_reserva DESC;


--Dependência Ofensiva das Seleções (Protagonismo Individual): calcular qual percentual dos gols totais de cada seleção foi 
--marcado por um único jogador (o "carregador" do time naquela Copa), 
--mostrando apenas atletas responsáveis por 30% ou mais dos gols da própria equipe.
WITH cte_gols_selecao AS (
    SELECT 
        p.idt_pais,
        p.nme_pais AS selecao,
        SUM(d.num_gols_pro) AS total_gols_selecao
    FROM tb_desempenho_jogador_partida d
    INNER JOIN tb_jogador j ON d.idt_jogador = j.idt_jogador
    INNER JOIN tb_pais p ON j.idt_pais = p.idt_pais
    GROUP BY p.idt_pais, p.nme_pais
    HAVING SUM(d.num_gols_pro) > 0
),
cte_gols_jogador AS (
    SELECT 
        j.idt_pais,
        j.nme_jogador AS jogador,
        pos.nme_descricao AS posicao,
        COUNT(d.idt_partida) AS partidas_jogadas,
        SUM(d.num_gols_pro) AS gols_jogador,
        SUM(d.num_assistencias) AS assistencias_jogador
    FROM tb_desempenho_jogador_partida d
    INNER JOIN tb_jogador j ON d.idt_jogador = j.idt_jogador
    INNER JOIN tb_posicao pos ON j.idt_posicao = pos.idt_posicao
    GROUP BY j.idt_pais, j.idt_jogador, j.nme_jogador, pos.nme_descricao
)
SELECT 
    gs.selecao,
    gj.jogador,
    gj.posicao,
    gj.partidas_jogadas,
    gj.gols_jogador,
    gs.total_gols_selecao,
    ROUND((gj.gols_jogador::DECIMAL / gs.total_gols_selecao) * 100, 1) AS percentual_gols_time,
    gj.assistencias_jogador
FROM cte_gols_jogador gj
INNER JOIN cte_gols_selecao gs ON gj.idt_pais = gs.idt_pais
WHERE (gj.gols_jogador::DECIMAL / gs.total_gols_selecao) >= 0.30
ORDER BY percentual_gols_time DESC, gj.gols_jogador DESC;


--Window fuctions01: . Ranking de Artilheiros por Posição (DENSE_RANK)
--Calcula a colocação de cada jogador dentro da sua própria posição tática 
--(PARTITION BY pos.nme_descricao), mantendo os detalhes de cada atleta sem esconder ninguém.
SELECT 
    pos.nme_descricao AS posicao,
    j.nme_jogador AS jogador,
    p.nme_pais AS selecao,
    SUM(d.num_gols_pro) AS total_gols,
    DENSE_RANK() OVER (
        PARTITION BY pos.nme_descricao 
        ORDER BY SUM(d.num_gols_pro) DESC, SUM(d.num_assistencias) DESC
    ) AS ranking_posicao
FROM tb_desempenho_jogador_partida d
INNER JOIN tb_jogador j ON d.idt_jogador = j.idt_jogador
INNER JOIN tb_posicao pos ON j.idt_posicao = pos.idt_posicao
INNER JOIN tb_pais p ON j.idt_pais = p.idt_pais
GROUP BY pos.nme_descricao, j.nme_jogador, p.nme_pais
HAVING SUM(d.num_gols_pro) > 0
ORDER BY posicao, ranking_posicao;




--2. Evolução de Minutagem e Gols Jogo a Jogo por Jogador (LAG)
--Mostra o histórico partida a partida de cada jogador em ordem cronológica, 
--comparando os minutos jogados na partida atual com a partida anterior (LAG) do mesmo atleta.
SELECT 
    j.nme_jogador AS jogador,
    pt.dta_partida AS data_jogo,
    d.num_min_jogados AS minutos_jogo_atual,
    LAG(d.num_min_jogados, 1, 0) OVER (
        PARTITION BY j.idt_jogador 
        ORDER BY pt.dta_partida ASC
    ) AS minutos_jogo_anterior,
    d.num_min_jogados - LAG(d.num_min_jogados, 1, 0) OVER (
        PARTITION BY j.idt_jogador 
        ORDER BY pt.dta_partida ASC
    ) AS variacao_minutos,
    d.num_gols_pro AS gols_na_partida
FROM tb_desempenho_jogador_partida d
INNER JOIN tb_jogador j ON d.idt_jogador = j.idt_jogador
INNER JOIN tb_partida pt ON d.idt_partida = pt.idt_partida
ORDER BY j.nme_jogador, pt.dta_partida;




--3. Destaque Individual (Craque) de Cada Partida (ROW_NUMBER)
--Numera os jogadores que atuaram em cada partida (PARTITION BY pt.idt_partida) do melhor para o pior desempenho ofensivo, 
--filtrando apenas o 1º de cada jogo.
WITH cte_desempenho_jogo AS (
    SELECT 
        pt.idt_partida,
        pt.dta_partida,
        j.nme_jogador AS jogador,
        p.nme_pais AS selecao,
        d.num_gols_pro AS gols,
        d.num_assistencias AS assistencias,
        ROW_NUMBER() OVER (
            PARTITION BY pt.idt_partida 
            ORDER BY d.num_gols_pro DESC, d.num_assistencias DESC, d.num_min_jogados DESC
        ) AS rank_partida
    FROM tb_desempenho_jogador_partida d
    INNER JOIN tb_partida pt ON d.idt_partida = pt.idt_partida
    INNER JOIN tb_jogador j ON d.idt_jogador = j.idt_jogador
    INNER JOIN tb_pais p ON j.idt_pais = p.idt_pais
)
SELECT 
    idt_partida,
    dta_partida,
    jogador AS destaque_partida,
    selecao,
    gols,
    assistencias
FROM cte_desempenho_jogo
WHERE rank_partida = 1
ORDER BY idt_partida;









































