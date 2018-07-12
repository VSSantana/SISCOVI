create or replace procedure "P_CALCULA_RESCISAO" (pCodTerceirizadoContrato NUMBER, pCodTipoRestituicao NUMBER, pDataDesligamento DATE, pCodTipoRescisao CHAR) 
AS

  vDataDisponibilizacao DATE;

  vCodContrato NUMBER;
  vCodTerceirizado NUMBER;
  vCodFuncaoContrato NUMBER;
  vCodTbRestituicaoRescisao NUMBER;
  vAno NUMBER;
  vMes NUMBER;

  vPercentualDecimoTerceiro FLOAT := 0;
  vPercentualIncidencia FLOAT := 0;
  vPercentualFGTS FLOAT := 0;
  vPercentualMultaFGTS FLOAT := 0;
  vPercentualPenalidadeFGTS FLOAT := 0;
  vPercentualFerias FLOAT := 0;
  
  vRemuneracao FLOAT := 0;
  
  vTotalMultaFGTSRemuneracao FLOAT := 0;
  
  vTotalDecimoTerceiro FLOAT := 0;
  vTotalIncidenciaDecimoTerceiro FLOAT := 0;
  vTotalMultaFGTSDecimoTerceiro FLOAT := 0;
  
  vTotalFerias FLOAT := 0;
  vTotalTercoConstitucional FLOAT := 0;
  vTotalIncidenciaFerias FLOAT := 0;
  vTotalIncidenciaTerco FLOAT := 0;
  vTotalMultaFGTSFerias FLOAT := 0;
  vTotalMultaFGTSTerco FLOAT := 0;

  --Variáveis de controle do saldo residual

  vIncidDecTer FLOAT := 0;
  vFGTSDecimoTerceiro FLOAT := 0;
  vIncidFerias FLOAT := 0;
  vIncidTerco FLOAT := 0;
  vFGTSFerias FLOAT := 0;
  vFGTSTerco FLOAT := 0;
  vFGTSRemuneracao FLOAT := 0;

  --Varíaveis que contém o valor final dos itens da rescisão.
  vDecimoTerceiro FLOAT := 0;
  vIncidSubmod41DecTer FLOAT := 0;
  vFerias FLOAT := 0;
  vTerco FLOAT := 0;
  vIncidSubmod41Ferias FLOAT := 0;
  vIncidSubmod41Terco FLOAT := 0;

  --Variáveis de datas. 
  vDataInicioRemuneracao DATE;
  vDataFimRemuneracao DATE;
  vDataInicioPercentual DATE;
  vDataFimPercentual DATE := NULL;
  vDataFimPercentualEstatico DATE := NULL;
  vDataReferencia DATE;
  vDataFimMes DATE;

  vDiasDeFerias NUMBER := 0;
  vDiasAdquiridos NUMBER := 0;
  vDiasVendidos NUMBER := 0;
  vNumeroDeMeses NUMBER := 0;
  vNumeroDeAnos NUMBER := 0;

  vRemuneracaoException EXCEPTION;
  vPeriodoException EXCEPTION;
  vContratoException EXCEPTION;
  vParametroNulo EXCEPTION;

BEGIN

  --Todos os parâmetros estão preenchidos.

  IF (pCodTerceirizadoContrato IS NULL OR
      pCodTipoRestituicao IS NULL OR
      pDataDesligamento IS NULL OR
      pCodTipoRescisao IS NULL) THEN
  
    RAISE vParametroNulo;
  
  END IF;

  --Carregar o cod do terceirizado, a data de disponibilizacao e o cod do contrato.

  SELECT tc.cod_terceirizado,
         tc.cod_contrato,
         tc.data_disponibilizacao
    INTO vCodTerceirizado,
         vCodContrato,
         vDataDisponibilizacao
    FROM tb_terceirizado_contrato tc 
    WHERE tc.cod = pCodTerceirizadoContrato;

  --Definição do total de vezes que o loop de cálculo será executado.
  
  vNumeroDeMeses := F_RETORNA_NUMERO_DE_MESES(vDataDisponibilizacao, pDataDesligamento);

  --Número de anos a serem contabilizados.

  SELECT (EXTRACT(year FROM pDataDesligamento) - EXTRACT(year FROM vDataDisponibilizacao)) + 1
    INTO vNumeroDeAnos
    FROM DUAL;
  
  --Cálculo dos valores relacionados ao 13° e a multa do FGTS sobre a remuneração.

  --Definir o valor das variáveis vMes e vAno de acordo com a data de início da contagem.

  vMes := EXTRACT(month FROM vDataDisponibilizacao);
  vAno := EXTRACT(year FROM vDataDisponibilizacao);

  --O cálculo é feito mês a mês para preservar os efeitos das alterações contratuais.

  FOR i IN 1 .. vNumeroDeMeses LOOP

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
        vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 1, 2);
        vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 1, 2);
        vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 1, 2);

        IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
        END IF;
      
        --Se existe direito de décimo terceiro para aquele mês.           

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
	  
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + ((vRemuneracao * (vPercentualDecimoTerceiro/100)));
          vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100));
          vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)));
          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)));

        END IF;

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_DIAS_TRABALHADOS_MES(f.cod, vMes, vAno));              
        
        END IF;

      END IF;

      --Se existe alteração de convenção.
 
      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
        --Define a remuneração do cargo para a primeira metade do mês e os percentuais do mês.
             
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 2, 2);
        vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
        vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 1, 2);
        vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 1, 2);
        vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 1, 2);

        IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
        END IF;
      
        --Se existe direito de décimo terceiro para aquele mês.          

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
	  
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));       
            
          vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));

          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

          IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
          END IF;
        
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));

        END IF;

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));              
      
          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

          IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
          END IF;

          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));

        END IF;               
  
      END IF;

      --Se existe apenas alteração de percentual no mês.

      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
        --Define a remuneração do cargo no mês e os percentuais do mês da primeira metade do mês.
             
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);
        vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 2, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 2, 2);
        vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 2, 2);
        vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 2, 2);
        vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 2, 2);

        IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
        END IF;
      
        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN

          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));

          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
          
          vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));

        END IF;

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));              
        
          vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);

          vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));

        END IF;                 
  
      END IF;
    
      --Se existe alteração na convenção e nos percentuais.
   
      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN

        vDataFimPercentual := NULL;
        vDataFimPercentualEstatico := NULL;
        vDataFimRemuneracao := NULL;
    
        --Define a primeira remuneração do cargo no mês.
          
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 2, 2);

        IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
        END IF;
    
        --Definição do percentual antigo.
      
        vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 2, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 2, 2);
        vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 2, 2);
        vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 2, 2);
        vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 2, 2);
      
        --Definição das datas para os períodos da convenção e percentuais.
   
        SELECT data_fim
          INTO vDataFimRemuneracao
          FROM tb_remuneracao_fun_con
          WHERE cod_funcao_contrato = f.cod_funcao_contrato
            AND data_aditamento IS NOT NULL
            AND (EXTRACT(month FROM data_fim) = vMes
                 AND EXTRACT(year FROM data_fim) = vAno);
               
        --Observação: datas dos percentuais são todas iguais para um bloco.

        --Para o percentual do contrato.

        IF (F_MUNDANCA_PERCENTUAL_CONTRATO(vCodContrato, vMes, vAno, 1) = TRUE) THEN

          SELECT DISTINCT(data_fim)
            INTO vDataFimPercentual
            FROM tb_percentual_contrato
            WHERE cod_contrato = vCodContrato
              AND data_aditamento IS NOT NULL
              AND (EXTRACT(month FROM data_fim) = vMes
                   AND EXTRACT(year FROM data_fim) = vAno);

        END IF;

        --Para o percentual estático.
  
        IF (F_MUNDANCA_PERCENTUAL_ESTATICO(vCodContrato, vMes, vAno, 1) = TRUE) THEN
 
          SELECT DISTINCT(data_fim)
            INTO vDataFimPercentualEstatico
            FROM tb_percentual_estatico
            WHERE data_aditamento IS NOT NULL
              AND (EXTRACT(month FROM data_fim) = vMes
                   AND EXTRACT(year FROM data_fim) = vAno);

        END IF;

        --Decisão da data fim do percentual.

        IF (vDataFimPercentual IS NOT NULL AND vDataFimPercentualEstatico IS NOT NULL) THEN

          SELECT GREATEST(vDataFimPercentual, vDataFimPercentualEstatico)
            INTO vDataFimPercentual
            FROM DUAL;
 
        END IF;
               
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
            vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));

            --Definição da nova remuneração.
          
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
          
            --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual atigo.
          
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));

            --Definição do percentual novo.

            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
              
            ----Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
         
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * (vDataFimMes - vDataInicioPercentual + 1));

          END IF;

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.
 
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));

            --Definição da nova remuneração.
          
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
           
            --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual atigo.
          
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));

            --Definição do percentual novo.

            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
           
            ----Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
          
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * (vDataFimMes - vDataInicioPercentual + 1));
          
          END IF;   

        END IF;
      
        --Convenção acaba depois do percentual.
      
        IF (vDataFimRemuneracao > vDataFimPercentual) THEN
     
          --Se existe direito de férias para aquele mês.         

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
        
            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.
   
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            
            vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));

            --Definição do percentual novo.

            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
           
            --Retenção proporcional da segunda porção do mês para a remuneração antiga com percentual novo.
          
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
          
            vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));

            --Definição da nova remuneração.
          
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
          
            --Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
              
            vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));

          END IF;

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.
  
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));

            --Definição do percentual novo.

            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
          
            --Retenção proporcional da segunda porção do mês para a remuneração antiga com percentual novo.
          
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));

            --Definição da nova remuneração.
          
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
          
            --Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));

          END IF;
        
        END IF;
      
        --Convenção acaba depois do percentual.
      
        IF (vDataFimRemuneracao = vDataFimPercentual) THEN
      
          --Se existe direito de férias para aquele mês.         

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
        
            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
         
            vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));

            --Definição dos novos percentuais e da nova convenção .

            vPercentualDecimoTerceiro := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 3, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
         
            --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual novo.
          
            vTotalDecimoTerceiro := vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            vTotalIncidenciaDecimoTerceiro := vTotalIncidenciaDecimoTerceiro + ((((vRemuneracao * (vPercentualDecimoTerceiro/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
      
            vTotalMultaFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualDecimoTerceiro/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            vTotalMultaFGTSRemuneracao := vTotalMultaFGTSRemuneracao + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));

          END IF;
        
        END IF;    

      END IF;

      --Atualização dos valores finais totais devidos.

      IF (vMes = 12 OR (vMes = EXTRACT(month FROM pDataDesligamento) AND vAno = EXTRACT(year FROM pDataDesligamento))) THEN

        --Para o valor do décimo terceiro.

        IF (vTotalDecimoTerceiro - F_SALDO_CONTA_VINCULADA (pCodTerceirizadoContrato, vAno, 3, 3) <= 0) THEN

          vTotalDecimoTerceiro := 0;

        ELSE

          vDecimoTerceiro :=  vDecimoTerceiro + (vTotalDecimoTerceiro - F_SALDO_CONTA_VINCULADA (pCodTerceirizadoContrato, vAno, 3, 3));
          vTotalDecimoTerceiro := 0;

        END IF;

        --Para o valor da incidência do décimo terceiro.

        IF (vTotalIncidenciaDecimoTerceiro - F_SALDO_CONTA_VINCULADA (pCodTerceirizadoContrato, vAno, 3, 103) <= 0) THEN

          vTotalIncidenciaDecimoTerceiro := 0;

        ELSE

          vIncidSubmod41DecTer :=  vIncidSubmod41DecTer + (vTotalIncidenciaDecimoTerceiro - F_SALDO_CONTA_VINCULADA (pCodTerceirizadoContrato, vAno, 3, 103));
          vTotalIncidenciaDecimoTerceiro := 0;

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

  --A incidência não é restituída para o empregado, portanto na movimentação
  --ela não deve ser computada. 
  
  IF (UPPER(F_RETORNA_TIPO_RESTITUICAO(pCodTipoRestituicao)) = 'MOVIMENTAÇÃO') THEN

    vTotalIncidenciaDecimoTerceiro := 0;

  END IF;

  --Cálculos relacionados às férias. 

  --Definir o valor das variáveis vMes e vAno de acordo com a data de início do período aquisitivo.

  vMes := EXTRACT(month FROM vDataDisponibilizacao);
  vAno := EXTRACT(year FROM vDataDisponibilizacao);

  --O cálculo é feito mês a mês para preservar os efeitos das alterações contratuais.

  FOR i IN 1 .. vNumeroDeMeses LOOP

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
    
        --Define a remuneração do cargo e os percentuais de férias e incidência.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);
        vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
        vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 1, 2);
        vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 1, 2);
        vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 1, 2);

        IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
        END IF;
      
        --Se existe direito de férias para aquele mês.           

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
	  
          vTotalFerias := vTotalFerias + ((vRemuneracao * (vPercentualFerias/100)));
          vTotalTercoConstitucional := vTotalTercoConstitucional + (vRemuneracao * ((vPercentualFerias/100)/3));
          vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100));
          vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100));
          vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)));
          vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)));
          
        END IF;               
  
      END IF;

      --Se existe alteração de convenção.

      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
        --Define a remuneração do cargo para a primeira metade do mês e os percentuais do mês.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 2, 2);
        vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
        vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 1, 2);
        vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 1, 2);
        vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 1, 2);
      
        IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
        END IF;

        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
	  
          vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
          
          vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

          IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
          END IF;
        
          vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 2));
          
        END IF;               
  
      END IF;

      --Se existe apenas alteração de percentual no mês.

      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = FALSE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
        --Define a remuneração do cargo no mês e os percentuais do mês da primeira metade do mês.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);
        vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 2, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 2, 2);
        vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 2, 2);
        vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 2, 2);
        vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 2, 2);

        IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
        END IF;
      
        --Se existe direito de férias para aquele mês.         

        IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN

	        vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
          
          vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 1, 2);
          vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
          vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 1, 2);
          vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 1, 2);
          vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 1, 2);
        
          vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
          
        END IF;               
  
      END IF;
    
      --Se existe alteração na convenção e nos percentuais.
    
      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = TRUE AND F_EXISTE_MUDANCA_PERCENTUAL(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
        vDataFimPercentual := NULL;
        vDataFimPercentualEstatico := NULL;
        vDataFimRemuneracao := NULL;
    
        --Define a primeira remuneração do cargo no mês.
          
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 2, 2);

        IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
        END IF;
    
        --Definição do percentual antigo.
      
        vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 2, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 2, 2);
        vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 2, 2);
        vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 2, 2);
        vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 2, 2);
      
        --Definição das datas para os períodos da convenção e percentuais.
   
        SELECT data_fim
          INTO vDataFimRemuneracao
          FROM tb_remuneracao_fun_con
          WHERE cod_funcao_contrato = f.cod_funcao_contrato
            AND data_aditamento IS NOT NULL
            AND (EXTRACT(month FROM data_fim) = vMes
                 AND EXTRACT(year FROM data_fim) = vAno);
               
        --Observação: datas dos percentuais são todas iguais para um bloco.

        --Para o percentual do contrato.

        IF (F_MUNDANCA_PERCENTUAL_CONTRATO(vCodContrato, vMes, vAno, 1) = TRUE) THEN

          SELECT DISTINCT(data_fim)
            INTO vDataFimPercentual
            FROM tb_percentual_contrato
            WHERE cod_contrato = vCodContrato
              AND data_aditamento IS NOT NULL
              AND (EXTRACT(month FROM data_fim) = vMes
                   AND EXTRACT(year FROM data_fim) = vAno);

        END IF;

        --Para o percentual estático.
  
        IF (F_MUNDANCA_PERCENTUAL_ESTATICO(vCodContrato, vMes, vAno, 1) = TRUE) THEN
 
          SELECT DISTINCT(data_fim)
            INTO vDataFimPercentualEstatico
            FROM tb_percentual_estatico
            WHERE data_aditamento IS NOT NULL
              AND (EXTRACT(month FROM data_fim) = vMes
                   AND EXTRACT(year FROM data_fim) = vAno);

        END IF;

        --Decisão da data fim do percentual.

        IF (vDataFimPercentual IS NOT NULL AND vDataFimPercentualEstatico IS NOT NULL) THEN

          SELECT GREATEST(vDataFimPercentual, vDataFimPercentualEstatico)
            INTO vDataFimPercentual
            FROM DUAL;
 
        END IF;
               
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
      
          --Se existe direito de férias para aquele mês.         

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
   
            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

            vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 1));
            
            --Definição da nova remuneração.
          
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
          
            --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual atigo.
            
            vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30)  * (vDataFimPercentual - vDataInicioRemuneracao + 1));
            
            --Definição do percentual novo.

            vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
            vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 1, 2);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 1, 2);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 1, 2);
          
            --Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
            vTotalFerias := vTotalFerias + (((vRemuneracao * (vPercentualFerias/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + (((((vRemuneracao * (vPercentualFerias/100)) + (vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
    
            vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * (vDataFimMes - vDataInicioPercentual + 1));
            
          END IF;
        
        END IF;
      
        --Convenção acaba depois do percentual.
      
        IF (vDataFimRemuneracao > vDataFimPercentual) THEN
      
          --Se existe direito de férias para aquele mês.         

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
        
            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

            vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            
            --Definição do percentual novo.

            vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
            vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 1, 2);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 1, 2);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 1, 2);
            
            --Retenção proporcional da segunda porção do mês para a remuneração antiga com percentual novo.
          
            vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * (vDataFimRemuneracao - vDataInicioPercentual + 1));
            
            --Definição da nova remuneração.
          
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);

            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
          
            --Retenção proporcional da terça parte do mês para a remuneração nova com percentual novo.
        
            vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * (vDataFimMes - vDataInicioRemuneracao + 1));
            
          END IF;
  
        END IF;
      
        --Convenção acaba depois do percentual.
      
        IF (vDataFimRemuneracao = vDataFimPercentual) THEN
      
          --Se existe direito de férias para aquele mês.         

          IF (F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = TRUE) THEN
        
            --Retenção proporcional da primeira porção do mês para a remuneração antiga com percentual antigo.

            vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 3));
            
            --Definição dos novos percentuais e da nova convenção .

            vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 1, 2);
            vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
            vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);
            vPercentualFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 4, vMes, vAno, 1, 2);
            vPercentualMultaFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 5, vMes, vAno, 1, 2);
            vPercentualPenalidadeFGTS := F_RETORNA_PERCENTUAL_ESTATICO (vCodContrato, 6, vMes, vAno, 1, 2);


            IF (vRemuneracao IS NULL) THEN
      
              RAISE vRemuneracaoException;
        
            END IF;
           
            --Retenção proporcional da segunda porção do mês para a remuneração nova com percentual novo.
          
            vTotalFerias := vTotalFerias + ((((vRemuneracao * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            vTotalTercoConstitucional := vTotalTercoConstitucional + (((vRemuneracao * ((vPercentualFerias/100)/3))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            vTotalIncidenciaFerias := vTotalIncidenciaFerias + ((((vRemuneracao * (vPercentualFerias/100)) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            vTotalIncidenciaTerco := vTotalIncidenciaTerco + (((((vRemuneracao * ((vPercentualFerias/100)/3))) * (vPercentualIncidencia/100))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            vTotalMultaFGTSFerias := vTotalMultaFGTSFerias + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * (vPercentualFerias/100)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            vTotalMultaFGTSTerco := vTotalMultaFGTSTerco + (((vRemuneracao * ((vPercentualFGTS/100) * (vPercentualMultaFGTS/100) * (vPercentualPenalidadeFGTS/100) * ((vPercentualFerias/100)/3)))/30) * F_RET_NUMERO_DIAS_MES_PARCIAL(f.cod_funcao_contrato, vMes, vAno, 4));
            
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

  --Contabilização do valor final (valor calculado menos restituições).

  vAno := EXTRACT(year FROM vDataDisponibilizacao);

  FOR i IN 1 .. vNumeroDeAnos LOOP

    vTotalFerias := (vTotalFerias - F_SALDO_CONTA_VINCULADA (pCodTerceirizadoContrato, vAno, 2, 1));
    vTotalTercoConstitucional :=  (vTotalTercoConstitucional - F_SALDO_CONTA_VINCULADA (pCodTerceirizadoContrato, vAno, 2, 2));
    vTotalIncidenciaFerias :=  (vTotalIncidenciaFerias - F_SALDO_CONTA_VINCULADA (pCodTerceirizadoContrato, vAno, 2, 101));
    vTotalIncidenciaTerco :=  (vTotalIncidenciaTerco - F_SALDO_CONTA_VINCULADA (pCodTerceirizadoContrato, vAno, 2, 102));

    vAno := vAno + 1;

  END LOOP;

  IF (vTotalFerias >= 0) THEN

    vFerias := vTotalFerias;

  END IF;

  IF (vTotalTercoConstitucional >= 0) THEN

    vTerco := vTotalTercoConstitucional;

  END IF;

  IF (vTotalIncidenciaFerias >= 0) THEN

    vIncidSubmod41Ferias := vTotalIncidenciaFerias;

  END IF;

  IF (vTotalIncidenciaTerco >= 0) THEN

    vIncidSubmod41Terco := vTotalIncidenciaTerco;

  END IF;

  --Chave primária do registro a ser inserido na tabela tb_restituicao_rescisao.

  vCodTbRestituicaoRescisao := tb_restituicao_rescisao_cod.nextval;

  --Readequação das variáveis para a manutenção.
  
  IF (UPPER(F_RETORNA_TIPO_RESTITUICAO(pCodTipoRestituicao)) = 'MOVIMENTAÇÃO') THEN

    vIncidDecTer := vIncidSubmod41DecTer;
    vFGTSDecimoTerceiro := vTotalMultaFGTSDecimoTerceiro;
    vIncidFerias := vIncidSubmod41Ferias;
    vIncidTerco :=vIncidSubmod41Terco;
    vFGTSFerias := vTotalMultaFGTSFerias;
    vFGTSTerco := vTotalMultaFGTSTerco;
    vFGTSRemuneracao := vTotalMultaFGTSRemuneracao;
      
    vIncidSubmod41DecTer := 0;
    vTotalMultaFGTSDecimoTerceiro := 0;
    vIncidSubmod41Ferias := 0;
    vIncidSubmod41Terco := 0;
    vTotalMultaFGTSFerias := 0;
    vTotalMultaFGTSTerco := 0;
    vTotalMultaFGTSRemuneracao := 0;

  END IF;
  
  INSERT INTO tb_restituicao_rescisao (cod,
                                       cod_terceirizado_contrato,
                                       cod_tipo_restituicao,
                                       cod_tipo_rescisao,
                                       data_desligamento,
                                       valor_decimo_terceiro,
                                       incid_submod_4_1_dec_terceiro,
                                       incid_multa_fgts_dec_terceiro,
                                       valor_ferias,
                                       valor_terco,
                                       incid_submod_4_1_ferias,
                                       incid_submod_4_1_terco,
                                       incid_multa_fgts_ferias,
                                       incid_multa_fgts_terco,
                                       multa_fgts_salario,
                                       data_referencia,
                                       login_atualizacao,
                                       data_atualizacao)
      VALUES (vCodTbRestituicaoRescisao,
              pCodTerceirizadoContrato,
              pCodTipoRestituicao,
              pCodTipoRescisao,
              pDataDesligamento,
              vDecimoTerceiro,
              vIncidSubmod41DecTer,
              vTotalMultaFGTSDecimoTerceiro,
              vFerias,
              vTerco,
              vIncidSubmod41Ferias,
              vIncidSubmod41Terco,
              vTotalMultaFGTSFerias,
              vTotalMultaFGTSTerco,
              vTotalMultaFGTSRemuneracao,
              SYSDATE,
              'SYSTEM',
              SYSDATE);

  
  IF (UPPER(F_RETORNA_TIPO_RESTITUICAO(pCodTipoRestituicao)) = 'MOVIMENTAÇÃO') THEN

    INSERT INTO tb_saldo_residual_rescisao (cod_restituicao_rescisao,
                                            valor_decimo_terceiro,
                                            incid_submod_4_1_dec_terceiro,
                                            incid_multa_fgts_dec_terceiro,
                                            valor_ferias,
                                            valor_terco,
                                            incid_submod_4_1_ferias,
                                            incid_submod_4_1_terco,
                                            incid_multa_fgts_ferias,
                                            incid_multa_fgts_terco,
                                            multa_fgts_salario,
                                            restituido,
                                            login_atualizacao,
                                            data_atualizacao)
      VALUES (vCodTbRestituicaoRescisao,
              0,
              vIncidDecTer,
              vFGTSDecimoTerceiro,
              0,
              0,
              vIncidFerias,
              vIncidTerco,
              vFGTSFerias,
              vFGTSTerco,
              vFGTSRemuneracao, 
              'N',
              'SYSTEM',
              SYSDATE);

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
