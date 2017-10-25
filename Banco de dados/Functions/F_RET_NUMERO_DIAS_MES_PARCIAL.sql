create or replace function "F_RET_NUMERO_DIAS_MES_PARCIAL" (pCodCargoContrato NUMBER, pMes NUMBER, pAno NUMBER, pOperacao NUMBER) RETURN NUMBER
IS

  vRetorno NUMBER;
  vDataReferencia DATE;
  vDataFimPercentual DATE;
  vDataInicioPercentual DATE;
  vCodContrato NUMBER;

BEGIN

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy');
  
  SELECT cod_contrato
    INTO vCodContrato
    FROM tb_cargo_contrato
    WHERE cod = pCodCargoContrato;
  
  --Primeira metade da convenção.
   
  IF (pOperacao = 1) THEN
  
    SELECT (data_fim_convencao - vDataReferencia) + 1
      INTO vRetorno
      FROM tb_convencao_coletiva
      WHERE data_aditamento IS NOT NULL
        AND cod_cargo_contrato = pCodCargoContrato
        AND EXTRACT(month FROM data_fim_convencao) = EXTRACT(month FROM vDataReferencia)
        AND EXTRACT(year FROM data_fim_convencao) = EXTRACT(year FROM vDataReferencia);
        
  END IF;
  
  --Segunda metade da convenção.
  
  IF (pOperacao = 2) THEN
  
    SELECT (LAST_DAY(vDataReferencia) - data_inicio_convencao) + 1
      INTO vRetorno
      FROM tb_convencao_coletiva
      WHERE data_aditamento IS NOT NULL
        AND cod_cargo_contrato = pCodCargoContrato
        AND EXTRACT(month FROM data_inicio_convencao) = EXTRACT(month FROM vDataReferencia)
        AND EXTRACT(year FROM data_inicio_convencao) = EXTRACT(year FROM vDataReferencia);
        
    IF (EXTRACT(day FROM LAST_DAY(vDataReferencia)) = 31) THEN
  
      vRetorno := vRetorno - 1;
  
    END IF;
    
  END IF;
  
  --Primeira metade do percentual.
    
  IF (pOperacao = 3) THEN
  
    SELECT MAX(pc.data_fim)
      INTO vDataFimPercentual
      FROM tb_percentual_contrato pc
        JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
      WHERE cod_contrato = vCodContrato
        AND pc.data_aditamento IS NOT NULL        
        AND EXTRACT(month FROM pc.data_fim) = EXTRACT(month FROM vDataReferencia)
        AND EXTRACT(year FROM pc.data_fim) = EXTRACT(year FROM vDataReferencia);
        
    vRetorno := (vDataFimPercentual - vDataReferencia) + 1;
        
  END IF;
  
  --Segunda metade do percentual.
  
  IF (pOperacao = 4) THEN
  
    SELECT MIN(pc.data_inicio)
      INTO vDataInicioPercentual
      FROM tb_percentual_contrato pc
        JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
      WHERE cod_contrato = vCodContrato
        AND pc.data_aditamento IS NOT NULL
        AND EXTRACT(month FROM pc.data_inicio) = EXTRACT(month FROM vDataReferencia)
        AND EXTRACT(year FROM pc.data_inicio) = EXTRACT(year FROM vDataReferencia);
        
    vRetorno := (LAST_DAY(vDataReferencia) - vDataInicioPercentual) + 1;
        
    IF (EXTRACT(day FROM LAST_DAY(vDataReferencia)) = 31) THEN
  
      vRetorno := vRetorno - 1;
  
    END IF;
        
  END IF;

  RETURN vRetorno;

END;
