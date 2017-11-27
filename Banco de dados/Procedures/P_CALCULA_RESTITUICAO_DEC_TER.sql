create or replace procedure "P_CALCULA_RESTITUICAO_DEC_TER" (pCodCargoFuncionario NUMBER, 
                                                             pInicioPeriodoAquisitivo DATE, 
                                                             pFimPeriodoAquisitivo DATE) 
AS

--Procedure que calcula faz o registro de restituição de férias no banco de dados.

  vCodContrato NUMBER;
  vCodFuncionario NUMBER;
  vCodCargoContrato NUMBER;
  vAno NUMBER;
  vMes NUMBER;
  vPercentualFerias FLOAT := 0;
  vPercentualIncidencia FLOAT := 0;
  vRemuneracao FLOAT := 0;
  vTotalFerias FLOAT := 0;
  vTotalIncidencia FLOAT := 0;
  vSeProporcional CHAR;
  vDataInicioConvencao DATE;
  vDataFimConvencao DATE;
  vDataInicioPercentual DATE;
  vDataFimPercentual DATE;
  vDataReferencia DATE;
  vDataFimMes DATE;

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

  --Definir o valor das variáveis vMes e vAno de acordo com a data de início do período aquisitivo.

  vMes := EXTRACT(month FROM pInicioPeriodoAquisitivo);
  vAno := EXTRACT(year FROM pInicioPeriodoAquisitivo);

  --O cálculo é feito mês a mês para preservar os efeitos das alterações contratuais.

  FOR i IN 1 .. F_RETORNA_NUMERO_DE_MESES(pInicioPeriodoAquisitivo, pFimPeriodoAquisitivo) LOOP

    --Se não existem alterações nos percentuais ou na convenção.

    IF (F_EXISTE_DUPLA_CONVENCAO(vCodCargoContrato, vMes, vAno, 2) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
      --Define a remuneração do cargo e os percentuais de férias e incidência.
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
      vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Férias', vMes, vAno, 1, 2);
      vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
      
      --Se existe direito de férias para aquele mês.           

      IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
	  
	    vTotalFerias := vTotalFerias + ((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)));
        vTotalIncidencia := vTotalIncidencia + (((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100));
      
      END IF;               
  
    END IF;

    --Se existe alteração de convenção.

    IF (F_EXISTE_DUPLA_CONVENCAO(vCodCargoContrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
      --Define a remuneração do cargo para a primeira metade do mês e os percentuais do mês.
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 2, 2);
      vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Férias', vMes, vAno, 1, 2);
      vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
      
      --Se existe direito de férias para aquele mês.         

      IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
	  
	    vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));
        vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));

        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
        
        vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));
        vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));
      
      END IF;               
  
    END IF;

    --Se existe apenas alteração de percentual no mês.

    IF (F_EXISTE_DUPLA_CONVENCAO(vCodCargoContrato, vMes, vAno, 2) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
      --Define a remuneração do cargo no mês e os percentuais do mês da primeira metade do mês.
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
      vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Férias', vMes, vAno, 2, 2);
      vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 2, 2);
      
      --Se existe direito de férias para aquele mês.         

      IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN

	    vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
        vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));

        vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Férias', vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
        
        vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 4));
        vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 4));
      
      END IF;               
  
    END IF;
    
    --Se existe alteração na convenção e nos percentuais.
    
    IF (F_EXISTE_DUPLA_CONVENCAO(vCodCargoContrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
      --Define a primeira remuneração do cargo no mês.
            
      vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 2, 2);
      
      --Definição do percentual antigo.
      
      vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Férias', vMes, vAno, 2, 2);
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
      
        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
   
          --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

	      vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));
          vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 1));
        
          --Definição da nova remuneração.
          
          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
          
          --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual atigo.
          
          vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * (vDataFimPercentual - vDataInicioConvencao + 1));
          vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * (vDataFimPercentual - vDataInicioConvencao + 1));
     
          --Definição do percentual novo.

          vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Férias', vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
          
          ----Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
          vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * (vDataFimMes - vDataInicioPercentual + 1));
          vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
    
        END IF;

        
      END IF;
      
      --Convenção acaba depois do percentual.
      
      IF (vDataFimConvencao > vDataFimPercentual) THEN
      
        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
        
          --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

	      vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
          vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
          
           --Definição do percentual novo.

          vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Férias', vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
          
          --Retenção proporcional da segunda porção do mês para a remuneração antiga com percentual novo.
          
          vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * (vDataFimConvencao - vDataInicioPercentual + 1));
          vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * (vDataFimConvencao - vDataInicioPercentual + 1));
          
          --Definição da nova remuneração.
          
          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
          
          --Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
          vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * (vDataFimMes - vDataInicioConvencao + 1));
          vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioConvencao + 1));
      
        END IF;

        
      END IF;
      
      --Convenção acaba depois do percentual.
      
      IF (vDataFimConvencao = vDataFimPercentual) THEN
      
        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(pCodCargoFuncionario, vMes, vAno) = TRUE) THEN
        
          --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

	      vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
          vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 3));
          
          --Definição dos novos percentuais e da nova convenção .

          vPercentualFerias := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Férias', vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_PERIODO(vCodContrato, 'Incidência do submódulo 4.1', vMes, vAno, 1, 2);
          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(vCodCargoContrato, vMes, vAno, 1, 2);
          
          --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual novo.
          
          vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 4));
          vTotalIncidencia := vTotalIncidencia + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(vCodCargoContrato, vMes, vAno, 4));
      
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

  --Gravação no banco.
  
  INSERT INTO tb_restituicao_ferias (cod_contrato,
                                     cod_funcionario,
                                     data_inicio_periodo_aquisitivo,
                                     data_fim_periodo_aquisitivo,
                                     data_inicio_usufruto,
                                     data_fim_usufruto,
                                     valor_ferias_e_terco,
                                     valor_incidencia_submodulo_4_1,
                                     se_proporcional,
                                     data_referencia,
                                     login_atualizacao,
                                     data_atualizacao)
    VALUES (vCodContrato,
            vCodFuncionario,
            pInicioPeriodoAquisitivo,
            pFimPeriodoAquisitivo,
            pInicioContagem,
            pFimContagem,
            vTotalFerias,
            vTotalIncidencia,
            vSeProporcional,
            SYSDATE,
            'SYSTEM',
            SYSDATE);

END;