create or replace function "F_FUNC_RETENCAO_INTEGRAL"(pCodCargoFuncionario NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS

--Função que retorna se um funcionário trabalhou período igual ou superior a 30
--dias em um determinado mês.

  vDataDisponibilizacao DATE;
  vDataDesligamento DATE;
  vDataReferencia DATE;

BEGIN

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy');
 
  SELECT data_disponibilizacao, 
         data_desligamento
    INTO vDataDisponibilizacao,
	     vDataDesligamento
    FROM tb_cargo_funcionario
	WHERE cod = pCodCargoFuncionario;
    
  --Caso não possua data de desligamento.  
   
  IF (vDataDesligamento IS NULL) THEN
  
    --Se a data de disponibilização é inferior a data referência então o
    --funcionário trabalhou os 30 dias do mês referência.
  
    IF (vDataDisponibilizacao < vDataReferencia) THEN
      
      RETURN TRUE;
      
    END IF;
    
    --Se a data de disponibilização está no mês referência enão se verifica
    --a quantidade de dias trabalhados pelo funcionário.
  
    IF (vDataDisponibilizacao >= vDataReferencia AND vDataDisponibilizacao <= LAST_DAY(vDataReferencia)) THEN
    
      IF (LAST_DAY(vDataDisponibilizacao) - vDataDisponibilizacao + 1 >= 15) THEN
  
        RETURN TRUE;
    
      END IF;
    
    END IF;
 
  END IF;
  
  --Caso possua data de desligamento.
  
  IF (vDataDesligamento IS NOT NULL) THEN
  
    --Se a data de disponibilização é inferior a data referência e a data de 
    --desligamento é superior ao último dia do mês referência então o
    --funcionário trabalhou os 30 dias.
  
    IF (vDataDisponibilizacao < vDataReferencia AND vDataDesligamento > LAST_DAY(vDataReferencia)) THEN
      
      RETURN TRUE;
      
    END IF;  
    
    --Se a data de disponibilização está no mês referência e a data de
    --desligamento é superior mês referência, então se verifica a quantidade
    --de dias trabalhados pelo funcionário.
  
    IF (vDataDisponibilizacao >= vDataReferencia 
        AND vDataDisponibilizacao <= LAST_DAY(vDataReferencia)
        AND vDataDesligamento > LAST_DAY(vDataReferencia)) THEN
    
      IF (LAST_DAY(vDataDisponibilizacao) - vDataDisponibilizacao + 1 >= 15) THEN
  
        RETURN TRUE;
    
      END IF;
    
    END IF;
    
    --Se a data de disponibilização está no mês referência e também a data de
    --desligamento, então contam-se os dias trabalhados pelo funcionário.
    
    IF (vDataDisponibilizacao >= vDataReferencia 
        AND vDataDisponibilizacao <= LAST_DAY(vDataReferencia)
        AND vDataDesligamento >= vDataReferencia
        AND vDataDesligamento <= LAST_DAY(vDataReferencia)) THEN
    
      IF (vDataDesligamento - vDataDisponibilizacao + 1 >= 15) THEN
  
        RETURN TRUE;
    
      END IF;
    
    END IF;
    
    --Se a data da disponibilização for inferior ao mês de cálculo e 
    --o funcionário tiver desligamento no mês referência, então contam-se
    --os dias trabalhados.
    
    IF (vDataDisponibilizacao < vDataReferencia 
        AND vDataDesligamento >= vDataReferencia
        AND vDataDesligamento <= LAST_DAY(vDataReferencia)) THEN
    
      IF (vDataDesligamento - vDataReferencia + 1 >= 15) THEN
  
        RETURN TRUE;
    
      END IF;
    
    END IF;
 
  END IF;

  RETURN FALSE;  

END;
