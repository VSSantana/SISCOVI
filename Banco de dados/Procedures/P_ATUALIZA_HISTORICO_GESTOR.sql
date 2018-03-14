create or replace procedure "P_ATUALIZA_HISTORICO_GESTOR" (pCodUsuario NUMBER, pCodContrato NUMBER, pLoginAtuatizacao VARCHAR, pDataContrato DATE)
AS

  vDataInicio DATE;
  vDataFim DATE;
  vCodGestorAtual NUMBER;
  vCodRegistro NUMBER;

BEGIN

  BEGIN

    SELECT cod,
           cod_usuario
      INTO vCodRegistro,
           vCodGestorAtual
      FROM TB_HISTORICO_GESTOR_CONTRATO
      WHERE cod_contrato = pCodContrato
        AND data_fim IS NULL;

    EXCEPTION WHEN NO_DATA_FOUND THEN

      vDataInicio := pDataContrato;
      vCodGestorAtual := NULL;

  END;
  
  --Caso não exista nehum gesto para o contrato.

  IF (vCodGestorAtual IS NULL) THEN

    INSERT INTO TB_HISTORICO_GESTOR_CONTRATO (cod_contrato,
                                              cod_usuario,
                                              data_inicio,
                                              login_atualizacao,
                                              data_atualizacao)
      VALUES (pCodContrato,
              pCodUsuario,
              pDataContrato,
              pLoginAtuatizacao,
              SYSDATE);

  END IF;
  
  --Caso se esteja mudando o gestor do contrato.

  IF (vCodGestorAtual IS NOT NULL AND vCodGestorAtual != pCodUsuario) THEN

    INSERT INTO TB_HISTORICO_GESTOR_CONTRATO (cod_contrato,
                                              cod_usuario,
                                              data_inicio,
                                              login_atualizacao,
                                              data_atualizacao)
      VALUES (pCodContrato,
              pCodUsuario,
              SYSDATE,
              pLoginAtuatizacao,
              SYSDATE);

    UPDATE TB_HISTORICO_GESTOR_CONTRATO 
      SET data_fim = SYSDATE - 1
      WHERE data_fim IS NULL
        AND cod_contrato = pCodContrato
        AND cod_usuario = vCodGestorAtual;
        
  END IF;

END;
