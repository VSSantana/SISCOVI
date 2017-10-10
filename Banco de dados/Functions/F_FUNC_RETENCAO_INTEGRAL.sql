create or replace function "F_FUNC_RETENCAO_INTEGRAL"(pCodCargoFuncionario NUMBER, pMes NUMBER, pAno NUMBER) RETURN BOOLEAN
IS

  vDataDisponibilizacao DATE;
  vDataDesligamento DATE;
  vDataReferencia DATE;

BEGIN

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno);
 
  SELECT data_disponibilizacao, 
         data_desligamento
    INTO vDataDisponibilizacao,
	     vDataDesligamento
    FROM tb_cargo_funcionario
	WHERE cod = pCodCargoFuncionario;

--Caso em que o cálculo está sendo feito dentro do mês em que o funcionário começou a prestar serviço para o Tribunal
--e a data de desligamento é nula ou maior que o mês de cálculo.	

  IF ((EXTRACT(month FROM vDataDisponibilizacao) = pMes AND EXTRACT(month FROM vDataDisponibilizacao) = pAno)
       AND (vDataDesligamento IS NULL OR TRUNC(vDataDesligamento) >= LAST_DAY(TRUNC(vDataReferencia)))) THEN
	   
    IF (LAST_DAY(TRUNC(vDataReferencia)) - TRUNC(vDataDisponibilizacao) >= 15) THEN
	
	  RETURN TRUE;
	  
	END IF;
	   
  END IF;

/*

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod = pCodCargoFuncionario
      AND TRUNC(data_disponibilizacao) >= TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))
      AND TRUNC(data_disponibilizacao) <= LAST_DAY(TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno))))
      AND (data_desligamento IS NULL OR TRUNC(data_desligamento) >= LAST_DAY(TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))))
      AND LAST_DAY(TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))) - TRUNC(data_disponibilizacao) >= 15;

--Caso geral, onde a data de disponibilização é inferior ao mês do cálculo e o desligamento é nulo ou superior.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod = pCodCargoFuncionario
      AND TRUNC(data_disponibilizacao) <= TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))
      AND (data_desligamento IS NULL OR TRUNC(data_desligamento) >= LAST_DAY(TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))));

--Caso com data de desligamento no mês de cálculo e data de disponibilização inferior ao mês de cálculo.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod = pCodCargoFuncionario
      AND TRUNC(data_disponibilizacao) <= TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))
      AND data_desligamento IS NOT NULL 
      AND TRUNC(data_desligamento) <= LAST_DAY(TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno))))
      AND TRUNC(data_desligamento) >= TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))
      AND (TRUNC(data_desligamento) - TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno))) + 1) >= 15;

--Caso em que o cálculo está sendo feito dentro do mês em que o funcionário começou a prestar serviço para o Tribunal
--e a data de desligamento também está no mesmo mês.

  SELECT COUNT(DISTINCT(cod))
    INTO vAux
    FROM tb_cargo_funcionario
    WHERE cod = pCodCargoFuncionario
      AND TRUNC(data_disponibilizacao) >= TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))
      AND TRUNC(data_disponibilizacao) <= LAST_DAY(TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))) 
      AND data_desligamento IS NOT NULL
      AND TRUNC(data_desligamento) <= LAST_DAY(TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno))))
      AND TRUNC(data_desligamento) >= TRUNC(TO_DATE('01/' || TO_CHAR(pMes) || '/' || TO_CHAR(pAno)))
      AND (TRUNC(data_desligamento) - TRUNC(data_disponibilizacao) + 1) >= 15;

  RETURN vTotalFuncionarios;
  
*/
  
  RETURN FALSE;  

  EXCEPTION WHEN NO_DATA_FOUND THEN
  
    RETURN NULL;

END;
