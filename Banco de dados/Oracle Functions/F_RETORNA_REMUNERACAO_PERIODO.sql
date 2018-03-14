create or replace function "F_RETORNA_REMUNERACAO_PERIODO"(pCodCargoContrato NUMBER, pMes NUMBER, pAno NUMBER, pOperacao NUMBER, pRetroatividade NUMBER) RETURN FLOAT
IS

--Função que recupera o valor da remuneração vigente para o cargo de um
--contrato em uma determinada perído em dupla vigência de convenção.

  vRemuneracao FLOAT := 0;
  vDataReferencia DATE;
  vCodContrato NUMBER;
  vCodConvencao NUMBER;
  vRetroatividade BOOLEAN := FALSE;
  vDataAditamento DATE;
  

  --Operação 1: Remuneração do mês em que não há dupla vigência ou remuneração atual. 
  --Operação 2: Remuneração encerrada do mês em que há dupla vigência.
  --pRetroatividade 1: Considera a retroatividade.
  --pRetroatividade 2: Desconsidera os períodos de retroatividade.

BEGIN

  --Definição do cod_contrato.
  
  SELECT cod_contrato
    INTO vCodContrato
    FROM tb_cargo_contrato
    WHERE cod = pCodCargoContrato;   

  --Definição sobre a consideração da retroatividade.
  
  IF (pRetroatividade = 1) THEN
  
    vRetroatividade := F_EXISTE_RETROATIVIDADE(vCodContrato, pCodCargoContrato, pMes, pAno, 1);
    
  END IF;

  --Definição da data referência.

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy'); 

  --Definição do percentual.

  IF (pOperacao = 1) THEN

    SELECT remuneracao, cod, data_aditamento
      INTO vRemuneracao, vCodConvencao, vDataAditamento
      FROM tb_convencao_coletiva 
      WHERE cod_cargo_contrato = pCodCargoContrato 
	    AND data_aditamento IS NOT NULL
        AND TRUNC(data_aditamento) <= TRUNC(SYSDATE)
        AND ((((TRUNC(data_inicio_convencao) <= TRUNC(vDataReferencia))
	         AND
	  	     (TRUNC(data_inicio_convencao) <= TRUNC(LAST_DAY(vDataReferencia))))
        AND (((TRUNC(data_fim_convencao) >= TRUNC(vDataReferencia))
		     AND 
		     (TRUNC(data_fim_convencao) >= TRUNC(LAST_DAY(vDataReferencia)))
		      OR data_fim_convencao IS NULL)))
             OR (EXTRACT(month FROM data_inicio_convencao) = EXTRACT(month FROM vDataReferencia) --Ou início no mês referência.
               AND EXTRACT(year FROM data_inicio_convencao) = EXTRACT(year FROM vDataReferencia)));
     
  END IF;
  
  IF (pOperacao = 2) THEN

    SELECT remuneracao 
      INTO vRemuneracao
      FROM tb_convencao_coletiva 
      WHERE cod_cargo_contrato = pCodCargoContrato 
	    AND data_aditamento IS NOT NULL
        AND (EXTRACT(month FROM data_fim_convencao) = EXTRACT(month FROM vDataReferencia) --Ou início no mês referência.
             AND EXTRACT(year FROM data_fim_convencao) = EXTRACT(year FROM vDataReferencia));

  END IF;
  
  
  
  IF (pOperacao = 1 AND vRetroatividade = TRUE) THEN
  
    vCodConvencao := F_RETORNA_CONVENCAO_ANTERIOR(vCodConvencao);
    
    SELECT remuneracao
      INTO vRemuneracao
      FROM tb_convencao_coletiva
      WHERE cod = vCodConvencao;
  
  END IF;

  RETURN vRemuneracao;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    IF (pOperacao = 1 AND pRetroatividade = 1) THEN
    
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(pCodCargoContrato, pMes, pAno, 2, 1);
      
      RETURN vRemuneracao;
      
    END IF;
    
    IF (pOperacao = 1 AND pRetroatividade = 2) THEN
    
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(pCodCargoContrato, pMes, pAno, 2, 2);
      
      RETURN vRemuneracao;
    
    ELSE
    
      RETURN NULL;
      
    END IF;  

END;