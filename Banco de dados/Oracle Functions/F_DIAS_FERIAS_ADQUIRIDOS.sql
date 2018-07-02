create or replace function "F_DIAS_FERIAS_ADQUIRIDOS" (pCodContrato NUMBER, pCodTerceirizadoContrato NUMBER, pDataInicio DATE, pDataFim DATE) RETURN NUMBER
IS

  --Função que retorna o número de dias que um terceirizado
  --possui em um determinado período aquisitivo.

  vDiasAUsufruir NUMBER := 0;
  vNumeroMeses NUMBER := 0;
  vCodTerceirizado NUMBER := 0;
  vMesesFerias NUMBER := 0;
  vDataContagem DATE := pDataInicio;

BEGIN

  --Seleciona o cod do terceirizado.

  SELECT cod_terceirizado
    INTO vCodTerceirizado
    FROM tb_terceirizado_contrato
    WHERE cod = pCodTerceirizadoContrato;

  --Conta o número de meses dentro do período aquisitivo para o loop.

  vNumeroMeses := F_RETORNA_NUMERO_DE_MESES(pDataInicio, pDataFim);

  --Calcula o número de dias baseado no número de meses trabalhados com mais de 15 dias.

  FOR i IN 1 .. vNumeroMeses LOOP

    IF (F_DIAS_TRABALHADOS_TERC(pCodTerceirizadoContrato, EXTRACT(month FROM vDataContagem), EXTRACT(year FROM vDataContagem)) >= 15) THEN
  
      vMesesFerias := vMesesFerias + 1;
    
    END IF;
    
    vDataContagem := ADD_MONTHS(vDataContagem, 1);
  
  END LOOP;
  
  --Para controlar possíveis casos de cálculo de 13 meses de férias.
  
  IF (vMesesFerias >= 13) THEN
  
    vMesesFerias := 12;
  
  END IF;

  --A cada mês de trabalho o funcionário adquire 2.5 dias de férias,
  --considerando um período de 12 meses, óbviamente.

  vDiasAUsufruir := 2.5 * vMesesFerias;

  RETURN vDiasAUsufruir;
  
  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;

END;
