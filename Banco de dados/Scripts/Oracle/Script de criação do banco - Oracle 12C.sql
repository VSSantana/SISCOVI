-- Gerado por Oracle SQL Developer Data Modeler 4.2.0.932
--   em:        2017-09-08 15:42:56 BRT
--   site:      Oracle Database 12c
--   tipo:      Oracle Database 12c

CREATE TABLE tb_cargo (
    cod                 INTEGER NOT NULL,
    nome                VARCHAR2(150 CHAR) NOT NULL,
    descricao           VARCHAR2(400 CHAR),
    login_atualizacao   VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao    TIMESTAMP NOT NULL
);

ALTER TABLE tb_cargo ADD CONSTRAINT tb_cargo_pk PRIMARY KEY ( cod );

ALTER TABLE tb_cargo ADD CONSTRAINT tb_cargo__un UNIQUE ( nome );

CREATE TABLE tb_cargo_contrato (
    cod                 INTEGER NOT NULL,
    cod_contrato        INTEGER NOT NULL,
    cod_cargo           INTEGER NOT NULL,
    descricao           VARCHAR2(400 CHAR),
    login_atualizacao   VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao    TIMESTAMP NOT NULL
);

ALTER TABLE tb_cargo_contrato ADD CONSTRAINT tb_cargo_contrato_pk PRIMARY KEY ( cod );

ALTER TABLE tb_cargo_contrato ADD CONSTRAINT tb_cargo_contrato_un UNIQUE ( cod_contrato,cod_cargo );

CREATE TABLE tb_cargo_funcionario (
    cod                     INTEGER NOT NULL,
    cod_funcionario         INTEGER NOT NULL,
    cod_cargo_contrato      INTEGER NOT NULL,
    data_disponibilizacao   DATE NOT NULL,
    data_desligamento       DATE,
    login_atualizacao       VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao        TIMESTAMP NOT NULL
);

ALTER TABLE tb_cargo_funcionario ADD CONSTRAINT tb_cargo_funcionario_pk PRIMARY KEY ( cod );

CREATE TABLE tb_contrato (
    cod                 INTEGER NOT NULL,
    cod_gestor          INTEGER NOT NULL,
    nome_empresa        VARCHAR2(200) NOT NULL,
    cnpj                VARCHAR2(14 CHAR) NOT NULL,
    numero_contrato     INTEGER NOT NULL,
    data_inicio         DATE NOT NULL,
    data_fim            DATE,
    se_ativo            CHAR(1 CHAR) NOT NULL,
    objeto              VARCHAR2(500 CHAR),
    login_atualizacao   VARCHAR2(100) NOT NULL,
    data_atualizacao    TIMESTAMP NOT NULL
);

ALTER TABLE tb_contrato ADD CONSTRAINT tb_contrato_pk PRIMARY KEY ( cod );

CREATE TABLE tb_convencao_coletiva (
    cod                  INTEGER NOT NULL,
    cod_cargo_contrato   INTEGER NOT NULL,
    data_convencao       DATE NOT NULL,
    data_aditamento      DATE,
    remuneracao          FLOAT(20) NOT NULL,
    login_atualizacao    VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao     TIMESTAMP NOT NULL
);

ALTER TABLE tb_convencao_coletiva ADD CONSTRAINT tb_convencao_coletiva_pk PRIMARY KEY ( cod );

CREATE TABLE tb_funcionario (
    cod                 INTEGER NOT NULL,
    nome                VARCHAR2(150) NOT NULL,
    cpf                 VARCHAR2(11 CHAR) NOT NULL,
    ativo               CHAR(1 CHAR) NOT NULL,
    login_atualizacao   VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao    TIMESTAMP NOT NULL
);

ALTER TABLE tb_funcionario ADD CONSTRAINT tb_funcionario_pk PRIMARY KEY ( cod );

ALTER TABLE tb_funcionario ADD CONSTRAINT tb_funcionario_cpf_un UNIQUE ( cpf );

CREATE TABLE tb_percentual_contrato (
    cod                 INTEGER NOT NULL,
    cod_contrato        INTEGER NOT NULL,
    cod_rubrica         INTEGER NOT NULL,
    percentual          FLOAT(20) NOT NULL,
    data_inicio         DATE NOT NULL,
    data_fim            DATE,
    login_atualizacao   VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao    TIMESTAMP NOT NULL
);

ALTER TABLE tb_percentual_contrato ADD CONSTRAINT tb_percentual_contrato_pk PRIMARY KEY ( cod );

CREATE TABLE tb_perfil (
    cod                 INTEGER NOT NULL,
    sigla               VARCHAR2(50) NOT NULL,
    descricao           VARCHAR2(400),
    login_atualizacao   VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao    TIMESTAMP NOT NULL
);

ALTER TABLE tb_perfil ADD CONSTRAINT tb_perfil_pk PRIMARY KEY ( cod );

ALTER TABLE tb_perfil ADD CONSTRAINT tb_perfil_sigla_un UNIQUE ( sigla );

CREATE TABLE tb_restituicao_decimo_terceiro (
    cod                        INTEGER NOT NULL,
    cod_contrato               INTEGER NOT NULL,
    cod_funcionario            INTEGER NOT NULL,
    data_inicio_contagem       DATE,
    dias_antes_cct             INTEGER NOT NULL,
    dias_depois_cct            INTEGER NOT NULL,
    valor_diario_posto         FLOAT(20) NOT NULL,
    incidencia_submodulo_4_1   FLOAT(20) NOT NULL,
    data_calculo               DATE NOT NULL,
    login_atualizacao          VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao           TIMESTAMP NOT NULL
);

ALTER TABLE tb_restituicao_decimo_terceiro ADD CONSTRAINT tb_rest_dec_ter_pk PRIMARY KEY ( cod );

CREATE TABLE tb_restituicao_ferias (
    cod                              INTEGER NOT NULL,
    cod_contrato                     INTEGER NOT NULL,
    cod_funcionario                  INTEGER NOT NULL,
    data_inicio_periodo_aquisitivo   DATE NOT NULL,
    data_fim_periodo_aquisitivo      DATE NOT NULL,
    data_inicio_usufruto             DATE NOT NULL,
    data_fim_usufruto                DATE NOT NULL,
    valor_ferias_e_terco             FLOAT(20) NOT NULL,
    valor_incidencia_submodulo_4_1   FLOAT(20) NOT NULL,
    se_proporcional                  CHAR(1 CHAR) NOT NULL,
    data_calculo                     DATE NOT NULL,
    login_atualizacao                VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao                 TIMESTAMP NOT NULL
);

ALTER TABLE tb_restituicao_ferias ADD CONSTRAINT tb_restituicao_ferias_pk PRIMARY KEY ( cod );

CREATE TABLE tb_restituicao_rescisao (
    cod                              INTEGER NOT NULL,
    cod_contrato                     INTEGER NOT NULL,
    cod_funcionario                  INTEGER NOT NULL,
    data_desligamento                DATE NOT NULL,
    incid_submod_4_1_dec_terceiro    FLOAT(20) NOT NULL,
    multa_fgts_dec_terceiro          FLOAT(20) NOT NULL,
    incid_submod_4_1_fgts_e_ferias   FLOAT(20) NOT NULL,
    multa_fgts_ferias                FLOAT(20) NOT NULL,
    ferias_multa_fgts_e_incid        FLOAT(20) NOT NULL,
    dec_terceiro_e_multa_fgts        FLOAT(20) NOT NULL,
    multa_fgts_salario               FLOAT(20) NOT NULL,
    demissao_a_pedido                CHAR(1 CHAR) NOT NULL,
    data_calculo                     DATE NOT NULL,
    login_atualizacao                VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao                 TIMESTAMP NOT NULL
);

ALTER TABLE tb_restituicao_rescisao ADD CONSTRAINT tb_restituicao_rescisao_pk PRIMARY KEY ( cod );

CREATE TABLE tb_rubricas (
    cod                 INTEGER NOT NULL,
    nome                VARCHAR2(150 CHAR) NOT NULL,
    sigla               VARCHAR2(50 CHAR) NOT NULL,
    descricao           VARCHAR2(400 CHAR),
    login_atualizacao   VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao    TIMESTAMP NOT NULL
);

ALTER TABLE tb_rubricas ADD CONSTRAINT tb_rubricas_pk PRIMARY KEY ( cod );

ALTER TABLE tb_rubricas ADD CONSTRAINT tb_rubricas_sigla_un UNIQUE ( sigla );

CREATE TABLE tb_total_mensal_a_reter (
    cod                           INTEGER NOT NULL,
    cod_contrato                  INTEGER NOT NULL,
    cod_cargo_contrato            INTEGER NOT NULL,
    ferias                        FLOAT(20) NOT NULL,
    abono_de_ferias               FLOAT(20) NOT NULL,
    decimo_terceiro               FLOAT(20) NOT NULL,
    incidencia_submodulo_4_1      FLOAT(20) NOT NULL,
    multa_fgts                    FLOAT(20) NOT NULL,
    numero_de_postos              INTEGER NOT NULL,
    numero_de_profissionais       INTEGER NOT NULL,
    dias_no_mes                   INTEGER NOT NULL,
    ret_diaria_por_profissional   FLOAT(20) NOT NULL,
    data_calculo                  DATE NOT NULL,
    login_atualizacao             VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao              TIMESTAMP NOT NULL
);

ALTER TABLE tb_total_mensal_a_reter ADD CONSTRAINT tb_total_mensal_a_reter_pk PRIMARY KEY ( cod );

CREATE TABLE tb_usuario (
    cod                 INTEGER NOT NULL,
    cod_perfil          INTEGER NOT NULL,
    nome                VARCHAR2(150 CHAR) NOT NULL,
    login               VARCHAR2(100 CHAR) NOT NULL,
    login_atualizacao   VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao    TIMESTAMP NOT NULL
);

ALTER TABLE tb_usuario ADD CONSTRAINT tb_usuario_pk PRIMARY KEY ( cod );

ALTER TABLE tb_usuario ADD CONSTRAINT tb_usuario__un UNIQUE ( login );

CREATE TABLE tb_vigencia_contrato (
    cod                    INTEGER NOT NULL,
    cod_contrato           INTEGER NOT NULL,
    data_inicio_vigencia   DATE NOT NULL,
    data_fim_vigencia      DATE NOT NULL,
    login_atualizacao      VARCHAR2(100 CHAR) NOT NULL,
    data_atualizacao       TIMESTAMP NOT NULL
);

ALTER TABLE tb_vigencia_contrato ADD CONSTRAINT tb_vigencia_contrato_pk PRIMARY KEY ( cod );

ALTER TABLE tb_cargo_contrato ADD CONSTRAINT tb_cargo_contrato_cargo_fk FOREIGN KEY ( cod_cargo )
    REFERENCES tb_cargo ( cod );

ALTER TABLE tb_cargo_contrato ADD CONSTRAINT tb_cargo_contrato_contrato_fk FOREIGN KEY ( cod_contrato )
    REFERENCES tb_contrato ( cod );

ALTER TABLE tb_cargo_funcionario ADD CONSTRAINT tb_cargo_contrato_fkv2 FOREIGN KEY ( cod_cargo_contrato )
    REFERENCES tb_cargo_contrato ( cod );

ALTER TABLE tb_cargo_funcionario ADD CONSTRAINT tb_cargo_funcionario_fk FOREIGN KEY ( cod_funcionario )
    REFERENCES tb_funcionario ( cod );

ALTER TABLE tb_convencao_coletiva ADD CONSTRAINT tb_cct_cargo_contrato_fk FOREIGN KEY ( cod_cargo_contrato )
    REFERENCES tb_cargo_contrato ( cod );

ALTER TABLE tb_contrato ADD CONSTRAINT tb_contrato_usuario_fk FOREIGN KEY ( cod_gestor )
    REFERENCES tb_usuario ( cod );

ALTER TABLE tb_restituicao_ferias ADD CONSTRAINT tb_ferias_contrato_fk FOREIGN KEY ( cod_contrato )
    REFERENCES tb_contrato ( cod );

ALTER TABLE tb_restituicao_ferias ADD CONSTRAINT tb_ferias_funcionario_fk FOREIGN KEY ( cod_funcionario )
    REFERENCES tb_funcionario ( cod );

ALTER TABLE tb_percentual_contrato ADD CONSTRAINT tb_percentual_contrato_fk FOREIGN KEY ( cod_contrato )
    REFERENCES tb_contrato ( cod );

ALTER TABLE tb_percentual_contrato ADD CONSTRAINT tb_percentual_rubricas_fk FOREIGN KEY ( cod_rubrica )
    REFERENCES tb_rubricas ( cod );

ALTER TABLE tb_restituicao_rescisao ADD CONSTRAINT tb_rescisao_contrato_fk FOREIGN KEY ( cod_contrato )
    REFERENCES tb_contrato ( cod );

ALTER TABLE tb_restituicao_rescisao ADD CONSTRAINT tb_rescisao_funcionario_fk FOREIGN KEY ( cod_funcionario )
    REFERENCES tb_funcionario ( cod );

ALTER TABLE tb_restituicao_decimo_terceiro ADD CONSTRAINT tb_rest_dec_ter_contrato_fk FOREIGN KEY ( cod_contrato )
    REFERENCES tb_contrato ( cod );

ALTER TABLE tb_restituicao_decimo_terceiro ADD CONSTRAINT tb_rest_dec_ter_funcionario_fk FOREIGN KEY ( cod_funcionario )
    REFERENCES tb_funcionario ( cod );

ALTER TABLE tb_total_mensal_a_reter ADD CONSTRAINT tb_t_mensal_cargo_contrato_fk FOREIGN KEY ( cod_cargo_contrato )
    REFERENCES tb_cargo_contrato ( cod );

ALTER TABLE tb_total_mensal_a_reter ADD CONSTRAINT tb_t_mensal_tb_contrato_fk FOREIGN KEY ( cod_contrato )
    REFERENCES tb_contrato ( cod );

ALTER TABLE tb_usuario ADD CONSTRAINT tb_usuario_perfil_fk FOREIGN KEY ( cod_perfil )
    REFERENCES tb_perfil ( cod );

ALTER TABLE tb_vigencia_contrato ADD CONSTRAINT tb_vigencia_contrato_fk FOREIGN KEY ( cod_contrato )
    REFERENCES tb_contrato ( cod );

CREATE SEQUENCE tb_cargo_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_cargo_cod_trg BEFORE
    INSERT ON tb_cargo
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_cargo_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_cargo_contrato_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_cargo_contrato_cod_trg BEFORE
    INSERT ON tb_cargo_contrato
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_cargo_contrato_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_cargo_funcionario_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_cargo_funcionario_cod_trg BEFORE
    INSERT ON tb_cargo_funcionario
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_cargo_funcionario_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_contrato_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_contrato_cod_trg BEFORE
    INSERT ON tb_contrato
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_contrato_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_convencao_coletiva_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_convencao_coletiva_cod_trg BEFORE
    INSERT ON tb_convencao_coletiva
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_convencao_coletiva_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_funcionario_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_funcionario_cod_trg BEFORE
    INSERT ON tb_funcionario
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_funcionario_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_percentual_contrato_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_percentual_contrato_cod_trg BEFORE
    INSERT ON tb_percentual_contrato
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_percentual_contrato_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_perfil_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_perfil_cod_trg BEFORE
    INSERT ON tb_perfil
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_perfil_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_rest_dec_ter_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_rest_dec_ter_trg BEFORE
    INSERT ON tb_restituicao_decimo_terceiro
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_rest_dec_ter_seq.nextval;
END;
/

CREATE SEQUENCE tb_restituicao_ferias_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_restituicao_ferias_cod_trg BEFORE
    INSERT ON tb_restituicao_ferias
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_restituicao_ferias_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_restituicao_rescisao_cod START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_restituicao_rescisao_cod BEFORE
    INSERT ON tb_restituicao_rescisao
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_restituicao_rescisao_cod.nextval;
END;
/

CREATE SEQUENCE tb_rubricas_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_rubricas_cod_trg BEFORE
    INSERT ON tb_rubricas
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_rubricas_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_tot_men_a_reter_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_tot_men_a_reter_cod_trg BEFORE
    INSERT ON tb_total_mensal_a_reter
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_tot_men_a_reter_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_usuario_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_usuario_cod_trg BEFORE
    INSERT ON tb_usuario
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_usuario_cod_seq.nextval;
END;
/

CREATE SEQUENCE tb_vigencia_contrato_cod_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER tb_vigencia_contrato_cod_trg BEFORE
    INSERT ON tb_vigencia_contrato
    FOR EACH ROW
    WHEN (
        new.cod IS NULL
    )
BEGIN
    :new.cod := tb_vigencia_contrato_cod_seq.nextval;
END;
/
