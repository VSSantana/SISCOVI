create or replace function "F_FUNC_RETENCAO_INTEGRAL"(pCodFuncaoTerceirizado NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS

--Função que retorna se um terceirizado trabalhou período integral (30 dias)
--ou não em um determinado mês.

  vDataInicio DATE;
  vDataFim DATE;
  vDataReferencia DATE;
  vCodTerceirizadoContrato NUMBER;
  vContagemDeDias NUMBER := 0;

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

    DECLARE 

            --Cursor com todas as datas de início do mês referência.
    
            CURSOR d1 IS SELECT ft.data_inicio AS data_inicio
                           FROM tb_funcao_terceirizado ft
                           WHERE ft.cod_terceirizado_contrato = vCodTerceirizadoContrato
                             AND ((EXTRACT(MONTH FROM ft.data_inicio) = pMes
                                   AND
                                   EXTRACT (YEAR FROM ft.data_inicio) = pAno)
                                  OR
                                  (EXTRACT(MONTH FROM ft.data_fim) = pMes
                                   AND
                                   EXTRACT (YEAR FROM ft.data_fim) = pAno))
                         ORDER BY 1 ASC;

            --Cursor com todas as datas de fim do mês referência.

            CURSOR d2 IS SELECT ft.data_fim AS data_fim
                           FROM tb_funcao_terceirizado ft
                           WHERE ft.cod_terceirizado_contrato = vCodTerceirizadoContrato
                             AND ((EXTRACT(MONTH FROM ft.data_inicio) = pMes
                                   AND
                                   EXTRACT (YEAR FROM ft.data_inicio) = pAno)
                                  OR
                                  (EXTRACT(MONTH FROM ft.data_fim) = pMes
                                   AND
                                   EXTRACT (YEAR FROM ft.data_fim) = pAno))
                         ORDER BY 1 ASC;
                          
    BEGIN

      OPEN d1;
      OPEN d2;

      --Contagem dos dias trabalhados no mês.

      FOR i IN d1 LOOP

        vDataInicio := i.data_inicio;
         
        FETCH d2 INTO vDataFim;

        IF (vDataInicio < vDataReferencia) THEN

          vDataInicio := vDataReferencia;

        END IF;

        IF (vDataFim IS NULL OR vDataFim > LAST_DAY(vDataReferencia)) THEN

          vDataFim := LAST_DAY(vDataReferencia);

        END IF;

        vContagemDeDias := vContagemDeDias + ((vDataFim - vDataInicio) + 1);

      END LOOP;
      
      IF (vContagemDeDias >= 30) THEN

        RETURN TRUE;

      END IF;
    
    END; 

  END IF;

  RETURN FALSE;  

END;
