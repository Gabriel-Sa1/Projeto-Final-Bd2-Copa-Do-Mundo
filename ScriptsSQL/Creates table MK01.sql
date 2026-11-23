CREATE TABLE tb_pais (
  idt_pais bigserial PRIMARY KEY,
  nme_pais varchar(150) not null,
  nme_sigla varchar(3),
  vlr_idh float
);




CREATE TABLE tb_posicao (
  idt_posicao bigserial PRIMARY KEY,
  nme_descricao varchar(100) not null,
  nme_sigla_posicao varchar(4),
  num_numeracao_classica_padrao varchar(100)
);




CREATE TABLE tb_funcao (
  idt_funcao bigserial PRIMARY KEY,
  nme_descricao_funcao varchar(100) not null,
  vlr_salario decimal,
  nme_especialidade_exigida varchar
);




CREATE TABLE tb_clube (
  idt_clube bigserial PRIMARY KEY,
  nme_clube varchar not null,
  idt_pais_clube bigint not null,
  sgl_clube varchar,
  FOREIGN KEY (idt_pais_clube) REFERENCES tb_pais (idt_pais)
);




CREATE TABLE tb_cidade (
  idt_cidade bigserial PRIMARY KEY,
  nme_cidade varchar not null,
  sgl_cidade varchar,
  idt_pais_cidade bigint,
  FOREIGN KEY (idt_pais_cidade) REFERENCES tb_pais (idt_pais)
);




CREATE TABLE tb_estadio (
  idt_estadio bigserial PRIMARY KEY,
  nme_estadio varchar not null,
  num_ano_construcao int,
  num_capacidade int not null,
  idt_cidade bigint not null,
  FOREIGN KEY (idt_cidade) REFERENCES tb_cidade (idt_cidade)
);




CREATE TABLE tb_arbitro (
  idt_juiz bigserial PRIMARY KEY,
  nme_arbitro varchar not null,
  idt_naturalidade bigint not null,
  dta_nascimento date not null,
  FOREIGN KEY (idt_naturalidade) REFERENCES tb_pais (idt_pais)
);




CREATE TABLE tb_selecao (
  idt_selecao bigserial PRIMARY KEY,
  idt_pais bigint not null,
  nme_tecnico varchar not null,
  nme_confederacao varchar not null,
  num_convocacao int,
  num_cortes int,
  FOREIGN KEY (idt_pais) REFERENCES tb_pais (idt_pais)
);




CREATE TABLE tb_jogador (
  idt_jogador bigserial PRIMARY KEY,
  nme_jogador varchar not null,
  dta_nascimento date not null,
  idt_naturalidade bigint not null,
  idt_selecao bigint not null,
  idt_posicao bigint not null,
  FOREIGN KEY (idt_naturalidade) REFERENCES tb_pais (idt_pais),
  FOREIGN KEY (idt_selecao) REFERENCES tb_selecao (idt_selecao),
  FOREIGN KEY (idt_posicao) REFERENCES tb_posicao (idt_posicao)
);




CREATE TABLE tb_copa (
  idt_copa bigserial PRIMARY KEY,
  num_ano int not null,
  idt_pais_sede bigint not null,
  idt_melhor_jogador_copa bigint not null,
  idt_chuteira_de_ouro bigint not null,
  idt_luva_de_ouro bigint not null,
  idt_melhor_jogador_jovem bigint not null,
  idt_podio_primeiro_lugar bigint not null,
  idt_podio_segundo_lugar bigint not null,
  idt_podio_terceiro_lugar bigint not null,
  FOREIGN KEY (idt_pais_sede) REFERENCES tb_pais (idt_pais),
  FOREIGN KEY (idt_melhor_jogador_copa) REFERENCES tb_jogador (idt_jogador),
  FOREIGN KEY (idt_chuteira_de_ouro) REFERENCES tb_jogador (idt_jogador),
  FOREIGN KEY (idt_luva_de_ouro) REFERENCES tb_jogador (idt_jogador),
  FOREIGN KEY (idt_melhor_jogador_jovem) REFERENCES tb_jogador (idt_jogador),
  FOREIGN KEY (idt_podio_primeiro_lugar) REFERENCES tb_selecao (idt_selecao),
  FOREIGN KEY (idt_podio_segundo_lugar) REFERENCES tb_selecao (idt_selecao),
  FOREIGN KEY (idt_podio_terceiro_lugar) REFERENCES tb_selecao (idt_selecao)
);




CREATE TABLE tb_partida (
  idt_partida bigserial PRIMARY KEY,
  dta_partida timestamp not null,
  nme_fase varchar not null,
  vlr_bilheteria decimal,
  num_faltas_marcadas int not null,
  num_impedimentos_totais int not null,
  num_cartoes_amarelos int not null,
  num_cartoes_vermelhos int not null,
  num_acrescimos_1_tempo int not null,
  num_acrescimos_2_tempo int not null,
  idt_copa bigint not null,
  idt_estadio bigint not null,
  idt_selecao_mandante bigint not null,
  idt_selecao_visitante bigint not null,
  FOREIGN KEY (idt_copa) REFERENCES tb_copa (idt_copa),
  FOREIGN KEY (idt_estadio) REFERENCES tb_estadio (idt_estadio),
  FOREIGN KEY (idt_selecao_mandante) REFERENCES tb_selecao (idt_selecao),
  FOREIGN KEY (idt_selecao_visitante) REFERENCES tb_selecao (idt_selecao)
);




CREATE TABLE tb_convocacao (
  idt_copa bigint not null,
  idt_selecao bigint not null,
  idt_jogador bigint not null,
  idt_clube bigint not null,
  PRIMARY KEY (idt_copa, idt_selecao, idt_jogador, idt_clube),
  FOREIGN KEY (idt_copa) REFERENCES tb_copa (idt_copa),
  FOREIGN KEY (idt_selecao) REFERENCES tb_selecao (idt_selecao),
  FOREIGN KEY (idt_jogador) REFERENCES tb_jogador (idt_jogador),
  FOREIGN KEY (idt_clube) REFERENCES tb_clube (idt_clube)
);




CREATE TABLE tb_desempenho_jogador_partida (
  idt_jogador bigint not null,
  idt_partida bigint not null,
  num_gols int not null,
  num_faltas_cometidas int not null,
  num_impedimentos int not null,
  num_cartoes_amarelos int not null,
  num_cartoes_vermelhos int not null,
  PRIMARY KEY (idt_jogador, idt_partida),
  FOREIGN KEY (idt_jogador) REFERENCES tb_jogador (idt_jogador),
  FOREIGN KEY (idt_partida) REFERENCES tb_partida (idt_partida)
);




CREATE TABLE tb_atuacao_arbitro_partida (
  idt_partida bigint not null,
  idt_juiz bigint not null,
  idt_funcao bigint not null,
  vlr_nota_atuacao float,
  PRIMARY KEY (idt_partida, idt_juiz, idt_funcao),
  FOREIGN KEY (idt_partida) REFERENCES tb_partida (idt_partida),
  FOREIGN KEY (idt_juiz) REFERENCES tb_arbitro (idt_juiz),
  FOREIGN KEY (idt_funcao) REFERENCES tb_funcao (idt_funcao)
);




CREATE TABLE tb_participacao_selecao_copa (
  idt_selecao bigint not null,
  idt_copa bigint not null,
  nme_grupo varchar not null,
  nme_fase_alcancada varchar,
  PRIMARY KEY (idt_selecao, idt_copa),
  FOREIGN KEY (idt_selecao) REFERENCES tb_selecao (idt_selecao),
  FOREIGN KEY (idt_copa) REFERENCES tb_copa (idt_copa)
););