/*    ==Parâmetros de Script==

    Versão do Servidor de Origem : SQL Server 2016 (13.0.1601)
    Edição do Mecanismo de Banco de Dados de Origem : Microsoft SQL Server Enterprise Edition
    Tipo do Mecanismo de Banco de Dados de Origem : SQL Server Autônomo

    Versão do Servidor de Destino : SQL Server 2016
    Edição de Mecanismo de Banco de Dados de Destino : Microsoft SQL Server Enterprise Edition
    Tipo de Mecanismo de Banco de Dados de Destino : SQL Server Autônomo
*/

USE [siscovi]
GO

/****** Object:  StoredProcedure [dbo].[DB_UNLOAD]    Script Date: 04/09/2017 15:08:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[DB_UNLOAD]
AS

BEGIN

  DELETE FROM tb_total_mensal_a_reter;

  DELETE FROM tb_restituicao_ferias;

  DELETE FROM tb_restituicao_decimo_terceiro;

  DELETE FROM tb_restituicao_rescisao;

  DELETE FROM tb_posto_funcionario;

  DELETE FROM tb_convencao_coletiva;

  DELETE FROM tb_funcionario;

  DELETE FROM tb_posto_trabalho;

  DELETE FROM tb_percentual_contrato;

  DELETE FROM tb_rubricas;

  DELETE FROM tb_contrato;

  DELETE FROM tb_usuario;

  DELETE FROM tb_perfil;

  DELETE FROM tb_cargo;

  DELETE FROM tb_vigencia_contrato;

  PRINT 'Script executado com sucesso'

END;
GO


