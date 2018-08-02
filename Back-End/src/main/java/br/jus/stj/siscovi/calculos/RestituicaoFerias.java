package br.jus.stj.siscovi.calculos;

import br.jus.stj.siscovi.model.CodFuncaoContratoECodFuncaoTerceirizadoModel;
import br.jus.stj.siscovi.model.CodTerceirizadoECodFuncaoTerceirizadoModel;
import java.sql.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class RestituicaoFerias {

    private Connection connection;

    public RestituicaoFerias(Connection connection) {

        this.connection = connection;

    }

    /**
     * Método que calcula o total de férias a ser restituído para um
     * determinado período aquisitivo.
     *
     * @param pCodTerceirizadoContrato;
     * @param pTipoRestituicao;
     * @param pDiasVendidos;
     * @param pInicioFerias;
     * @param pFimFerias;
     * @param pInicioPeriodoAquisitivo;
     * @param pFimPeriodoAquisitivo;
     * @param pValorMovimentado;
     * @param pProporcional;
     */

    public void CalculaRestituicaoFerias (int pCodTerceirizadoContrato,
                                          String pTipoRestituicao,
                                          int pDiasVendidos,
                                          Date pInicioFerias,
                                          Date pFimFerias,
                                          Date pInicioPeriodoAquisitivo,
                                          Date pFimPeriodoAquisitivo,
                                          float pValorMovimentado,
                                          char pProporcional) {

        PreparedStatement preparedStatement;
        ResultSet resultSet;
        Retencao retencao = new Retencao(connection);
        Percentual percentual = new Percentual(connection);
        Periodos periodo = new Periodos(connection);
        Remuneracao remuneracao = new Remuneracao(connection);

        /**Chaves primárias.*/

        int vCodContrato = 0;
        int vCodTbRestituicaoFerias = 0;
        int vCodTipoRestituicao = 0;

        /**Variáveis totalizadoras de valores.*/

        float vTotalFerias = 0;
        float vTotalTercoConstitucional = 0;
        float vTotalIncidenciaFerias = 0;
        float vTotalIncidenciaTerco = 0;

        /**Variáveis de valores parciais.*/

        float vValorFerias = 0;
        float vValorTercoConstitucional = 0;
        float vValorIncidenciaFerias = 0;
        float vValorIncidenciaTerco = 0;

        /**Variáveis de percentuais.*/

        float vPercentualFerias = 0;
        float vPercentualTercoConstitucional = 0;
        float vPercentualIncidencia = 0;

        /**Variável de remuneração da função.*/

        float vRemuneracao = 0;

        /**Variáveis de data.*/

        Date vDataReferencia = null;
        Date vDataInicio = null;
        Date vDataFim = null;
        int vAno = 0;
        int vMes = 0;

        /**Variável para a checagem de existência do terceirizado.*/

        int vCheck = 0;

        /**Variáveis de controle.*/

        int vDiasDeFerias = 0;
        int vDiasAdquiridos = 0;
        int vDiasVendidos = 0;
        int vNumeroDeMeses = 0;
        int vControleMeses = 0;

        /**Variáveis auxiliares.*/

        float vIncidenciaFerias = 0;
        float vIncidenciaTerco = 0;
        float vTerco = 0;
        float vFerias = 0;

        /**Checagem dos parâmetros passados.*/
/*
        if (pCodTerceirizadoContrato == null ||
            pTipoRestituicao == null ||
            pDiasVendidos == null ||
            pInicioFerias == null ||
            pFimFerias == null ||
            pInicioPeriodoAquisitivo == null ||
            pFimPeriodoAquisitivo == null) {

            return;

        }


*/

        /**Atribuição do cod do tipo de restituição.*/

        try {

            preparedStatement = connection.prepareStatement("SELECT COD" +
                                                                 " FROM TB_TIPO_RESTITUICAO" +
                                                                 " WHERE UPPER(nome) = UPPER(?)");

            preparedStatement.setString(1, pTipoRestituicao);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {

                vCodTipoRestituicao = resultSet.getInt(1);

            }

        } catch (SQLException e) {

            e.printStackTrace();

        }

        if (vCodTipoRestituicao == 0) {

            throw new NullPointerException("Tipo de restituição não encontrada.");

        }

        /**Checagem da existência do terceirizado no contrato.*/

        try {

            preparedStatement = connection.prepareStatement("SELECT COUNT(COD) FROM TB_TERCEIRIZADO_CONTRATO WHERE COD=?");

            preparedStatement.setInt(1, pCodTerceirizadoContrato);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {

                vCheck = resultSet.getInt(1);

            }

        } catch (SQLException e) {

            e.printStackTrace();

        }

        if (vCheck == 0) {

            throw new NullPointerException("Terceirizado não encontrado no contrato.");

        }

        /**Carrega o código do contrato.*/

        try {

            preparedStatement = connection.prepareStatement("SELECT tc.cod_contrato FROM tb_terceirizado_contrato tc WHERE tc.cod=?");

            preparedStatement.setInt(1, pCodTerceirizadoContrato);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {

                vCodContrato = resultSet.getInt(1);

            }

        } catch (SQLException e) {

            e.printStackTrace();

        }

        /**Define o valor das variáveis vMes e Vano de acordo com a adata de inínio do período aquisitivo.*/

        vMes = pInicioPeriodoAquisitivo.toLocalDate().getMonthValue();
        vAno = pInicioPeriodoAquisitivo.toLocalDate().getYear();

        /**Início da contabilização de férias do período.*/

        do{

            /**Definição da data referência (sempre o primeiro dia do mês).*/

            vDataReferencia = Date.valueOf(vAno + "-" + vMes + "-" + "01");

            /**Reset das variáveis que contém valores parciais.*/

            vValorFerias = 0;
            vValorTercoConstitucional = 0;
            vValorIncidenciaFerias = 0;
            vValorIncidenciaTerco = 0;

            /**Seleciona as funções que o terceirizado ocupou no mês avaliado.*/

            ArrayList<CodFuncaoContratoECodFuncaoTerceirizadoModel> tuplas = selecionaFuncaoContratoEFuncaoTerceirizado(pCodTerceirizadoContrato, vDataReferencia);

            Convencao convencao = new Convencao(connection);

            /**Para cada função que o terceirizado ocupou no mês avaliado.*/

            for(int i = 0; i < tuplas.size(); i++){

                /**Caso não exista mais de uma remuneração vigente no mês e não tenha havido alteração nos percentuais do contrato ou nos percentuais estáticos.*/

                if(!convencao.ExisteDuplaConvencao(tuplas.get(i).getCodFuncaoContrato(), vMes, vAno, 2) && !percentual.ExisteMudancaPercentual(vCodContrato, vMes, vAno, 2)) {

                    /**Define o valor da remuneração da função e dos percentuais do contrato.*/

                    vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(tuplas.get(i).getCodFuncaoContrato(), vMes, vAno, 1, 2);
                    vPercentualFerias = percentual.RetornaPercentualContrato(vCodContrato, 1, vMes, vAno, 1, 2);
                    vPercentualTercoConstitucional = percentual.RetornaPercentualContrato(vCodContrato, 2, vMes, vAno, 1, 2);
                    vPercentualIncidencia = percentual.RetornaPercentualContrato(vCodContrato, 7, vMes, vAno, 1, 2);

                    if (vRemuneracao == 0) {

                        throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. Código -20001");

                    }

                    /**Cálculo do valor integral correspondente ao mês avaliado.*/

                    vValorFerias = (vRemuneracao * (vPercentualFerias/100));
                    vValorTercoConstitucional = (vRemuneracao * (vPercentualTercoConstitucional/100));
                    vValorIncidenciaFerias = (vValorFerias * (vPercentualIncidencia/100));
                    vValorIncidenciaTerco = (vValorTercoConstitucional * (vPercentualIncidencia/100));

                    /**o caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo,
                    situação similar para a retenção proporcional por menos de 14 dias trabalhados.*/

                    if (retencao.ExisteMudancaFuncao(pCodTerceirizadoContrato, vMes, vAno) || !retencao.FuncaoRetencaoIntegral(tuplas.get(i).getCod(), vMes, vAno)) {

                        vValorFerias = (vValorFerias/30) * periodo.DiasTrabalhadosMes(tuplas.get(i).getCod(), vMes, vAno);
                        vValorTercoConstitucional = (vValorTercoConstitucional/30) * periodo.DiasTrabalhadosMes(tuplas.get(i).getCod(), vMes, vAno);
                        vValorIncidenciaFerias = (vValorIncidenciaFerias/30) * periodo.DiasTrabalhadosMes(tuplas.get(i).getCod(), vMes, vAno);
                        vValorIncidenciaTerco = (vValorIncidenciaTerco/30) * periodo.DiasTrabalhadosMes(tuplas.get(i).getCod(), vMes, vAno);

                    }

                    /**Contabilização do valor calculado.*/

                    vTotalFerias = vTotalFerias + vValorFerias;
                    vTotalTercoConstitucional = vTotalTercoConstitucional + vValorTercoConstitucional;
                    vTotalIncidenciaFerias = vTotalIncidenciaFerias + vValorIncidenciaFerias;
                    vTotalIncidenciaTerco = vTotalIncidenciaTerco + vValorIncidenciaTerco;

                }

                /**Se existe apenas alteração de percentual no mês.*/

                if(!convencao.ExisteDuplaConvencao(tuplas.get(i).getCodFuncaoContrato(), vMes, vAno, 2) && percentual.ExisteMudancaPercentual(vCodContrato, vMes, vAno, 2)) {

                    /**Define a remuneração do cargo, que não se altera no período.*/

                    vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(tuplas.get(i).getCodFuncaoContrato(), vMes, vAno, 1, 2);

                    if (vRemuneracao == 0) {

                        throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. Código -20001");

                    }

                    /**Definição da data de início como sendo a data referência (primeiro dia do mês).*/

                    vDataInicio = vDataReferencia;

                    /**Loop contendo das datas das alterações de percentuais que comporão os subperíodos.*/

                    List<Date> datas = new ArrayList<>();

                    /**Seleciona as datas que compõem os subperíodos gerados pelas alterações de percentual no mês.*/

                    try {

                        preparedStatement = connection.prepareStatement("SELECT data_inicio AS data" +
                                                                             " FROM tb_percentual_contrato" +
                                                                             " WHERE cod_contrato = ?" +
                                                                               " AND (MONTH(DATA_INICIO) = ?" +
                                                                                    " AND \n" +
                                                                                    " YEAR(DATA_INICIO) = ?)" +
                                                                            " UNION" +
                                                                            " SELECT data_fim AS data" +
                                                                              " FROM tb_percentual_contrato" +
                                                                              " WHERE cod_contrato = ?" +
                                                                                " AND (MONTH(DATA_FIM)=?" +
                                                                                     " AND" +
                                                                                     " YEAR(DATA_FIM) = ?)" +
                                                                            " UNION" +
                                                                            " SELECT data_inicio AS data" +
                                                                              " FROM tb_percentual_estatico" +
                                                                              " WHERE (MONTH(DATA_INICIO)=?" +
                                                                                     " AND " +
                                                                                     " YEAR(DATA_INICIO)=?)" +
                                                                            " UNION" +
                                                                            " SELECT data_fim AS data" +
                                                                              " FROM tb_percentual_estatico" +
                                                                              " WHERE (MONTH(DATA_FIM)=?" +
                                                                                     " AND" +
                                                                                     " YEAR(DATA_FIM)=?)" +
                                                                            " UNION" +
                                                                            " SELECT CASE WHEN ? = 2 THEN" +
                                                                                     " EOMONTH(CONVERT(DATE, CONCAT('28/' , ? , '/' ,?), 103))" +
                                                                                   " ELSE" +
                                                                                     " CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103) END AS data" +
                                                                            " ORDER BY data ASC");

                        preparedStatement.setInt(1, vCodContrato);
                        preparedStatement.setInt(2, vMes);
                        preparedStatement.setInt(3, vAno);
                        preparedStatement.setInt(4, vCodContrato);
                        preparedStatement.setInt(5, vMes);
                        preparedStatement.setInt(6, vAno);
                        preparedStatement.setInt(7, vMes);
                        preparedStatement.setInt(8, vAno);
                        preparedStatement.setInt(9, vMes);
                        preparedStatement.setInt(10, vAno);
                        preparedStatement.setInt(11, vMes);
                        preparedStatement.setInt(12, vMes);
                        preparedStatement.setInt(13, vAno);
                        preparedStatement.setInt(14, vMes);
                        preparedStatement.setInt(15, vAno);
                        resultSet = preparedStatement.executeQuery();

                        while(resultSet.next()){

                            datas.add(resultSet.getDate("data"));

                        }

                    } catch (SQLException e) {

                        throw new NullPointerException("Erro ao tentar carregar as datas referentes ao percentuais. " + " Contrato: " + vCodContrato + ". No perídodo: " + vDataReferencia.toLocalDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));

                    }

                    for (Date data: datas) {

                        /**Definição da data fim do subperíodo.*/

                        vDataFim = data;

                        /**Definição dos percentuais do subperíodo.*/

                        vPercentualFerias = percentual.RetornaPercentualContrato(vCodContrato, 1, vDataInicio, vDataFim, 2);
                        vPercentualTercoConstitucional = percentual.RetornaPercentualContrato(vCodContrato, 2, vDataInicio, vDataFim, 2);
                        vPercentualIncidencia = percentual.RetornaPercentualContrato(vCodContrato, 7, vDataInicio, vDataFim, 2);

                        /**Calculo da porção correspondente ao subperíodo.*/

                        vValorFerias = ((vRemuneracao * (vPercentualFerias/100))/30) * ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);
                        vValorTercoConstitucional = ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);
                        vValorIncidenciaFerias = (vValorFerias * (vPercentualIncidencia/100));
                        vValorIncidenciaTerco = (vValorTercoConstitucional * (vPercentualIncidencia/100));

                        /**No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo,
                         situação similar para a retenção proporcional por menos de 14 dias trabalhados.*/

                        if (retencao.ExisteMudancaFuncao(pCodTerceirizadoContrato, vMes, vAno) || !retencao.FuncaoRetencaoIntegral(tuplas.get(i).getCod(), vMes, vAno)) {

                            vValorFerias = (vValorFerias/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorTercoConstitucional = (vValorTercoConstitucional/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaFerias = (vValorIncidenciaFerias/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaTerco = (vValorIncidenciaTerco/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);

                        }

                        /**Contabilização do valor calculado.*/

                        vTotalFerias = vTotalFerias + vValorFerias;
                        vTotalTercoConstitucional = vTotalTercoConstitucional + vValorTercoConstitucional;
                        vTotalIncidenciaFerias = vTotalIncidenciaFerias + vValorIncidenciaFerias;
                        vTotalIncidenciaTerco = vTotalIncidenciaTerco + vValorIncidenciaTerco;

                        vDataInicio = Date.valueOf(vDataFim.toLocalDate().plusDays(1));

                    }

                }

                /**Se existe alteração de remuneração apenas.*/

                if(convencao.ExisteDuplaConvencao(tuplas.get(i).getCodFuncaoContrato(), vMes, vAno, 2) && !percentual.ExisteMudancaPercentual(vCodContrato, vMes, vAno, 2)) {

                    /**Definição dos percentuais, que não se alteram no período.*/

                    vPercentualFerias = percentual.RetornaPercentualContrato(vCodContrato, 1, vMes, vAno, 1, 2);
                    vPercentualTercoConstitucional = percentual.RetornaPercentualContrato(vCodContrato, 2, vMes, vAno, 1, 2);
                    vPercentualIncidencia = percentual.RetornaPercentualContrato(vCodContrato, 7, vMes, vAno, 1, 2);

                    /**Definição da data de início como sendo a data referência (primeiro dia do mês).*/

                    vDataInicio = vDataReferencia;

                    /**Loop contendo das datas das alterações de percentuais que comporão os subperíodos.*/

                    /**Seleciona as datas que compõem os subperíodos gerados pelas alterações de percentual no mês.*/

                    List<Date> datas = new ArrayList<>();

                    try {

                        preparedStatement = connection.prepareStatement("SELECT rfc.data_inicio AS data" +
                                                                             " FROM tb_remuneracao_fun_con rfc\n" +
                                                                               " JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato" +
                                                                             " WHERE fc.cod_contrato = ?" +
                                                                               " AND fc.cod = ?" +
                                                                               " AND (MONTH(rfc.data_inicio) = ?" +
                                                                                    " AND" +
                                                                                    " YEAR(rfc.data_inicio) = ?)" +
                                                                            " UNION" +
                                                                            " SELECT rfc.data_fim AS data " +
                                                                              " FROM tb_remuneracao_fun_con rfc" +
                                                                                " JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato" +
                                                                              " WHERE fc.cod_contrato = ?" +
                                                                                " AND fc.cod = ?" +
                                                                                " AND (MONTH(rfc.data_fim) = ?" +
                                                                                     " AND " +
                                                                                     " YEAR(rfc.data_fim) = ?)" +
                                                                            " UNION" +
                                                                            " SELECT CASE WHEN ? = 2 THEN" +
                                                                                     " EOMONTH(CONVERT(DATE, CONCAT('28/' , ? , '/' ,?), 103))" +
                                                                                    " ELSE" +
                                                                                     " CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103) END AS data" +
                                                                            " ORDER BY DATA ASC");

                        preparedStatement.setInt(1, vCodContrato);
                        preparedStatement.setInt(2, tuplas.get(i).getCodFuncaoContrato());
                        preparedStatement.setInt(3, vMes);
                        preparedStatement.setInt(4, vAno);
                        preparedStatement.setInt(5, vCodContrato);
                        preparedStatement.setInt(6, tuplas.get(i).getCodFuncaoContrato());
                        preparedStatement.setInt(7, vMes);
                        preparedStatement.setInt(8, vAno);
                        preparedStatement.setInt(9, vMes);
                        preparedStatement.setInt(10, vAno);
                        resultSet = preparedStatement.executeQuery();

                        while (resultSet.next()) {

                            datas.add(resultSet.getDate("data"));

                        }
                    } catch (SQLException e) {

                        throw new NullPointerException("Não foi possível determinar os subperíodos do mês provenientes da alteração de remuneração da função: " +
                                                       tuplas.get(i).getCodFuncaoContrato() + " na data referência: " + vDataReferencia);

                    }

                    for (Date data: datas) {

                        /**Definição da data fim do subperíodo.*/

                        vDataFim = data;

                        /**Define a remuneração do cargo, que não se altera no período.*/

                        vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(tuplas.get(i).getCodFuncaoContrato(),  vDataInicio, vDataFim, 2);

                        if (vRemuneracao == 0) {

                            throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. Código -20001");

                        }

                        /**Calculo da porção correspondente ao subperíodo.*/

                        vValorFerias = ((vRemuneracao * (vPercentualFerias/100))/30) * ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);
                        vValorTercoConstitucional = ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);
                        vValorIncidenciaFerias = (vValorFerias * (vPercentualIncidencia/100));
                        vValorIncidenciaTerco = (vValorTercoConstitucional * (vPercentualIncidencia/100));

                        /**No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo,
                         situação similar para a retenção proporcional por menos de 14 dias trabalhados.*/

                        if (retencao.ExisteMudancaFuncao(pCodTerceirizadoContrato, vMes, vAno) || !retencao.FuncaoRetencaoIntegral(tuplas.get(i).getCod(), vMes, vAno)) {

                            vValorFerias = (vValorFerias/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorTercoConstitucional = (vValorTercoConstitucional/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaFerias = (vValorIncidenciaFerias/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaTerco = (vValorIncidenciaTerco/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);

                        }

                        /**Contabilização do valor calculado.*/

                        vTotalFerias = vTotalFerias + vValorFerias;
                        vTotalTercoConstitucional = vTotalTercoConstitucional + vValorTercoConstitucional;
                        vTotalIncidenciaFerias = vTotalIncidenciaFerias + vValorIncidenciaFerias;
                        vTotalIncidenciaTerco = vTotalIncidenciaTerco + vValorIncidenciaTerco;

                        vDataInicio = Date.valueOf(vDataFim.toLocalDate().plusDays(1));

                    }

                }

                /**Se existe alteração na remuneração e nos percentuais.*/

                if(convencao.ExisteDuplaConvencao(tuplas.get(i).getCodFuncaoContrato(), vMes, vAno, 2) && percentual.ExisteMudancaPercentual(vCodContrato, vMes, vAno, 2)) {

                    /**Definição da data de início como sendo a data referência (primeiro dia do mês).*/

                    vDataInicio = vDataReferencia;

                    List<Date> datas = new ArrayList<>();

                    try {

                        preparedStatement = connection.prepareStatement("SELECT data_inicio AS data" +
                                                                             " FROM tb_percentual_contrato" +
                                                                             " WHERE cod_contrato = ?" +
                                                                               " AND (MONTH(DATA_INICIO) = ?" +
                                                                                    " AND \n" +
                                                                                    " YEAR(DATA_INICIO) = ?)" +
                                                                             " UNION" +
                                                                             " SELECT data_fim AS data" +
                                                                               " FROM tb_percentual_contrato" +
                                                                               " WHERE cod_contrato = ?" +
                                                                                 " AND (MONTH(DATA_FIM)=?" +
                                                                                      " AND" +
                                                                                      " YEAR(DATA_FIM) = ?)" +
                                                                             " UNION" +
                                                                             " SELECT data_inicio AS data" +
                                                                               " FROM tb_percentual_estatico" +
                                                                               " WHERE (MONTH(DATA_INICIO)=?" +
                                                                                      " AND " +
                                                                                      " YEAR(DATA_INICIO)=?)" +
                                                                             " UNION" +
                                                                             " SELECT data_fim AS data" +
                                                                               " FROM tb_percentual_estatico" +
                                                                               " WHERE (MONTH(DATA_FIM)=?" +
                                                                                      " AND" +
                                                                                      " YEAR(DATA_FIM)=?)" +
                                                                             " UNION" +
                                                                             " SELECT rfc.data_inicio AS data" +
                                                                               " FROM tb_remuneracao_fun_con rfc\n" +
                                                                                 " JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato" +
                                                                               " WHERE fc.cod_contrato = ?" +
                                                                                 " AND fc.cod = ?" +
                                                                                 " AND (MONTH(rfc.data_inicio) = ?" +
                                                                                      " AND" +
                                                                                      " YEAR(rfc.data_inicio) = ?)" +
                                                                             " UNION" +
                                                                             " SELECT rfc.data_fim AS data " +
                                                                               " FROM tb_remuneracao_fun_con rfc" +
                                                                                 " JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato" +
                                                                               " WHERE fc.cod_contrato = ?" +
                                                                                 " AND fc.cod = ?" +
                                                                                 " AND (MONTH(rfc.data_fim) = ?" +
                                                                                      " AND " +
                                                                                      " YEAR(rfc.data_fim) = ?)" +
                                                                             " UNION" +
                                                                             " SELECT CASE WHEN ? = 2 THEN" +
                                                                                      " EOMONTH(CONVERT(DATE, CONCAT('28/' , ? , '/' ,?), 103))" +
                                                                                     " ELSE" +
                                                                                      " CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103) END AS data" +
                                                                             " ORDER BY DATA ASC");

                        preparedStatement.setInt(1, vCodContrato);
                        preparedStatement.setInt(2, vMes);
                        preparedStatement.setInt(3, vAno);
                        preparedStatement.setInt(4, vCodContrato);
                        preparedStatement.setInt(5, vMes);
                        preparedStatement.setInt(6, vAno);
                        preparedStatement.setInt(7, vMes);
                        preparedStatement.setInt(8, vAno);
                        preparedStatement.setInt(9, vMes);
                        preparedStatement.setInt(10, vAno);
                        preparedStatement.setInt(11, vCodContrato);
                        preparedStatement.setInt(12, tuplas.get(i).getCodFuncaoContrato());
                        preparedStatement.setInt(13, vMes);
                        preparedStatement.setInt(14, vAno);
                        preparedStatement.setInt(15, vCodContrato);
                        preparedStatement.setInt(16, tuplas.get(i).getCodFuncaoContrato());
                        preparedStatement.setInt(17, vMes);
                        preparedStatement.setInt(18, vAno);
                        preparedStatement.setInt(19, vMes);
                        preparedStatement.setInt(20, vMes);
                        preparedStatement.setInt(21, vAno);
                        preparedStatement.setInt(22, vMes);
                        preparedStatement.setInt(23, vAno);
                        resultSet = preparedStatement.executeQuery();

                        while (resultSet.next()) {

                            datas.add(resultSet.getDate("data"));

                        }

                    } catch (SQLException e) {

                        throw new NullPointerException("Não foi possível determinar os subperíodos do mês provenientes da alteração de percentuais e da remuneração da função: " +
                                tuplas.get(i).getCodFuncaoContrato() + " na data referência: " + vDataReferencia);

                    }

                    for (Date data: datas) {

                        /**Definição da data fim do subperíodo.*/

                        vDataFim = data;

                        /**Define a remuneração do cargo, que não se altera no período.*/

                        vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(tuplas.get(i).getCodFuncaoContrato(),  vDataInicio, vDataFim, 2);

                        if (vRemuneracao == 0) {

                            throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. Código -20001");

                        }

                        /**Definição dos percentuais do subperíodo.*/

                        vPercentualFerias = percentual.RetornaPercentualContrato(vCodContrato, 1, vDataInicio, vDataFim, 2);
                        vPercentualTercoConstitucional = percentual.RetornaPercentualContrato(vCodContrato, 2, vDataInicio, vDataFim, 2);
                        vPercentualIncidencia = percentual.RetornaPercentualContrato(vCodContrato, 7, vDataInicio, vDataFim, 2);

                        /**Calculo da porção correspondente ao subperíodo.*/

                        vValorFerias = ((vRemuneracao * (vPercentualFerias/100))/30) * ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);
                        vValorTercoConstitucional = ((vRemuneracao * (vPercentualTercoConstitucional/100))/30) * ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);
                        vValorIncidenciaFerias = (vValorFerias * (vPercentualIncidencia/100));
                        vValorIncidenciaTerco = (vValorTercoConstitucional * (vPercentualIncidencia/100));

                        /**No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo,
                         situação similar para a retenção proporcional por menos de 14 dias trabalhados.*/

                        if (retencao.ExisteMudancaFuncao(pCodTerceirizadoContrato, vMes, vAno) || !retencao.FuncaoRetencaoIntegral(tuplas.get(i).getCod(), vMes, vAno)) {

                            vValorFerias = (vValorFerias/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorTercoConstitucional = (vValorTercoConstitucional/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaFerias = (vValorIncidenciaFerias/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaTerco = (vValorIncidenciaTerco/((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1)) * periodo.DiasTrabalhadosPeriodo(tuplas.get(i).getCod(), vDataInicio, vDataFim);

                        }

                        /**Contabilização do valor calculado.*/

                        vTotalFerias = vTotalFerias + vValorFerias;
                        vTotalTercoConstitucional = vTotalTercoConstitucional + vValorTercoConstitucional;
                        vTotalIncidenciaFerias = vTotalIncidenciaFerias + vValorIncidenciaFerias;
                        vTotalIncidenciaTerco = vTotalIncidenciaTerco + vValorIncidenciaTerco;

                        vDataInicio = Date.valueOf(vDataFim.toLocalDate().plusDays(1));

                    }


                }

                vControleMeses = vControleMeses + 1;

            }

            if (vMes != 12) {

                vMes = vMes + 1;
            }

            else {

                vMes = 1;
                vAno = vAno + 1;

            }

        } while (vMes != pFimPeriodoAquisitivo.toLocalDate().getMonthValue() && vAno != pFimPeriodoAquisitivo.toLocalDate().getYear());

        System.out.println(vTotalFerias);
        System.out.println(vTotalTercoConstitucional);
        System.out.println(vTotalIncidenciaFerias);
        System.out.println(vTotalIncidenciaTerco);

    }

    /**Seleção do código da função terceirizado e da função contrato.*/

    ArrayList<CodFuncaoContratoECodFuncaoTerceirizadoModel> selecionaFuncaoContratoEFuncaoTerceirizado (int pCodTerceirizadoContrato, Date pDataReferencia) {

        /**Busca as funções que um funcionário exerceu no mês de cálculo.*/

        ArrayList<CodFuncaoContratoECodFuncaoTerceirizadoModel> tuplas = new ArrayList<>();

        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT ft.cod_funcao_contrato, " +
                                                                                           "ft.cod" +
                                                                                     " FROM tb_funcao_terceirizado ft" +
                                                                                     " WHERE ft.cod_terceirizado_contrato = ?" +
                                                                                        " AND ((((CONVERT(date, CONVERT(varchar, year(ft.data_inicio)) + '-' + CONVERT(varchar, month(ft.data_inicio)) + '-01')) <= ?)" +
                                                                                               " AND" +
                                                                                               " (ft.data_fim >= ?))" +
                                                                                               " OR" +
                                                                                               " (((CONVERT(date, CONVERT(varchar, year(ft.data_inicio)) + '-' + CONVERT(varchar, month(ft.data_inicio)) + '-01')) <= ?) " +
                                                                                                "AND" +
                                                                                               " (ft.data_fim IS NULL)))")){

            preparedStatement.setInt(1, pCodTerceirizadoContrato);
            preparedStatement.setDate(2, pDataReferencia);
            preparedStatement.setDate(3, pDataReferencia);
            preparedStatement.setDate(4, pDataReferencia);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                while (resultSet.next()) {

                    CodFuncaoContratoECodFuncaoTerceirizadoModel tupla = new CodFuncaoContratoECodFuncaoTerceirizadoModel(resultSet.getInt("COD"), resultSet.getInt("COD_FUNCAO_CONTRATO"));

                    tuplas.add(tupla);

                }

            }

        } catch(SQLException slqe) {
            //slqe.printStackTrace();
            throw new NullPointerException("Problemas durante a consulta ao banco em relação ao terceirizado: " + pCodTerceirizadoContrato);

        }

        return tuplas;

    }

}