create or replace function "F_RETORNA_REMUNERACAO_PERIODO"(pCodCargoContrato NUMBER, pMes NUMBER, pAno NUMBER, pOperacao NUMBER) RETURN FLOAT
IS

--Função que recupera o valor da remuneração vigente para o cargo de um
--contrato em uma determinada perído em dupla vigência de convenção.

  vRemuneracao FLOAT := 0;
  vDataReferencia DATE;

  --Operação 1: Percentual do mês em que não há dupla vigência ou percentual atual. 
  --Operação 2: Percentual encerrado do mês em que há dupla vigência.

BEGIN

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy'); 

  --Definição do percentual.

  IF (pOperacao = 1) THEN

    SELECT remuneracao 
      INTO vRemuneracao
      FROM tb_convencao_coletiva 
      WHERE cod_cargo_contrato = pCodCargoContrato 
	    AND data_aditamento IS NOT NULL
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

  RETURN vRemuneracao;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;

END;