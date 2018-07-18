create or replace function "F_DIAS_TRABALHADOS_PERIOODO"(pCodFuncaoTerceirizado NUMBER, pDataInicio DATE, pDataFim DATE) RETURN NUMBER
IS

  --Função que retorna o número de dias que um terceirizado
  --trabalhou em uma função em um determinado mês.

  vDataInicio DATE;
  vDataFim DATE;

BEGIN

  --Carregamento das datas de disponibilização e desligamento do terceirizado na função.

  SELECT data_inicio, 
         data_fim
    INTO vDataInicio,
	     vDataFim
    FROM tb_funcao_terceirizado
	WHERE cod = pCodFuncaoTerceirizado;
    
  --Caso não possua data de desligamento.  
   
  IF (vDataFim IS NULL) THEN
  
    --Se a data de disponibilização é inferior a data referência então o
    --terceirizado trabalhou o período completo, a data
    --referência é sempre a data inicio argumento da função.
  
    IF (vDataInicio < pDataInicio) THEN
      
      RETURN ((pDataFim - pDataInicio) + 1);
      
    END IF;
    
    --Se a data de disponibilização está no mês referência enão se verifica
    --a quantidade de dias trabalhados pelo terceirizado no período.
  
    IF (vDataInicio >= pDataInicio AND vDataInicio <= pDataFim) THEN
  
      RETURN (pDataFim - vDataInicio) + 1;
    
    END IF;
 
  END IF;
  
  --Caso possua data de desligamento.
  
  IF (vDataFim IS NOT NULL) THEN
  
    --Se a data de disponibilização é inferior a data referência e a data de 
    --desligamento é superior ao último dia do mês referência então o
    --terceirizado trabalhou os 30 dias.
  
    IF (vDataInicio < pDataInicio AND vDataFim > pDataFim) THEN
      
      RETURN ((pDataFim - pDataInicio) + 1);
      
    END IF;  
    
    --Se a data de disponibilização está no mês referência e a data de
    --desligamento é superior mês referência, então se verifica a quantidade
    --de dias trabalhados pelo terceirizado.
  
    IF (vDataInicio >= pDataInicio 
        AND vDataInicio <= pDataFim
        AND vDataFim > pDataFim) THEN
    
      RETURN (pDataFim - vDataInicio) + 1;
    
    END IF;
    
    --Se a data de disponibilização está no mês referência e também a data de
    --desligamento, então contam-se os dias trabalhados pelo terceirizado.
    
    IF (vDataInicio >= pDataInicio 
        AND vDataInicio <= pDataFim
        AND vDataFim >= pDataInicio
        AND vDataFim <= pDataFim) THEN
  
      RETURN (vDataFim - vDataInicio) + 1;
    
    END IF;
    
    --Se a data da disponibilização for inferior ao mês de cálculo e 
    --o terceirizado tiver desligamento no mês referência, então contam-se
    --os dias trabalhados.
    
    IF (vDataInicio < pDataInicio 
        AND vDataFim >= pDataInicio
        AND vDataFim <= pDataFim) THEN
    
      RETURN (vDataFim - pDataInicio) + 1;
    
    END IF;
 
  END IF;
  
  EXCEPTION WHEN OTHERS THEN

    RETURN NULL;  

END;