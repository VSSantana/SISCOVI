create or replace function "F_EXISTE_RETROATIVIDADE" (pCodContrato NUMBER, pCodCargoContrato NUMBER, pMes NUMBER, pAno NUMBER, pOperacao NUMBER) RETURN BOOLEAN
IS

  --Função que retorna se em um determinado mês existe situação de retroatividade.
  --pOperacao = 1 - Retroatividade para convenção.
  --pOperacao = 2 - Retroatividade para percentual.

  vRetroatividade NUMBER := 0;
  vDataReferencia DATE;

BEGIN

  --Definição da data referência.
  
  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy'); 
    
  IF (pOperacao = 1) THEN

    --Verifica se o mês se encontra dentro de um período de retroatividade.

    SELECT COUNT(cod)
      INTO vRetroatividade
      FROM tb_retroatividade_convencao
      WHERE cod_cargo_contrato = pCodCargoContrato
        AND TRUNC(vDataReferencia) >= TRUNC(LAST_DAY(ADD_MONTHS(inicio, -1)) + 1)
        AND TRUNC(vDataReferencia) <= TRUNC(fim);  
            
            

  END IF;
  
  IF (pOperacao = 2) THEN
  
    SELECT COUNT(rp.cod)
      INTO vRetroatividade
      FROM tb_retroatividade_percentual rp
        JOIN tb_percentual_contrato pc ON pc.cod = rp.cod_percentual_contrato
      WHERE pc.cod_contrato = pCodContrato
        AND TRUNC(vDataReferencia) >= TRUNC(LAST_DAY(ADD_MONTHS(inicio, -1)) + 1)
        AND TRUNC(vDataReferencia) <= TRUNC(fim);  
  
  END IF;

  IF (vRetroatividade = 1) THEN

    RETURN TRUE;

  ELSE

    RETURN FALSE;

  END IF;

  EXCEPTION WHEN NO_DATA_FOUND THEN

    RETURN NULL;
  
END;
