/*    ==Parâmetros de Script==

    Versão do Servidor de Origem : SQL Server 2016 (13.0.4001)
    Edição do Mecanismo de Banco de Dados de Origem : Microsoft SQL Server Enterprise Edition
    Tipo do Mecanismo de Banco de Dados de Origem : SQL Server Autônomo

    Versão do Servidor de Destino : SQL Server 2016
    Edição de Mecanismo de Banco de Dados de Destino : Microsoft SQL Server Enterprise Edition
    Tipo de Mecanismo de Banco de Dados de Destino : SQL Server Autônomo
*/

USE [SISCOVI]
GO

/****** Object:  StoredProcedure [dbo].[DBLOAD]    Script Date: 07/09/2017 21:11:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[DBLOAD]
AS

BEGIN

  DECLARE @vDataDisponibilizacao DATE = '29/01/2017';
  DECLARE @vDataAtualizacao DATE = GETDATE();
  DECLARE @vLoginAtualizacao VARCHAR(15) = 'SYSTEM';
  DECLARE @vCodPerfilGestor INT;
  DECLARE @vCodPerfilAdmin INT;
  DECLARE @vCodGestor1 INT;
  DECLARE @vCodGestor2 INT;
  DECLARE @vCodContrato1 INT;
  DECLARE @vCodContrato2 INT;
  DECLARE @vCod13 INT;
  DECLARE @vCodSubMod INT;
  DECLARE @vCodAbono INT;
  DECLARE @vCodFerias INT;
  DECLARE @vCodFgts INT;
  DECLARE @vCodCargoContrato1 INT;
  DECLARE @vCodCargoContrato2 INT;
  DECLARE @vCodFuncionario INT;
  DECLARE @vCount INT = 0;
  DECLARE @vCodCargo1 INT;
  DECLARE @vCodCargo2 INT;
  DECLARE @vRemuneracao1 FLOAT = CONVERT(FLOAT,'1142.68');
  DECLARE @vRemuneracao2 FLOAT = CONVERT(FLOAT,'1239.80');

  DECLARE cur_funcionario CURSOR FOR 
    SELECT cod AS "cod_funcionario"
      FROM tb_funcionario;

  --Insert em tb_perfil.
  
  INSERT INTO tb_perfil (sigla, login_atualizacao, data_atualizacao) VALUES ('ADMINISTRADOR', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_perfil (sigla, login_atualizacao, data_atualizacao) VALUES ('GESTOR', @vLoginAtualizacao, @vDataAtualizacao);

  --Carregamento das variáveis de perfil

  SELECT @vCodPerfilGestor = cod
    FROM tb_perfil
    WHERE UPPER(sigla) = 'GESTOR';

  SELECT @vCodPerfilAdmin = cod
    FROM tb_perfil
    WHERE UPPER(sigla) = 'ADMINISTRADOR';

  --Insert em tb_usuario

  INSERT INTO tb_usuario (cod_perfil, nome, login, login_atualizacao, data_atualizacao) VALUES (@vCodPerfilGestor, 'SHAKA DE VIRGEM', 'VSHAKA', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_usuario (cod_perfil, nome, login, login_atualizacao, data_atualizacao) VALUES (@vCodPerfilGestor, 'LELOUCH LAMPEROUGE', 'LEROUGE', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_usuario (cod_perfil, nome, login, login_atualizacao, data_atualizacao) VALUES (@vCodPerfilAdmin, 'MATHEUS MIRANDA DE SOUSA', 'VSSOUSA', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_usuario (cod_perfil, nome, login, login_atualizacao, data_atualizacao) VALUES (@vCodPerfilAdmin, 'VINICIUS DE SOUSA SANTANA', 'MMSOUSA', @vLoginAtualizacao, @vDataAtualizacao); 

  --Insert em tb_rubricas

  INSERT INTO tb_rubricas (nome, sigla, login_atualizacao, data_atualizacao) VALUES ('Décimo terceiro salário', '13°', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_rubricas (nome, sigla, login_atualizacao, data_atualizacao) VALUES ('Incidência do submódulo 4.1', 'Submódulo', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_rubricas (nome, sigla, login_atualizacao, data_atualizacao) VALUES ('Abono de férias', 'Abono', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_rubricas (nome, sigla, login_atualizacao, data_atualizacao) VALUES ('Férias', 'Férias', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_rubricas (nome, sigla, login_atualizacao, data_atualizacao) VALUES ('Multa do FGTS', 'Multa FGTS', @vLoginAtualizacao, @vDataAtualizacao);

  --Carregamento das variáveis de gestor
  
  SELECT @vCodGestor1 = cod
    FROM tb_usuario
    WHERE UPPER(login) = 'VSHAKA';

  SELECT @vCodGestor2 = cod
    FROM tb_usuario
    WHERE UPPER(login) = 'LEROUGE';

  --Insert em tb_contrato

  INSERT INTO tb_contrato (cod_gestor, nome_empresa, cnpj, numero_contrato, data_inicio, se_ativo, login_atualizacao, data_atualizacao) VALUES (@vCodGestor1, 'ESPARTA SEGURANÇA LTDA', '65616094000173', 63, '29/07/2017', 'S',@vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_contrato (cod_gestor, nome_empresa, cnpj, numero_contrato, data_inicio, se_ativo, login_atualizacao, data_atualizacao) VALUES (@vCodGestor2, 'BRASFORT ADMINISTRAÇÃO E SERVIÇOS LTDA', '46048365000197', 70, '22/02/2017', 'S',@vLoginAtualizacao, @vDataAtualizacao);

  --Carregamento das variáveis de contrato
  
  SELECT @vCodContrato1 = cod
    FROM tb_contrato
    WHERE UPPER(nome_empresa) = 'ESPARTA SEGURANÇA LTDA';
    
  SELECT @vCodContrato2 = cod
    FROM tb_contrato
    WHERE UPPER(nome_empresa) = 'BRASFORT ADMINISTRAÇÃO E SERVIÇOS LTDA';

  --Carregamento das variáveis de percentual

  SELECT @vCod13 = cod
    FROM tb_rubricas
    WHERE UPPER(sigla) = UPPER('13°');

  SELECT @vCodSubMod = cod
    FROM tb_rubricas
    WHERE UPPER(sigla) = UPPER('Submódulo');

  SELECT @vCodAbono = cod
    FROM tb_rubricas
    WHERE UPPER(sigla) = UPPER('Abono');

  SELECT @vCodFerias = cod
    FROM tb_rubricas
    WHERE UPPER(sigla) = UPPER('Férias');

  SELECT @vCodFgts = cod
    FROM tb_rubricas
    WHERE UPPER(sigla) = UPPER('Multa FGTS');

  --Insert em tb_percentual_contrato

  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato1, @vCod13, '9.09', '29/01/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato1, @vCodSubMod, '7.81', '29/01/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato1, @vCodAbono, '3.03', '29/01/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato1, @vCodFerias, '9.09', '29/01/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato1, @vCodFgts, '4.36', '29/01/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato2, @vCod13, '9.09', '22/02/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato2, @vCodSubMod, '7.81', '22/02/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato2, @vCodAbono, '3.03', '22/02/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato2, @vCodFerias, '9.09', '22/02/2017', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_percentual_contrato (cod_contrato, cod_rubrica, percentual, data_inicio, login_atualizacao, data_atualizacao) VALUES (@vCodContrato2, @vCodFgts, '4.36', '22/02/2017', @vLoginAtualizacao, @vDataAtualizacao);

  --Insert em tb_cargo

  INSERT INTO tb_cargo (nome, login_atualizacao, data_atualizacao) VALUES ('Agente de Segurança', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_cargo (nome, login_atualizacao, data_atualizacao) VALUES ('Segurança Patrimonial', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_cargo (nome, login_atualizacao, data_atualizacao) VALUES ('Secretariado Executivo', @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_cargo (nome, login_atualizacao, data_atualizacao) VALUES ('Assistente Executivo', @vLoginAtualizacao, @vDataAtualizacao);
  
  --Insert em tb_cargo_contrato

  SELECT @vCodCargo1 = cod
    FROM tb_cargo
    WHERE UPPER(nome) = UPPER('Agente de Segurança');

  SELECT @vCodCargo2 = cod
    FROM tb_cargo
    WHERE UPPER(nome) = UPPER('Segurança Patrimonial');

  INSERT INTO tb_cargo_contrato (cod_contrato, cod_cargo, login_atualizacao, data_atualizacao) VALUES (@vCodContrato1, @vCodCargo1, @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_cargo_contrato (cod_contrato, cod_cargo, login_atualizacao, data_atualizacao) VALUES (@vCodContrato1, @vCodCargo2, @vLoginAtualizacao, @vDataAtualizacao);

  SELECT @vCodCargo1 = cod
    FROM tb_cargo
    WHERE UPPER(nome) = UPPER('Secretariado Executivo');

  SELECT @vCodCargo2 = cod
    FROM tb_cargo
    WHERE UPPER(nome) = UPPER('Assistente Executivo');

  INSERT INTO tb_cargo_contrato (cod_contrato, cod_cargo, login_atualizacao, data_atualizacao) VALUES (@vCodContrato2, @vCodCargo1, @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_cargo_contrato (cod_contrato, cod_cargo, login_atualizacao, data_atualizacao) VALUES (@vCodContrato2, @vCodCargo2, @vLoginAtualizacao, @vDataAtualizacao);

  --Insert em tb_funcionarios

    INSERT INTO tb_funcionario (nome,cpf,ativo,login_atualizacao,data_atualizacao)
  VALUES ('Eliseu Padilha',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao), 
         ('Gilberto Kassab',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Moreira Franco',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Roberto Freire',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Bruno Araújo',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Aloysio Nunes Ferreira',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Marcos Pereira',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Blairo Maggi',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Helder Barbalho',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Romero Jucá Filho',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Aécio Neves da Cunha',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Renan Calheiros',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Fernando Bezerra Coelho',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Paulo Rocha',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Humberto Sérgio Costa Lima',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Edison Lobão',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Cássio Cunha Lima',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Jorge Viana',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Lidice da Mata',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('José Agripino Maia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Marta Suplicy',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Ciro Nogueira',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Dalírio José Beber',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Ivo Cassol',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Lindbergh Farias',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Vanessa Grazziotin',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Kátia Regina de Abreu',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Fernando Afonso Collor de Mello',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('José Serra',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Eduardo Braga',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Omar Aziz',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Valdir Raupp',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Eunício Oliveira',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Eduardo Amorim',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Maria do Carmo Alves',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Garibaldi Alves Filho',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Ricardo Ferraço',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Antônio Anastasia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Paulinho da Força',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Marco Maia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Carlos Zarattini',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Rodrigo Maia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('João Carlos Bacelar',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Milton Monti',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('José Carlos Aleluia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Daniel Almeida',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Mário Negromonte Jr.',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Nelson Pellegrino',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Jutahy Júnior',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Maria do Rosário',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Felipe Maia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Ônix Lorenzoni',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Jarbas de Andrade Vasconcelos',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Vicente Paulo da Silva',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Arthur Oliveira Maia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Yeda Crusius',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Paulo Henrique Lustosa',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('José Reinaldo',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('João Paulo Papa',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Vander Loubet',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Rodrigo Garcia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Cacá Leão',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Celso Russomano',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Dimas Fabiano Toledo',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Pedro Paulo',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Lúcio Vieira Lima',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Paes Landim',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Daniel Vilela',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Alfredo Nascimento',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Zeca Dirceu',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Betinho Gomes',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Zeca do PT',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Vicente Cândido',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Júlio Lopes',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Fábio Faria',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Heráclito Fortes',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Beto Mansur',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Antônio Brito',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Décio Lima',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Arlindo Chinaglia',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Renan Filho',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Robinson Faria',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Tião Viana',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Vital do Rêgo Filho',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Rosalba Ciarlini',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Valdemar da Costa Neto',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Luís Alberto Maguito Vilela',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Edvaldo Pereira de Brito',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Oswaldo Borges da Costa',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao),
         ('Cândido Vaccarezza',dbo.F_RETURN_RANDOM_CPF(FLOOR(RAND() * (99999999999 - 10000000000) + 10000000000)),'S',@vLoginAtualizacao,@vDataAtualizacao);

  --Carregamento das variáveis de cargo para o contrato 1

  SELECT @vCodCargoContrato1 = cc.cod
    FROM tb_cargo_contrato cc
	  JOIN tb_cargo c ON c.cod = cc.cod_cargo
    WHERE UPPER(c.nome) = UPPER('Agente de Segurança')
      AND cc.cod_contrato = @vCodContrato1;

  SELECT @vCodCargoContrato2 = cc.cod
    FROM tb_cargo_contrato cc
	  JOIN tb_cargo c ON c.cod = cc.cod_cargo
    WHERE UPPER(c.nome) = UPPER('Segurança Patrimonial')
      AND cc.cod_contrato = @vCodContrato1;

  --Insert em tb_convencao_coletiva
  
  INSERT INTO tb_convencao_coletiva (cod_cargo_contrato, data_convencao, data_aditamento, remuneracao, login_atualizacao, data_atualizacao) VALUES (@vCodCargoContrato1, '29/01/2017', '29/01/2017', @vRemuneracao1, @vLoginAtualizacao, @vDataAtualizacao);
  INSERT INTO tb_convencao_coletiva (cod_cargo_contrato, data_convencao, data_aditamento, remuneracao, login_atualizacao, data_atualizacao) VALUES (@vCodCargoContrato2, '29/01/2017', '29/01/2017', @vRemuneracao2, @vLoginAtualizacao, @vDataAtualizacao);

  --Insert em tb_cargo_funcionario

  OPEN cur_funcionario

  FETCH NEXT FROM cur_funcionario INTO @vCodFuncionario

  WHILE @@FETCH_STATUS = 0
    
BEGIN

      IF (@vCount < 30) 

        BEGIN

        INSERT INTO tb_cargo_funcionario(cod_funcionario, 
                                         cod_cargo_contrato, 
                                         data_disponibilizacao, 
                                         login_atualizacao, 
                                         data_atualizacao) 
          VALUES (@vCodFuncionario, 
                  @vCodCargoContrato1,
                  @vDataDisponibilizacao, 
                  @vLoginAtualizacao, 
                  @vDataAtualizacao);

        FETCH NEXT FROM  cur_funcionario INTO @vCodFuncionario

        END;

      ELSE

        IF (@vCount >= 30 AND @vCount < 40) 
 
        BEGIN

          INSERT INTO tb_cargo_funcionario(cod_funcionario, 
                                           cod_cargo_contrato, 
                                           data_disponibilizacao, 
                                           login_atualizacao, 
                                           data_atualizacao) 
            VALUES (@vCodFuncionario, 
                    @vCodCargoContrato2,
                    @vDataDisponibilizacao, 
                    @vLoginAtualizacao, 
                    @vDataAtualizacao);

          FETCH NEXT FROM  cur_funcionario INTO @vCodFuncionario

        END;

        ELSE

          IF (@vCount >= 40 AND @vCount < 75)

          BEGIN
          
            INSERT INTO tb_cargo_funcionario(cod_funcionario, 
                                      cod_cargo_contrato, 
                                      data_disponibilizacao, 
                                      login_atualizacao, 
                                      data_atualizacao) 
              VALUES (@vCodFuncionario, 
                      @vCodCargoContrato1,
                      @vDataDisponibilizacao, 
                      @vLoginAtualizacao, 
                      @vDataAtualizacao);

            FETCH NEXT FROM  cur_funcionario INTO @vCodFuncionario

          END;
            
          ELSE

            IF (@vCount >= 75 AND @vCount < 90) 

            BEGIN

              INSERT INTO tb_cargo_funcionario(cod_funcionario, 
                                               cod_cargo_contrato, 
                                               data_disponibilizacao, 
                                               login_atualizacao, 
                                               data_atualizacao) 
                VALUES (@vCodFuncionario, 
                        @vCodCargoContrato2,
                        @vDataDisponibilizacao, 
                        @vLoginAtualizacao, 
                        @vDataAtualizacao);

              FETCH NEXT FROM  cur_funcionario INTO @vCodFuncionario

            END;
            
      SET @vCount = @vCount + 1;

      IF (@vCount = 40)

      BEGIN

      --Carregamento das variáveis dos postos de trabalho para o contrato 2  

        SELECT @vCodCargoContrato1 = cc.cod
		  FROM tb_cargo_contrato cc
		    JOIN tb_cargo c ON c.cod = cc.cod_cargo
		  WHERE UPPER(c.nome) = UPPER('Secretariado Executivo')
		    AND cc.cod_contrato = @vCodContrato2;

        SELECT @vCodCargoContrato2 = cc.cod
          FROM tb_cargo_contrato cc
	        JOIN tb_cargo c ON c.cod = cc.cod_cargo
          WHERE UPPER(c.nome) = UPPER('Assistente Executivo')
            AND cc.cod_contrato = @vCodContrato2;

        INSERT INTO tb_convencao_coletiva (cod_cargo_contrato, data_convencao, data_aditamento, remuneracao, login_atualizacao, data_atualizacao) VALUES (@vCodCargoContrato1, '22/01/2017', '22/01/2017', '1320.40', @vLoginAtualizacao, @vDataAtualizacao);
	    INSERT INTO tb_convencao_coletiva (cod_cargo_contrato, data_convencao, data_aditamento, remuneracao, login_atualizacao, data_atualizacao) VALUES (@vCodCargoContrato2, '22/02/2017', '22/01/2017', '1518.80', @vLoginAtualizacao, @vDataAtualizacao);

      END;
  
  END;

  CLOSE cur_funcionario;

  DEALLOCATE cur_funcionario;

  PRINT 'Script executado com sucesso!'
      
END;

GO


