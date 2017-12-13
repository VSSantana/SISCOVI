create or replace function "F_RETORNA_PERCENTUAL_PERIODO" (pCodContrato NUMBER, pRubrica VARCHAR2, pMes NUMBER, pAno NUMBER, pOperacao NUMBER, pRetroatividade NUMBER) RETURN FLOAT
IS

--O período passado deve ser exato, não podendo compreender
--aquele em que há dupla vigência.

  vPercentual FLOAT;
  vCodPercentual NUMBER;
  vRetroatividade BOOLEAN := FALSE;
  vDataReferencia DATE;
  vRetroatividadePercentual NUMBER := 0;
  
  
  --pOperação = 1: Percentual do mês em que não há dupla vigência ou percentual atual. 
  --pOperação = 2: Percentual encerrado do mês em que há dupla vigência.
  --pRetroatividade = 1: Leva em consideração a retroatividade (funcionamento normal).
  --pRetroatividade = 2: Desconsidera a retroatividade para realizar o cálculo desta.

BEGIN

  --Definição sobre a consideração da retroatividade.
  
  IF (pRetroatividade = 1) THEN
  
    vRetroatividade := F_EXISTE_RETROATIVIDADE(pCodContrato, NULL, pMes, pAno, 2);
    
  END IF;
  
  --Definição da data referência.

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy'); 
  
  --Verificação de se a retroatividade está ligada ao percentual designado.
  
  IF (vRetroatividade = TRUE) THEN
  
    SELECT COUNT(rp.cod)
      INTO vRetroatividadePercentual
      FROM tb_retroatividade_percentual rp
        JOIN tb_percentual_contrato pc ON pc.cod = rp.cod_percentual_contrato
        JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
      WHERE pc.cod_contrato = pCodContrato
        AND UPPER(r.nome) = UPPER(pRubrica)
        AND TRUNC(vDataReferencia) >= TRUNC(LAST_DAY(ADD_MONTHS(rp.inicio, -1)) + 1)
        AND TRUNC(vDataReferencia) <= TRUNC(rp.fim);
        
    IF (vRetroatividadePercentual = 0) THEN
    
      vRetroatividade := FALSE;
    
    END IF;
  
  END IF;

  --Definição do percentual.

  IF (pOperacao = 1) THEN

    SELECT pc.percentual, pc.cod
      INTO vPercentual, vCodPercentual
      FROM tb_percentual_contrato pc
        JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
      WHERE pc.cod_contrato = pCodContrato --Contrato.
        AND UPPER(r.nome) = UPPER(pRubrica) --Rubrica.
        AND pc.data_aditamento IS NOT NULL --Aditamento.
        AND TRUNC(data_aditamento) <= TRUNC(SYSDATE)
        AND ((((TRUNC(pc.data_inicio) <= TRUNC(vDataReferencia)) --Início em mês anterior.
	         AND
		     (TRUNC(pc.data_inicio) <= TRUNC(LAST_DAY(vDataReferencia)))) --Início menor que o último dia do mês referência.
        AND (((TRUNC(pc.data_fim) >= TRUNC(vDataReferencia)) --Fim maior que a data referência.
	  	     AND 
		     (TRUNC(pc.data_fim) >= TRUNC(LAST_DAY(vDataReferencia)))) --Fim maior ou igual ao último dia do mês.
		      OR pc.data_fim IS NULL)) --Ou fim nulo.
             OR (EXTRACT(month FROM data_inicio) = EXTRACT(month FROM vDataReferencia) --Ou início no mês referência.
             AND EXTRACT(year FROM data_inicio) = EXTRACT(year FROM vDataReferencia)));

  END IF;
  
  IF (pOperacao = 2) THEN

    SELECT pc.percentual
      INTO vPercentual 
      FROM tb_percentual_contrato pc
        JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
      WHERE pc.cod_contrato = pCodContrato --Contrato.
        AND UPPER(r.nome) = UPPER(pRubrica) --Rubrica.
        AND pc.data_aditamento IS NOT NULL --Aditamento.
        AND (EXTRACT(month FROM data_fim) = EXTRACT(month FROM vDataReferencia) --Fim no mês referência.
             AND EXTRACT(year FROM data_fim) = EXTRACT(year FROM vDataReferencia));

  END IF;
  
  IF (pOperacao = 1 AND vRetroatividade = TRUE) THEN
  
    vCodPercentual := F_RETORNA_PERCENTUAL_ANTERIOR(vCodPercentual);
    
    SELECT percentual
      INTO vPercentual
      FROM tb_percentual_contrato
      WHERE cod = vCodPercentual;
  
  END IF;

  RETURN vPercentual;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    IF(pOperacao = 2 AND pRetroatividade = 1) THEN
    
      vPercentual := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, pRubrica, pMes, pAno, 1, 1);
      
      RETURN vPercentual;
      
    END IF;
        
    IF (pOperacao = 1 AND pRetroatividade = 1) THEN
      
      vPercentual := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, pRubrica, pMes, pAno, 2, 1);
      
      RETURN vPercentual;
      
    END IF;
    
    IF(pOperacao = 2 AND pRetroatividade = 2) THEN
    
      vPercentual := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, pRubrica, pMes, pAno, 1, 2);
      
      RETURN vPercentual;
      
    END IF;
        
    IF (pOperacao = 1 AND pRetroatividade = 2) THEN
      
      vPercentual := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, pRubrica, pMes, pAno, 2, 2);
      
      RETURN vPercentual;
      
    ELSE
    
      RETURN NULL;
    
    END IF;

END;