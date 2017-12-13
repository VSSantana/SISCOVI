create or replace function "F_EXISTE_DUPLO_PERCENTUAL"(pCodContrato NUMBER, pRubrica VARCHAR2, pMes NUMBER, pAno NUMBER, pRetroatividade NUMBER) RETURN BOOLEAN
IS
  
  --Função que retorna se em um dado mês existe um caso de cálculo parcial
  --por existirem dois percentuais da mesma rubrica vigentes no mesmo mês.
  
  --pRetroatividade = 1 - Considera a retroatividade.
  --pRetroatividade = 2 - Desconsidera a retroatividade.
  
  vCount NUMBER;
  vRetroatividade BOOLEAN := FALSE;
 
BEGIN

  --Definição do modo de funcionamento da função.
  
  IF (pRetroatividade = 1) THEN
  
    vRetroatividade := F_EXISTE_RETROATIVIDADE(pCodContrato, NULL, pMes, pAno, 2);
  
  END IF;

  --Conta o número de percentuais da mesma rubrica vigentes no mês.
  
  SELECT COUNT(pc.cod)
    INTO vCount
    FROM tb_percentual_contrato pc
      JOIN tb_rubricas r ON r.cod = pc.cod_rubrica
    WHERE pc.cod_contrato = pCodContrato
      AND data_aditamento IS NOT NULL
      AND UPPER(r.nome) = UPPER(pRubrica)
      AND (((EXTRACT(month FROM pc.data_inicio) = pMes AND EXTRACT(year FROM pc.data_inicio) = pAno)
           AND
           (EXTRACT(month FROM data_aditamento) = pMes AND EXTRACT(year FROM data_aditamento) = pAno)
           AND 
           (TRUNC(data_aditamento) <= TRUNC(SYSDATE))) --Define a validade da convenção. 
           OR
           (EXTRACT(month FROM pc.data_fim) = pMes AND EXTRACT(year FROM pc.data_fim) = pAno));
           
  IF (vCount IS NOT NULL) THEN
  
    --Se houverem dois percentuais da mesma rubrica no mês passado retorna VERDADEIRO.
  
    IF (vCount = 2 AND vRetroatividade = FALSE) THEN

      RETURN TRUE;

    ELSE

      RETURN FALSE;

    END IF;

  END IF;

  RETURN FALSE;
  
  EXCEPTION WHEN OTHERS THEN
  
    RETURN NULL;

END;
