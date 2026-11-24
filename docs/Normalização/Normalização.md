# Normalização

---

COPA(idt_copa, num_ano, país_sede(FK da Tabela País), idt_melhor_jogador_copa(FK da Tabela Copa), idt_chuteira_de_ouro(FK da Tabela Jogador), idt_luva_de_ouro(FK da Tabela Jogador), idt_melhor_jogador_jovem(FK da Tabela Jogador), idt_podio_primeiro_lugar(FK da Tabela Seleção), idt_podio_segundo_lugar(FK da Tabela Seleção), idt_podio_terceiro_lugar(FK da Tabela Seleção)), num_max_convocados

COPA_SEDE(idt_copa(PK)(FK da Tabela Copa), idt_pais(PK)(FK da Tabela PAÍS), vlr_investimento_bilhoes, vlr_faturamento_economico)

SELEÇÃO (idt_selecao, idt_pais(FK da Tabela País),  nme_técnico,  nme_federação, num_cortes)

PAÍS(idt_país, nme_pais, nme_sigla, vlr_idh)

JOGADOR (idt_jogador, nme_jogador, dta_nascimento,  id_spais (FK da Tabela País), idt_posição(FK da Tabela Posição))	

POSIÇÂO(idt_posição, nme_descrição, nme_Sigla_Posição, num_numeracao_classica_padrao )

CLUBE(idt_clube, nme_clube, idt_país_clube(FK da tabela País), nme_sigla)

CONVOCAÇÂO(idt_copa(PK)(FK da Tabela Copa),idt_selecao(FK da Tabela Seleção), idt _jogador(PK)(FK da Tabela Jogador), idt_clube(FK da Tabela Clube))

ESTÁDIO (idt_estadio, nme_estadio, num_ano_construção, num_capacidade, idt_cidade(FK da Tabela Cidade))

CIDADE(idt_cidade, nme_cidade, qtd_ct, idt_pais_cidade(FK) da Tabela País)

ÁRBITRO (idt_juiz, nme_árbitro, idt_naturalidade (FK da Tabela País), dta_nascimento)

FUNÇÃO(Idt_Função, nme_descricao_funcao, vlr_salario, nme_especialidade_exigida )
	

PARTIDA (idt_partida, dta_partida, idt_fase, vlr_bilheteria, num_acrescimos_1_tempo, num_acrescimos_2_tempo, idt_copa (FK da Tabela Copa), idt_estadio (FK da Tabela Estádio), idt_selecao_mandante (FK da Tabela Seleção), idt_selecao_visitante (FK da Tabela Seleção))

DESEMPENHO_JOGADOR_PARTIDA (idt_jogador (FK da Tabela Jogador), idt_partida (FK da Tabela Partida), num_de_gols, num_faltas_cometidas, num_impedimentos, num_faltas_sofridas, cartoes_amarelos_recebidos, cartoes_vermelhos_recebidos, num_min_jogados, flg_titular, num_gols_contra, num_assitencias)

ATUAÇÃO_ÁRBITRO_PARTIDA (idt_partida (PK)(FK da Tabela Partida), idt_juiz(PK) (FK da Tabela Árbitro), Idt_Função (PK) (FK da Tabela Função), vlr_nota_atuacao)

PARTICIPAÇÃO_SELEÇÃO_COPA (idt_selecao (FK da Tabela Seleção), idt_copa (FK da Tabela Copa), nme_grupo,  idt_fase_alcancada(FK da Tabela Fase), num_pos_grupo)

Fase(idt_fase, nme_descricao_fase)
