create or replace function "F_RETORNA_COD_GESTOR_ATUAL" (pCodContrato NUMBER) RETURN NUMBER
IS

  vCodUsuario NUMBER;

BEGIN

  SELECT u.cod
    INTO vCodUsuario
    FROM tb_historico_gestor_contrato hgc
      JOIN tb_contrato c ON c.cod = hgc.cod_contrato
      JOIN tb_usuario u ON u.cod = hgc.cod_usuario
    WHERE hgc.cod_contrato = pCodContrato
      AND (hgc.data_fim IS NULL
           OR
           hgc.data_fim = (SELECT MAX(data_fim)
                             FROM tb_historico_gestor_contrato
                             WHERE cod_contrato = pCodContrato
                               AND NOT EXISTS (SELECT cod
                                                 FROM tb_historico_gestor_contrato
                                                 WHERE cod_contrato = pCodContrato
                                                   AND data_fim IS NULL)));


  RETURN vCodUsuario;

  EXCEPTION WHEN NO_DATA_FOUND THEN
 
    RETURN NULL;

END;
