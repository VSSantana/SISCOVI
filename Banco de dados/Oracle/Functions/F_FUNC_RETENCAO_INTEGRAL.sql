create or replace function "F_FUNC_RETENCAO_INTEGRAL"(pCodFuncaoTerceirizado NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS

--Função que retorna se um terceirizado trabalhou período igual ou superior a 15
--dias em um determinado mês.

  vDataInicio DATE;
  vDataFim DATE;
  vDataReferencia DATE;
  vCodTerceirizadoContrato NUMBER;

BEGIN

  --Define como data referência o primeiro dia do mês e ano passados como argumentos.

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy');

  --Carrega o cod_terceirizado_contrato.
 
  SELECT cod_terceirizado_contrato
    INTO vCodTerceirizadoContrato
    FROM tb_funcao_terceirizado
  	WHERE cod = pCodFuncaoTerceirizado;

  --Carregamento das datas de disponibilização e desligamento do terceirizado.

  IF (F_EXISTE_MUDANCA_FUNCAO (vCodTerceirizadoContrato, pMes, pAno) = FALSE) THEN

    SELECT data_inicio,
           data_fim
      INTO vDataInicio,
           vDataFim
      FROM tb_funcao_terceirizado ft
      WHERE ft.cod_terceirizado_contrato = vCodTerceirizadoContrato
      AND (((TO_DATE('01/' || EXTRACT(month FROM ft.data_inicio) || '/' || EXTRACT(year FROM ft.data_inicio), 'dd/mm/yyyy') <= TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy'))
           AND 
           (ft.data_fim >= TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy')))
           OR
           ((TO_DATE('01/' || EXTRACT(month FROM ft.data_inicio) || '/' || EXTRACT(year FROM ft.data_inicio), 'dd/mm/yyyy') <= TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy'))
            AND
            (ft.data_fim IS NULL)));

    --Caso não possua data de desligamento.  

    IF (vDataFim IS NULL) THEN
  
      --Se a data de disponibilização é inferior a data referência então o
      --funcionário trabalhou os 30 dias do mês referência.
  
      IF (vDataInicio < vDataReferencia) THEN
      
       RETURN TRUE;
      
      END IF;
    
      --Se a data de disponibilização está no mês referência então se verifica
      --a quantidade de dias trabalhados pelo funcionário.
  
     IF (vDataInicio >= vDataReferencia AND vDataInicio <= LAST_DAY(vDataReferencia)) THEN

        IF (((LAST_DAY(vDataInicio) - vDataInicio) + 1) >= 30) THEN
  
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
    
        IF (((LAST_DAY(vDataInicio) - vDataInicio) + 1) >= 30) THEN
  
          RETURN TRUE;
    
        END IF;
    
      END IF;
    
      --Se a data de disponibilização está no mês referência e também a data de
      --desligamento, então contam-se os dias trabalhados pelo funcionário.

      IF (vDataInicio >= vDataReferencia 
         AND vDataInicio <= LAST_DAY(vDataReferencia)
         AND vDataFim >= vDataReferencia
         AND vDataFim <= LAST_DAY(vDataReferencia)) THEN
    
        IF (((vDataFim - vDataInicio) + 1) >= 30) THEN
  
          RETURN TRUE;
    
        END IF;
    
      END IF;
    
      --Se a data da disponibilização for inferior ao mês de cálculo e 
      --o funcionário tiver desligamento no mês referência, então contam-se
      --os dias trabalhados.
    
      IF (vDataInicio < vDataReferencia 
          AND vDataFim >= vDataReferencia
          AND vDataFim <= LAST_DAY(vDataReferencia)) THEN
    
        IF (((vDataFim - vDataReferencia) + 1) >= 30) THEN
  
          RETURN TRUE;
    
        END IF;
    
      END IF;
 
    END IF;

  ELSE

      SELECT data_inicio
        INTO vDataInicio     
        FROM tb_funcao_terceirizado ft
        WHERE ft.cod_terceirizado_contrato = vCodTerceirizadoContrato
          AND data_fim = (SELECT MIN(data_fim)
                            FROM tb_funcao_terceirizado
                            WHERE cod_terceirizado_contrato = vCodTerceirizadoContrato
                              AND EXTRACT(month FROM data_fim) = pMes
                              AND EXTRACT(year FROM data_fim) = pAno);

      SELECT data_fim
        INTO vDataFim     
        FROM tb_funcao_terceirizado ft
        WHERE ft.cod_terceirizado_contrato = vCodTerceirizadoContrato
          AND data_inicio = (SELECT MAX(data_inicio)
                               FROM tb_funcao_terceirizado
                               WHERE cod_terceirizado_contrato = vCodTerceirizadoContrato
                                 AND EXTRACT(month FROM data_inicio) = pMes
                                 AND EXTRACT(year FROM data_inicio) = pAno);

    END IF;
    
  
   
  

  RETURN FALSE;  

END;
