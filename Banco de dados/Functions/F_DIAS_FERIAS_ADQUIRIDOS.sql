create or replace function "F_DIAS_FERIAS_ADQUIRIDOS" (pCodContrato NUMBER, pCodCargoFuncionario NUMBER, pDataInicio DATE, pDataFim DATE) RETURN NUMBER
IS

  --Função que retorna o número de dias que um funcionários
  --possui em um determinado período aquisitivo.

  vDiasAUsufruir NUMBER := 0;
  vNumeroMeses NUMBER := 0;
  vCodFuncionario NUMBER := 0;
  vMesesFerias NUMBER := 0;
  vDataContagem DATE := pDataInicio;

BEGIN

  SELECT cod_funcionario
    INTO vCodFuncionario
    FROM tb_cargo_funcionario
    WHERE cod = pCodCargoFuncionario;

  vNumeroMeses := F_RETORNA_NUMERO_DE_MESES(pDataInicio, pDataFim);

  FOR i IN 1 .. vNumeroMeses LOOP

    IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, EXTRACT(month FROM vDataContagem), EXTRACT(year FROM vDataContagem)) = TRUE) THEN
  
      vMesesFerias := vMesesFerias + 1;
    
    END IF;
    
    vDataContagem := ADD_MONTHS(vDataContagem, 1);
  
  END LOOP;

  --A cada mês de trabalho o funcionário adquire 2.5 dias de férias,
  --considerando um período de 12 meses, óbviamente.

  vDiasAUsufruir := 2.5 * vMesesFerias;

  RETURN vDiasAUsufruir;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;

END;
