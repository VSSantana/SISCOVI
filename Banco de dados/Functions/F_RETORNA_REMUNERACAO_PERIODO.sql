create or replace function "F_RETORNA_REMUNERACAO_PERIODO"(pCodCargoContrato NUMBER, pDataInicio DATE, pDataFim DATE) RETURN FLOAT
IS

--Função que recupera o valor da remuneração vigente para o cargo de um
--contrato em uma determinada perído em dupla vigência de convenção.

  vRemuneracao FLOAT := 0;

BEGIN

  SELECT remuneracao 
    INTO vRemuneracao
    FROM tb_convencao_coletiva 
    WHERE cod_cargo_contrato = pCodCargoContrato 
	  AND data_aditamento IS NOT NULL
      AND ((TRUNC(data_inicio_convencao) <= TRUNC(pDataInicio))
	       AND
		   (TRUNC(data_inicio_convencao) <= TRUNC(pDataFim)))
      AND (((TRUNC(data_fim_convencao) >= TRUNC(pDataInicio))
		   AND 
		   (TRUNC(data_fim_convencao) >= TRUNC(pDataFim)))
		   OR data_fim_convencao IS NULL);

  RETURN vRemuneracao;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;

END;