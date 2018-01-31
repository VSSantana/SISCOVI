create or replace function "F_SALDO_CONTA_VINCULADA" (pCodCargoFuncionario NUMBER, pAno NUMBER, pOperacao NUMBER, pRubrica VARCHAR2) RETURN FLOAT
IS

  --Função que retorna um valor relacionado ao saldo da conta vinculada.

  --pOperacao = 1 - RETENÇÃO
  --pOperacao = 2 - RESTITUIÇÃO FÉRIAS
  --pOperacao = 3 - RESTITUICAO 13º

  vFeriasRetido FLOAT := 0;
  vTercoConstitucionalRetido FLOAT := 0;
  vDecimoTerceiroRetido FLOAT := 0;
  vIncidenciaRetido FLOAT := 0;
  vMultaFGTSRetido FLOAT := 0;
  vTotalRetido FLOAT := 0;
  vFeriasRestituido FLOAT := 0;
  vTercoConstitucionalRestituido FLOAT := 0;
  vIncidenciaFeriasRestituido FLOAT := 0;
  vIncidenciaTercoRestituido FLOAT := 0;
  vDecimoTerceiroRestituido FLOAT := 0;
  vIncidencia13Restituido FLOAT := 0;
  vTotalRestituido FLOAT := 0;

BEGIN

  --Definição dos valores relacionados a retenção.

  IF (pOperacao = 1) THEN

    SELECT SUM(tmr.ferias + DECODE(rtm.ferias, NULL, 0, rtm.ferias)) AS "Férias retido",
           SUM(tmr.terco_constitucional + DECODE(rtm.terco_constitucional, NULL, 0, rtm.terco_constitucional))  AS "Abono de férias retido",
           SUM(tmr.decimo_terceiro + DECODE(rtm.decimo_terceiro, NULL, 0, rtm.decimo_terceiro)) AS "Décimo terceiro retido",
           SUM(tmr.incidencia_submodulo_4_1 + DECODE(rtm.incidencia_submodulo_4_1, NULL, 0, rtm.incidencia_submodulo_4_1)) AS "Incid. do submód. 4.1 retido",
           SUM(tmr.multa_fgts + DECODE(rtm.multa_fgts, NULL, 0, rtm.multa_fgts)) AS "Multa do FGTS retido",
           SUM(tmr.total + DECODE(rtm.total, NULL, 0, rtm.total)) AS "Total retido"
      INTO vFeriasRetido,
           vTercoConstitucionalRetido,
           vDecimoTerceiroRetido,
           vIncidenciaRetido,
           vMultaFGTSRetido,
           vTotalRetido 
      FROM tb_total_mensal_a_reter tmr
        JOIN tb_cargo_funcionario cf ON cf.cod = tmr.cod_cargo_funcionario
        LEFT JOIN tb_retroatividade_total_mensal rtm ON rtm.cod_total_mensal_a_reter = tmr.cod
      WHERE EXTRACT(year FROM tmr.data_referencia) = pAno
        AND cf.cod = pCodCargoFuncionario;

  END IF;

  --Definição dos valores relacionados a restituição de férias.

  IF (pOperacao = 2) THEN

    SELECT SUM(rf.valor_ferias) AS "Férias restituído",
           SUM(rf.valor_terco_constitucional) AS "1/3 constitucional restituído",
           SUM(rf.incid_submod_4_1_ferias) AS "Incid. de férias restituído",
           SUM(rf.incid_submod_4_1_terco) AS "Incod. de terço restituído",
           SUM(rf.valor_ferias + rf.valor_terco_constitucional + rf.incid_submod_4_1_ferias + rf.incid_submod_4_1_terco) AS "Total restituído"
      INTO vFeriasRestituido,
           vTercoConstitucionalRestituido,
           vIncidenciaFeriasRestituido,
           vIncidenciaTercoRestituido,
           vTotalRestituido 
      FROM tb_restituicao_ferias rf
        JOIN tb_cargo_funcionario cf ON cf.cod = rf.cod_cargo_funcionario
      WHERE EXTRACT(year FROM rf.data_inicio_periodo_aquisitivo) = pAno
        AND cf.cod = pCodCargoFuncionario;

  END IF;
  
  --Definição dos valores relacionados a restituição de décimo terceiro.
  
  IF (pOperacao = 3) THEN

    SELECT SUM(rdt.valor) AS "Décimo terceiro restituído",
           SUM(rdt.incidencia_submodulo_4_1) AS "Incid. de 13° restituído",
           SUM(rdt.valor + rdt.incidencia_submodulo_4_1) AS "Total restituído"
      INTO vDecimoTerceiroRestituido,
           vIncidencia13Restituido,
           vTotalRestituido
      FROM tb_restituicao_decimo_terceiro rdt
        JOIN tb_cargo_funcionario cf ON cf.cod = rdt.cod_cargo_funcionario
      WHERE EXTRACT(year FROM rdt.data_inicio_contagem) = pAno
        AND cf.cod = pCodCargoFuncionario;

  END IF;
  
  --Retorno do valor de férias retido.

  IF (pOperacao = 1 AND pRubrica = 'FÉRIAS') THEN
  
    IF (vFeriasRetido IS NULL) THEN vFeriasRetido := 0; END IF;
  
    RETURN vFeriasRetido;
  
  END IF;
  
  --Retorno do valor de terço constitucional retido.
  
  IF (pOperacao = 1 AND pRubrica = 'TERÇO CONSTITUCIONAL') THEN
  
    IF (vTercoConstitucionalRetido IS NULL) THEN vTercoConstitucionalRetido := 0; END IF;
  
    RETURN vTercoConstitucionalRetido;
  
  END IF;
  
  --Retorno do valor de décimo terceiro retido.

  IF (pOperacao = 1 AND pRubrica = 'DÉCIMO TERCEIRO') THEN
  
    IF (vDecimoTerceiroRetido IS NULL) THEN vDecimoTerceiroRetido := 0; END IF;
  
    RETURN vDecimoTerceiroRetido;
  
  END IF;
  
  --Retorno do valor de incidência retido.
  
  IF (pOperacao = 1 AND pRubrica = 'INCIDÊNCIA') THEN
  
    IF (vIncidenciaRetido IS NULL) THEN vIncidenciaRetido := 0; END IF;
  
    RETURN vIncidenciaRetido;
  
  END IF;
  
  --Retorno do valor de multa do FGTS retido.
  
  IF (pOperacao = 1 AND pRubrica = 'MULTA FGTS') THEN
  
    IF (vMultaFGTSRetido IS NULL) THEN vMultaFGTSRetido := 0; END IF;
  
    RETURN vMultaFGTSRetido;
  
  END IF;
  
  --Retorno do valor total retido.
  
  IF (pOperacao = 1 AND pRubrica = 'TOTAL') THEN
  
    IF (vTotalRetido IS NULL) THEN vTotalRetido := 0; END IF;
  
    RETURN vTotalRetido;
  
  END IF;
  
  --Retorno do valor de férias restituído.
  
  IF (pOperacao = 2 AND pRubrica = 'FÉRIAS') THEN
  
    IF (vFeriasRestituido IS NULL) THEN vFeriasRestituido := 0; END IF;
  
    RETURN vFeriasRestituido;
  
  END IF;
  
  --Retorno do valor de terço constitucional restituído.
  
  IF (pOperacao = 2 AND pRubrica = 'TERÇO CONSTITUCIONAL') THEN
  
    IF (vTercoConstitucionalRestituido IS NULL) THEN vTercoConstitucionalRestituido := 0; END IF;
  
    RETURN vTercoConstitucionalRestituido;
  
  END IF;
  
  --Retorno do valor de incidência sobre férias restituído.
  
  IF (pOperacao = 2 AND pRubrica = 'INCIDÊNCIA FÉRIAS') THEN
  
    IF (vIncidenciaFeriasRestituido IS NULL) THEN vIncidenciaFeriasRestituido := 0; END IF;
  
    RETURN vIncidenciaFeriasRestituido;
  
  END IF;
  
  --Retorno do valor de incidência sobre férias restituído.
  
  IF (pOperacao = 2 AND pRubrica = 'INCIDÊNCIA TERÇO CONSTITUCIONAL') THEN
  
    IF (vIncidenciaTercoRestituido IS NULL) THEN vIncidenciaTercoRestituido := 0; END IF;
  
    RETURN vIncidenciaTercoRestituido;
  
  END IF;
  
  --Retorno do valor total restituído de férias.
  
  IF (pOperacao = 2 AND pRubrica = 'TOTAL') THEN
  
    IF (vTotalRestituido IS NULL) THEN vTotalRestituido := 0; END IF;
  
    RETURN vTotalRestituido;
  
  END IF;
  
  --Retorno do valor de décimo terceiro restituído.
  
  IF (pOperacao = 3 AND pRubrica = 'DÉCIMO TERCEIRO') THEN
  
    IF (vDecimoTerceiroRestituido IS NULL) THEN vDecimoTerceiroRestituido := 0; END IF;
  
    RETURN vDecimoTerceiroRestituido;
  
  END IF;
  
  --Retorno do valor de incidência de décimo terceiro restituído.
  
  IF (pOperacao = 3 AND pRubrica = 'INCIDÊNCIA DÉCIMO TERCEIRO') THEN
  
    IF (vIncidencia13Restituido IS NULL) THEN vIncidencia13Restituido := 0; END IF;
  
    RETURN vIncidencia13Restituido;
  
  END IF;
  
  --Retorno do valor total restituído de férias.
  
  IF (pOperacao = 3 AND pRubrica = 'TOTAL') THEN
  
    IF (vTotalRestituido IS NULL) THEN vTotalRestituido := 0; END IF;
  
    RETURN vTotalRestituido;
  
  END IF;
  
  
  EXCEPTION WHEN OTHERS THEN
  
    RETURN -1;

END;
