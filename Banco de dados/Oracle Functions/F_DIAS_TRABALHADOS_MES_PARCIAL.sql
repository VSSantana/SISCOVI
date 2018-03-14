create or replace function "F_DIAS_TRABALHADOS_MES_PARCIAL"(pCodCargoContrato NUMBER, pCodCargoFuncionario NUMBER, pMes NUMBER, pAno NUMBER, pOperacao NUMBER) RETURN NUMBER
IS

--Função que retorna o número de dias que um funcionário
--trabalhou em determinado período do mês.

  vRetorno NUMBER := 0;
  vDataReferencia DATE;
  vDataInicio DATE;
  vDataFim DATE;
  vCodContrato NUMBER;
  vDataDisponibilizacao DATE;
  vDataDesligamento DATE;
  
  --Operação 1: Primeira metade da convenção.
  --Operação 2: Segunda metade da convenção.
  --Operação 3: Primeira metade do percentual.
  --Operação 4: Segunda metade do percentual.

BEGIN

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy');
  
  SELECT cod_contrato
    INTO vCodContrato
    FROM tb_cargo_contrato
    WHERE cod = pCodCargoContrato;

  SELECT data_disponibilizacao, 
         data_desligamento
    INTO vDataDisponibilizacao,
	       vDataDesligamento
    FROM tb_cargo_funcionario
	WHERE cod = pCodCargoFuncionario;
  
  --Primeira metade da convenção (a convenção anterior tem data fim naquele mês).
   
  IF (pOperacao = 1) THEN
  
    SELECT data_fim_convencao,
           vDataReferencia
      INTO vDataFim,
           vDataInicio
      FROM tb_convencao_coletiva
      WHERE data_aditamento IS NOT NULL
        AND cod_cargo_contrato = pCodCargoContrato
        AND EXTRACT(month FROM data_fim_convencao) = EXTRACT(month FROM vDataReferencia)
        AND EXTRACT(year FROM data_fim_convencao) = EXTRACT(year FROM vDataReferencia);
        
  END IF;
  
  --Segunda metade da convenção (a convenção mais recente tem data inicio naquele mês).
  
  IF (pOperacao = 2) THEN
  
    SELECT LAST_DAY(vDataReferencia),
           data_inicio_convencao
      INTO vDataFim,
           vDataInicio
      FROM tb_convencao_coletiva
      WHERE data_aditamento IS NOT NULL
        AND cod_cargo_contrato = pCodCargoContrato
        AND EXTRACT(month FROM data_inicio_convencao) = EXTRACT(month FROM vDataReferencia)
        AND EXTRACT(year FROM data_inicio_convencao) = EXTRACT(year FROM vDataReferencia);

    IF (EXTRACT(day FROM LAST_DAY(vDataFim)) = 31) THEN
  
      vDataFim := vDataFim - 1;
  
    END IF;
             
  END IF;
  
  --Primeira metade do percentual (último percentual não tem data fim).
    
  IF (pOperacao = 3) THEN
  
    SELECT MAX(pc.data_fim),
           vDataReferencia
      INTO vDataFim,
           vDataInicio
      FROM tb_percentual_contrato pc
        JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
      WHERE cod_contrato = vCodContrato
        AND pc.data_aditamento IS NOT NULL        
        AND EXTRACT(month FROM pc.data_fim) = EXTRACT(month FROM vDataReferencia)
        AND EXTRACT(year FROM pc.data_fim) = EXTRACT(year FROM vDataReferencia);
        
  END IF;
  
  --Segunda metade do percentual.
  
  IF (pOperacao = 4) THEN
  
    SELECT MIN(pc.data_inicio),
           LAST_DAY(vDataReferencia)
      INTO vDataInicio,
           vDataFim
      FROM tb_percentual_contrato pc
        JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
      WHERE cod_contrato = vCodContrato
        AND pc.data_aditamento IS NOT NULL
        AND EXTRACT(month FROM pc.data_inicio) = EXTRACT(month FROM vDataReferencia)
        AND EXTRACT(year FROM pc.data_inicio) = EXTRACT(year FROM vDataReferencia);

    --Ajuste do último dia para que o mês contenha apenas 30 dias.

    IF (EXTRACT(day FROM LAST_DAY(vDataFim)) = 31) THEN
  
      vDataFim := vDataFim - 1;
  
    END IF;
        
  END IF;

  --Definição do número de dias trabalhados para o caso de primeira metade do mês.

  IF (pOperacao IN (1,3)) THEN

    IF (vDataDesligamento IS NULL) THEN

      IF (vDataDisponibilizacao < vDataReferencia) THEN
      
        vRetorno := (vDataFim - vDataReferencia) + 1;
      
      END IF;

      IF (vDataDisponibilizacao >= vDataReferencia AND vDataDisponibilizacao <= vDataFim) THEN
  
        vRetorno := (vDataFim - vDataDisponibilizacao) + 1;
    
      END IF;

    END IF;

    IF (vDataDesligamento IS NOT NULL) THEN
  
    --Se a data de disponibilização é inferior a data referência e a data de 
    --desligamento é superior ao último dia do mês referência então o
    --funcionário trabalhou os dias entre o inicio do mes e a data fim.
  
    IF (vDataDisponibilizacao < vDataReferencia AND vDataDesligamento > vDataFim) THEN
      
      vRetorno := (vDataFim - vDataReferencia) + 1;
      
    END IF;  
    
    --Se a data de disponibilização está no mês referência e a data de
    --desligamento é superior mês referência, então se verifica a quantidade
    --de dias trabalhados pelo funcionário entre a data fim e a disponibilização.
  
    IF (vDataDisponibilizacao >= vDataReferencia 
        AND vDataDisponibilizacao <= vDataFim
        AND vDataDesligamento > vDataFim) THEN
    
      vRetorno := (vDataFim - vDataDisponibilizacao) + 1;
    
    END IF;
    
    --Se a data de disponibilização está na primeira metade do mês referência 
    --e também a data de desligamento, então contam-se os dias trabalhados 
    --pelo funcionário entre o desligamento e a disponibilização.
    
    IF (vDataDisponibilizacao >= vDataReferencia 
        AND vDataDisponibilizacao <= vDataFim
        AND vDataDesligamento >= vDataReferencia
        AND vDataDesligamento <= vDataFim) THEN
  
      vRetorno := vDataDesligamento - vDataDisponibilizacao + 1;
    
    END IF;
    
    --Se a data da disponibilização for inferior ao mês de cálculo e 
    --o funcionário tiver desligamento antes da data fim, então contam-se
    --os dias trabalhados nesse período.
    
    IF (vDataDisponibilizacao < vDataReferencia 
        AND vDataDesligamento >= vDataReferencia
        AND vDataDesligamento <= vDataFim) THEN
    
      vRetorno := vDataDesligamento - vDataReferencia + 1;
    
    END IF;
 
  END IF;

  END IF;

  --Cálculo para a segunda metade do mês.

  IF (pOperacao IN (2,4)) THEN

  IF (vDataDesligamento IS NULL) THEN

    IF (vDataDisponibilizacao < vDataReferencia) THEN
      
      vRetorno := (vDataFim - vDataInicio) + 1;
      
    END IF;

    IF (vDataDisponibilizacao >= vDataInicio AND vDataDisponibilizacao <= vDataFim) THEN
  
      vRetorno := (vDataFim - vDataDisponibilizacao) + 1;
    
    END IF;

  END IF;

  IF (vDataDesligamento IS NOT NULL) THEN
  
    --Se a data de disponibilização é inferior a data referência e a data de 
    --desligamento é superior ao último dia do mês referência então o
    --funcionário trabalhou os dias entre o início e o fim.
  
    IF (vDataDisponibilizacao < vDataReferencia AND vDataDesligamento > vDataFim) THEN
      
      vRetorno := (vDataFim - vDataInicio) + 1;
      
    END IF;  
    
    --Se a data de disponibilização é maior que a data de inicio
    --e a data de desligamento superior a data de fim então
    --conta-se o período entre data fim e data de disponibilização.
  
    IF (vDataDisponibilizacao >= vDataInicio 
        AND vDataDisponibilizacao <= vDataFim
        AND vDataDesligamento > vDataFim) THEN
    
      vRetorno := (vDataFim - vDataDisponibilizacao) + 1;
    
    END IF;
    
    --Se a data de disponibilização é maior que a data de inicio
    --e a data de desligamento inferior a data de fim e superior
    --a data de inicio então conta-se este período.
    
    IF (vDataDisponibilizacao >= vDataInicio 
        AND vDataDisponibilizacao <= vDataFim
        AND vDataDesligamento >= vDataInicio
        AND vDataDesligamento <= vDataFim) THEN
  
      vRetorno := vDataDesligamento - vDataDisponibilizacao + 1;
    
    END IF;
    
    --Se a data da disponibilização for inferior ao mês de cálculo e 
    --o funcionário tiver desligamento no mês referência, então contam-se
    --os dias trabalhados.
    
    IF (vDataDisponibilizacao < vDataInicio 
        AND vDataDesligamento >= vDataInicio
        AND vDataDesligamento <= vDataFim) THEN
    
      vRetorno := vDataDesligamento - vDataInicio + 1;
    
    END IF;
 
  END IF;

  END IF;  

  RETURN vRetorno;

END;