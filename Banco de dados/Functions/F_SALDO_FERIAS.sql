create or replace function "F_SALDO_FERIAS" (pCodContrato NUMBER, pCodCargoFuncionario NUMBER, pDataInicio DATE, pDataFim DATE) RETURN NUMBER
IS

  --Função que retorna o número de dias que um funcionários
  --possui em um determinado período aquisitivo, descontados
  --aqueles usufruídos.

  vDiasUsufruidos NUMBER := 0;
  vDiasAUsufruir NUMBER := 0;
  vSaldoDeFerias NUMBER := 0;
  vNumeroMeses NUMBER := 0;
  vMesesFerias NUMBER := 0;
  vDataContagem DATE := pDataInicio;

BEGIN

  SELECT SUM(data_fim_usufruto - data_inicio_usufruto + dias_vendidos + 1)
    INTO vDiasUsufruidos
    FROM tb_restituicao_ferias
    WHERE cod_cargo_funcionario = pCodCargoFuncionario
      AND data_inicio_periodo_aquisitivo = pDataInicio
      AND data_fim_periodo_aquisitivo = pDataFim;
      
  --Caso ainda não tenha usufruído nenhum dia é atribuído zero.
  --Peculiaridades do PL\SQL.
      
  IF (vDiasUsufruidos IS NULL) THEN
  
    vDiasUsufruidos := 0;
    
  END IF;

  vNumeroMeses := F_RETORNA_NUMERO_DE_MESES(pDataInicio, pDataFim);

  FOR i IN 1 .. vNumeroMeses LOOP

    IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, EXTRACT(month FROM vDataContagem), EXTRACT(year FROM vDataContagem)) = TRUE) THEN
  
      vMesesFerias := vMesesFerias + 1;
    
    END IF;
    
    vDataContagem := ADD_MONTHS(vDataContagem, 1);
  
  END LOOP;

  vDiasAUsufruir := 2.5 * vMesesFerias;

  vSaldoDeFerias := vDiasAUsufruir - vDiasUsufruidos;

  IF (vSaldoDeFerias < 0) THEN

    RETURN 0;

  END IF;

  RETURN vSaldoDeFerias;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;

END;
