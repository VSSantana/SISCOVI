create or replace function "F_EXISTE_CONVENCAO_RETROATIVA"(pCodConvencao NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS

--Função que retorna se em um determinado mês, para um determindado cargo, existe caso de retroatividade.

  vDataConvencao DATE;
  vDataAditamento DATE;
  vCount NUMBER := 0;
  vCodCargoContrato NUMBER;
  vDataCalculoAnterior DATE;

BEGIN
    
  --Determina os dados da convenção.
  
  SELECT data_inicio_convencao, data_aditamento, cod_cargo_contrato 
    INTO vDataConvencao, vDataAditamento, vCodCargoContrato
    FROM tb_convencao_coletiva
    WHERE cod = pCodConvencao
	  AND data_aditamento IS NOT NULL;
      
  --O primeiro caso é o de calcular um mês com aditamento.
  
  IF (EXTRACT(month FROM vDataAditamento) = pMes AND (EXTRACT(year FROM vDataAditamento) = pAno)) THEN
  
    IF (TRUNC(vDataAditamento) <= TRUNC(SYSDATE)) THEN
    
      RETURN TRUE;      
    
    END IF;
    
  END IF;
  
  --O segundo caso é o de calcular em um mês seguinte ao de aditamento.
  
  IF (EXTRACT(month FROM vDataAditamento) + 1 = pMes AND (EXTRACT(year FROM vDataAditamento) = pAno)) THEN
  
    SELECT COUNT(cod)
      INTO vCount
	  FROM tb_total_mensal_a_reter
	  WHERE cod_cargo_contrato = vCodCargoContrato
	    AND EXTRACT(month FROM data_referencia) = pMes - 1
	    AND EXTRACT(year FROM data_referencia) = pAno;
        
    IF (vCount > 0) THEN
    
      SELECT MAX(DISTINCT(data_referencia))
        INTO vDataCalculoAnterior
	    FROM tb_total_mensal_a_reter
	    WHERE cod_cargo_contrato = vCodCargoContrato
	      AND EXTRACT(month FROM data_referencia) = pMes - 1
	      AND EXTRACT(year FROM data_referencia) = pAno;
          
      IF (TRUNC(vDataAditamento) > TRUNC(vDataCalculoAnterior)) THEN
    
        RETURN TRUE;      
    
      END IF;      
    
    END IF;
  
  END IF;
  
  RETURN FALSE;
  
END;