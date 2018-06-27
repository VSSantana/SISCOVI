create or replace function "F_FUNC_RETENCAO_INTEGRAL"(pCodFuncaoTerceirizado NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS

--Função que retorna se um terceirizado trabalhou período igual ou superior a 15
--dias em um determinado mês.

  vDataInicio DATE;
  vDataFim DATE;
  vDataReferencia DATE;

BEGIN

  --Define como data referência o primeiro dia do mês e ano passados como argumentos.

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy');

  --Carrega as datas de disponibilização e desligamento do terceirizado.
 
  SELECT data_inicio, 
         data_fim
    INTO vDataInicio,
	       vDataFim
    FROM tb_funcao_terceirizado
  	WHERE cod = pCodFuncaoTerceirizado;
    
  --Caso não possua data de desligamento.  
   
  IF (vDataFim IS NULL) THEN
  
    --Se a data de disponibilização é inferior a data referência então o
    --funcionário trabalhou os 30 dias do mês referência.
  
    IF (vDataInicio < vDataReferencia) THEN
      
      RETURN TRUE;
      
    END IF;
    
    --Se a data de disponibilização está no mês referência enão se verifica
    --a quantidade de dias trabalhados pelo funcionário.
  
    IF (vDataInicio >= vDataReferencia AND vDataInicio <= LAST_DAY(vDataReferencia)) THEN
    
      IF (((LAST_DAY(vDataInicio) - vDataInicio) + 1) >= 15) THEN
  
        RETURN TRUE;
    
      END IF;
    
    END IF;
 
  END IF;
  
  --Caso possua data de desligamento.
  
  IF (vDataFim IS NOT NULL) THEN
  
    --Se a data de disponibilização é inferior a data referência e a data de 
    --desligamento é superior ao último dia do mês referência então o
    --funcionário trabalhou os 30 dias.
  
    IF (vDataInicio < vDataReferencia AND vDataFim > LAST_DAY(vDataReferencia)) THEN
      
      RETURN TRUE;
      
    END IF;  
    
    --Se a data de disponibilização está no mês referência e a data de
    --desligamento é superior ao mês referência, então se verifica a quantidade
    --de dias trabalhados pelo funcionário.
  
    IF (vDataInicio >= vDataReferencia 
        AND vDataInicio <= LAST_DAY(vDataReferencia)
        AND vDataFim > LAST_DAY(vDataReferencia)) THEN
    
      IF (((LAST_DAY(vDataInicio) - vDataInicio) + 1) >= 15) THEN
  
        RETURN TRUE;
    
      END IF;
    
    END IF;
    
    --Se a data de disponibilização está no mês referência e também a data de
    --desligamento, então contam-se os dias trabalhados pelo funcionário.
    
    IF (vDataInicio >= vDataReferencia 
        AND vDataInicio <= LAST_DAY(vDataReferencia)
        AND vDataFim >= vDataReferencia
        AND vDataFim <= LAST_DAY(vDataReferencia)) THEN
    
      IF (((vDataFim - vDataInicio) + 1) >= 15) THEN
  
        RETURN TRUE;
    
      END IF;
    
    END IF;
    
    --Se a data da disponibilização for inferior ao mês de cálculo e 
    --o funcionário tiver desligamento no mês referência, então contam-se
    --os dias trabalhados.
    
    IF (vDataInicio < vDataReferencia 
        AND vDataFim >= vDataReferencia
        AND vDataFim <= LAST_DAY(vDataReferencia)) THEN
    
      IF (((vDataFim - vDataReferencia) + 1) >= 15) THEN
  
        RETURN TRUE;
    
      END IF;
    
    END IF;
 
  END IF;

  RETURN FALSE;  

END;
