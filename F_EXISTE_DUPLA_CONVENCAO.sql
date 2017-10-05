create or replace function "F_EXISTE_DUPLA_CONVENCAO"(pCodCargoContrato NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS
  
--Função que retorna se em um dado mês existe um caso de cálculo parcial
--por existirem duas convenções vigentes no mesmo mês.  
  
  vCount NUMBER;
 
BEGIN
  
  --Conta o número de convenções vigentes no mês.
  
  SELECT COUNT(cod)
    INTO vCount
    FROM tb_convencao_coletiva
    WHERE data_aditamento IS NOT NULL
      AND cod_cargo_contrato = pCodCargoContrato
      AND (((EXTRACT(month FROM data_convencao) = pMes AND EXTRACT(year FROM data_convencao) = pAno)
           AND
           (EXTRACT(month FROM data_aditamento) = pMes AND EXTRACT(year FROM data_aditamento) = pAno))
           OR
           ((EXTRACT(month FROM F_ULTIMO_DIA_CONVENCAO(cod)) = pMes AND EXTRACT(year FROM F_ULTIMO_DIA_CONVENCAO(cod)) = pAno)
           AND
           (EXTRACT(month FROM F_ULTIMO_DIA_CONVENCAO(cod)) = pMes AND EXTRACT(year FROM F_ULTIMO_DIA_CONVENCAO(cod)) = pAno)));

  IF (vCount IS NOT NULL) THEN
  
    --Se houverem duas convenções no mês passado retorna VERDADEIRO.
  
    IF (vCount = 2) THEN

      RETURN TRUE;

    ELSE

      RETURN FALSE;

    END IF;

  END IF;

  RETURN FALSE;
  
  EXCEPTION WHEN OTHERS THEN
  
    RETURN NULL;

END;
