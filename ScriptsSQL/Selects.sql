SET search_path TO "ProjetoMK02";

SELECT 'tb_pais' AS tabela, COUNT(*) AS total_registros FROM tb_pais
UNION ALL SELECT 'tb_funcao', COUNT(*) FROM tb_funcao
UNION ALL SELECT 'tb_posicao', COUNT(*) FROM tb_posicao
UNION ALL SELECT 'tb_fase', COUNT(*) FROM tb_fase
UNION ALL SELECT 'tb_cidade', COUNT(*) FROM tb_cidade
UNION ALL SELECT 'tb_estadio', COUNT(*) FROM tb_estadio
UNION ALL SELECT 'tb_selecao', COUNT(*) FROM tb_selecao
UNION ALL SELECT 'tb_arbitro', COUNT(*) FROM tb_arbitro
UNION ALL SELECT 'tb_clube', COUNT(*) FROM tb_clube
UNION ALL SELECT 'tb_jogador', COUNT(*) FROM tb_jogador
UNION ALL SELECT 'tb_copa', COUNT(*) FROM tb_copa
UNION ALL SELECT 'tb_copa_sede', COUNT(*) FROM tb_copa_sede
UNION ALL SELECT 'tb_participacao_selecao_copa', COUNT(*) FROM tb_participacao_selecao_copa
UNION ALL SELECT 'tb_convocacao', COUNT(*) FROM tb_convocacao
UNION ALL SELECT 'tb_partida', COUNT(*) FROM tb_partida
UNION ALL SELECT 'tb_desempenho_jogador_partida', COUNT(*) FROM tb_desempenho_jogador_partida
UNION ALL SELECT 'tb_atuacao_arbitro_partida', COUNT(*) FROM tb_atuacao_arbitro_partida
ORDER BY tabela;

SELECT 
    p.idt_partida,
    f.nme_descricao_fase AS fase,
    e.nme_estadio AS estadio,
    pm.nme_pais AS mandante,
    COALESCE(SUM(CASE WHEN c.idt_selecao = p.idt_selecao_mandante THEN d.num_gols_pro ELSE 0 END)
           + SUM(CASE WHEN c.idt_selecao = p.idt_selecao_visitante THEN d.num_gols_contra ELSE 0 END), 0) AS gols_mandante,
    COALESCE(SUM(CASE WHEN c.idt_selecao = p.idt_selecao_visitante THEN d.num_gols_pro ELSE 0 END)
           + SUM(CASE WHEN c.idt_selecao = p.idt_selecao_mandante THEN d.num_gols_contra ELSE 0 END), 0) AS gols_visitante,
    pv.nme_pais AS visitante,
    p.dta_partida
FROM tb_partida p
JOIN tb_fase f ON p.idt_fase = f.idt_fase
JOIN tb_estadio e ON p.idt_estadio = e.idt_estadio
JOIN tb_selecao sm ON p.idt_selecao_mandante = sm.idt_selecao
JOIN tb_pais pm ON sm.idt_pais = pm.idt_pais
JOIN tb_selecao sv ON p.idt_selecao_visitante = sv.idt_selecao
JOIN tb_pais pv ON sv.idt_pais = pv.idt_pais
LEFT JOIN tb_desempenho_jogador_partida d ON d.idt_partida = p.idt_partida
LEFT JOIN tb_convocacao c ON c.idt_jogador = d.idt_jogador AND c.idt_copa = p.idt_copa
GROUP BY p.idt_partida, f.nme_descricao_fase, e.nme_estadio, pm.nme_pais, pv.nme_pais, p.dta_partida
ORDER BY p.dta_partida
LIMIT 20;


SELECT 
    j.nme_jogador,
    pa.nme_pais AS selecao,
    pos.nme_sigla_posicao AS pos,
    SUM(d.num_gols_pro) AS gols,
    SUM(d.num_assistencias) AS assistencias,
    SUM(d.num_min_jogados) AS minutos
FROM tb_desempenho_jogador_partida d
JOIN tb_jogador j ON d.idt_jogador = j.idt_jogador
JOIN tb_pais pa ON j.idt_pais = pa.idt_pais
JOIN tb_posicao pos ON j.idt_posicao = pos.idt_posicao
GROUP BY j.idt_jogador, j.nme_jogador, pa.nme_pais, pos.nme_sigla_posicao
ORDER BY gols DESC, assistencias DESC
LIMIT 15;



SELECT 
    c.num_ano,
    p1.nme_pais AS campeao,
    p2.nme_pais AS vice,
    p3.nme_pais AS terceiro,
    jm.nme_jogador AS melhor_jogador,
    jc.nme_jogador AS chuteira_ouro,
    jl.nme_jogador AS luva_ouro,
    jj.nme_jogador AS melhor_jovem
FROM tb_copa c
LEFT JOIN tb_selecao s1 ON c.idt_podio_primeiro_lugar = s1.idt_selecao
LEFT JOIN tb_pais p1 ON s1.idt_pais = p1.idt_pais
LEFT JOIN tb_selecao s2 ON c.idt_podio_segundo_lugar = s2.idt_selecao
LEFT JOIN tb_pais p2 ON s2.idt_pais = p2.idt_pais
LEFT JOIN tb_selecao s3 ON c.idt_podio_terceiro_lugar = s3.idt_selecao
LEFT JOIN tb_pais p3 ON s3.idt_pais = p3.idt_pais
LEFT JOIN tb_jogador jm ON c.idt_melhor_jogador_copa = jm.idt_jogador
LEFT JOIN tb_jogador jc ON c.idt_chuteira_de_ouro = jc.idt_jogador
LEFT JOIN tb_jogador jl ON c.idt_luva_de_ouro = jl.idt_jogador
LEFT JOIN tb_jogador jj ON c.idt_melhor_jogador_jovem = jj.idt_jogador;




SELECT 
    a.nme_arbitro,
    pa.nme_pais AS nacionalidade,
    fn.nme_descricao_funcao AS funcao,
    COUNT(*) AS partidas_atuadas,
    ROUND(AVG(aa.vlr_nota_atuacao), 2) AS media_nota
FROM tb_atuacao_arbitro_partida aa
JOIN tb_arbitro a ON aa.idt_juiz = a.idt_juiz
JOIN tb_pais pa ON a.idt_naturalidade = pa.idt_pais
JOIN tb_funcao fn ON aa.idt_funcao = fn.idt_funcao
GROUP BY a.idt_juiz, a.nme_arbitro, pa.nme_pais, fn.nme_descricao_funcao
ORDER BY partidas_atuadas DESC, media_nota DESC
LIMIT 15;















































