package br.jus.stj.siscovi.calculos;

import br.jus.stj.siscovi.model.CodTerceirizadoECodFuncaoTerceirizadoModel;

import java.sql.*;
import java.util.ArrayList;

public class RestituicaoFerias {
    private Connection connection;
    public RestituicaoFerias(Connection connection) {
        this.connection = connection;
    }

    /**
     * Método que calcula o total de férias a ser restituído para um
     *determinado período aquisitivo.
     * 
     *
     * @param pCodContrato
     * @param pMes
     * @param pAno
     */
    public void CalculaRestituicaoFerias(int pCodTerceirizadoContrato, int pCodTipoRestituicao, int pDiasVendidos, Date pInicioFerias, Date pFimFerias, Date pInicioPeriodoAquisitivo, Date pFimPeriodoAquisitivo
                                         float pValorMovimentado, char pProporcional) {
    
        PreparedStatement preparedStatement;
        ResultSet resultSet;
        Retencao retencao = new Retencao(connection);
        Percentual percentual = new Percentual(connection);
        Periodos periodo = new Periodos(connection);
        Remuneracao remuneracao = new Remuneracao(connection);

        //Chaves primárias.
        
        int vCodContrato = 0;
        int vCodTbRestituicaoFerias = 0;

        //Variáveis totalizadoras de valores.

        float vTotalFerias = 0;
        float vTotalTercoConstitucional = 0;
        float vTotalIncidenciaFerias = 0;
        float vTotalIncidenciaTerco = 0;

        //Variáveis de valores parciais.

        float vValorFerias = 0;
        float vValorTercoConstitucional = 0;
        float vValorIncidenciaFerias = 0;
        float vValorIncidenciaTerco = 0;

        //Variáveis de percentuais.

        float vPercentualFerias = 0;
        float vPercentualTercoConstitucional = 0;
        float vPercentualIncidencia = 0;
 
        //Variável de remuneração da função.

        float vRemuneracao = 0;
 
        //Variáveis de data.

        Date vDataReferencia = null;
        Date vDataInicio = null;
        Date vDataFim = null;
        int vAno = null;
        int vMes = null;

        //Variável para a checagem de existência do terceirizado.

        int vCheck = 0;

        //Variáveis de controle.

        int vDiasDeFerias = 0;
        int vDiasAdquiridos = 0;
        int vDiasVendidos = 0;
        int vNumeroDeMeses = 0;
        int vControleMeses = 0;

        //Variáveis auxiliares.
        
        float vIncidenciaFerias = 0;
        float vIncidenciaTerco = 0;
        float vTerco = 0;
        float vFerias = 0;

        //Checagem dos parâmetros passados.

        if(pCodTerceirizadoContrato == null || 
           pCodTipoRestituicao == null ||
           pDiasVendidos == null ||
           pInicioFerias == null ||
           pFimFerias == null ||
           pInicioPeriodoAquisitivo == null ||
           pFimPeriodoAquisitivo == null){

            return;    

        }

        //Checagem da existência do terceirizado no contrato.

        try {
            preparedStatement = connection.prepareStatement("SELECT COUNT(COD) FROM TB_TERCEIRIZADO_CONTRATO WHERE COD=?");
            preparedStatement.setInt(1, pCodTerceirizadoContrato);
            resultSet = preparedStatement.executeQuery();
            if(resultSet.next()) {
                vCheck = resultSet.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if(vCheck == 0){

          return;

        }

        //Carrega o código do contrato.
        try {
            preparedStatement = connection.prepareStatement("SELECT tc.cod_contrato FROM tb_terceirizado_contrato tc WHERE tc.cod=?");
            preparedStatement.setInt(1, pCodTerceirizadoContrato);
            resultSet = preparedStatement.executeQuery();
            if(resultSet.next()) {
                vCodContrato = resultSet.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        //Define o vvalor das variáveis vMes e Vano de acordo com a adata de inínio do período aquisitivo.

        vMes = pDataInicio.getMonth();
        vAno = pDataInicio.getYear();
        
       

        // Busca funções do contrato
        ArrayList<Integer> c1 = new ArrayList<>();
        try {
            preparedStatement = connection.prepareStatement("SELECT COD FROM TB_FUNCAO_CONTRATO WHERE COD_CONTRATO=?");
            preparedStatement.setInt(1, pCodContrato);
            resultSet = preparedStatement.executeQuery();
            while(resultSet.next()) {
             c1.add(resultSet.getInt("COD"));
            }
        }catch (SQLException sqle) {
            throw new NullPointerException("Erro ao tentar buscar as funções do contrato !");
        }
        // --Para cada função do contrato.
        Convencao convencao = new Convencao(connection);
        for(int i = 0; i < c1.size(); i++) {
            ArrayList<CodTerceirizadoECodFuncaoTerceirizadoModel> tuplas = selecionaTerceirizadosContratoFuncao(c1.get(i), vDataReferencia, pMes, pAno);
            // --Se não existe dupla convenção e duplo percentual.
            if(!convencao.ExisteDuplaConvencao(c1.get(i), pMes, pAno, 1) && !percentual.ExisteMudancaPercentual(pCodContrato, pMes, pAno, 1)) {
                vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(c1.get(i), pMes, pAno, 1, 1);
                if(vRemuneracao == 0) {
                    throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. CÓDICO: -20001");
                }
                // --Para cada funcionário que ocupa aquele função.
                for(int j= 0; j < tuplas.size(); j++) {
                    // Redefine todas as variáveis.
                    vTotal = 0;
                    vTotalFerias = 0;
                    vTotalTercoConstitucional = 0;
                    vTotalDecimoTerceiro = 0;
                    vTotalIncidencia = 0;
                    vTotalIndenizacao = 0;

                    // --Se a retenção for para período integral.

                    vTotalFerias = vRemuneracao * (vPercentualFerias/100);
                    vTotalTercoConstitucional = vRemuneracao * (vPercentualTercoConstitucional/100);
                    vTotalDecimoTerceiro = vRemuneracao * (vPercentualDecimoTerceiro/100);
                    vTotalIncidencia = vRemuneracao * (vPercentualIncidencia/100);
                    vTotalIndenizacao = vRemuneracao * (vPercentualIndenizacao/100);

                    // --No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo, situação similar para a retenção proporcional.
                    if(retencao.ExisteMudancaFuncao(tuplas.get(j).getCodTerceirizadoContrato(), pMes, pAno) && !retencao.FuncaoRetencaoIntegral(tuplas.get(j).getCod(), pMes, pAno)) {
                        vTotalFerias = (vTotalFerias/30) * periodo.DiasTrabalhadosMes(tuplas.get(j).getCod(), pMes, pAno);
                        vTotalTercoConstitucional = (vTotalTercoConstitucional/30) * periodo.DiasTrabalhadosMes(tuplas.get(j).getCod(), pMes, pAno);
                        vTotalDecimoTerceiro = (vTotalDecimoTerceiro/30) * periodo.DiasTrabalhadosMes(tuplas.get(j).getCod(), pMes, pAno);
                        vTotalIncidencia = (vTotalIncidencia/30) * periodo.DiasTrabalhadosMes(tuplas.get(j).getCod(), pMes, pAno);
                        vTotalIndenizacao = (vTotalIndenizacao/30) * periodo.DiasTrabalhadosMes(tuplas.get(j).getCod(), pMes, pAno);
                    }
                    vTotal = (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);
                    try {
                        preparedStatement = connection.prepareStatement("INSERT INTO TB_TOTAL_MENSAL_A_RETER (COD_TERCEIRIZADO_CONTRATO, COD_FUNCAO_TERCEIRIZADO, FERIAS, TERCO_CONSTITUCIONAL," +
                                " DECIMO_TERCEIRO, INCIDENCIA_SUBMODULO_4_1, MULTA_FGTS, TOTAL, DATA_REFERENCIA, LOGIN_ATUALIZACAO, DATA_ATUALIZACAO) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'SYSTEM', CURRENT_TIMESTAMP)");
                        preparedStatement.setInt(1, tuplas.get(j).getCodTerceirizadoContrato());
                        preparedStatement.setInt(2, tuplas.get(j).getCod());
                        preparedStatement.setFloat(3, vTotalFerias);
                        preparedStatement.setFloat(4, vTotalTercoConstitucional);
                        preparedStatement.setFloat(5, vTotalDecimoTerceiro);
                        preparedStatement.setFloat(6, vTotalIncidencia);
                        preparedStatement.setFloat(7, vTotalIndenizacao);
                        preparedStatement.setFloat(8, vTotal);
                        preparedStatement.setDate(9, vDataReferencia);
                        preparedStatement.executeUpdate();
                    } catch (SQLException e) {
                        throw new RuntimeException("Erro ao tentar inserir os resultados do cálculo de Total Mensal a Reter no banco de dados !");
                    }

                }

            }
            /*
            // --Se não existe dupla convenção e existe duplo percentual.
            if(!convencao.ExisteDuplaConvencao(c1[i], pMes, pAno, 1) && percentual.ExisteMudancaPercentual(pCodContrato, pMes, pAno, 1)) {
                // Define a remuneração da função
                vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(c1[i], pMes, pAno, 1 ,1);
                if(vRemuneracao == 0) {
                    throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada");
                }
                // --Para cada funcionário que ocupa aquele função.

                for(int j = 0; j > tuplas.size(); j++) {
                    // --Redefine todas as variáveis.
                    vTotal = 0;
                    vTotalFerias = 0;
                    vTotalTercoConstitucional = 0;
                    vTotalDecimoTerceiro = 0;
                    vTotalIncidencia = 0;
                    vTotalIndenizacao = 0;

                    // --Definição dos percentuais da primeira metade do mês
                    vPercentualFerias = percentual.RetornaPercentualContrato(pCodContrato, 1, pMes, pAno, 2 ,1);
                    vPercentualTercoConstitucional = vPercentualFerias/3;
                    vPercentualDecimoTerceiro = percentual.RetornaPercentualContrato(pCodContrato, 3, pMes, pAno, 2 ,1);
                    vPercentualIncidencia = (percentual.RetornaPercentualContrato(pCodContrato, 7, pMes, pAno, 2 ,1) *
                            (vPercentualFerias + vPercentualDecimoTerceiro + vPercentualTercoConstitucional))/100;
                    vPercentualIndenizacao = percentual.RetornaPercentualEstatico(pCodContrato, 4, pMes, pAno, 2, 1);
                    vPercentualPenalidadeFGTS = percentual.RetornaPercentualEstatico(pCodContrato, 6, pMes, pAno, 2, 1);
                    vPercentualMultaFGTS = percentual.RetornaPercentualEstatico(pCodContrato, 5, pMes, pAno, 2, 1);
                    vPercentualIndenizacao = (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100)) *
                            (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;

                    // --Se a retenção for para período integral.

                    if(retencao.FuncaoRetencaoIntegral(tuplas.get(j).getCod(), pMes, pAno)) {
                        // --Recolhimento referente a primeira metade do mês.
                        vTotalFerias = (((vRemuneracao * (vPercentualFerias/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 3));
                        vTotalTercoConstitucional = (((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 3));
                        vTotalDecimoTerceiro = (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 3));
                        vTotalIncidencia = (((vRemuneracao * (vPercentualIncidencia/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 3));
                        vTotalIndenizacao = (((vRemuneracao * (vPercentualIndenizacao/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 3));

                        // --Definição dos percentuais da segunda metade do mês.
                        vPercentualFerias = percentual.RetornaPercentualContrato(pCodContrato, 1, pMes, pAno, 1 ,1);
                        vPercentualTercoConstitucional = vPercentualFerias / 3;
                        vPercentualDecimoTerceiro = percentual.RetornaPercentualContrato(pCodContrato, 3, pMes, pAno, 1, 1);
                        vPercentualIncidencia = (percentual.RetornaPercentualContrato(pCodContrato, 7, pMes, pAno, 1, 1) *
                                (vPercentualMultaFGTS + vPercentualDecimoTerceiro + vPercentualTercoConstitucional)) / 100;
                        vPercentualIndenizacao = percentual.RetornaPercentualEstatico(pCodContrato, 4, pMes, pAno, 1 ,1);
                        vPercentualPenalidadeFGTS = percentual.RetornaPercentualEstatico(pCodContrato, 6, pMes, pAno, 1, 1);
                        vPercentualMultaFGTS = percentual.RetornaPercentualEstatico(pCodContrato, 5, pMes, pAno, 1, 1);
                        vPercentualIndenizacao = (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) *
                                (vPercentualMultaFGTS/100)) * (1 + (vPercentualFerias/100) + (vPercentualDecimoTerceiro/100) + (vPercentualTercoConstitucional/100))) * 100;

                        // --Recolhimento referente a primeira metade do mês.

                        vTotalFerias = vTotalFerias + (((vRemuneracao * (vPercentualFerias/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 4));
                        vTotalTercoConstitucional = vTotalTercoConstitucional + (((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 4));
                        vTotalDecimoTerceiro = vTotalDecimoTerceiro + (((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 4));
                        vTotalIncidencia = vTotalIncidencia + (((vRemuneracao * (vPercentualIncidencia/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 4));
                        vTotalIndenizacao = vTotalIndenizacao + (((vRemuneracao * (vPercentualIndenizacao/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 4));

                    }

                    // --Caso o funcionário não tenha trabalhado 15 dias ou mais no período.

                    if(!retencao.FuncaoRetencaoIntegral(tuplas.get(j).getCod(), pMes, pAno)) {
                        vPercentualIndenizacao = percentual.RetornaPercentualEstatico(pCodContrato, 4, pMes, pAno, 2 ,1);
                        vPercentualIndenizacao = (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;
                        vTotalIndenizacao = (((vRemuneracao * (vPercentualIndenizacao/100))/30) * periodo.DiasTrabalhadosMesParcial(c1[i], tuplas.get(j).getCod(), pMes, pAno, 3));

                        //--Definição dos percentuais da segunda metade do mês.

                        vPercentualIndenizacao = percentual.RetornaPercentualEstatico(pCodContrato, 4, pMes, pAno, 1, 1);
                        vPercentualPenalidadeFGTS = percentual.RetornaPercentualEstatico(pCodContrato, 6, pMes, pAno, 1, 1);
                        vPercentualMultaFGTS = percentual.RetornaPercentualEstatico(pCodContrato, 5, pMes, pAno, 1, 1);
                        vPercentualIndenizacao = (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;

                        vTotalIndenizacao = vTotalIndenizacao + (((vRemuneracao * (vPercentualIndenizacao/100))/30) * periodo.DiasTrabalhadosMesParcial(c1[i], tuplas.get(j).getCod(), pMes, pAno, 4));
                    }

                    vTotal = (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);
                    try {
                        preparedStatement = connection.prepareStatement("INSERT INTO TB_TOTAL_MENSAL_A_RETER(COD_TERCEIRIZADO_CONTRATO," +
                                "COD_FUNCAO_TERCEIRIZADO, FERIAS, TERCO_CONSTITUCIONAL, DECIMO_TERCEIRO, INCIDENCIA_SUBMODULO_4_1, MULTA_FGTS, TOTAL, DATA_REFERENCIA, LOGIN_ATUALIZACAO, DATA_ATUALIZACAO)" +
                                " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'SYSTEM', GETDATE())");
                        preparedStatement.setInt(1, tuplas.get(j).getCodTerceirizadoContrato());
                        preparedStatement.setInt(2, tuplas.get(j).getCod());
                        preparedStatement.setFloat(3, vTotalFerias);
                        preparedStatement.setFloat(4, vTotalTercoConstitucional);
                        preparedStatement.setFloat(5, vTotalDecimoTerceiro);
                        preparedStatement.setFloat(6, vTotalIncidencia);
                        preparedStatement.setFloat(7, vTotalIndenizacao);
                        preparedStatement.setFloat(8, vTotal);
                        preparedStatement.setDate(9, vDataReferencia);
                        preparedStatement.executeUpdate();
                    }catch (SQLException sqle) {
                        throw new RuntimeException("Erro ao tentar Inserir os valores de Total Mensal a Reter. Código do Contrato: " + pCodContrato +
                                ". Código da função do contrato: " + c1[i] + ". Código do Terceirizado no contrato: " + tuplas.get(j).getCodTerceirizadoContrato());
                    }
                }
            }
            // Se existe dupla convenção e não existe duplo percentual.
            if(convencao.ExisteDuplaConvencao(c1[i], pMes, pAno, 1) && percentual.ExisteMudancaPercentual(pCodContrato, pMes, pAno, 1)) {
                // --Define a remuneração do funcao

                vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(c1[i], pMes, pAno, 2 ,1);
                vRemuneracao2 = remuneracao.RetornaRemuneracaoPeriodo(c1[i], pMes, pAno, 1, 1);
                if(vRemuneracao == 0 || vRemuneracao2 == 0 ) {
                    throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. COD: -20001");
                }
                // --Para cada funcionário que ocupa aquele funcao.

                for(int j = 0;j > tuplas.size(); j++) {

                    // Redefine todas as variáveis.

                    vTotal = 0;
                    vTotalFerias = 0;
                    vTotalTercoConstitucional = 0;
                    vTotalDecimoTerceiro = 0;
                    vTotalIncidencia = 0;
                    vTotalIndenizacao = 0;
                    // Se a retenção for para período integral.
                    if(retencao.FuncaoRetencaoIntegral(tuplas.get(j).getCod(), pMes, pAno)) {
                        // --Retenção proporcional da primeira convenção.
                        vTotalFerias = ((vRemuneracao * (vPercentualFerias/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 1);
                        vTotalTercoConstitucional = ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 1);
                        vTotalDecimoTerceiro = ((vRemuneracao * (vPercentualDecimoTerceiro/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 1);
                        vTotalIncidencia = ((vRemuneracao * (vPercentualIncidencia/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 1);
                        vTotalIndenizacao = ((vRemuneracao * (vPercentualIndenizacao/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 1);

                        // Retenção proporcional da segunda convenção.
                        vTotalFerias = vTotalFerias + (((vRemuneracao2 * (vPercentualFerias/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 2));
                        vTotalTercoConstitucional = vTotalTercoConstitucional + (((vRemuneracao2 * (vPercentualTercoConstitucional/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 2));
                        vTotalDecimoTerceiro = vTotalDecimoTerceiro + (((vRemuneracao2 * (vPercentualDecimoTerceiro/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 2));
                        vTotalIncidencia = vTotalIncidencia + (((vRemuneracao2 * (vPercentualIncidencia/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 2));
                        vTotalIndenizacao = vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) * periodo.RetornaNumeroDiasMesParcial(c1[i], pMes, pAno, 2));
                    }

                    //--Caso o funcionário não tenha trabalhado 15 dias ou mais no período.
                    if(retencao.FuncaoRetencaoIntegral(tuplas.get(j).getCod(), pMes, pAno)) {
                        vPercentualIndenizacao = percentual.RetornaPercentualEstatico(pCodContrato, 4, pMes, pAno, 1, 1);
                        vPercentualIndenizacao = (((vPercentualIndenizacao/100) *  (vPercentualPenalidadeFGTS/100) * (vPercentualMultaFGTS/100))) * 100;

                        // Retenção proporcional da primeira convenção.

                        vTotalIndenizacao = (((vRemuneracao * (vPercentualIndenizacao/100))/30) * periodo.DiasTrabalhadosMesParcial(c1[i], tuplas.get(j).getCod(), pMes, pAno, 1));

                        //--Retenção proporcional da segunda convenção.
                        vTotalIndenizacao = vTotalIndenizacao + (((vRemuneracao2 * (vPercentualIndenizacao/100))/30) *  periodo.DiasTrabalhadosMesParcial(c1[i], tuplas.get(j).getCod(), pMes, pAno, 2));
                    }
                    vTotal = (vTotalFerias + vTotalTercoConstitucional + vTotalDecimoTerceiro + vTotalIncidencia + vTotalIndenizacao);
                    try {
                        preparedStatement = connection.prepareStatement("INSERT INTO TB_TOTAL_MENSAL_A_RETER (COD_TERCEIRIZADO_CONTRATO, COD_FUNCAO_TERCEIRIZADO," +
                                "FERIAS, TERCO_CONSTITUCIONAL, DECIMO_TERCEIRO, INCIDENCIA_SUBMODULO_4_1, MULTA_FGTS, TOTAL, DATA_REFERENCIA, LOGIN_ATUALIZACAO, DATA_ATUALIZACAO) " +
                                " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'SYSTEM', GETDATE())");
                        preparedStatement.setInt(1, tuplas.get(j).getCodTerceirizadoContrato());
                        preparedStatement.setInt(2, tuplas.get(j).getCod());
                        preparedStatement.setFloat(3, vTotalFerias);
                        preparedStatement.setFloat(4, vTotalTercoConstitucional);
                        preparedStatement.setFloat(5, vTotalDecimoTerceiro);
                        preparedStatement.setFloat(6, vTotalIncidencia);
                        preparedStatement.setFloat(7, vTotalIndenizacao);
                        preparedStatement.setFloat(8, vTotal);
                        preparedStatement.setDate(9, vDataReferencia);
                        preparedStatement.executeUpdate();
                    }catch (SQLException sqle) {
                        throw new NullPointerException("");
                    }
                }
            }
            // Se existe mudança de percentual e mudança de convenção.
            if(convencao.ExisteDuplaConvencao(c1[i], pMes, pAno, 1) && percentual.ExisteMudancaPercentual(pCodContrato, pMes, pAno,1)) {
                // Define a remuneração do funcao.
                vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(c1[i], pMes, pAno, 2, 1);
                vRemuneracao2 = remuneracao.RetornaRemuneracaoPeriodo(c1[i], pMes, pAno, 1, 1);

                // Definição das datas para os períodos da convenção e percentuais.
                try {
                    preparedStatement = connection.prepareStatement("SELECT DATA_FIM FROM TB_REMUNERACAO_FUN_CON WHERE COD_FUNCAO_CONTRATO=? AND DATA_ADITAMENTO IS NOT NULL" +
                            " AND MONTH(DATA_FIM)=? AND YEAR(DATA_FIM)=?");
                    preparedStatement.setInt(1, c1[i]);
                    preparedStatement.setInt(2, pMes);
                    preparedStatement.setInt(3, pAno);
                    resultSet = preparedStatement.executeQuery();
                    if(resultSet.next()) {
                        vDataFimConvencao = resultSet.getDate("DATA_FIM");
                    }
                }catch (SQLException sqle) {
                    throw new NullPointerException("");
                }
                // Observação: datas dos percentuais são todas iguais para um bloco.
                 // Para o percentual do contrato.

                if(percentual.MudancaPercentualContrato(pCodContrato, pMes, pAno, 1)) {
                    try {
                        preparedStatement = connection.prepareStatement("SELECT DISTINCT(DATA_FIM) FROM TB_PERCENTUAL_CONTRATO WHERE COD_CONTRATO = ? AND DATA_ADITAMENTO IS NOT NULL" +
                                " AND MONTH(DATA_FIM)=? AND YEAR(DATA_FIM)=?");
                        preparedStatement.setInt(1, pCodContrato);
                        preparedStatement.setInt(2, pMes);
                        preparedStatement.setInt(3, pAno);
                        resultSet = preparedStatement.executeQuery();
                        if(resultSet.next()) {
                            vDataFimPercentual = resultSet.getDate(1);
                        }
                    } catch (SQLException e) {
                        throw new NullPointerException("");
                    }
                }

                //--Para o percentual estático.
                */
        }
    }
    Date adaptaDataPara360(Date vDataFimMes) {
        if(vDataFimMes.toLocalDate().getDayOfMonth() == 31) {
            vDataFimMes = Date.valueOf(vDataFimMes.toLocalDate().minusDays(1));
        }
        if(vDataFimMes.toLocalDate().getDayOfMonth() == 28){
            vDataFimMes = Date.valueOf(vDataFimMes.toLocalDate().plusDays(2));
        }
        if(vDataFimMes.toLocalDate().getDayOfMonth() == 29) {
            vDataFimMes = Date.valueOf(vDataFimMes.toLocalDate().plusDays(1));
        }
        return vDataFimMes;
    }
    ArrayList<CodTerceirizadoECodFuncaoTerceirizadoModel> selecionaTerceirizadosContratoFuncao(int pCodFuncaoContrato, Date pDataReferencia, int pMes, int pAno) {
        // Busca funcionários do contrato na respectiva função c1[i]
        ArrayList<CodTerceirizadoECodFuncaoTerceirizadoModel> tuplas = new ArrayList<>();
        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT ft.cod_terceirizado_contrato, ft.cod FROM tb_funcao_terceirizado ft WHERE ft.cod_funcao_contrato = ?" +
                " AND ((ft.data_inicio <= ?) OR (MONTH(ft.data_inicio) = ?) AND YEAR(ft.data_inicio) = ?) AND ((ft.data_fim IS NULL) OR (ft.data_fim >= EOMONTH(?))" +
                " OR (MONTH(ft.data_fim) = ?) AND YEAR(ft.data_fim) = ?)")){
            preparedStatement.setInt(1, pCodFuncaoContrato);
            preparedStatement.setDate(2, pDataReferencia);
            preparedStatement.setInt(3, pMes);
            preparedStatement.setInt(4, pAno);
            preparedStatement.setDate(5, pDataReferencia);
            preparedStatement.setInt(6, pMes);
            preparedStatement.setInt(7, pAno);
            try(ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    CodTerceirizadoECodFuncaoTerceirizadoModel tupla = new CodTerceirizadoECodFuncaoTerceirizadoModel(resultSet.getInt("COD_TERCEIRIZADO_CONTRATO"), resultSet.getInt("COD"));
                    tuplas.add(tupla);
                }
            }
        }catch(SQLException slqe) {
            throw new NullPointerException("Não foram encontrardos funcionários para a função: " + pCodFuncaoContrato);
        }
        return tuplas;
    }
}
