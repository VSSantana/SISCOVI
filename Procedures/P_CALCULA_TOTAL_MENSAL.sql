create or replace procedure "P_CALCULA_TOTAL_MENSAL" (pCodContrato NUMBER, pMes NUMBER, pAno NUMBER) 
AS

  --Procedure que calcula o total mensal a reter em um determinado mês para
  --um determinado contrato.
  
  --Para fazer DEBUG no Oracle: DBMS_OUTPUT.PUT_LINE(vDataReferencia);

  vTotalFerias FLOAT := 0;
  vTotalTercoConstitucional FLOAT := 0;
  vTotalDecimoTerceiro FLOAT := 0;
  vTotalIncidencia FLOAT := 0;
  vTotalIndenizacao FLOAT := 0;
  vTotal FLOAT := 0;

  vValorFerias FLOAT := 0;
  vValorTercoConstitucional FLOAT := 0;
  vValorDecimoTerceiro FLOAT := 0;
  vValorIncidencia FLOAT := 0;
  vValorIndenizacao FLOAT := 0;

  vPercentualFerias FLOAT := 0;
  vPercentualTercoConstitucional FLOAT := 0;
  vPercentualDecimoTerceiro FLOAT := 0;
  vPercentualIncidencia FLOAT := 0;
  vPercentualIndenizacao FLOAT := 0;
  vPercentualPenalidadeFGTS FLOAT := 0;
  vPercentualMultaFGTS FLOAT := 0;
  vRemuneracao FLOAT := 0;
  vRemuneracao2 FLOAT := 0;
  
  vExisteCalculo NUMBER := 0;
  vDataReferencia DATE;
  vDataInicioConvencao DATE;
  vDataFimRemuneracao DATE;
  vDataInicioPercentual DATE;
  vDataFimPercentual DATE := NULL;
  vDataFimPercentualEstatico DATE := NULL;
  vDataFimMes DATE;
  vDataRetroatividadeConvencao DATE;
  vFimRetroatividadeConvencao DATE;
  vDataRetroatividadePercentual DATE;
  vFimRetroatividadePercentual DATE;
  vDataRetroatividadePercentual2 DATE := NULL;
  vFimRetroatividadePercentual2 DATE := NULL;
  vDataInicio DATE;
  vDataFim DATE;
  vDataCobranca DATE;
  vDataInicioContrato DATE;
  vDataFimContrato DATE;

  vCheck NUMBER := 0;

  vRemuneracaoException EXCEPTION;
  vPeriodoException EXCEPTION;
  vContratoException EXCEPTION;

BEGIN
  
  --Checagem da validade do contrato passado (existe).

  SELECT COUNT(cod)
    INTO vCheck
    FROM tb_contrato 
    WHERE cod = pCodContrato;

  IF (vCheck = 0) THEN

    RAISE vContratoException;

  END IF;

  --Definição da data referência (início do mês de cálculo) e do fim do mês.

  vDataReferencia := TO_DATE('01/' || pMes || '/' || pAno, 'dd/mm/yyyy');
  
  vDataFimMes := LAST_DAY(vDataReferencia);
  
  IF (EXTRACT(day FROM vDataFimMes) = 31) THEN
  
    vDataFimMes := vDataFimMes - 1;
  
  END IF;
  
  IF (EXTRACT(day FROM vDataFimMes) = 28) THEN
  
    vDataFimMes := vDataFimMes + 2;
  
  END IF;
  
  IF (EXTRACT(day FROM vDataFimMes) = 29) THEN
  
    vDataFimMes := vDataFimMes + 1;
  
  END IF;

  --Se a data passada for anterior ao contrato ou posterior ao seu termino aborta-se.
    
  SELECT MIN(ec.data_inicio_vigencia)
    INTO vDataInicioContrato
    FROM tb_evento_contratual ec 
    WHERE ec.cod_contrato = pCodContrato;
    
  SELECT MAX(ec.data_fim_vigencia)
    INTO vDataFimContrato
    FROM tb_evento_contratual ec 
    WHERE ec.cod_contrato = pCodContrato;

  IF (vDataReferencia < (LAST_DAY((ADD_MONTHS(TRUNC(vDataInicioContrato), -1)) + 1))) THEN

    RAISE vPeriodoException;

    RETURN;

  END IF;

  IF (vDataFimContrato IS NOT NULL AND (TRUNC(vDataReferencia) > TRUNC((LAST_DAY((ADD_MONTHS(vDataFimContrato, -1)) + 1))))) THEN

    RAISE vPeriodoException;

    RETURN;

  END IF; 

  --Verificação da existência de cálculo para aquele mês e consequente deleção.
  
  SELECT COUNT(tmr.cod)
    INTO vExisteCalculo
	FROM tb_total_mensal_a_reter tmr
      JOIN tb_terceirizado_contrato tc ON tc.cod = tmr.cod_terceirizado_contrato
	WHERE EXTRACT(month FROM tmr.data_referencia) = pMes
	  AND EXTRACT(year FROM tmr.data_referencia) = pAno
    AND tc.cod_contrato = pCodContrato;
	  
  IF (vExisteCalculo > 0) THEN

    --Deleta as retroatividades associadas aquele mês/ano.
  
    DELETE
      FROM tb_retroatividade_total_mensal
      WHERE cod_total_mensal_a_reter IN (SELECT tmr.cod 
                                           FROM tb_total_mensal_a_reter tmr
                                             JOIN tb_terceirizado_contrato tc ON tc.cod = tmr.cod_terceirizado_contrato
                                           WHERE EXTRACT(month FROM tmr.data_referencia) = pMes 
                                             AND EXTRACT(year FROM tmr.data_referencia) = pAno
                                             AND tc.cod_contrato = pCodContrato);

    --Deleta os recolhimentos realizados naquele mês/ano.
  
    DELETE 
	    FROM tb_total_mensal_a_reter tmr
  	  WHERE EXTRACT(month FROM tmr.data_referencia) = pMes 
	      AND EXTRACT(year FROM tmr.data_referencia) = pAno
		    AND tmr.cod_terceirizado_contrato IN (SELECT tc.cod 
                                                FROM tb_terceirizado_contrato tc
                                                WHERE tc.cod_contrato = pCodContrato);                                                 
  
  END IF;
  
    --Caso não haja mudaça de percentual no mês designado carregam-se os valores.
  
  IF (F_EXISTE_MUDANCA_PERCENTUAL(pCodContrato, pMes, pAno, 1) = FALSE) THEN 
	  
    --Definição dos percentuais.
  
    vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 1, pMes, pAno, 1, 1);
    vPercentualTercoConstitucional := vPercentualFerias/3;
    vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 3, pMes, pAno, 1, 1);
    vPercentualIncidencia := (F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 7, pMes, pAno, 1, 1) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
    vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);
    vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 1, 1);
    vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 1, 1);
    vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;

  END IF;
	
  --Para cada função do contrato.
  
  FOR c1 IN (SELECT cod
               FROM tb_funcao_contrato
               WHERE cod_contrato = pCodContrato) LOOP 
  
    --Se não existe dupla convenção e duplo percentual.

    IF (F_EXISTE_DUPLA_CONVENCAO(c1.cod, pMes, pAno, 1) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(pCodContrato, pMes, pAno, 1) = FALSE) THEN

      --Define a remuneração do função.

      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(c1.cod, pMes, pAno, 1, 1);
      
      IF (vRemuneracao IS NULL) THEN
      
        RAISE vRemuneracaoException;
        
      END IF;
          
      --Para cada funcionário que ocupa aquele função.
      
      FOR c2 IN (SELECT ft.cod_terceirizado_contrato,
                        ft.cod
                   FROM tb_funcao_terceirizado ft
                   WHERE ft.cod_funcao_contrato = c1.cod
                     AND ((ft.data_inicio <= vDataReferencia)
                          OR (EXTRACT(month FROM ft.data_inicio) = pMes)
                              AND EXTRACT(year FROM ft.data_inicio) = pAno)
                     AND ((ft.data_fim IS NULL)
                          OR (ft.data_fim >= LAST_DAY(vDataReferencia))
                          OR (EXTRACT(month FROM ft.data_fim) = pMes)
                              AND EXTRACT(year FROm ft.data_fim) = pAno)
                ) LOOP
                 
        --Redefine todas as variáveis.
    
        vTotal := 0.00;
        vTotalFerias := 0.00;
        vTotalTercoConstitucional := 0.00;
        vTotalDecimoTerceiro := 0.00;
        vTotalIncidencia := 0.00;
        vTotalIndenizacao := 0.00;
               
        --Se a retenção for para período integral.           

        vTotalFerias := vRemuneracao * (vPercentualFerias/100);
        vTotalTercoConstitucional := vRemuneracao * (vPercentualTercoConstitucional/100);
        vTotalDecimoTerceiro := vRemuneracao * (vPercentualDecimoTerceiro/100);
        vTotalIncidencia := vRemuneracao * (vPercentualIncidencia/100);
        vTotalIndenizacao := vRemuneracao * (vPercentualIndenizacao/100);

        --No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo, situação similar para a retenção proporcional.

        IF (F_EXISTE_MUDANCA_FUNCAO(c2.cod_terceirizado_contrato, pMes, pAno) = TRUE OR F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = FALSE) THEN

          vTotalFerias := (vTotalFerias/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);
          vTotalTercoConstitucional := (vTotalTercoConstitucional/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);
          vTotalDecimoTerceiro := (vTotalDecimoTerceiro/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);
          vTotalIncidencia := (vTotalIncidencia/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);
          vTotalIndenizacao := (vTotalIndenizacao/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);

        END IF;
                          
        vTotal := (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);	
      
        INSERT INTO tb_total_mensal_a_reter (cod_terceirizado_contrato,
                                             cod_funcao_terceirizado,
                                             ferias,
                                             terco_constitucional,
                                             decimo_terceiro,
                                             incidencia_submodulo_4_1,
                                             multa_fgts,
                                             total,
                                             data_referencia,
                                             login_atualizacao,
                                             data_atualizacao)
		      VALUES(c2.cod_terceirizado_contrato,
                 c2.cod,
                 vTotalFerias,
                 vTotalTercoConstitucional,
                 vTotalDecimoTerceiro,
                 vTotalIncidencia,
                 vTotalIndenizacao,
                 vTotal,
                 vDataReferencia,
                 'SYSTEM',
                 SYSDATE);
        
	    END LOOP;
  
    END IF;

    --Se não existe dupla convenção e existe duplo percentual.

    IF (F_EXISTE_DUPLA_CONVENCAO(c1.cod, pMes, pAno, 1) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(pCodContrato, pMes, pAno, 1) = TRUE) THEN
    
      --Define a remuneração do funcao
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(c1.cod, pMes, pAno, 1, 1);

      IF (vRemuneracao IS NULL) THEN
      
        RAISE vRemuneracaoException;
        
      END IF;
            
      --Para cada funcionário que ocupa aquele função.
      
      FOR c2 IN (SELECT ft.cod_terceirizado_contrato,
                        ft.cod
                   FROM tb_funcao_terceirizado ft
                   WHERE ft.cod_funcao_contrato = c1.cod
                     AND ((ft.data_inicio <= vDataReferencia)
                          OR (EXTRACT(month FROM ft.data_inicio) = pMes)
                              AND EXTRACT(year FROM ft.data_inicio) = pAno)
                     AND ((ft.data_fim IS NULL)
                          OR (ft.data_fim >= LAST_DAY(vDataReferencia))
                          OR (EXTRACT(month FROM ft.data_fim) = pMes)
                              AND EXTRACT(year FROm ft.data_fim) = pAno)
                ) LOOP
                   
        --Redefine todas as variáveis.
    
        vTotal := 0.00;
        vTotalFerias := 0.00;
        vTotalTercoConstitucional := 0.00;
        vTotalDecimoTerceiro := 0.00;
        vTotalIncidencia := 0.00;
        vTotalIndenizacao := 0.00;
        
        vValorFerias := 0;
        vValorTercoConstitucional := 0;
        vValorDecimoTerceiro := 0;
        vValorIncidencia := 0;
        vValorIndenizacao := 0;
        
        vDataInicio := vDataReferencia;

        FOR c3 IN (SELECT data_inicio AS data 
                     FROM tb_percentual_contrato
                     WHERE cod_contrato = 15
                       AND (EXTRACT(month FROM data_inicio) = 09
                            AND 
                            EXTRACT(year FROM data_inicio) = 2016)
    
                   UNION

                   SELECT data_fim AS data
                     FROM tb_percentual_contrato
                     WHERE cod_contrato = 15
                       AND (EXTRACT(month FROM data_fim) = 09
                            AND 
                            EXTRACT(year FROM data_fim) = 2016)

                   UNION

                   SELECT TO_DATE('30/' || pMes || '/' || pAno, 'dd/mm/yyyy') AS data
                     FROM DUAL

                   ORDER BY data ASC) LOOP

            --Definição das datas de início e fim do subperíodo.

            vDataFim := c3.data;
        
            --Definição dos percentuais da primeira metade do mês.
  
            vPercentualFerias := F_RET_PERCENTUAL_CONTRATO(pCodContrato, 1, vDataInicio, vDataFim, 1);     
            vPercentualTercoConstitucional := vPercentualFerias/3;
            vPercentualDecimoTerceiro := F_RET_PERCENTUAL_CONTRATO(pCodContrato, 3, vDataInicio, vDataFim 1);
            vPercentualIncidencia := (F_RET_PERCENTUAL_CONTRATO(pCodContrato, 7, vDataInicio, vDataFim 1) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
        
            IF (F_MUNDANCA_PERCENTUAL_ESTATICO(pCodContrato, pMes, pAno, 1) = TRUE) THEN

              vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 2, 1);
              vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 2, 1);
              vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 2, 1);
        
            ELSE

              vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);
              vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 1, 1);
              vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 1, 1);

            END IF;
        
            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;

            --Calculo da porção correspondente ao subperíodo.
 
            vValorFerias := ((vRemuneracao * (vPercentualFerias/100))/30) * ((vDataFim - vDataInicio) + 1);
            vValorTercoConstitucional := ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * ((vDataFim - vDataInicio) + 1);
            vValorDecimoTerceiro := ((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * ((vDataFim - vDataInicio) + 1);
            vValorIncidencia := ((vRemuneracao * (vPercentualIncidencia/100))/30) * ((vDataFim - vDataInicio) + 1);
            vValorIndenizacao := ((vRemuneracao * (vPercentualIndenizacao/100))/30) * ((vDataFim - vDataInicio) + 1);

            --No caso de mudança de função ou retenção parcial temos um recolhimento proporcional ao dias trabalhados no cargo.

            IF (F_EXISTE_MUDANCA_FUNCAO(c2.cod_terceirizado_contrato, pMes, pAno) = TRUE OR F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = FALSE) THEN

              vValorFerias := (vValorFerias/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);
              vValorTercoConstitucional := (vValorTercoConstitucional/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);
              vValorDecimoTerceiro := (vValorDecimoTerceiro/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);
              vValorIncidencia := (vValorIncidencia/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);
              vValorIndenizacao := (vValorIndenizacao/30) * F_DIAS_TRABALHADOS_MES(c2.cod, pMes, pAno);

            END IF;

            vTotalFerias := vTotalFerias + vValorFerias;
            vTotalTercoConstitucional := vTotalTercoConstitucional + vValorTercoConstitucional;
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + vValorDecimoTerceiro;
            vTotalIncidencia := vTotalIncidencia + vValorIncidencia;
            vTotalIndenizacao := vTotalIndenizacao + vValorIndenizacao;

        END LOOP;
     
        vTotal := (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);	
      
        INSERT INTO tb_total_mensal_a_reter (cod_terceirizado_contrato,
                                             cod_funcao_terceirizado,
                                             ferias,
                                             terco_constitucional,
                                             decimo_terceiro,
                                             incidencia_submodulo_4_1,
                                             multa_fgts,
                                             total,
                                             data_referencia,
                                             login_atualizacao,
                                             data_atualizacao)
		      VALUES(c2.cod_terceirizado_contrato,
                 c2.cod,
                 vTotalFerias,
                 vTotalTercoConstitucional,
                 vTotalDecimoTerceiro,
                 vTotalIncidencia,
                 vTotalIndenizacao,
                 vTotal,
                 vDataReferencia,
                 'SYSTEM',
                 SYSDATE);
        
	    END LOOP;
  
    END IF;
    
    --Se existe dupla convenção e não existe duplo percentual.

    IF (F_EXISTE_DUPLA_CONVENCAO(c1.cod, pMes, pAno, 1) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(pCodContrato, pMes, pAno, 1) = FALSE) THEN
    
      --Define a remuneração do funcao
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(c1.cod, pMes, pAno, 2, 1);
      vRemuneracao2 := F_RETORNA_REMUNERACAO_PERIODO(c1.cod, pMes, pAno, 1, 1);

      IF (vRemuneracao IS NULL OR vRemuneracao2 IS NULL) THEN
      
        RAISE vRemuneracaoException;
        
      END IF;
      
      --Para cada funcionário que ocupa aquele funcao.
      
      FOR c2 IN (SELECT ft.cod_terceirizado_contrato,
                        ft.cod
                   FROM tb_funcao_terceirizado ft
                   WHERE ft.cod_funcao_contrato = c1.cod
                     AND ((ft.data_inicio <= vDataReferencia)
                          OR (EXTRACT(month FROM ft.data_inicio) = pMes)
                              AND EXTRACT(year FROM ft.data_inicio) = pAno)
                     AND ((ft.data_fim IS NULL)
                          OR (ft.data_fim >= LAST_DAY(vDataReferencia))
                          OR (EXTRACT(month FROM ft.data_fim) = pMes)
                              AND EXTRACT(year FROm ft.data_fim) = pAno)
                ) LOOP
                   
        --Redefine todas as variáveis.
    
        vTotal := 0.00;
        vTotalFerias := 0.00;
        vTotalTercoConstitucional := 0.00;
        vTotalDecimoTerceiro := 0.00;
        vTotalIncidencia := 0.00;
        vTotalIndenizacao := 0.00;
                   
        --Se a retenção for para período integral.           

        IF (F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = TRUE) THEN
	  
          --Retenção proporcional da primeira convenção.
          
          vTotalFerias := ((vRemuneracao * (vPercentualFerias/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
          vTotalTercoConstitucional := ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
          vTotalDecimoTerceiro := ((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
          vTotalIncidencia := ((vRemuneracao * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
          vTotalIndenizacao := ((vRemuneracao * (vPercentualIndenizacao/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
          
          --Retenção proporcional da segunda convenção.
          
          vTotalFerias := vTotalFerias + (((vRemuneracao2 * (vPercentualFerias/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 2));
          vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao2 * (vPercentualTercoConstitucional/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 2));
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao2 * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 2));
          vTotalIncidencia := vTotalIncidencia + (((vRemuneracao2 * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 2));
          vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 2));
      
        END IF;
        
        --Caso o funcionário não tenha trabalhado 15 dias ou mais no período.
      
        IF (F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = FALSE) THEN

          vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);

          vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;
        
          --Retenção proporcional da primeira convenção.
	  
          vTotalIndenizacao := (((vRemuneracao * (vPercentualIndenizacao/100))/30) * F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 1));
          
          --Retenção proporcional da segunda convenção.
	  
          vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) *  F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 2));
      
        END IF;
      
        vTotal := (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);	
      
        INSERT INTO tb_total_mensal_a_reter (cod_terceirizado_contrato,
                                             cod_funcao_terceirizado,
                                             ferias,
                                             terco_constitucional,
                                             decimo_terceiro,
                                             incidencia_submodulo_4_1,
                                             multa_fgts,
                                             total,
                                             data_referencia,
                                             login_atualizacao,
                                             data_atualizacao)
		      VALUES(c2.cod_terceirizado_contrato,
                 c2.cod,
                 vTotalFerias,
                 vTotalTercoConstitucional,
                 vTotalDecimoTerceiro,
                 vTotalIncidencia,
                 vTotalIndenizacao,
                 vTotal,
                 vDataReferencia,
                 'SYSTEM',
                 SYSDATE);
        
	  END LOOP;
  
    END IF;
    
    --Se existe mudança de percentual e mudança de convenção.
    
    IF (F_EXISTE_DUPLA_CONVENCAO(c1.cod, pMes, pAno, 1) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(pCodContrato, pMes, pAno, 1) = TRUE) THEN

      vDataFimPercentual := NULL;
      vDataFimPercentualEstatico := NULL;
      vDataFimRemuneracao := NULL;
    
      --Define a remuneração do funcao
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(c1.cod, pMes, pAno, 2, 1);
      vRemuneracao2 := F_RETORNA_REMUNERACAO_PERIODO(c1.cod, pMes, pAno, 1, 1);
      
      --Definição das datas para os períodos da convenção e percentuais.
   
      SELECT data_fim
        INTO vDataFimRemuneracao
        FROM tb_remuneracao_fun_con
        WHERE cod_funcao_contrato = c1.cod
          AND data_aditamento IS NOT NULL
          AND (EXTRACT(month FROM data_fim) = pMes
               AND EXTRACT(year FROM data_fim) = pAno);
               
      --Observação: datas dos percentuais são todas iguais para um bloco.

      --Para o percentual do contrato.

      IF (F_MUNDANCA_PERCENTUAL_CONTRATO(pCodContrato, pMes, pAno, 1) = TRUE) THEN

        SELECT DISTINCT(data_fim)
          INTO vDataFimPercentual
          FROM tb_percentual_contrato
          WHERE cod_contrato = pCodContrato
            AND data_aditamento IS NOT NULL
            AND (EXTRACT(month FROM data_fim) = pMes
                 AND EXTRACT(year FROM data_fim) = pAno);

      END IF;

      --Para o percentual estático.

      IF (F_MUNDANCA_PERCENTUAL_ESTATICO(pCodContrato, pMes, pAno, 1) = TRUE) THEN

        SELECT DISTINCT(data_fim)
          INTO vDataFimPercentualEstatico
          FROM tb_percentual_estatico
          WHERE data_aditamento IS NOT NULL
            AND (EXTRACT(month FROM data_fim) = pMes
                 AND EXTRACT(year FROM data_fim) = pAno);

      END IF;

      --Decisão da data fim do percentual.

      IF (vDataFimPercentual IS NOT NULL AND vDataFimPercentualEstatico IS NOT NULL) THEN

        SELECT GREATEST(vDataFimPercentual, vDataFimPercentualEstatico)
          INTO vDataFimPercentual
          FROM DUAL;
 
      END IF;
               
      vDataInicioConvencao := vDataFimRemuneracao + 1;
      vDataInicioPercentual := vDataFimPercentual + 1;
         
      --Para cada funcionário que ocupa aquele funcao.
      
      FOR c2 IN (SELECT ft.cod_terceirizado_contrato,
                        ft.cod
                   FROM tb_funcao_terceirizado ft
                   WHERE ft.cod_funcao_contrato = c1.cod
                     AND ((ft.data_inicio <= vDataReferencia)
                          OR (EXTRACT(month FROM ft.data_inicio) = pMes)
                              AND EXTRACT(year FROM ft.data_inicio) = pAno)
                     AND ((ft.data_fim IS NULL)
                          OR (ft.data_fim >= LAST_DAY(vDataReferencia))
                          OR (EXTRACT(month FROM ft.data_fim) = pMes)
                              AND EXTRACT(year FROm ft.data_fim) = pAno)
                ) LOOP
                   
        --Redefine todas as variáveis.
    
        vTotal := 0.00;
        vTotalFerias := 0.00;
        vTotalTercoConstitucional := 0.00;
        vTotalDecimoTerceiro := 0.00;
        vTotalIncidencia := 0.00;
        vTotalIndenizacao := 0.00;
        
        --Definição do método de cálculo.
        
        IF (vDataFimRemuneracao < vDataFimPercentual) THEN
        
          --Definição dos percentuais da primeira metade do mês.
  
          vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 1, pMes, pAno, 2, 1);     
          vPercentualTercoConstitucional := vPercentualFerias/3;
          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 3, pMes, pAno, 2, 1);
          vPercentualIncidencia := (F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 7, pMes, pAno, 2, 1) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
          vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 2, 1);
          vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 2, 1);
          vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 2, 1); 
          vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;

          --Se a retenção for para período integral.           

          IF (F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = TRUE) THEN
	  
            --Retenção proporcional da primeira porção do mês.
          
            vTotalFerias := ((vRemuneracao * (vPercentualFerias/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
            vTotalTercoConstitucional := ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
            vTotalDecimoTerceiro := ((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
            vTotalIncidencia := ((vRemuneracao * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
            vTotalIndenizacao := ((vRemuneracao * (vPercentualIndenizacao/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 1);
          
            --Retenção proporcional da segunda porção do mês.
          
            vTotalFerias := vTotalFerias + (((vRemuneracao2 * (vPercentualFerias/100))/30) * (vDataFimPercentual - vDataInicioConvencao + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao2 * (vPercentualTercoConstitucional/100))/30) * (vDataFimPercentual - vDataInicioConvencao + 1));
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao2 * (vPercentualDecimoTerceiro/100))/30) * (vDataFimPercentual - vDataInicioConvencao + 1));
            vTotalIncidencia := vTotalIncidencia + (((vRemuneracao2 * (vPercentualIncidencia/100))/30) * (vDataFimPercentual - vDataInicioConvencao + 1));
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * (vDataFimPercentual - vDataInicioConvencao + 1));
            
            --Definição dos percentuais da segunda metade do mês.
  
            vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 1, pMes, pAno, 2, 1);     
            vPercentualTercoConstitucional := vPercentualFerias/3;
            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 3, pMes, pAno, 1, 1);
            vPercentualIncidencia := (F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 7, pMes, pAno, 1, 1) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 1, 1);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 1, 1);
            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;
            
            --Retenção proporcional da terceira porção do mês.
          
            vTotalFerias := vTotalFerias + (((vRemuneracao2 * (vPercentualFerias/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao2 * (vPercentualTercoConstitucional/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao2 * (vPercentualDecimoTerceiro/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalIncidencia := vTotalIncidencia + (((vRemuneracao2 * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));            
      
          END IF;
        
          --Caso o funcionário não tenha trabalhado 15 dias ou mais no período.
      
          IF (F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = FALSE) THEN

            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 2, 1);

            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;
        
            --Retenção proporcional da primeira porção do mês.
          
            vTotalIndenizacao := ((vRemuneracao * (vPercentualIndenizacao/100))/30) * F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 1);
          
            --Retenção proporcional da segunda porção do mês.
          
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * (F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 2) - F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 4)));
            
            --Definição dos percentuais da segunda metade do mês.
   
            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 1, 1);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 1, 1);
            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;

            --Retenção proporcional da terceira porção do mês.
          
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 4)); 
      
          END IF;
      
          vTotal := (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);
        
        END IF;
        
        IF (vDataFimRemuneracao > vDataFimPercentual) THEN
        
          --Definição dos percentuais da primeira metade do mês.
  
          vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 1, pMes, pAno, 2, 1);     
          vPercentualTercoConstitucional := vPercentualFerias/3;
          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 3, pMes, pAno, 2, 1);
          vPercentualIncidencia := (F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 7, pMes, pAno, 2, 1) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
          vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 2, 1);
          vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 2, 1);
          vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 2, 1);
          vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;

          --Se a retenção for para período integral.           

          IF (F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = TRUE) THEN
	  
            --Retenção proporcional da primeira porção do mês.
          
            vTotalFerias := ((vRemuneracao * (vPercentualFerias/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
            vTotalTercoConstitucional := ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
            vTotalDecimoTerceiro := ((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
            vTotalIncidencia := ((vRemuneracao * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
            vTotalIndenizacao := ((vRemuneracao * (vPercentualIndenizacao/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
          
            --Definição dos percentuais da segunda metade do mês.
  
            vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 1, pMes, pAno, 1, 1);     
            vPercentualTercoConstitucional := vPercentualFerias/3;
            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 3, pMes, pAno, 1, 1);
            vPercentualIncidencia := (F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 7, pMes, pAno, 1, 1) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 1, 1);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 1, 1);
            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;
          
            --Retenção proporcional da segunda porção do mês.
          
            vTotalFerias := vTotalFerias + (((vRemuneracao * (vPercentualFerias/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalIncidencia := vTotalIncidencia + (((vRemuneracao * (vPercentualIncidencia/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao * (vPercentualIndenizacao/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            
            --Retenção proporcional da terceira porção do mês.
          
            vTotalFerias := vTotalFerias + (((vRemuneracao2 * (vPercentualFerias/100))/30) * (vDataFimMes - vDataInicioConvencao + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao2 * (vPercentualTercoConstitucional/100))/30) * (vDataFimMes - vDataInicioConvencao + 1));
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao2 * (vPercentualDecimoTerceiro/100))/30) * (vDataFimMes - vDataInicioConvencao + 1));
            vTotalIncidencia := vTotalIncidencia + (((vRemuneracao2 * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioConvencao + 1));
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * (vDataFimMes - vDataInicioConvencao + 1));            
      
          END IF;
        
          --Caso o funcionário não tenha trabalhado 15 dias ou mais no período.
      
          IF (F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = FALSE) THEN

            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 2, 1);

            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;
        
            --Retenção proporcional da primeira porção do mês.
          
            vTotalIndenizacao := ((vRemuneracao * (vPercentualIndenizacao/100))/30) * F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 3);
          
            --Definição dos percentuais da segunda metade do mês.
  
            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 1, 1);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 1, 1);
            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;
          
            --Retenção proporcional da segunda porção do mês.
          
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao * (vPercentualIndenizacao/100))/30) * (F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 4) - F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 2)));
            
            --Retenção proporcional da terceira porção do mês.
          
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 2));     
      
          END IF;
      
          vTotal := (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);
        
        END IF;
        
        --Caso as datas da convenção e do percentual sejam iguais.
        
        IF (vDataFimRemuneracao = vDataFimPercentual) THEN
        
          --Definição dos percentuais da primeira metade do mês.
  
          vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 1, pMes, pAno, 2, 1);     
          vPercentualTercoConstitucional := vPercentualFerias/3;
          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 3, pMes, pAno, 2, 1);
          vPercentualIncidencia := (F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 7, pMes, pAno, 2, 1) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
          vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 2, 1);
          vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 2, 1);
          vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 2, 1);
          vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;

          --Se a retenção for para período integral.           

          IF (F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = TRUE) THEN
	  
            --Retenção proporcional da primeira porção do mês.
          
            vTotalFerias := ((vRemuneracao * (vPercentualFerias/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
            vTotalTercoConstitucional := ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
            vTotalDecimoTerceiro := ((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
            vTotalIncidencia := ((vRemuneracao * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
            vTotalIndenizacao := ((vRemuneracao * (vPercentualIndenizacao/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 3);
          
            --Definição dos percentuais da segunda metade do mês.
  
            vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 1, pMes, pAno, 1, 1);     
            vPercentualTercoConstitucional := vPercentualFerias/3;
            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 3, pMes, pAno, 1, 1);
            vPercentualIncidencia := (F_RETORNA_PERCENTUAL_CONTRATO(pCodContrato, 7, pMes, pAno, 1, 1) * (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 1, 1);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 1, 1);
            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;
          
            --Retenção proporcional da segunda porção do mês.
          
            vTotalFerias := vTotalFerias + (((vRemuneracao2 * (vPercentualFerias/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 4));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao2 * (vPercentualTercoConstitucional/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 4));
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao2 * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 4));
            vTotalIncidencia := vTotalIncidencia + (((vRemuneracao2 * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 4));
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(c1.cod, pMes, pAno, 4));            
      
          END IF;
        
          --Caso o funcionário não tenha trabalhado 15 dias ou mais no período.
      
          IF (F_FUNC_RETENCAO_INTEGRAL(c2.cod, pMes, pAno) = FALSE) THEN

            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 2, 1);

            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;
        
            --Retenção proporcional da primeira porção do mês.
          
	          vTotalIndenizacao := ((vRemuneracao * (vPercentualIndenizacao/100))/30) * F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 3);
          
            --Definição dos percentuais da segunda metade do mês.
  
            vPercentualIndenizacao := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 4, pMes, pAno, 1, 1);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 6, pMes, pAno, 1, 1);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO(pCodContrato, 5, pMes, pAno, 1, 1);
            vPercentualIndenizacao := (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;
            
            --Retenção proporcional da segunda porção do mês.
          
  	        vTotalIndenizacao := vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * F_DIAS_TRABALHADOS_MES_PARCIAL(c1.cod, c2.cod, pMes, pAno, 4));      
      
          END IF;
      
          vTotal := (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);
        
        END IF;

        INSERT INTO tb_total_mensal_a_reter (cod_terceirizado_contrato,
                                             cod_funcao_terceirizado,
                                             ferias,
                                             terco_constitucional,
                                             decimo_terceiro,
                                             incidencia_submodulo_4_1,
                                             multa_fgts,
                                             total,
                                             data_referencia,
                                             login_atualizacao,
                                             data_atualizacao)
		      VALUES(c2.cod_terceirizado_contrato,
                 c2.cod,
                 vTotalFerias,
                 vTotalTercoConstitucional,
                 vTotalDecimoTerceiro,
                 vTotalIncidencia,
                 vTotalIndenizacao,
                 vTotal,
                 vDataReferencia,
                 'SYSTEM',
                 SYSDATE);
        
	  END LOOP;
  
    END IF;

  END LOOP;
  
  --Verifica se existe a retroarividade e dispara o processo de cálculo
  --em caso afirmativo.
  
  IF (F_COBRANCA_RETROATIVIDADE(pCodContrato, pMes, pANo, 1) = TRUE OR F_COBRANCA_RETROATIVIDADE(pCodContrato, pMes, pANo, 2) = TRUE) THEN

    IF (F_COBRANCA_RETROATIVIDADE(pCodContrato, pMes, pANo, 1) = TRUE) THEN
  
      SELECT MIN(inicio),
             MAX(fim)
        INTO vDataRetroatividadeConvencao,
             vFimRetroatividadeConvencao
        FROM tb_retroatividade_remuneracao rr
          JOIN tb_remuneracao_fun_con rcco ON rcco.cod = rr.cod_rem_funcao_contrato
          JOIN tb_funcao_contrato cc ON cc.cod = rcco.cod_funcao_contrato
        WHERE cc.cod_contrato = pCodContrato
          AND EXTRACT(month FROM data_cobranca) = pMes
          AND EXTRACT(year FROM data_cobranca) = pAno; 

    END IF;

    IF (F_COBRANCA_RETROATIVIDADE(pCodContrato, pMes, pANo, 2) = TRUE) THEN

      BEGIN

        SELECT MIN(rp.inicio),
               MAX(rp.fim)
          INTO vDataRetroatividadePercentual,
               vFimRetroatividadePercentual        
          FROM tb_retroatividade_percentual rp
            JOIN tb_percentual_contrato pc ON pc.cod = rp.cod_percentual_contrato
          WHERE pc.cod_contrato = pCodContrato
            AND EXTRACT(month FROM data_cobranca) = pMes
            AND EXTRACT(year FROM data_cobranca) = pAno;

        EXCEPTION WHEN NO_DATA_FOUND THEN

          vDataRetroatividadePercentual := NULL;
          vFimRetroatividadePercentual := NULL;

      END;

      BEGIN

        SELECT MIN(rpe.inicio),
               MAX(rpe.fim)
          INTO vDataRetroatividadePercentual2,
               vFimRetroatividadePercentual2      
          FROM tb_retro_percentual_estatico rpe
          WHERE rpe.cod_contrato = pCodContrato
            AND EXTRACT(month FROM rpe.data_cobranca) = pMes
            AND EXTRACT(year FROM rpe.data_cobranca) = pAno;

        EXCEPTION WHEN NO_DATA_FOUND THEN

          vDataRetroatividadePercentual2 := NULL;
          vFimRetroatividadePercentual2 := NULL;

      END;

      IF (vDataRetroatividadePercentual2 IS NOT NULL AND vFimRetroatividadePercentual2 IS NOT NULL) THEN

        IF (vDataRetroatividadePercentual IS NOT NULL AND vFimRetroatividadePercentual IS NOT NULL) THEN

          vDataRetroatividadePercentual := LEAST (vDataRetroatividadePercentual, vDataRetroatividadePercentual2);
          vFimRetroatividadePercentual := GREATEST (vFimRetroatividadePercentual, vFimRetroatividadePercentual2);

        END IF;

        ELSE
 
          vDataRetroatividadePercentual := vDataRetroatividadePercentual2;
          vFimRetroatividadePercentual := vFimRetroatividadePercentual2;

      END IF;

    END IF;

    BEGIN

      IF (F_COBRANCA_RETROATIVIDADE(pCodContrato, pMes, pANo, 1) = TRUE AND F_COBRANCA_RETROATIVIDADE(pCodContrato, pMes, pANo, 2) = TRUE) THEN

        vDataInicio := LEAST(vDataRetroatividadeConvencao, vDataRetroatividadePercentual);
        vDataFim := GREATEST(vFimRetroatividadeConvencao, vFimRetroatividadePercentual);

      ELSE

        IF (F_COBRANCA_RETROATIVIDADE(pCodContrato, pMes, pANo, 1) = TRUE) THEN
  
          vDataInicio := vDataRetroatividadeConvencao;
          vDataFim := vFimRetroatividadeConvencao;

        ELSE

          IF (F_COBRANCA_RETROATIVIDADE(pCodContrato, pMes, pANo, 2) = TRUE) THEN

            vDataInicio := vDataRetroatividadePercentual;
            vDataFim := vFimRetroatividadePercentual;

          END IF;
          
        END IF;
        
      END IF;

      vDataCobranca := vDataReferencia;

      --P_CALCULA_RETROATIVIDADE(pCodContrato, vDataInicio, vDataFim, vDataCobranca);

    END;
  
  END IF;

  EXCEPTION 
  
    WHEN vRemuneracaoException THEN

      RAISE_APPLICATION_ERROR(-20001, 'Erro na execução do procedimento: Remuneração não encontrada.');

    WHEN vPeriodoException THEN

      RAISE_APPLICATION_ERROR(-20002, 'Erro na execução do procedimento: Período fora da vigência contratual.');
  
    WHEN vContratoException THEN

      RAISE_APPLICATION_ERROR(-20003, 'Erro na execução do procedimento: Contrato inexistente.');
    
    WHEN OTHERS THEN
  
      RAISE_APPLICATION_ERROR(-20004, 'Erro na execução do procedimento: Causa não detectada.');

END;
