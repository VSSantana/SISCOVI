create or replace function "F_EXISTE_RETROATIVIDADE"(pCodCargoContrato NUMBER, pMes NUMBER, pAno NUMBER) RETURN NUMBER
IS

--Função que retorna se em um determinado mês, para um determindado cargo, existe caso de retroatividade.

  vCodConvencao NUMBER := 0;
  vCodContrato NUMBER := 0;
  vDataReferencia DATE;
  vDataConvencao DATE;
  vDataAditamento DATE;
  vRetorno NUMBER := 0;
  vExisteCalculo NUMBER := 0;

BEGIN

  vDataReferencia := TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno), 'dd/mm/yyyy');
  
  --Seleciona o código do contrato.
  
  SELECT cod_contrato
    INTO vCodContrato
    FROM tb_cargo_contrato
    WHERE cod = pCodCargoContrato;
    
  --Verifica a existência de cálculo no mês referência.
  
   SELECT COUNT(cod)
     INTO vExisteCalculo
	 FROM tb_total_mensal_a_reter
	WHERE EXTRACT(month FROM data_referencia) = pMes
	  AND EXTRACT(year FROM data_referencia) = pAno
      AND cod_contrato = vCodContrato;
    
  --Seleciona convenção com data de aditamento no mês referência.
  
  SELECT cod, data_inicio_convencao, data_aditamento 
    INTO vCodConvencao, vDataConvencao, vDataAditamento
    FROM tb_convencao_coletiva
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND data_aditamento IS NOT NULL
      AND ((EXTRACT(month FROM data_aditamento) = pMes
           AND 
           EXTRACT(year FROM data_aditamento) = pAno))   
      AND F_CONVENCAO_ANTERIOR(cod) IS NOT NULL;
      
  --Se existe convenção com data de aditamento no mês referência.

  IF(vCodConvencao IS NOT NULL) THEN

    IF(TRUNC(vDataConvencao) < TRUNC(vDataAditamento)) THEN
    
      RETURN vCodConvencao;
      
    END IF;
    
    IF(vDataConvencao =  vDataReferencia AND EXTRACT(month FROM vDataAditamento) > pMes) THEN
    
      RETURN vCodConvencao;
      
    END IF;

  END IF;
  
  SELECT cod, data_inicio_convencao, data_aditamento 
    INTO vCodConvencao, vDataConvencao, vDataAditamento
    FROM tb_convencao_coletiva
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND data_aditamento IS NOT NULL
      AND ((EXTRACT(month FROM data_aditamento) = pMes
           AND 
           EXTRACT(year FROM data_aditamento) = pAno)
           OR
           (EXTRACT(month FROM data_aditamento) = EXTRACT(month FROM ADD_MONTHS(vDataReferencia, -1))
           AND 
           EXTRACT(year FROM data_aditamento) = EXTRACT(month FROM ADD_MONTHS(vDataReferencia, -1))))   
      AND F_CONVENCAO_ANTERIOR(cod) IS NOT NULL;

  RETURN NULL;
  
END;