create or replace procedure "P_CALCULA_RESCISAO" (pCodTerceirizadoContrato NUMBER, pCodTipoRestituicao NUMBER, pDataDesligamento DATE, pCodTipoRescisao CHAR) 
AS

  --Para DEBUG no ORACLE: DBMS_OUTPUT.PUT_LINE(vTotalFerias);

  --Chaves primárias

  vCodContrato NUMBER;
  vCodTbRestituicaoFerias NUMBER
  vCodTbRestituicaoRescisao NUMBER;

  --Variáveis totalizadoras de valores.

  vTotalFerias FLOAT := 0;
  vTotalTercoConstitucional FLOAT := 0;
  vTotalDecimoTerceiro FLOAT := 0;
  vTotalIncidenciaFerias FLOAT := 0;
  vTotalIncidenciaTerco FLOAT := 0;
  vTotalIncidenciaDecimoTerceiro FLOAT := 0;
  vTotalMultaFGTSRemuneracao FLOAT := 0;
  vTotalMultaFGTSFerias FLOAT := 0;
  vTotalMultaFGTSTerco FLOAT := 0;
  vTotalMultaFGTSDecimoTerceiro FLOAT := 0;

  --Variáveis de valores parciais.

  vValorFerias FLOAT := 0;
  vValorTercoConstitucional FLOAT := 0;
  vValorDecimoTerceiro FLOAT := 0;
  vValorIncidenciaFerias FLOAT := 0;
  vValorIncidenciaTerco FLOAT := 0;
  vValorIncidenciaDecimoTerceiro FLOAT := 0;
  vValorMultaFGTSRemuneracao FLOAT := 0;
  vValorMultaFGTSFerias FLOAT := 0;
  vValorMultaFGTSTerco FLOAT := 0;
  vValorMultaFGTSDecimoTerceiro FLOAT := 0;

  --Variáveis de percentuais.

  vPercentualFerias FLOAT := 0;
  vPercentualTercoConstitucional FLOAT := 0;
  vPercentualDecimoTerceiro FLOAT := 0;
  vPercentualIncidencia FLOAT := 0;
  vPercentualFGTS FLOAT := 0;
  vPercentualMultaFGTS FLOAT := 0;
  vPercentualPenalidadeFGTS FLOAT := 0;
   
  --Variável da remuneração da função do contrato.
  
  vRemuneracao FLOAT := 0;

  --Variáveis de datas.

  vDataDisponibilizacao DATE;
  vDataReferencia DATE;
  vDataInicio DATE;
  vDataFim DATE;
  vAno NUMBER;
  vMes NUMBER;

  --Variável de checagem da existência do terceirizado.

  vCheck NUMBER := 0;

  --Variáveis de exceção.

  vRemuneracaoException EXCEPTION;
  vPeriodoException EXCEPTION;
  vContratoException EXCEPTION;
  vParametroNulo EXCEPTION;

  --Variáveis de controle.
  
  vDiasDeFerias NUMBER := 0;
  vDiasAdquiridos NUMBER := 0;
  vDiasVendidos NUMBER := 0;
  vNumeroDeMeses NUMBER := 0;
  vControleMeses NUMBER := 0;

  --Variáveis auxiliares.

  vIncidenciaFerias FLOAT := 0;
  vIncidenciaTerco FLOAT := 0;
  vTerco FLOAT := 0;
  vFerias FLOAT := 0;

-----------------------------------------------------------------

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

BEGIN
  
  --Todos os parâmetros estão preenchidos.

  IF (pCodTerceirizadoContrato IS NULL OR
      pCodTipoRestituicao IS NULL OR
      pDataDesligamento IS NULL OR
      pCodTipoRescisao IS NULL) THEN
  
    RAISE vParametroNulo;
  
  END IF;

  --Checagem da validade do terceirizado passado (existe).

  SELECT COUNT(cod)
    INTO vCheck
    FROM tb_terceirizado_contrato
    WHERE cod = pCodTerceirizadoContrato;

  IF (vCheck = 0) THEN

    RAISE vContratoException;

  END IF;

  --Carregar a data de disponibilização e o cod do contrato.

  SELECT tc.cod_contrato,
         tc.data_disponibilizacao
    INTO vCodContrato,
         vDataDisponibilizacao
    FROM tb_terceirizado_contrato tc 
    WHERE tc.cod = pCodTerceirizadoContrato;

  --Número de anos a serem contabilizados.

  SELECT (EXTRACT(year FROM pDataDesligamento) - EXTRACT(year FROM vDataDisponibilizacao)) + 1
    INTO vNumeroDeAnos
    FROM DUAL;

  --Carrega o número de meses que compreende o período de férias.
  
  vNumeroDeMeses := F_RETORNA_NUMERO_DE_MESES(pInicioPeriodoAquisitivo, pFimPeriodoAquisitivo);
  
  --Definir o valor das variáveis vMes e vAno de acordo com a data de disponibilização.

  vMes := EXTRACT(month FROM pInicioPeriodoAquisitivo);
  vAno := EXTRACT(year FROM pInicioPeriodoAquisitivo);

  --O cálculo é feito mês a mês para preservar os efeitos das alterações contratuais.

  FOR i IN 1 .. vNumeroDeMeses LOOP

    --Definição da data referência.

    vDataReferencia := TO_DATE('01/' || vMes || '/' || vAno, 'dd/mm/yyyy');

    --Reset das variáveis que contém valores parciais.

    vValorFerias := 0;
    vValorTercoConstitucional := 0;
    vValorIncidenciaFerias := 0;
    vValorIncidenciaTerco := 0;

    --Este loop reúne as funções que um determinado terceirizado exerceu no mês de cálculo.

    FOR f IN (SELECT ft.cod_funcao_contrato,
                     ft.cod
                FROM tb_funcao_terceirizado ft
                WHERE ft.cod_terceirizado_contrato = pCodTerceirizadoContrato
                  AND (((TO_DATE('01/' || EXTRACT(month FROM ft.data_inicio) || '/' || EXTRACT(year FROM ft.data_inicio), 'dd/mm/yyyy') <= vDataReferencia)
                       AND 
                       (ft.data_fim >= vDataReferencia))
                        OR
                       ((TO_DATE('01/' || EXTRACT(month FROM ft.data_inicio) || '/' || EXTRACT(year FROM ft.data_inicio), 'dd/mm/yyyy') <= vDataReferencia)
                        AND
                       (ft.data_fim IS NULL)))) LOOP

      --Se não existem alterações nos percentuais ou na remuneração.

      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = FALSE AND F_MUNDANCA_PERCENTUAL_CONTRATO(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
        --Define a remuneração do cargo e os percentuais de férias, terço e incidência.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);
        vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 1, 2);
        vPercentualTercoConstitucional := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 2, vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
     
        IF (vRemuneracao IS NULL) THEN
       
          RAISE vRemuneracaoException;
        
        END IF;

        --Cálculo do valor integral correspondente ao mês.      

        vValorFerias := (vRemuneracao * (vPercentualFerias/100));
        vValorTercoConstitucional := (vRemuneracao * (vPercentualTercoConstitucional/100));
        vValorIncidenciaFerias := (vValorFerias * (vPercentualIncidencia/100));
        vValorIncidenciaTerco := (vValorTercoConstitucional * (vPercentualIncidencia/100));

        --No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo, 
        --situação similar para a retenção proporcional por menos de 14 dias trabalhados.

        IF (F_EXISTE_MUDANCA_FUNCAO(pCodTerceirizadoContrato, vMes, vAno) = TRUE OR F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

          vValorFerias := (vValorFerias/30) * F_DIAS_TRABALHADOS_MES(f.cod, vMes, vAno);
          vValorTercoConstitucional := (vValorTercoConstitucional/30) * F_DIAS_TRABALHADOS_MES(f.cod, vMes, vAno);
          vValorIncidenciaFerias := (vValorIncidenciaFerias/30) * F_DIAS_TRABALHADOS_MES(f.cod, vMes, vAno);
          vValorIncidenciaTerco := (vValorIncidenciaTerco/30) * F_DIAS_TRABALHADOS_MES(f.cod, vMes, vAno);
          
        END IF;

        vTotalFerias := vTotalFerias + vValorFerias;
        vTotalTercoConstitucional := vTotalTercoConstitucional + vValorTercoConstitucional;
        vTotalIncidenciaFerias := vTotalIncidenciaFerias + vValorIncidenciaFerias;
        vTotalIncidenciaTerco := vTotalIncidenciaTerco + vValorIncidenciaTerco;            
  
      END IF;

      --Se existe apenas alteração de percentual no mês.

      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = FALSE AND F_MUNDANCA_PERCENTUAL_CONTRATO(vCodContrato, vMes, vAno, 2) = TRUE) THEN

        --Define a remuneração do cargo, que não se altera no período.
            
        vRemuneracao := F_RETORNA_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vMes, vAno, 1, 2);
     
        IF (vRemuneracao IS NULL) THEN
       
          RAISE vRemuneracaoException;
        
        END IF;
    
        --Definição da data de início como sendo a data referência (primeiro dia do mês).

        vDataInicio := vDataReferencia;

        --Loop contendo das datas das alterações de percentuais que comporão os subperíodos.

        FOR c3 IN (SELECT data_inicio AS data 
                     FROM tb_percentual_contrato
                     WHERE cod_contrato = vCodContrato
                       AND (EXTRACT(month FROM data_inicio) = vMes
                            AND 
                            EXTRACT(year FROM data_inicio) = vAno)
    
                   UNION

                   SELECT data_fim AS data
                     FROM tb_percentual_contrato
                     WHERE cod_contrato = vCodContrato
                       AND (EXTRACT(month FROM data_fim) = vMes
                            AND 
                            EXTRACT(year FROM data_fim) = vAno)

                   UNION

                   SELECT data_inicio AS data 
                     FROM tb_percentual_estatico
                     WHERE (EXTRACT(month FROM data_inicio) = vMes
                            AND 
                            EXTRACT(year FROM data_inicio) = vAno)
    
                   UNION

                   SELECT data_fim AS data
                     FROM tb_percentual_estatico
                     WHERE (EXTRACT(month FROM data_fim) = vMes
                            AND 
                            EXTRACT(year FROM data_fim) = vAno)

                   UNION

                   SELECT CASE WHEN vMes = 2 THEN 
                            LAST_DAY(TO_DATE('28/' || vMes || '/' || vAno, 'dd/mm/yyyy')) 
                          ELSE 
                            TO_DATE('30/' || vMes || '/' || vAno, 'dd/mm/yyyy') END AS data
                     FROM DUAL

                   ORDER BY data ASC) LOOP
          
          --Definição da data fim do subperíodo.

          vDataFim := c3.data;

          --Definição dos percentuais do subperíodo.
  
          vPercentualFerias := F_RET_PERCENTUAL_CONTRATO(vCodContrato, 1, vDataInicio, vDataFim, 2);     
          vPercentualTercoConstitucional := F_RET_PERCENTUAL_CONTRATO(vCodContrato, 2, vDataInicio, vDataFim, 2);
          vPercentualIncidencia := F_RET_PERCENTUAL_CONTRATO(vCodContrato, 7, vDataInicio, vDataFim, 2);
        
          --Calculo da porção correspondente ao subperíodo.
 
          vValorFerias := ((vRemuneracao * (vPercentualFerias/100))/30) * ((vDataFim - vDataInicio) + 1);
          vValorTercoConstitucional := ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * ((vDataFim - vDataInicio) + 1);
          vValorIncidenciaFerias := (vValorFerias * (vPercentualIncidencia/100)) * ((vDataFim - vDataInicio) + 1);
          vValorIncidenciaTerco := (vValorTercoConstitucional * (vPercentualIncidencia/100)) * ((vDataFim - vDataInicio) + 1);

          --No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo, 
          --situação similar para a retenção proporcional por menos de 14 dias trabalhados.

          IF (F_EXISTE_MUDANCA_FUNCAO(pCodTerceirizadoContrato, vMes, vAno) = TRUE OR F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

            vValorFerias := (vValorFerias/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorTercoConstitucional := (vValorTercoConstitucional/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorIncidenciaFerias := (vValorIncidenciaFerias/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorIncidenciaTerco := (vValorIncidenciaTerco/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            
          END IF;

          vTotalFerias := vTotalFerias + vValorFerias;
          vTotalTercoConstitucional := vTotalTercoConstitucional + vValorTercoConstitucional;
          vTotalIncidenciaFerias := vTotalIncidenciaFerias + vValorIncidenciaFerias;
          vTotalIncidenciaTerco := vTotalIncidenciaTerco + vValorIncidenciaTerco;    

          vDataInicio := vDataFim + 1;

        END LOOP;
  
      END IF;

      --Se existe alteração de remuneração apenas.
  
      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = TRUE AND F_MUNDANCA_PERCENTUAL_CONTRATO(vCodContrato, vMes, vAno, 2) = FALSE) THEN
    
        --Definição dos percentuais, que não se alteram no período.
  
        vPercentualFerias := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 1, vMes, vAno, 1, 2);
        vPercentualTercoConstitucional := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 2, vMes, vAno, 1, 2);
        vPercentualIncidencia := F_RETORNA_PERCENTUAL_CONTRATO(vCodContrato, 7, vMes, vAno, 1, 2);
    
        --Definição da data de início como sendo a data referência (primeiro dia do mês).

        vDataInicio := vDataReferencia;

        --Loop contendo das datas das alterações de percentuais que comporão os subperíodos.

        FOR c3 IN (SELECT rfc.data_inicio AS data 
                     FROM tb_remuneracao_fun_con rfc
                       JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato
                     WHERE fc.cod_contrato = vCodContrato
                       AND fc.cod = f.cod_funcao_contrato
                       AND (EXTRACT(month FROM rfc.data_inicio) = vMes
                            AND 
                            EXTRACT(year FROM rfc.data_inicio) = vAno)

                   UNION

                   SELECT rfc.data_fim AS data 
                     FROM tb_remuneracao_fun_con rfc
                       JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato
                     WHERE fc.cod_contrato = vCodContrato
                       AND fc.cod = f.cod_funcao_contrato
                       AND (EXTRACT(month FROM rfc.data_fim) = vMes
                            AND 
                            EXTRACT(year FROM rfc.data_fim) = vAno)

                   UNION

                   SELECT CASE WHEN vMes = 2 THEN 
                          LAST_DAY(TO_DATE('28/' || vMes || '/' || vAno, 'dd/mm/yyyy')) 
                          ELSE 
                          TO_DATE('30/' || vMes || '/' || vAno, 'dd/mm/yyyy') END AS data
                     FROM DUAL

                   ORDER BY data ASC) LOOP
          
          --Definição da data fim do subperíodo.

          vDataFim := c3.data;

          --Define a remuneração do cargo, que não se altera no período.
            
          vRemuneracao := F_RET_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vDataInicio, vDataFim, 2);
     
          IF (vRemuneracao IS NULL) THEN
       
            RAISE vRemuneracaoException;
        
          END IF;

          --Calculo da porção correspondente ao subperíodo.
 
          vValorFerias := ((vRemuneracao * (vPercentualFerias/100))/30) * ((vDataFim - vDataInicio) + 1);
          vValorTercoConstitucional := ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * ((vDataFim - vDataInicio) + 1);
          vValorIncidenciaFerias := (vValorFerias * (vPercentualIncidencia/100)) * ((vDataFim - vDataInicio) + 1);
          vValorIncidenciaTerco := (vValorTercoConstitucional * (vPercentualIncidencia/100)) * ((vDataFim - vDataInicio) + 1);

          --No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo, 
          --situação similar para a retenção proporcional por menos de 14 dias trabalhados.

          IF (F_EXISTE_MUDANCA_FUNCAO(pCodTerceirizadoContrato, vMes, vAno) = TRUE OR F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

            vValorFerias := (vValorFerias/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorTercoConstitucional := (vValorTercoConstitucional/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorIncidenciaFerias := (vValorIncidenciaFerias/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorIncidenciaTerco := (vValorIncidenciaTerco/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            
          END IF;

          vTotalFerias := vTotalFerias + vValorFerias;
          vTotalTercoConstitucional := vTotalTercoConstitucional + vValorTercoConstitucional;
          vTotalIncidenciaFerias := vTotalIncidenciaFerias + vValorIncidenciaFerias;
          vTotalIncidenciaTerco := vTotalIncidenciaTerco + vValorIncidenciaTerco;    

          vDataInicio := vDataFim + 1;

        END LOOP;              
  
      END IF;
    
      --Se existe alteração na remuneração e nos percentuais.
    
      IF (F_EXISTE_DUPLA_CONVENCAO(f.cod_funcao_contrato, vMes, vAno, 2) = TRUE AND F_MUNDANCA_PERCENTUAL_CONTRATO(vCodContrato, vMes, vAno, 2) = TRUE) THEN
    
        --Definição da data de início como sendo a data referência (primeiro dia do mês).

        vDataInicio := vDataReferencia;

        --Loop contendo das datas das alterações de percentuais que comporão os subperíodos.

        FOR c3 IN (SELECT data_inicio AS data 
                     FROM tb_percentual_contrato
                     WHERE cod_contrato = vCodContrato
                       AND (EXTRACT(month FROM data_inicio) = vMes
                            AND 
                            EXTRACT(year FROM data_inicio) = vAno)
    
                   UNION

                   SELECT data_fim AS data
                     FROM tb_percentual_contrato
                     WHERE cod_contrato = vCodContrato
                       AND (EXTRACT(month FROM data_fim) = vMes
                            AND 
                            EXTRACT(year FROM data_fim) = vAno)

                   UNION

                   SELECT data_inicio AS data 
                     FROM tb_percentual_estatico
                     WHERE (EXTRACT(month FROM data_inicio) = vMes
                            AND 
                            EXTRACT(year FROM data_inicio) = vAno)
    
                   UNION

                   SELECT data_fim AS data
                     FROM tb_percentual_estatico
                     WHERE (EXTRACT(month FROM data_fim) = vMes
                            AND 
                            EXTRACT(year FROM data_fim) = vAno)

                   UNION
                   
                   SELECT rfc.data_inicio AS data 
                     FROM tb_remuneracao_fun_con rfc
                       JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato
                     WHERE fc.cod_contrato = vCodContrato
                       AND fc.cod = f.cod_funcao_contrato
                       AND (EXTRACT(month FROM rfc.data_inicio) = vMes
                            AND 
                            EXTRACT(year FROM rfc.data_inicio) = vAno)

                   UNION

                   SELECT rfc.data_fim AS data 
                     FROM tb_remuneracao_fun_con rfc
                       JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato
                     WHERE fc.cod_contrato = vCodContrato
                       AND fc.cod = f.cod_funcao_contrato
                       AND (EXTRACT(month FROM rfc.data_fim) = vMes
                            AND 
                            EXTRACT(year FROM rfc.data_fim) = vAno)

                   UNION

                   SELECT CASE WHEN vMes = 2 THEN 
                          LAST_DAY(TO_DATE('28/' || vMes || '/' || vAno, 'dd/mm/yyyy')) 
                          ELSE 
                          TO_DATE('30/' || vMes || '/' || vAno, 'dd/mm/yyyy') END AS data
                     FROM DUAL

                   ORDER BY data ASC) LOOP
          
          --Definição da data fim do subperíodo.

          vDataFim := c3.data;

          --Define a remuneração da função no subperíodo.
            
          vRemuneracao := F_RET_REMUNERACAO_PERIODO(f.cod_funcao_contrato, vDataInicio, vDataFim, 2);
     
          IF (vRemuneracao IS NULL) THEN
       
            RAISE vRemuneracaoException;
        
          END IF;

          --Definição dos percentuais do subperíodo.
  
          vPercentualFerias := F_RET_PERCENTUAL_CONTRATO(vCodContrato, 1, vDataInicio, vDataFim, 2);     
          vPercentualTercoConstitucional := F_RET_PERCENTUAL_CONTRATO(vCodContrato, 2, vDataInicio, vDataFim, 2);
          vPercentualIncidencia := F_RET_PERCENTUAL_CONTRATO(vCodContrato, 7, vDataInicio, vDataFim, 2);

          --Calculo da porção correspondente ao subperíodo.
 
          vValorFerias := ((vRemuneracao * (vPercentualFerias/100))/30) * ((vDataFim - vDataInicio) + 1);
          vValorTercoConstitucional := ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * ((vDataFim - vDataInicio) + 1);
          vValorIncidenciaFerias := (vValorFerias * (vPercentualIncidencia/100)) * ((vDataFim - vDataInicio) + 1);
          vValorIncidenciaTerco := (vValorTercoConstitucional * (vPercentualIncidencia/100)) * ((vDataFim - vDataInicio) + 1);

          --No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo, 
          --situação similar para a retenção proporcional por menos de 14 dias trabalhados.

          IF (F_EXISTE_MUDANCA_FUNCAO(pCodTerceirizadoContrato, vMes, vAno) = TRUE OR F_FUNC_RETENCAO_INTEGRAL(f.cod, vMes, vAno) = FALSE) THEN

            vValorFerias := (vValorFerias/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorTercoConstitucional := (vValorTercoConstitucional/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorIncidenciaFerias := (vValorIncidenciaFerias/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            vValorIncidenciaTerco := (vValorIncidenciaTerco/((vDataFim - vDataInicio) + 1)) * F_DIAS_TRABALHADOS_PERIOODO(f.cod, vDataInicio, vDataFim);
            
          END IF;

          vTotalFerias := vTotalFerias + vValorFerias;
          vTotalTercoConstitucional := vTotalTercoConstitucional + vValorTercoConstitucional;
          vTotalIncidenciaFerias := vTotalIncidenciaFerias + vValorIncidenciaFerias;
          vTotalIncidenciaTerco := vTotalIncidenciaTerco + vValorIncidenciaTerco;    

          vDataInicio := vDataFim + 1;

        END LOOP;  
        
      END IF;

      vControleMeses := vControleMeses + 1;

    END LOOP;

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
