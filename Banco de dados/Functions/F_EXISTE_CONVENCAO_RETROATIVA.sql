create or replace function "F_EXISTE_CONVENCAO_RETROATIVA"(pCodCargoContrato NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS

--Função que retorna se em um determinado mês, para um determindado cargo, existe caso de retroatividade.

  vCodConvencao NUMBER := 0;
  vDataConvencao DATE;
  vDataAditamento DATE;

BEGIN
    
  --Determina o código da convenção do período informado baseado na data do aditamento.
  
  SELECT cod, data_inicio_convencao, data_aditamento 
    INTO vCodConvencao, vDataConvencao, vDataAditamento
    FROM tb_convencao_coletiva
    WHERE cod_cargo_contrato = pCodCargoContrato
	  AND data_aditamento IS NOT NULL
      AND EXTRACT(month FROM data_aditamento) = pMes
      AND EXTRACT(year FROM data_aditamento) = pAno;

  --Se existir convenção aditada ao período informado.  
	  
  IF(vCodConvencao IS NOT NULL) THEN
  
    --Se a data de inicio da convenção é superior a data referência e o mês de aditamento é
	--maior que o mês da data da convenção, então há retroatividade.

    IF((EXTRACT(month FROM vDataAditamento) > EXTRACT(month FROM vDataConvencao)) AND (EXTRACT(year FROM vDataAditamento) = EXTRACT(year FROM vDataConvencao))) THEN
    
      RETURN TRUE;
      
    END IF;
	
	IF((EXTRACT(year FROM vDataAditamento) > EXTRACT(year FROM vDataConvencao)) AND (EXTRACT(month FROM vDataAditamento) < EXTRACT(month FROM vDataConvencao))) THEN
    
      RETURN TRUE;
      
    END IF;
    
  END IF;

  RETURN FALSE;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;
  
END;
