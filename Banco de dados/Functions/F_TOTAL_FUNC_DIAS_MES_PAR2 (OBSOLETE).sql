create or replace function "F_TOTAL_FUNC_DIAS_MES_PAR2"(pCodCargoContrato NUMBER, pDataInicio DATE, pDataFim DATE, pDias NUMBER) RETURN NUMBER
IS

--Variação que retorna no número de funcionários que trabalharam x dias no mês y
--do dia w ao z.

  vTotalFuncionarios NUMBER;
  vAux NUMBER;

BEGIN

  vAux := 0;
  vTotalFuncionarios := 0;

--Caso em que o cálculo está sendo feito dentro do período em que o funcionário começou a prestar serviço para o Tribunal
--e a data de desligamento é nula ou maior que o período de cálculo.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND TRUNC(data_disponibilizacao) >= TRUNC(pDataInicio)
      AND TRUNC(data_disponibilizacao) <= TRUNC(pDataFim)
      AND data_desligamento IS NULL
      AND (TRUNC(pDataFim) - TRUNC(data_disponibilizacao) + 1) = pDias;

  vTotalFuncionarios := vTotalFuncionarios + vAux;
  vAux := 0;

--Caso com data de desligamento no período de cálculo e data de disponibilização inferior ao período de cálculo.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND TRUNC(data_disponibilizacao) < TRUNC(pDataInicio)
      AND data_desligamento IS NOT NULL 
      AND TRUNC(data_desligamento) <= TRUNC(pDataFim)
      AND TRUNC(data_desligamento) >= TRUNC(pDataInicio)
      AND (TRUNC(data_desligamento) - TRUNC(pDataInicio) + 1) + 1 = pDias;
      
  vTotalFuncionarios := vTotalFuncionarios + vAux;
  vAux := 0;

--Caso em que o cálculo está sendo feito dentro do período em que o funcionário começou a prestar serviço para o Tribunal
--e a data de desligamento também está no mesmo período.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND TRUNC(data_disponibilizacao) >= TRUNC(pDataInicio)
      AND TRUNC(data_disponibilizacao) <= TRUNC(pDataFim)
      AND data_desligamento IS NOT NULL
      AND TRUNC(data_desligamento) <= TRUNC(pDataFim)
      AND TRUNC(data_desligamento) >= TRUNC(pDataInicio)
      AND (TRUNC(data_desligamento) - TRUNC(data_disponibilizacao) + 1) + 1 = pDias;
      
  vTotalFuncionarios := vTotalFuncionarios + vAux;
  vAux := 0;
  
--Caso em que o cálculo está sendo feito dentro do período em que o funcionário começou a prestar serviço para o Tribunal
--e a data de desligamento é nula ou maior que o período de cálculo.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND TRUNC(data_disponibilizacao) >= TRUNC(pDataInicio)
      AND TRUNC(data_disponibilizacao) <= TRUNC(pDataFim)
      AND data_desligamento IS NOT NULL 
      AND TRUNC(data_desligamento) > TRUNC(pDataFim)
      AND TRUNC(pDataFim) - TRUNC(data_disponibilizacao) + 1 = pDias;

  vTotalFuncionarios := vTotalFuncionarios + vAux;
  vAux := 0;
  
--Caso em que o cálculo está sendo feito fora do período em que o funcionário começou a prestar serviço para o Tribunal
--e a data de desligamento é não nula.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND EXTRACT(month FROM TRUNC(data_disponibilizacao)) < EXTRACT(month FROM TRUNC(pDataInicio))
      AND EXTRACT(year FROM TRUNC(data_disponibilizacao)) = EXTRACT(year FROM TRUNC(pDataInicio))
      AND data_desligamento IS NOT NULL 
      AND TRUNC(pDataFim) - TRUNC(pDataInicio) + 1 = pDias;

  vTotalFuncionarios := vTotalFuncionarios + vAux;
  vAux := 0; 
  
--Caso em que o cálculo está sendo feito fora do período em que o funcionário começou a prestar serviço para o Tribunal
--e a data de desligamento é nula.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod_cargo_contrato = pCodCargoContrato
      AND EXTRACT(month FROM TRUNC(data_disponibilizacao)) < EXTRACT(month FROM TRUNC(pDataInicio))
      AND EXTRACT(year FROM TRUNC(data_disponibilizacao)) = EXTRACT(year FROM TRUNC(pDataInicio))
      AND data_desligamento IS NULL 
      AND TRUNC(pDataFim) - TRUNC(pDataInicio) + 1 = pDias;

  vTotalFuncionarios := vTotalFuncionarios + vAux;
  vAux := 0;  

  RETURN vTotalFuncionarios;

  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;

END;