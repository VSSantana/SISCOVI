create or replace function "F_EXISTE_PERCENTUAL_RETROATIVO"(pCodContrato NUMBER, pCodRubrica NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS

--Função que retorna se em um determinado mês, para um determindado cargo, existe caso de retroatividade.

  vCodPercentualContrato NUMBER := 0;
  vDataInicio DATE;
  vDataAditamento DATE;

BEGIN
    
  --Determina o código da convenção do período informado baseado na data do aditamento.
  
  SELECT cod, data_inicio, data_aditamento 
    INTO vCodPercentualContrato, vDataInicio, vDataAditamento
    FROM tb_percentual_contrato
    WHERE cod_contrato = pCodContrato
	  AND data_aditamento IS NOT NULL
      AND EXTRACT(month FROM data_aditamento) = pMes
      AND EXTRACT(year FROM data_aditamento) = pAno;

  --Se existir convenção aditada ao período informado.  
	  
  IF(vCodPercentualContrato IS NOT NULL) THEN
  
    --Se a data de inicio da convenção é superior a data referência e o mês de aditamento é
	--maior que o mês da data da convenção, então há retroatividade.

    IF((EXTRACT(month FROM vDataAditamento) > EXTRACT(month FROM vDataInicio)) AND (EXTRACT(year FROM vDataAditamento) = EXTRACT(year FROM vDataInicio))) THEN
    
      RETURN TRUE;
      
    END IF;
	
	IF((EXTRACT(year FROM vDataAditamento) > EXTRACT(year FROM vDataInicio)) AND (EXTRACT(month FROM vDataAditamento) < EXTRACT(month FROM vDataInicio))) THEN
    
      RETURN TRUE;
      
    END IF;
    
  END IF;

  RETURN FALSE;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;
  
END;
