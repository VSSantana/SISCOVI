create or replace function "F_RETORNA_CONVENCAO_ANTERIOR" (pCodConvencao NUMBER) RETURN NUMBER
IS

--Retorna o código (cod) da convenção anterior ao cod da convenção passada.
--Entenda "passada" como referência.

  vCodConvencaoAnterior NUMBER;
  vCodCargoContrato NUMBER;
  vDataReferencia DATE;

BEGIN

  --Define o cargo e a data referência com base na convenção passada.
  
  SELECT cod_cargo_contrato, data_inicio_convencao
    INTO vCodCargoContrato, vDataReferencia 
    FROM tb_convencao_coletiva
    WHERE cod = pCodConvencao;
	
  --Seleciona o cod da conveção anterior com base na maior data de início
  --de conveção daquele cargo, anterior a convenção passada.
	
  SELECT cod
    INTO vCodConvencaoAnterior
    FROM tb_convencao_coletiva
    WHERE data_aditamento IS NOT NULL
      AND cod_cargo_contrato = vCodCargoContrato
      AND data_inicio_convencao = (SELECT MAX(data_inicio_convencao)
                                     FROM tb_convencao_coletiva
                                     WHERE TO_DATE(TO_CHAR(data_inicio_convencao, 'dd/mm/yyyy'), 'dd/mm/yyyy') < TO_DATE(TO_CHAR(vDataReferencia, 'dd/mm/yyyy'), 'dd/mm/yyyy')
                                       AND cod_cargo_contrato = vCodCargoContrato
                                       AND data_aditamento IS NOT NULL);

  RETURN vCodConvencaoAnterior;

  EXCEPTION WHEN NO_DATA_FOUND THEN

    RETURN NULL;

END;
