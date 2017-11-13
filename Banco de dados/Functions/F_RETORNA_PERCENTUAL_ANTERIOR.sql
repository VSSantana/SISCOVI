create or replace function "F_RETORNA_PERCENTUAL_ANTERIOR" (pCodPercentual NUMBER) RETURN NUMBER
IS

--Retorna o código (cod) do percentual anterior ao cod do percentual passada.
--Entenda "passado" como referência.

  vCodPercentualAnterior NUMBER;
  vCodContrato NUMBER;
  vCodRubrica NUMBER;
  vDataReferencia DATE;

BEGIN

  --Define o contrato e a data referência com base no percentual referência.
  
  SELECT cod_contrato, data_inicio, cod_rubrica
    INTO vCodContrato, vDataReferencia, vCodRubrica
    FROM tb_percentual_contrato
    WHERE cod = pCodPercentual;
	
  --Seleciona o cod do percentual anterior com base na maior data de início
  --de percentual daquela rubrica, anterior ao percentual referência.
	
  SELECT cod
    INTO vCodPercentualAnterior
    FROM tb_percentual_contrato
    WHERE data_aditamento IS NOT NULL
      AND cod_contrato = vCodContrato
      AND cod_rubrica = vCodRubrica
      AND data_inicio = (SELECT MAX(data_inicio)
                           FROM tb_percentual_contrato
                           WHERE TO_DATE(TO_CHAR(data_inicio, 'dd/mm/yyyy'), 'dd/mm/yyyy') < TO_DATE(TO_CHAR(vDataReferencia, 'dd/mm/yyyy'), 'dd/mm/yyyy')
                             AND cod_contrato = vCodContrato
                             AND cod_rubrica = vCodRubrica
                             AND data_aditamento IS NOT NULL);

  RETURN vCodPercentualAnterior;

  EXCEPTION WHEN NO_DATA_FOUND THEN

    RETURN NULL;

END;