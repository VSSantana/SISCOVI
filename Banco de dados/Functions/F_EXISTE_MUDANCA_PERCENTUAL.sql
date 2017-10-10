create or replace function "F_EXISTE_MUDANCA_PERCENTUAL"(pCodContrato NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS
  
--Função que retorna se em um dado mês existe ao menos um caso
--de mudança de percentual que enseje dupla vigência.  
  
  vCount NUMBER := 0;
 
BEGIN
  
  --Conta o número de percentuais da mesma rubrica vigentes no mês.
  
  SELECT COUNT(pc.cod)
    INTO vCount
    FROM tb_percentual_contrato pc
      JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
    WHERE pc.cod_contrato = pCodContrato
      AND ((EXTRACT(month FROM pc.data_inicio) = pMes AND EXTRACT(year FROM pc.data_inicio) = pAno)
           OR
           (EXTRACT(month FROM pc.data_fim) = pMes AND EXTRACT(year FROM pc.data_fim) = pAno));

  IF (vCount IS NOT NULL) THEN
  
    --Se houver qualquer número de percentuais da mesma rubrica no mês passado retorna VERDADEIRO.
  
    IF (vCount > 0) THEN

      RETURN TRUE;

    ELSE

      RETURN FALSE;

    END IF;

  END IF;

  RETURN FALSE;
  
  EXCEPTION WHEN OTHERS THEN
  
    RETURN NULL;

END;