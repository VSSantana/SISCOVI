create or replace function "F_RETORNA_ANO_CONTRATO"(pCodContrato NUMBER) RETURN VARCHAR
IS

  --Função que retorna o ano do contrato baseado na data de início deste.

  vAnoContrato VARCHAR(4);

BEGIN

  SELECT TO_CHAR(MIN(v.data_inicio_vigencia), 'yyyy')
    INTO vAnoContrato
    FROM tb_contrato c
      JOIN tb_vigencia_contrato v ON v.cod_contrato = c.cod
    WHERE c.cod = pCodContrato;

  RETURN vAnoContrato;

  EXCEPTION WHEN OTHERS THEN 
  
    RETURN NULL;

END;
