create or replace procedure "P_CALCULA_TOTAL_MENSAL" (pCodContrato NUMBER, pMes NUMBER, pAno NUMBER) 
AS

  vTotalFerias FLOAT := 0;
  vTotalAbono FLOAT := 0;
  vTotalDecimoTerceiro FLOAT := 0;
  vTotalIncidencia FLOAT := 0;
  vTotalIndenizacao FLOAT := 0;
  vPercentualFerias FLOAT := 0;
  vPercentualAbono FLOAT := 0;
  vPercentualDecimoTerceiro FLOAT := 0;
  vPercentualIncidencia FLOAT := 0;
  vPercentualIndenizacao FLOAT := 0;
  vPercentualPenalidadeFGTS FLOAT := 0;
  vPercentualMultaFGTS FLOAT := 0;
  vRemuneracao FLOAT := 0;
  vRetencaoDiaria FLOAT := 0;
  vTotalIntegral FLOAT := 0;
  vTotalParcial FLOAT := 0;
  vTotal FLOAT := 0;
  vExisteCalculo NUMBER := 0;
  vDataReferencia DATE;
  vUltimoDiaConvencao DATE;

  CURSOR cargo IS
    SELECT cod
      FROM tb_cargo_contrato
      WHERE cod_contrato = pCodContrato;

BEGIN

  --Definição da data referência (início do mês de cálculo)

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno);

  --Verificação da existência de cálculo para aquele mês.
  
  SELECT COUNT(cod)
    INTO vExisteCalculo
	FROM tb_total_mensal_a_reter
	WHERE EXTRACT(month FROM data_referencia) = pMes
	  AND EXTRACT(year FROM data_referencia) = pAno
      AND cod_contrato = pCodContrato;
	  
  IF (vExisteCalculo > 0) THEN
  
    DELETE 
	  FROM tb_total_mensal_a_reter 
	  WHERE EXTRACT(month FROM data_referencia) = pMes 
	    AND EXTRACT(year FROM data_referencia) = pAno
		AND cod_contrato = pCodContrato;;                                                   
  
  END IF;
  
  IF (F_EXISTE_MUDANCA_PERCENTUAL(pCodContrato, pMes, pAno) = FALSE) THEN 
	  
    vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(c1.cod, vDataReferencia, LAST_DAY(vDataReferencia));
	  
    --Definição dos percentuais.
  
    vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, 'Férias', vDataReferencia, LAST_DAY(vDataReferencia));
	vPercentualAbono := vPercentualFerias/3;
	vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, 'Décimo terceiro salário', vDataReferencia, LAST_DAY(vDataReferencia));
	vPercentualIncidencia := (F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, 'Incidência do submódulo 4.1', vDataReferencia, LAST_DAY(vDataReferencia)) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualAbono))/100;
	vPercentualIndenizacao := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, 'FGTS', vDataReferencia, LAST_DAY(vDataReferencia));
	vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, 'Penalidade FGTS', vDataReferencia, LAST_DAY(vDataReferencia));
	vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_PERIODO(pCodContrato, 'Multa do FGTS', vDataReferencia, LAST_DAY(vDataReferencia));
	vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualAbono/100))) * 100;

  END IF;
  
  IF (F_EXISTE_DUPLA_CONVENCAO(c1.cod, pMes, pAno) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(pCodContrato, pMes, pAno) = FALSE) THEN
	
    FOR c1 IN cargo LOOP 
	
      vTotal := 0;
      vTotalFerias := 0;
      vTotalAbono := 0;
      vTotalDecimoTerceiro := 0;
      vTotalIncidencia := 0;
      vTotalIndenizacao := 0;
      vRetencaoDiaria := 0;

      CURSOR funcionario IS
	    SELECT cod_funcionario, cod
		  FROM tb_cargo_funcionario
		  WHERE cod_cargo_contrato = c.cod;
		  
	  vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(c1.cod, vDataReferencia, LAST_DAY(vDataReferencia));
	  
	  vTotalFerias := vRemuneracao * (vPercentualFerias/100);
      vTotalAbono := vRemuneracao * (vPercentualAbono/100);
      vTotalDecimoTerceiro := vRemuneracao * (vPercentualDecimoTerceiro/100);
      vTotalIncidencia := vRemuneracao * (vPercentualIncidencia/100);
	  vTotalIndenizacao := vRemuneracao * (vPercentualIndenizacao/100);
		
      FOR c2 IN funcionario LOOP
	
	    
  
  

	 

    
	  END LOOP;
  
    END LOOP;
  
  END IF;

END;
