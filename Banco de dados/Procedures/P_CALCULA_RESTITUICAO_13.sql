create or replace procedure "P_CALCULA_RESTITUICAO_13" (pCodTerceirizadoContrato NUMBER,
                                                        pCodTipoRestituicao NUMBER,
                                                        pNumeroParcela NUMBER,
                                                        pInicioContagem DATE,
                                                        pFimContagem DATE,
                                                        pValor13 FLOAT) AS

--Procedure que calcula faz o registro de restituição de férias no banco de dados.

  vCodContrato NUMBER;
  vCodTerceirizado NUMBER;
  vCodFuncaoContrato NUMBER;
  vCodTbRestituicao13 NUMBER;
  vAno NUMBER;
  vMes NUMBER;
  vPercentualDecimoTerceiro FLOAT := 0;
  vPercentualIncidencia FLOAT := 0;
  vRemuneracao FLOAT := 0;
  vTotalDecimoTerceiro FLOAT := 0;
  vTotalIncidencia FLOAT := 0;
  vValor FLOAT := 0;
  vIncidencia FLOAT := 0; 
  vDataInicioRemuneracao DATE;
  vDataFimRemuneracao DATE;
  vDataInicioPercentual DATE;
  vDataFimPercentual DATE;
  vDataReferencia DATE;
  vDataFimMes DATE;

  vParametroNulo EXCEPTION;
  vRemuneracaoException EXCEPTION;
  vPeriodoException EXCEPTION;
  vContratoException EXCEPTION;

BEGIN

  --Todos os parâmetros estão preenchidos.

  IF (pCodTerceirizadoContrato IS NULL OR
      pCodTipoRestituicao IS NULL OR
      pNumeroParcela IS NULL OR
      pInicioContagem IS NULL OR
      pFimContagem IS NULL OR
      pValor13 IS NULL) THEN
  
    RAISE vParametroNulo;
  
  END IF;

   --Carregar o cod do terceirizado e do contrato.

  SELECT tc.cod_terceirizado,
         tc.cod_contrato
    INTO vCodTerceirizado,
         vCodContrato
    FROM tb_terceirizado_contrato tc 
    WHERE tc.cod = pCodTerceirizadoContrato;

  --Definir o valor das variáveis vMes e vAno de acordo com a data de início da contagem.

  vMes := EXTRACT(month FROM pInicioContagem);
  vAno := EXTRACT(year FROM pInicioContagem);

  --O cálculo é feito mês a mês para preservar os efeitos das alterações contratuais.

  FOR i IN 1 .. F_RETORNA_NUMERO_DE_MESES(pInicioContagem, pFimContagem) LOOP

    FOR f IN (SELECT ft.cod_funcao_contrato,
                     ft.cod
                FROM tb_funcao_terceirizado ft
                WHERE ft.cod_terceirizado_contrato = pCodTerceirizadoContrato
                  AND (((TO_DATE('01/' || EXTRACT(month FROM ft.data_inicio) || '/' || EXTRACT(year FROM ft.data_inicio), 'dd/mm/yyyy') <= TO_DATE('01/' || vMes || '/' || vAno, 'dd/mm/yyyy'))
                       AND 
                       (ft.data_fim >= TO_DATE('01/' || vMes || '/' || vAno, 'dd/mm/yyyy')))
                        OR
                       ((TO_DATE('01/' || EXTRACT(month FROM ft.data_inicio) || '/' || EXTRACT(year FROM ft.data_inicio), 'dd/mm/yyyy') <= TO_DATE('01/' || vMes || '/' || vAno, 'dd/mm/yyyy'))
                        AND
                       (ft.data_fim IS NULL)))) LOOP

      --Se não existem alterações nos percentuais ou na convenção.

      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
        --Define a remuneração do cargo e os percentuais de décimo terceiro e incidência.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);
        vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);

        IF (vRemuneracao IS NULL) THEN
      
          RAISE vRemuneracaoException;
        
        END IF;
      
        --Se existe direito de décimo terceiro para aquele mês.           

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
	  
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + ((vRemuneracao * (vPercentualDecimoTerceiro/100)));
          vTotalIncidencia := vTotalIncidencia + ((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100));
        
        END IF;               
  
      END IF;

      --Se existe alteração de convenção.

      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
        --Define a remuneração do cargo para a primeira metade do mês e os percentuais do mês.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 2, 2);
        vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);

        IF (vRemuneracao IS NULL) THEN
      
          RAISE vRemuneracaoException;
        
        END IF;
      
        --Se existe direito de décimo terceiro para aquele mês.          

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
	  
	        vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));

          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

          IF (vRemuneracao IS NULL) THEN
      
            RAISE vRemuneracaoException;
        
          END IF;
        
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
      
        END IF;               
  
      END IF;

      --Se existe apenas alteração de percentual no mês.

      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
        --Define a remuneração do cargo no mês e os percentuais do mês da primeira metade do mês.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);
        vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 2, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 2, 2);

        IF (vRemuneracao IS NULL) THEN
      
          RAISE vRemuneracaoException;
        
        END IF;
      
        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN

	        vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));

          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
         
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
      
        END IF;               
  
      END IF;
    
      --Se existe alteração na convenção e nos percentuais.
    
      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN

        vDataFimPercentual := NULL;
        vDataFimRemuneracao := NULL;
    
        --Define a primeira remuneração do cargo no mês.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 2, 2);

        IF (vRemuneracao IS NULL) THEN
      
          RAISE vRemuneracaoException;
        
        END IF;
      
        --Definição do percentual antigo.
      
        vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 2, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 2, 2);
      
        --Definição das datas para os períodos da convenção e percentuais.
      
        SELECT DISTINCT (data_fim)
          INTO vDataFimRemuneracao
          FROM tb_remuneracao_fun_con
          WHERE cod_funcao_contrato = f.cod_funcao_contrato
            AND data_aditamento IS NOT NULL
            AND (EXTRACT(month FROM data_fim) = vMes
                 AND EXTRACT(year FROM data_fim) = vAno);
               
        SELECT DISTINCT (data_fim)
          INTO vDataFimPercentual
          FROM tb_percentual_contrato
          WHERE cod_contrato = vCodContrato
            AND data_aditamento IS NOT NULL
            AND (EXTRACT(month FROM data_fim) = vMes
                 AND EXTRACT(year FROM data_fim) = vAno);
               
        vDataInicioRemuneracao := vDataFimRemuneracao + 1;
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
      
        IF (vDataFimRemuneracao < vDataFimPercentual) THEN
      
          --Se existe direito de décimo terceiro para aquele mês.         

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
   
            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
        
            --Definição da nova remuneração.
          
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
          
            --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual atigo.
          
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimPercentual - vDataInicioRemuneracao + 1));
     
            --Definição do percentual novo.

            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
          
            ----Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
    
          END IF;
        
        END IF;
      
        --Convenção acaba depois do percentual.
      
        IF (vDataFimRemuneracao > vDataFimPercentual) THEN
      
          --Se existe direito de férias para aquele mês.         

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
        
            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          
            --Definição do percentual novo.

            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
          
            --Retenção proporcional da segunda porção do mês para a remuneração antiga com percentual novo.
          
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
           
            --Definição da nova remuneração.
          
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
          
            --Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
      
          END IF;
  
        END IF;
      
        --Convenção acaba depois do percentual.
      
        IF (vDataFimRemuneracao = vDataFimPercentual) THEN
      
          --Se existe direito de férias para aquele mês.         

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
        
            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          
            --Definição dos novos percentuais e da nova convenção .

            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
          
            --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual novo.
          
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            vTotalIncidencia := vTotalIncidencia + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
      
          END IF;
        
        END IF;    

      END IF;

    END LOOP;
    
    --Atualização do mês e ano conforme a sequência do loop.
    
    IF (vMes != 12) THEN
    
      vMes := vMes + 1;
    
    ELSE
    
      vMes := 1;
      vAno := vAno + 1;    
    
    END IF;

  END LOOP;

    vCodTbRestituicao13 := tb_rest_dec_ter_seq.nextval;

    --No caso de primeira parcela é liberado a metade daquilo que foi retido.
  
  IF (pNumeroParcela = 1 OR pNumeroParcela = 2) THEN

    vTotalDecimoTerceiro := vTotalDecimoTerceiro/2;
    vTotalIncidencia := vTotalIncidencia/2;

  END IF;

  --No caso de segunda parcela a movimentação gera resíduos referentes ao
  --valor do décimo terceiro que é afetado pelos descontos (IRPF, INSS e etc.)

  IF ((pNumeroParcela = 2 OR pNumeroParcela = 0) AND UPPER(F_RETORNA_TIPO_RESTITUICAO(pCodTipoRestituicao)) = 'MOVIMENTAÇÃO') THEN

    vValor := vTotalDecimoTerceiro - pValor13;

    vTotalDecimoTerceiro := pValor13;    

  END IF;

  --A incidência não é restituída para o empregado, portanto na movimentação
  --ela não deve ser computada. 
  
  IF (UPPER(F_RETORNA_TIPO_RESTITUICAO(pCodTipoRestituicao)) = 'MOVIMENTAÇÃO') THEN

    vIncidencia := vTotalIncidencia;

    vTotalIncidencia := 0;

  END IF;
  
  --Gravação no banco.
  
  INSERT INTO tb_restituicao_decimo_terceiro (cod,
                                              cod_terceirizado_contrato,
                                              cod_tipo_restituicao,
                                              parcela,
                                              data_inicio_contagem,
                                              valor,
                                              incidencia_submodulo_4_1,
                                              data_referencia,
                                              login_atualizacao,
                                              data_atualizacao)
    VALUES (vCodTbRestituicao13,
            pCodTerceirizadoContrato,
            pCodTipoRestituicao,
            pNumeroParcela,
            pInicioContagem,
            vTotalDecimoTerceiro,
            vTotalIncidencia,
            SYSDATE,
           'SYSTEM',
            SYSDATE);

  --Da primeira parcela sobra metade do valor de décimo terceiro.

  IF (pNumeroParcela = 1 AND UPPER(F_RETORNA_TIPO_RESTITUICAO(pCodTipoRestituicao)) = 'MOVIMENTAÇÃO') THEN

    vValor := vTotalDecimoTerceiro;    

  END IF;          

  --A incidência não é restituída para o empregado, portanto na movimentação
  --ela não deve ser computada. 
  
  IF (UPPER(F_RETORNA_TIPO_RESTITUICAO(pCodTipoRestituicao)) = 'MOVIMENTAÇÃO') THEN

    INSERT INTO tb_saldo_residual_dec_ter (cod_restituicao_dec_terceiro,
                                           valor,
                                           incidencia_submodulo_4_1,
                                           restituido,
                                           login_atualizacao,
                                           data_atualizacao)
      VALUES (vCodTbRestituicao13,
              vValor,
              vIncidencia,
              'N',
              'SYSTEM',
              SYSDATE);

    vTotalIncidencia := 0;

  END IF;

  EXCEPTION 
    
    WHEN vParametroNulo THEN

      RAISE_APPLICATION_ERROR(-20001, 'Falha no procedimento P_CALCULA_RESTITUICAO_FERIAS: parâmetro nulo.');

    WHEN vRemuneracaoException THEN

      RAISE_APPLICATION_ERROR(-20002, 'Erro na execução do procedimento: Remuneração não encontrada.');
      
    WHEN OTHERS THEN
    
      RAISE_APPLICATION_ERROR(-20003, 'Falha no procedimento P_CALCULA_RESTITUICAO_FERIAS.');

END;