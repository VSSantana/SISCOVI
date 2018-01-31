create or replace function "F_EXISTE_ANO_RETENCAO" (pCodContrato NUMBER, pAno NUMBER) RETURN NUMBER
IS

  --Verifica se existe ao menos uma retenção feita para o ano passado
  --no contrato em questão.

  vRetorno NUMBER := 0;

BEGIN

  SELECT COUNT(tmr.cod)
    INTO vRetorno
    FROM tb_total_mensal_a_reter tmr
      JOIN tb_cargo_funcionario cf ON cf.cod = tmr.cod_cargo_funcionario
      JOIN tb_cargo_contrato cc ON cc.cod = cf.cod_cargo_contrato
      JOIN tb_contrato c ON c.cod = cc.cod_contrato
    WHERE c.cod = pCodContrato
      AND EXTRACT(year FROM tmr.data_referencia) = pAno;

  IF (vRetorno > 0) THEN

    RETURN vRetorno;

  END IF;

  RETURN NULL;

  EXCEPTION WHEN OTHERS THEN

    RETURN NULL;

END;
