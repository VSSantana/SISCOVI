create or replace function "F_RETORNA_ANO_CONTRATO"(pCodContrato NUMBER) RETURN VARCHAR
IS

  vAnoContrato VARCHAR(4);

BEGIN

  SELECT TO_CHAR(data_inicio, 'yyyy')
    INTO vAnoContrato
    FROM tb_contrato
    WHERE cod = pCodContrato;

  RETURN vAnoContrato;

  EXCEPTION WHEN OTHERS THEN 
  
    RETURN NULL;

END;
