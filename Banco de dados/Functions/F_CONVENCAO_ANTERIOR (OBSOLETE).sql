create or replace function "F_CONVENCAO_ANTERIOR"(pCodConvencao NUMBER) RETURN NUMBER
IS

  --Função que retorna o código da convenção anterior a convenção referência.

  vCodConvencaoAnterior NUMBER;
  vCodCargoContrato NUMBER;
  vDataReferencia DATE;

BEGIN

  --Define os dados da convenção referência.

  SELECT cod_cargo_contrato, data_inicio_convencao
    INTO vCodCargoContrato, vDataReferencia 
    FROM tb_convencao_coletiva
    WHERE cod = pCodConvencao;
    
  --Busca a convenção com maior data de inicio anterior a convenção referência.

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