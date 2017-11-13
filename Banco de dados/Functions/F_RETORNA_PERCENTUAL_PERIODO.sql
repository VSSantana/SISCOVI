create or replace function "F_RETORNA_PERCENTUAL_PERIODO" (pCodContrato NUMBER, pRubrica VARCHAR2, pMes NUMBER, pAno NUMBER, pOperacao NUMBER) RETURN FLOAT
IS

--O período passado deve ser exato, não podendo compreender
--aquele em que há dupla vigência.

  vPercentual FLOAT;
  vCodPercentual NUMBER;
  vDataReferencia DATE;
  
  --Operação 1: Percentual do mês em que não há dupla vigência ou percentual atual. 
  --Operação 2: Percentual encerrado do mês em que há dupla vigência.

BEGIN

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy'); 

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
  
  IF (pOperacao = 1 AND F_EXISTE_RETROATIVIDADE(pCodContrato, NULL, pMes, pAno, 2) = TRUE) THEN
  
    vCodPercentual := F_RETORNA_PERCENTUAL_ANTERIOR(vCodPercentual);
    
    SELECT percentual
      INTO vPercentual
      FROM tb_percentual_contrato
      WHERE cod = vCodPercentual;
  
  END IF;

  RETURN vPercentual;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    IF(pOperacao = 2) THEN
    
      vPercentual := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, pRubrica, pMes, pAno, 1);
      
      RETURN vPercentual;
      
    END IF;
        
    IF (pOperacao = 1) THEN
      
      vPercentual := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, pRubrica, pMes, pAno, 2);
      
      RETURN NULL;
      
    ELSE
    
      RETURN NULL;
    
    END IF;

END;