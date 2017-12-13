create or replace procedure "P_CALCULA_RESTITUICAO_13" (pCodCargoFuncionario NUMBER,
                                                        pCodTipoResgate NUMBER,
                                                        pNumeroParcela NUMBER,
                                                        pInicioContagem DATE,
                                                        pFimContagem DATE,
                                                        pValor13 FLOAT) AS

--Procedure que calcula faz o registro de restituição de férias no banco de dados.

  vCodContrato NUMBER;
  vCodFuncionario NUMBER;
  vCodCargoContrato NUMBER;
  vAno NUMBER;
  vMes NUMBER;
  vPercentualDecimoTerceiro FLOAT := 0;
  vPercentualIncidencia FLOAT := 0;
  vRemuneracao FLOAT := 0;
  vTotalDecimoTerceiro FLOAT := 0;
  vTotalIncidencia FLOAT := 0;
  vDataInicioConvencao DATE;
  vDataFimConvencao DATE;
  vDataInicioPercentual DATE;
  vDataFimPercentual DATE;
  vDataReferencia DATE;
  vDataFimMes DATE;

  vDiasDeFerias NUMBER := 0;
  vDiasAdquiridos NUMBER := 0;
  vDiasVendidos NUMBER := 0;

BEGIN

  --Carregar o cod do funcionário e do contrato.

  SELECT cf.cod_funcionario,
         cc.cod_contrato,
         cc.cod
    INTO vCodFuncionario,
         vCodContrato,
         vCodCargoContrato
    FROM tb_cargo_funcionario cf
      JOIN tb_cargo_contrato cc ON cc.cod = cf.cod_cargo_contrato
    WHERE cf.cod = pCodCargoFuncionario;

  --Definir o valor das variáveis vMes e vAno de acordo com a data de início da contagem.

  vMes := EXTRACT(month FROM pInicioContagem);
  vAno := EXTRACT(year FROM pInicioContagem);

  --O cálculo é feito mês a mês para preservar os efeitos das alterações contratuais.

  FOR i IN 1 .. F_RETORNA_NUMERO_DE_MESES(pInicioContagem, pFimContagem) LOOP

    --Se não existem alterações nos percentuais ou na convenção.

    IF (F_EXISTE_DUPLA_CONVENCAO(vCodCargoContrato, vMes, vAno, 2) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
      --Define a remuneração do cargo e os percentuais de décimo terceiro e incidência.
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
      vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Décimo terceiro salário', vMes, vAno, 1, 2);
      vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
      
      --Se existe direito de décimo terceiro para aquele mês.           

      IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
	  
        vTotalDecimoTerceiro := vTotalDecimoTerceiro + ((vRemuneracao * (vPercentualDecimoTerceiro/100)));
        vTotalIncidencia := vTotalIncidencia + ((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100));
      
      END IF;               
  
    END IF;

    --Se existe alteração de convenção.

    IF (F_EXISTE_DUPLA_CONVENCAO(vCodCargoContrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
      --Define a remuneração do cargo para a primeira metade do mês e os percentuais do mês.
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 2, 2);
      vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Décimo terceiro salário', vMes, vAno, 1, 2);
      vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
      
      --Se existe direito de décimo terceiro para aquele mês.          

      IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
	  
	      vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));
        vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));

        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
        
        vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 2));
        vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 2));
      
      END IF;               
  
    END IF;

    --Se existe apenas alteração de percentual no mês.

    IF (F_EXISTE_DUPLA_CONVENCAO(vCodCargoContrato, vMes, vAno, 2) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
      --Define a remuneração do cargo no mês e os percentuais do mês da primeira metade do mês.
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
      vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Décimo terceiro salário', vMes, vAno, 2, 2);
      vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 2, 2);
      
      --Se existe direito de férias para aquele mês.         

      IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN

	      vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
        vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));

        vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Décimo terceiro salário', vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
        
        vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 4));
        vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 4));
      
      END IF;               
  
    END IF;
    
    --Se existe alteração na convenção e nos percentuais.
    
    IF (F_EXISTE_DUPLA_CONVENCAO(vCodCargoContrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
      --Define a primeira remuneração do cargo no mês.
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 2, 2);
      
      --Definição do percentual antigo.
      
      vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Décimo terceiro salário', vMes, vAno, 2, 2);
      vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 2, 2);
      
      --Definição das datas para os períodos da convenção e percentuais.
      
      SELECT data_fim_convencao
        INTO vDataFimConvencao
        FROM tb_convencao_coletiva
        WHERE cod_cargo_contrato = vCodCargoContrato
          AND data_aditamento IS NOT NULL
          AND (EXTRACT(month FROM data_fim_convencao) = vMes
               AND EXTRACT(year FROM data_fim_convencao) = vAno);
               
      SELECT data_fim
        INTO vDataFimPercentual
        FROM tb_percentual_contrato
        WHERE cod_contrato = vCodContrato
          AND data_aditamento IS NOT NULL
          AND (EXTRACT(month FROM data_fim) = vMes
               AND EXTRACT(year FROM data_fim) = vAno);
               
      vDataInicioConvencao := vDataFimConvencao + 1;
      vDataInicioPercentual := vDataFimPercentual + 1;
      
      vDataReferencia := TO_DATE('01/' || vMes || '/' || vAno, 'dd/mm/yyyy');
      
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
      
      --Convenção acaba antes do percentual.
      
      IF (vDataFimConvencao < vDataFimPercentual) THEN
      
        --Se existe direito de décimo terceiro para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
   
          --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));
        
          --Definição da nova remuneração.
          
          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
          
          --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual atigo.
          
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30)  * (vDataFimPercentual - vDataInicioConvencao + 1));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimPercentual - vDataInicioConvencao + 1));
     
          --Definição do percentual novo.

          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Décimo terceiro salário', vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
          
          ----Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
    
        END IF;

        
      END IF;
      
      --Convenção acaba depois do percentual.
      
      IF (vDataFimConvencao > vDataFimPercentual) THEN
      
        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
        
          --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
          
           --Definição do percentual novo.

          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Décimo terceiro salário', vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
          
          --Retenção proporcional da segunda porção do mês para a remuneração antiga com percentual novo.
          
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimConvencao - vDataInicioPercentual + 1));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimConvencao - vDataInicioPercentual + 1));
          
          --Definição da nova remuneração.
          
          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
          
          --Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimMes - vDataInicioConvencao + 1));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioConvencao + 1));
      
        END IF;

        
      END IF;
      
      --Convenção acaba depois do percentual.
      
      IF (vDataFimConvencao = vDataFimPercentual) THEN
      
        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
        
          --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
          
          --Definição dos novos percentuais e da nova convenção .

          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Décimo terceiro salário', vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
          
          --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual novo.
          
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 4));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 4));
      
        END IF;
        
      END IF;    

    END IF;
    
    --Atualização do mês e ano conforme a sequência do loop.
    
    IF (vMes != 12) THEN
    
      vMes := vMes + 1;
    
    ELSE
    
      vMes := 1;
      vAno := vAno + 1;    
    
    END IF;

  END LOOP;

  --No caso de primeira parcela é liberado a metade daquilo que foi retido.
  
  IF (pNumeroParcela = 1 OR pNumeroParcela = 2) THEN

    vTotalDecimoTerceiro := vTotalDecimoTerceiro/2;
    vTotalIncidencia := vTotalIncidencia/2;

  END IF;

  --A incidência não é restituída para o empregado, portanto na movimentação
  --ela não deve ser computada. 
  
  IF (UPPER(F_RETORNA_TIPO_RESTITUICAO(pCodTipoResgate)) = 'MOVIMENTAÇÃO') THEN

    vTotalIncidencia := 0;

  END IF;
  
  --Também, em caso de movimentação aceitar o valor de décimo terceiro passado.
  
  IF (pNumeroParcela = 2) THEN
  
    vTotalDecimoTerceiro := pValor13;
  
  END IF;

  --Gravação no banco.
  
  INSERT INTO tb_restituicao_decimo_terceiro (cod_cargo_funcionario,
                                              cod_tipo_resgate,
                                              parcela,
                                              data_inicio_contagem,
                                              valor,
                                              incidencia_submodulo_4_1,
                                              data_referencia,
                                              login_atualizacao,
                                              data_atualizacao)
    VALUES (pCodCargoFuncionario,
            pCodTipoResgate,
            pNumeroParcela,
            pInicioContagem,
            vTotalDecimoTerceiro,
            vTotalIncidencia,
            SYSDATE,
           'SYSTEM',
            SYSDATE);

END;
