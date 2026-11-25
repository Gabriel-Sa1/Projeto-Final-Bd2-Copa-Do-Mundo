SET search_path TO "Schema que ta sendo usado";

-- ============================================================================
-- DROP (ordem inversa das dependencias)
-- ============================================================================
DROP TABLE IF EXISTS tb_atuacao_arbitro_partida CASCADE;
DROP TABLE IF EXISTS tb_desempenho_jogador_partida CASCADE;
DROP TABLE IF EXISTS tb_partida CASCADE;
DROP TABLE IF EXISTS tb_convocacao CASCADE;
DROP TABLE IF EXISTS tb_participacao_selecao_copa CASCADE;
DROP TABLE IF EXISTS tb_copa_sede CASCADE;
DROP TABLE IF EXISTS tb_copa CASCADE;
DROP TABLE IF EXISTS tb_jogador CASCADE;
DROP TABLE IF EXISTS tb_clube CASCADE;
DROP TABLE IF EXISTS tb_arbitro CASCADE;
DROP TABLE IF EXISTS tb_selecao CASCADE;
DROP TABLE IF EXISTS tb_estadio CASCADE;
DROP TABLE IF EXISTS tb_cidade CASCADE;
DROP TABLE IF EXISTS tb_fase CASCADE;
DROP TABLE IF EXISTS tb_posicao CASCADE;
DROP TABLE IF EXISTS tb_funcao CASCADE;
DROP TABLE IF EXISTS tb_pais CASCADE;

-- ============================================================================
-- CREATE
-- ============================================================================
CREATE TABLE tb_pais (
    idt_pais  BIGSERIAL PRIMARY KEY,
    nme_pais  VARCHAR(100) NOT NULL UNIQUE,
    nme_sigla VARCHAR(10) NOT NULL UNIQUE,
    vlr_idh   DECIMAL(4,3) CHECK (vlr_idh IS NULL OR (vlr_idh > 0 AND vlr_idh <= 1.000))
);

CREATE TABLE tb_funcao (
    idt_funcao                BIGSERIAL PRIMARY KEY,
    nme_descricao_funcao      VARCHAR(100) NOT NULL UNIQUE,
    vlr_salario               DECIMAL(10,2) NOT NULL CHECK (vlr_salario > 0),
    nme_especialidade_exigida VARCHAR(150) NOT NULL
);

CREATE TABLE tb_posicao (
    idt_posicao                   BIGSERIAL PRIMARY KEY,
    nme_descricao                 VARCHAR(100) NOT NULL UNIQUE,
    nme_sigla_posicao             VARCHAR(10) NOT NULL UNIQUE,
    num_numeracao_classica_padrao INTEGER NOT NULL CHECK (num_numeracao_classica_padrao >= 1 AND num_numeracao_classica_padrao <= 99)
);

CREATE TABLE tb_fase (
    idt_fase           BIGSERIAL PRIMARY KEY,
    nme_descricao_fase VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE tb_cidade (
    idt_cidade      BIGSERIAL PRIMARY KEY,
    nme_cidade      VARCHAR(100) NOT NULL,
    qtd_ct          INTEGER NOT NULL CHECK (qtd_ct >= 0),
    idt_pais_cidade BIGINT NOT NULL REFERENCES tb_pais(idt_pais)
);

CREATE TABLE tb_estadio (
    idt_estadio        BIGSERIAL PRIMARY KEY,
    nme_estadio        VARCHAR(120) NOT NULL UNIQUE,
    num_ano_construcao INTEGER NOT NULL CHECK (num_ano_construcao >= 1850 AND num_ano_construcao <= 2100),
    num_capacidade     INTEGER NOT NULL CHECK (num_capacidade > 0),
    idt_cidade         BIGINT NOT NULL REFERENCES tb_cidade(idt_cidade)
);

CREATE TABLE tb_selecao (
    idt_selecao   BIGSERIAL PRIMARY KEY,
    idt_pais      BIGINT NOT NULL UNIQUE REFERENCES tb_pais(idt_pais),
    nme_tecnico   VARCHAR(120) NOT NULL,
    nme_federacao VARCHAR(150) NOT NULL UNIQUE,
    num_cortes    INTEGER NOT NULL DEFAULT 0 CHECK (num_cortes >= 0)
);

CREATE TABLE tb_arbitro (
    idt_juiz         BIGSERIAL PRIMARY KEY,
    nme_arbitro      VARCHAR(120) NOT NULL UNIQUE,
    idt_naturalidade BIGINT NOT NULL REFERENCES tb_pais(idt_pais),
    dta_nascimento   DATE NOT NULL
);

CREATE TABLE tb_clube (
    idt_clube      BIGSERIAL PRIMARY KEY,
    nme_clube      VARCHAR(120) NOT NULL UNIQUE,
    idt_pais_clube BIGINT NOT NULL REFERENCES tb_pais(idt_pais),
    nme_sigla      VARCHAR(10) NOT NULL
);

CREATE TABLE tb_jogador (
    idt_jogador    BIGSERIAL PRIMARY KEY,
    nme_jogador    VARCHAR(120) NOT NULL,
    dta_nascimento DATE NOT NULL,
    idt_pais       BIGINT NOT NULL REFERENCES tb_pais(idt_pais),
    idt_posicao    BIGINT NOT NULL REFERENCES tb_posicao(idt_posicao)
);

CREATE TABLE tb_copa (
    idt_copa                 BIGSERIAL PRIMARY KEY,
    num_ano                  INTEGER NOT NULL UNIQUE CHECK (num_ano >= 1930 AND num_ano <= 2100),
    idt_melhor_jogador_copa  BIGINT REFERENCES tb_jogador(idt_jogador),
    idt_chuteira_de_ouro     BIGINT REFERENCES tb_jogador(idt_jogador),
    idt_luva_de_ouro         BIGINT REFERENCES tb_jogador(idt_jogador),
    idt_melhor_jogador_jovem BIGINT REFERENCES tb_jogador(idt_jogador),
    idt_podio_primeiro_lugar BIGINT REFERENCES tb_selecao(idt_selecao),
    idt_podio_segundo_lugar  BIGINT REFERENCES tb_selecao(idt_selecao),
    idt_podio_terceiro_lugar BIGINT REFERENCES tb_selecao(idt_selecao),
    num_max_convocados       INTEGER NOT NULL CHECK (num_max_convocados > 0)
);

CREATE TABLE tb_copa_sede (
    idt_copa                  BIGINT NOT NULL REFERENCES tb_copa(idt_copa),
    idt_pais                  BIGINT NOT NULL REFERENCES tb_pais(idt_pais),
    vlr_investimento_bilhoes  BIGINT NOT NULL CHECK (vlr_investimento_bilhoes >= 0),
    vlr_faturamento_economico BIGINT NOT NULL CHECK (vlr_faturamento_economico >= 0),
    PRIMARY KEY (idt_copa, idt_pais)
);

CREATE TABLE tb_participacao_selecao_copa (
    idt_selecao        BIGINT NOT NULL REFERENCES tb_selecao(idt_selecao),
    idt_copa           BIGINT NOT NULL REFERENCES tb_copa(idt_copa),
    nme_grupo          CHAR(1) NOT NULL CHECK (nme_grupo IN ('A','B','C','D','E','F','G','H','I','J','K','L')),
    idt_fase_alcancada BIGINT NOT NULL REFERENCES tb_fase(idt_fase),
    num_pos_grupo      INTEGER NOT NULL CHECK (num_pos_grupo >= 1 AND num_pos_grupo <= 4),
    PRIMARY KEY (idt_selecao, idt_copa)
);

CREATE TABLE tb_convocacao (
    idt_copa    BIGINT NOT NULL REFERENCES tb_copa(idt_copa),
    idt_selecao BIGINT NOT NULL REFERENCES tb_selecao(idt_selecao),
    idt_jogador BIGINT NOT NULL REFERENCES tb_jogador(idt_jogador),
    idt_clube   BIGINT NOT NULL REFERENCES tb_clube(idt_clube),
    PRIMARY KEY (idt_copa, idt_selecao, idt_jogador)
);

CREATE TABLE tb_partida (
    idt_partida            BIGSERIAL PRIMARY KEY,
    dta_partida            TIMESTAMP NOT NULL,
    idt_fase               BIGINT NOT NULL REFERENCES tb_fase(idt_fase),
    vlr_bilheteria         DECIMAL(14,2) NOT NULL CHECK (vlr_bilheteria >= 0),
    num_acrescimos_1_tempo INTEGER NOT NULL DEFAULT 0 CHECK (num_acrescimos_1_tempo >= 0),
    num_acrescimos_2_tempo INTEGER NOT NULL DEFAULT 0 CHECK (num_acrescimos_2_tempo >= 0),
    idt_copa               BIGINT NOT NULL REFERENCES tb_copa(idt_copa),
    idt_estadio            BIGINT NOT NULL REFERENCES tb_estadio(idt_estadio),
    idt_selecao_mandante   BIGINT NOT NULL REFERENCES tb_selecao(idt_selecao),
    idt_selecao_visitante  BIGINT NOT NULL REFERENCES tb_selecao(idt_selecao),
    CHECK (idt_selecao_mandante <> idt_selecao_visitante)
);

CREATE TABLE tb_desempenho_jogador_partida (
    idt_jogador           BIGINT NOT NULL REFERENCES tb_jogador(idt_jogador),
    idt_partida           BIGINT NOT NULL REFERENCES tb_partida(idt_partida),
    num_gols_pro          INTEGER NOT NULL DEFAULT 0 CHECK (num_gols_pro >= 0),
    num_faltas_cometidas  INTEGER NOT NULL DEFAULT 0 CHECK (num_faltas_cometidas >= 0),
    num_impedimentos      INTEGER NOT NULL DEFAULT 0 CHECK (num_impedimentos >= 0),
    num_faltas_sofridas   INTEGER NOT NULL DEFAULT 0 CHECK (num_faltas_sofridas >= 0),
    num_cartoes_amarelos  INTEGER NOT NULL DEFAULT 0 CHECK (num_cartoes_amarelos >= 0),
    num_cartoes_vermelhos INTEGER NOT NULL DEFAULT 0 CHECK (num_cartoes_vermelhos >= 0),
    num_min_jogados       INTEGER NOT NULL DEFAULT 0 CHECK (num_min_jogados >= 0),
    flg_titular           BOOLEAN NOT NULL DEFAULT FALSE,
    num_gols_contra       INTEGER NOT NULL DEFAULT 0 CHECK (num_gols_contra >= 0),
    num_assistencias      INTEGER NOT NULL DEFAULT 0 CHECK (num_assistencias >= 0),
    PRIMARY KEY (idt_jogador, idt_partida)
);

CREATE TABLE tb_atuacao_arbitro_partida (
    idt_partida      BIGINT NOT NULL REFERENCES tb_partida(idt_partida),
    idt_juiz         BIGINT NOT NULL REFERENCES tb_arbitro(idt_juiz),
    idt_funcao       BIGINT NOT NULL REFERENCES tb_funcao(idt_funcao),
    vlr_nota_atuacao DECIMAL(3,1) NOT NULL CHECK (vlr_nota_atuacao >= 0 AND vlr_nota_atuacao <= 10.0),
    PRIMARY KEY (idt_partida, idt_juiz, idt_funcao)
);
