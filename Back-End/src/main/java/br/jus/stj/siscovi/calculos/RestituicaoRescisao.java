package br.jus.stj.siscovi.calculos;

import br.jus.stj.siscovi.dao.sql.ConsultaTSQL;
import br.jus.stj.siscovi.dao.sql.InsertTSQL;
import br.jus.stj.siscovi.model.CodFuncaoContratoECodFuncaoTerceirizadoModel;
import br.jus.stj.siscovi.model.ValorRestituicaoRescisaoModel;

import java.sql.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class RestituicaoRescisao {

    private Connection connection;

    public RestituicaoRescisao(Connection connection) {

        this.connection = connection;

    }

    /**
     * Método que calcula o total da rescisão a ser restituída para um
     * determinado período aquisitivo.
     *
     * @param pCodTerceirizadoContrato;
     * @param pDataDesligamento;
     */

    public ValorRestituicaoRescisaoModel CalculaRestituicaoRescisao (int pCodTerceirizadoContrato,
                                                                     Date pDataDesligamento) {

        PreparedStatement preparedStatement;
        ResultSet resultSet;
        Retencao retencao = new Retencao(connection);
        Percentual percentual = new Percentual(connection);
        Periodos periodo = new Periodos(connection);
        Remuneracao remuneracao = new Remuneracao(connection);
        Saldo saldo = new Saldo(connection);
        ConsultaTSQL consulta = new ConsultaTSQL(connection);

        /*Chaves primárias.*/

        int vCodContrato;

        /*Variáveis totalizadoras de valores.*/

        float vTotalFerias = 0;
        float vTotalTercoConstitucional = 0;
        float vTotalIncidenciaFerias = 0;
        float vTotalIncidenciaTerco = 0;
        float vTotalDecimoTerceiro = 0;
        float vTotalIncidenciaDecimoTerceiro = 0;
        float vTotalMultaFGTSRemuneracao = 0;
        float vTotalMultaFGTSFerias = 0;
        float vTotalMultaFGTSTerco = 0;
        float vTotalMultaFGTSDecimoTerceiro = 0;

        /*Variáveis de valores parciais.*/

        float vValorFerias;
        float vValorTercoConstitucional;
        float vValorIncidenciaFerias;
        float vValorIncidenciaTerco;
        float vValorDecimoTerceiro;
        float vValorIncidenciaDecimoTerceiro;
        float vValorMultaFGTSRemuneracao;
        float vValorMultaFGTSFerias;
        float vValorMultaFGTSTerco;
        float vValorMultaFGTSDecimoTerceiro;

        /*Variáveis de percentuais.*/

        float vPercentualFerias;
        float vPercentualTercoConstitucional;
        float vPercentualIncidencia;
        float vPercentualDecimoTerceiro;
        float vPercentualFGTS;
        float vPercentualMultaFGTS;
        float vPercentualPenalidadeFGTS;

        /*Variável de remuneração da função.*/

        float vRemuneracao;

        /*Variáveis de data.*/

        Date vDataDisponibilizacao;
        Date vDataReferencia;
        Date vDataInicio;
        Date vDataFim;
        int vAno;
        int vMes;

        /*Variável para a checagem de existência do terceirizado.*/

        int vCheck = 0;

        /*Variáveis de controle.*/

        int vDiasSubperiodo;

        /*Checagem dos parâmetros passados.*/

        if (pDataDesligamento == null) {

            throw new NullPointerException("Erro na checagem dos parâmetros.");

        }

        /*Atribuiçao da data de disponibilização e do cod do contrato.*/

        vCodContrato = consulta.RetornaContratoTerceirizado(pCodTerceirizadoContrato);
        vDataDisponibilizacao = consulta.RetornaDataDisponibilizacaoTerceirizado(pCodTerceirizadoContrato);

        /*Define o valor das variáveis vMes e Vano de acordo com a adata de inínio do período aquisitivo.*/

        vMes = vDataDisponibilizacao.toLocalDate().getMonthValue();
        vAno = vDataDisponibilizacao.toLocalDate().getYear();

        /*Definição da data referência (sempre o primeiro dia do mês).*/

        vDataReferencia = Date.valueOf(vAno + "-" + vMes + "-" + "01");

        /*Início da contabilização de férias do período.*/

        do {

            /*Seleciona as funções que o terceirizado ocupou no mês avaliado.*/

            ArrayList<CodFuncaoContratoECodFuncaoTerceirizadoModel> tuplas = consulta.SelecionaFuncaoContratoEFuncaoTerceirizado(pCodTerceirizadoContrato, vDataReferencia);

            Convencao convencao = new Convencao(connection);

            /*Para cada função que o terceirizado ocupou no mês avaliado.*/

            for (CodFuncaoContratoECodFuncaoTerceirizadoModel tupla : tuplas) {

                /*Caso não exista mais de uma remuneração vigente no mês e não tenha havido alteração nos percentuais do contrato ou nos percentuais estáticos.*/

                if (!convencao.ExisteDuplaConvencao(tupla.getCodFuncaoContrato(), vMes, vAno, 2) && !percentual.ExisteMudancaPercentual(vCodContrato, vMes, vAno, 2)) {

                    /*Define o valor da remuneração da função e dos percentuais do contrato.*/

                    vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(tupla.getCodFuncaoContrato(), vMes, vAno, 1, 2);
                    vPercentualFerias = percentual.RetornaPercentualContrato(vCodContrato, 1, vMes, vAno, 1, 2);
                    vPercentualTercoConstitucional = percentual.RetornaPercentualContrato(vCodContrato, 2, vMes, vAno, 1, 2);
                    vPercentualDecimoTerceiro = percentual.RetornaPercentualContrato(vCodContrato, 3, vMes, vAno, 1, 2);
                    vPercentualIncidencia = percentual.RetornaPercentualContrato(vCodContrato, 7, vMes, vAno, 1, 2);
                    vPercentualFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 4, vMes, vAno, 1, 2);
                    vPercentualPenalidadeFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 6, vMes, vAno, 1, 2);
                    vPercentualMultaFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 5, vMes, vAno, 1, 2);

                    if (vRemuneracao == 0) {

                        throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. Código -20001");

                    }

                    /*Cálculo do valor integral correspondente ao mês avaliado.*/

                    vValorFerias = (vRemuneracao * (vPercentualFerias / 100));
                    vValorTercoConstitucional = (vRemuneracao * (vPercentualTercoConstitucional / 100));
                    vValorDecimoTerceiro = (vRemuneracao * (vPercentualDecimoTerceiro / 100));
                    vValorIncidenciaFerias = (vValorFerias * (vPercentualIncidencia / 100));
                    vValorIncidenciaTerco = (vValorTercoConstitucional * (vPercentualIncidencia / 100));
                    vValorIncidenciaDecimoTerceiro = (vValorDecimoTerceiro * (vPercentualIncidencia / 100));
                    vValorMultaFGTSFerias = (vValorFerias * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100)));
                    vValorMultaFGTSTerco = (vValorTercoConstitucional * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100)));
                    vValorMultaFGTSDecimoTerceiro = (vValorDecimoTerceiro * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100)));
                    vValorMultaFGTSRemuneracao = (vRemuneracao * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100)));

                    /*o caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo,
                     situação similar para a retenção proporcional por menos de 14 dias trabalhados.*/

                    if (retencao.ExisteMudancaFuncao(pCodTerceirizadoContrato, vMes, vAno) || !retencao.FuncaoRetencaoIntegral(tupla.getCod(), vMes, vAno)) {

                        vValorFerias = (vValorFerias / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorTercoConstitucional = (vValorTercoConstitucional / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorDecimoTerceiro = (vValorDecimoTerceiro / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorIncidenciaFerias = (vValorIncidenciaFerias / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorIncidenciaTerco = (vValorIncidenciaTerco / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorIncidenciaDecimoTerceiro = (vValorIncidenciaDecimoTerceiro / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorMultaFGTSFerias = (vValorMultaFGTSFerias / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorMultaFGTSTerco = (vValorMultaFGTSTerco / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorMultaFGTSDecimoTerceiro = (vValorMultaFGTSDecimoTerceiro / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);
                        vValorMultaFGTSRemuneracao = (vValorMultaFGTSRemuneracao / 30) * periodo.DiasTrabalhadosMes(tupla.getCod(), vMes, vAno);

                    }

                    /*Contabilização do valor calculado.*/

                    vTotalFerias = vTotalFerias + vValorFerias;
                    vTotalTercoConstitucional = vTotalTercoConstitucional + vValorTercoConstitucional;
                    vTotalDecimoTerceiro = vTotalDecimoTerceiro + vValorDecimoTerceiro;
                    vTotalIncidenciaFerias = vTotalIncidenciaFerias + vValorIncidenciaFerias;
                    vTotalIncidenciaTerco = vTotalIncidenciaTerco + vValorIncidenciaTerco;
                    vTotalIncidenciaDecimoTerceiro = vTotalIncidenciaDecimoTerceiro + vValorIncidenciaDecimoTerceiro;
                    vTotalMultaFGTSRemuneracao = vTotalMultaFGTSRemuneracao + vValorMultaFGTSRemuneracao;
                    vTotalMultaFGTSFerias = vTotalMultaFGTSFerias + vValorMultaFGTSFerias;
                    vTotalMultaFGTSTerco = vTotalMultaFGTSTerco + vValorMultaFGTSTerco;
                    vTotalMultaFGTSDecimoTerceiro = vTotalMultaFGTSDecimoTerceiro + vValorMultaFGTSDecimoTerceiro;

                }

                /*Se existe apenas alteração de percentual no mês.*/

                if (!convencao.ExisteDuplaConvencao(tupla.getCodFuncaoContrato(), vMes, vAno, 2) && percentual.ExisteMudancaPercentual(vCodContrato, vMes, vAno, 2)) {

                    /*Define a remuneração do cargo, que não se altera no período.*/

                    vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(tupla.getCodFuncaoContrato(), vMes, vAno, 1, 2);

                    if (vRemuneracao == 0) {

                        throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. Código -20001");

                    }

                    /*Definição da data de início como sendo a data referência (primeiro dia do mês).*/

                    vDataInicio = vDataReferencia;

                    /*Loop contendo das datas das alterações de percentuais que comporão os subperíodos.*/

                    List<Date> datas = new ArrayList<>();

                    /*Seleciona as datas que compõem os subperíodos gerados pelas alterações de percentual no mês.*/

                    try {

                        preparedStatement = connection.prepareStatement("SELECT data_inicio AS data" + " FROM tb_percentual_contrato" + " WHERE cod_contrato = ?" + " AND (MONTH(DATA_INICIO) = ?" + " AND \n" + " YEAR(DATA_INICIO) = ?)" + " UNION" + " SELECT data_fim AS data" + " FROM tb_percentual_contrato" + " WHERE cod_contrato = ?" + " AND (MONTH(DATA_FIM)=?" + " AND" + " YEAR(DATA_FIM) = ?)" + " UNION" + " SELECT data_inicio AS data" + " FROM tb_percentual_estatico" + " WHERE (MONTH(DATA_INICIO)=?" + " AND " + " YEAR(DATA_INICIO)=?)" + " UNION" + " SELECT data_fim AS data" + " FROM tb_percentual_estatico" + " WHERE (MONTH(DATA_FIM)=?" + " AND" + " YEAR(DATA_FIM)=?)" + " UNION" + " SELECT CASE WHEN ? = 2 THEN" + " EOMONTH(CONVERT(DATE, CONCAT('28/' , ? , '/' ,?), 103))" + " ELSE" + " CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103) END AS data" + " EXCEPT" + " SELECT CASE WHEN DAY(EOMONTH(CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103))) = 31 THEN" + " CONVERT(DATE, CONCAT('31/' , ? , '/' ,?), 103)" + " ELSE" + " NULL END AS data" + " ORDER BY data ASC");

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
                        preparedStatement.setInt(16, vMes);
                        preparedStatement.setInt(17, vAno);
                        preparedStatement.setInt(18, vMes);
                        preparedStatement.setInt(19, vAno);
                        resultSet = preparedStatement.executeQuery();

                        while (resultSet.next()) {

                            datas.add(resultSet.getDate("data"));

                        }

                    } catch (SQLException e) {

                        throw new NullPointerException("Erro ao tentar carregar as datas referentes ao percentuais. " + " Contrato: " + vCodContrato + ". No perídodo: " + vDataReferencia.toLocalDate().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));

                    }

                    for (Date data : datas) {

                        /*Definição da data fim do subperíodo.*/

                        vDataFim = data;

                        /*Definição dos dias contidos no subperíodo*/

                        vDiasSubperiodo = (int) ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);

                        if (vMes == 2) {

                            if (vDataFim.toLocalDate().getDayOfMonth() == Date.valueOf(vDataReferencia.toLocalDate().withDayOfMonth(vDataReferencia.toLocalDate().lengthOfMonth())).toLocalDate().getDayOfMonth()) {

                                if (vDataFim.toLocalDate().getDayOfMonth() == 28) {

                                    vDiasSubperiodo = vDiasSubperiodo + 2;

                                } else {

                                    vDiasSubperiodo = vDiasSubperiodo + 1;

                                }

                            }

                        }

                        /*Definição dos percentuais do subperíodo.*/

                        vPercentualFerias = percentual.RetornaPercentualContrato(vCodContrato, 1, vDataInicio, vDataFim, 2);
                        vPercentualTercoConstitucional = percentual.RetornaPercentualContrato(vCodContrato, 2, vDataInicio, vDataFim, 2);
                        vPercentualDecimoTerceiro = percentual.RetornaPercentualContrato(vCodContrato, 3, vDataInicio, vDataFim, 2);
                        vPercentualIncidencia = percentual.RetornaPercentualContrato(vCodContrato, 7, vDataInicio, vDataFim, 2);
                        vPercentualFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 4, vDataInicio, vDataFim, 2);
                        vPercentualPenalidadeFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 6, vDataInicio, vDataFim, 2);
                        vPercentualMultaFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 5, vDataInicio, vDataFim, 2);

                        /*Calculo da porção correspondente ao subperíodo.*/

                        vValorFerias = ((vRemuneracao * (vPercentualFerias / 100)) / 30) * vDiasSubperiodo;
                        vValorTercoConstitucional = ((vRemuneracao * (vPercentualTercoConstitucional / 100)) / 30) * vDiasSubperiodo;
                        vValorDecimoTerceiro = ((vRemuneracao * (vPercentualDecimoTerceiro / 100)) / 30) * vDiasSubperiodo;
                        vValorIncidenciaFerias = (vValorFerias * (vPercentualIncidencia / 100));
                        vValorIncidenciaTerco = (vValorTercoConstitucional * (vPercentualIncidencia / 100));
                        vValorIncidenciaDecimoTerceiro = (vValorDecimoTerceiro * (vPercentualIncidencia / 100));
                        vValorMultaFGTSFerias = ((vValorFerias * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSTerco = ((vValorTercoConstitucional * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSDecimoTerceiro = ((vValorDecimoTerceiro * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSRemuneracao = ((vRemuneracao * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;

                        /*No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo,
                         situação similar para a retenção proporcional por menos de 30 dias trabalhados.*/

                        if (retencao.ExisteMudancaFuncao(pCodTerceirizadoContrato, vMes, vAno) || !retencao.FuncaoRetencaoIntegral(tupla.getCod(), vMes, vAno)) {

                            vValorFerias = (vValorFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorTercoConstitucional = (vValorTercoConstitucional / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorDecimoTerceiro = (vValorDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaFerias = (vValorIncidenciaFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaTerco = (vValorIncidenciaTerco / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaDecimoTerceiro = (vValorIncidenciaDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSFerias = (vValorMultaFGTSFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSTerco = (vValorMultaFGTSTerco / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSDecimoTerceiro = (vValorMultaFGTSDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSRemuneracao = (vValorMultaFGTSRemuneracao / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);

                        }

                        /*Contabilização do valor calculado.*/

                        vTotalFerias = vTotalFerias + vValorFerias;
                        vTotalTercoConstitucional = vTotalTercoConstitucional + vValorTercoConstitucional;
                        vTotalDecimoTerceiro = vTotalDecimoTerceiro + vValorDecimoTerceiro;
                        vTotalIncidenciaFerias = vTotalIncidenciaFerias + vValorIncidenciaFerias;
                        vTotalIncidenciaTerco = vTotalIncidenciaTerco + vValorIncidenciaTerco;
                        vTotalIncidenciaDecimoTerceiro = vTotalIncidenciaDecimoTerceiro + vValorIncidenciaDecimoTerceiro;
                        vTotalMultaFGTSRemuneracao = vTotalMultaFGTSRemuneracao + vValorMultaFGTSRemuneracao;
                        vTotalMultaFGTSFerias = vTotalMultaFGTSFerias + vValorMultaFGTSFerias;
                        vTotalMultaFGTSTerco = vTotalMultaFGTSTerco + vValorMultaFGTSTerco;
                        vTotalMultaFGTSDecimoTerceiro = vTotalMultaFGTSDecimoTerceiro + vValorMultaFGTSDecimoTerceiro;

                        vDataInicio = Date.valueOf(vDataFim.toLocalDate().plusDays(1));

                    }

                }

                /*Se existe alteração de remuneração apenas.*/

                if (convencao.ExisteDuplaConvencao(tupla.getCodFuncaoContrato(), vMes, vAno, 2) && !percentual.ExisteMudancaPercentual(vCodContrato, vMes, vAno, 2)) {

                    /*Definição dos percentuais, que não se alteram no período.*/

                    vPercentualFerias = percentual.RetornaPercentualContrato(vCodContrato, 1, vMes, vAno, 1, 2);
                    vPercentualTercoConstitucional = percentual.RetornaPercentualContrato(vCodContrato, 2, vMes, vAno, 1, 2);
                    vPercentualDecimoTerceiro = percentual.RetornaPercentualContrato(vCodContrato, 3, vMes, vAno, 1, 2);
                    vPercentualIncidencia = percentual.RetornaPercentualContrato(vCodContrato, 7, vMes, vAno, 1, 2);
                    vPercentualFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 4, vMes, vAno, 1, 2);
                    vPercentualPenalidadeFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 6, vMes, vAno, 1, 2);
                    vPercentualMultaFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 5, vMes, vAno, 1, 2);

                    /*Definição da data de início como sendo a data referência (primeiro dia do mês).*/

                    vDataInicio = vDataReferencia;

                    /*Loop contendo das datas das alterações de percentuais que comporão os subperíodos.*/

                    /*Seleciona as datas que compõem os subperíodos gerados pelas alterações de percentual no mês.*/

                    List<Date> datas = new ArrayList<>();

                    try {

                        preparedStatement = connection.prepareStatement("SELECT rfc.data_inicio AS data" + " FROM tb_remuneracao_fun_con rfc\n" + " JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato" + " WHERE fc.cod_contrato = ?" + " AND fc.cod = ?" + " AND (MONTH(rfc.data_inicio) = ?" + " AND" + " YEAR(rfc.data_inicio) = ?)" + " UNION" + " SELECT rfc.data_fim AS data " + " FROM tb_remuneracao_fun_con rfc" + " JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato" + " WHERE fc.cod_contrato = ?" + " AND fc.cod = ?" + " AND (MONTH(rfc.data_fim) = ?" + " AND " + " YEAR(rfc.data_fim) = ?)" + " UNION" + " SELECT CASE WHEN ? = 2 THEN" + " EOMONTH(CONVERT(DATE, CONCAT('28/' , ? , '/' ,?), 103))" + " ELSE" + " CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103) END AS data" + " EXCEPT" + " SELECT CASE WHEN DAY(EOMONTH(CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103))) = 31 THEN" + " CONVERT(DATE, CONCAT('31/' , ? , '/' ,?), 103)" + " ELSE" + " NULL END AS data" + " ORDER BY DATA ASC");

                        preparedStatement.setInt(1, vCodContrato);
                        preparedStatement.setInt(2, tupla.getCodFuncaoContrato());
                        preparedStatement.setInt(3, vMes);
                        preparedStatement.setInt(4, vAno);
                        preparedStatement.setInt(5, vCodContrato);
                        preparedStatement.setInt(6, tupla.getCodFuncaoContrato());
                        preparedStatement.setInt(7, vMes);
                        preparedStatement.setInt(8, vAno);
                        preparedStatement.setInt(9, vMes);
                        preparedStatement.setInt(10, vMes);
                        preparedStatement.setInt(11, vAno);
                        preparedStatement.setInt(12, vMes);
                        preparedStatement.setInt(13, vAno);
                        preparedStatement.setInt(14, vMes);
                        preparedStatement.setInt(15, vAno);
                        preparedStatement.setInt(16, vMes);
                        preparedStatement.setInt(17, vAno);
                        resultSet = preparedStatement.executeQuery();

                        while (resultSet.next()) {

                            datas.add(resultSet.getDate("data"));

                        }

                    } catch (SQLException e) {

                        throw new NullPointerException("Não foi possível determinar os subperíodos do mês provenientes da alteração de remuneração da função: " + tupla.getCodFuncaoContrato() + " na data referência: " + vDataReferencia);

                    }

                    for (Date data : datas) {

                        /*Definição da data fim do subperíodo.*/

                        vDataFim = data;

                        /*Definição dos dias contidos no subperíodo*/

                        vDiasSubperiodo = (int) ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);

                        if (vMes == 2) {

                            if (vDataFim.toLocalDate().getDayOfMonth() == Date.valueOf(vDataReferencia.toLocalDate().withDayOfMonth(vDataReferencia.toLocalDate().lengthOfMonth())).toLocalDate().getDayOfMonth()) {

                                if (vDataFim.toLocalDate().getDayOfMonth() == 28) {

                                    vDiasSubperiodo = vDiasSubperiodo + 2;

                                } else {

                                    vDiasSubperiodo = vDiasSubperiodo + 1;

                                }

                            }

                        }

                        /*Define a remuneração do cargo, que não se altera no período.*/

                        vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(tupla.getCodFuncaoContrato(), vDataInicio, vDataFim, 2);

                        if (vRemuneracao == 0) {

                            throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. Código -20001");

                        }

                        /*Calculo da porção correspondente ao subperíodo.*/

                        vValorFerias = ((vRemuneracao * (vPercentualFerias / 100)) / 30) * vDiasSubperiodo;
                        vValorTercoConstitucional = ((vRemuneracao * (vPercentualTercoConstitucional / 100)) / 30) * vDiasSubperiodo;
                        vValorDecimoTerceiro = ((vRemuneracao * (vPercentualDecimoTerceiro / 100)) / 30) * vDiasSubperiodo;
                        vValorIncidenciaFerias = (vValorFerias * (vPercentualIncidencia / 100));
                        vValorIncidenciaTerco = (vValorTercoConstitucional * (vPercentualIncidencia / 100));
                        vValorIncidenciaDecimoTerceiro = (vValorDecimoTerceiro * (vPercentualIncidencia / 100));
                        vValorMultaFGTSFerias = ((vValorFerias * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSTerco = ((vValorTercoConstitucional * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSDecimoTerceiro = ((vValorDecimoTerceiro * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSRemuneracao = ((vRemuneracao * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;

                        /*No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo,
                         situação similar para a retenção proporcional por menos de 14 dias trabalhados.*/

                        if (retencao.ExisteMudancaFuncao(pCodTerceirizadoContrato, vMes, vAno) || !retencao.FuncaoRetencaoIntegral(tupla.getCod(), vMes, vAno)) {

                            vValorFerias = (vValorFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorTercoConstitucional = (vValorTercoConstitucional / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorDecimoTerceiro = (vValorDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaFerias = (vValorIncidenciaFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaTerco = (vValorIncidenciaTerco / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaDecimoTerceiro = (vValorIncidenciaDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSFerias = (vValorMultaFGTSFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSTerco = (vValorMultaFGTSTerco / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSDecimoTerceiro = (vValorMultaFGTSDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSRemuneracao = (vValorMultaFGTSRemuneracao / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);

                        }

                        /*Contabilização do valor calculado.*/

                        vTotalFerias = vTotalFerias + vValorFerias;
                        vTotalTercoConstitucional = vTotalTercoConstitucional + vValorTercoConstitucional;
                        vTotalDecimoTerceiro = vTotalDecimoTerceiro + vValorDecimoTerceiro;
                        vTotalIncidenciaFerias = vTotalIncidenciaFerias + vValorIncidenciaFerias;
                        vTotalIncidenciaTerco = vTotalIncidenciaTerco + vValorIncidenciaTerco;
                        vTotalIncidenciaDecimoTerceiro = vTotalIncidenciaDecimoTerceiro + vValorIncidenciaDecimoTerceiro;
                        vTotalMultaFGTSRemuneracao = vTotalMultaFGTSRemuneracao + vValorMultaFGTSRemuneracao;
                        vTotalMultaFGTSFerias = vTotalMultaFGTSFerias + vValorMultaFGTSFerias;
                        vTotalMultaFGTSTerco = vTotalMultaFGTSTerco + vValorMultaFGTSTerco;
                        vTotalMultaFGTSDecimoTerceiro = vTotalMultaFGTSDecimoTerceiro + vValorMultaFGTSDecimoTerceiro;

                        vDataInicio = Date.valueOf(vDataFim.toLocalDate().plusDays(1));

                    }

                }

                /*Se existe alteração na remuneração e nos percentuais.*/

                if (convencao.ExisteDuplaConvencao(tupla.getCodFuncaoContrato(), vMes, vAno, 2) && percentual.ExisteMudancaPercentual(vCodContrato, vMes, vAno, 2)) {

                    /*Definição da data de início como sendo a data referência (primeiro dia do mês).*/

                    vDataInicio = vDataReferencia;

                    List<Date> datas = new ArrayList<>();

                    try {

                        preparedStatement = connection.prepareStatement("SELECT data_inicio AS data" + " FROM tb_percentual_contrato" + " WHERE cod_contrato = ?" + " AND (MONTH(DATA_INICIO) = ?" + " AND \n" + " YEAR(DATA_INICIO) = ?)" + " UNION" + " SELECT data_fim AS data" + " FROM tb_percentual_contrato" + " WHERE cod_contrato = ?" + " AND (MONTH(DATA_FIM)=?" + " AND" + " YEAR(DATA_FIM) = ?)" + " UNION" + " SELECT data_inicio AS data" + " FROM tb_percentual_estatico" + " WHERE (MONTH(DATA_INICIO)=?" + " AND " + " YEAR(DATA_INICIO)=?)" + " UNION" + " SELECT data_fim AS data" + " FROM tb_percentual_estatico" + " WHERE (MONTH(DATA_FIM)=?" + " AND" + " YEAR(DATA_FIM)=?)" + " UNION" + " SELECT rfc.data_inicio AS data" + " FROM tb_remuneracao_fun_con rfc\n" + " JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato" + " WHERE fc.cod_contrato = ?" + " AND fc.cod = ?" + " AND (MONTH(rfc.data_inicio) = ?" + " AND" + " YEAR(rfc.data_inicio) = ?)" + " UNION" + " SELECT rfc.data_fim AS data " + " FROM tb_remuneracao_fun_con rfc" + " JOIN tb_funcao_contrato fc ON fc.cod = rfc.cod_funcao_contrato" + " WHERE fc.cod_contrato = ?" + " AND fc.cod = ?" + " AND (MONTH(rfc.data_fim) = ?" + " AND " + " YEAR(rfc.data_fim) = ?)" + " UNION" + " SELECT CASE WHEN ? = 2 THEN" + " EOMONTH(CONVERT(DATE, CONCAT('28/' , ? , '/' ,?), 103))" + " ELSE" + " CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103) END AS data" + " EXCEPT" + " SELECT CASE WHEN DAY(EOMONTH(CONVERT(DATE, CONCAT('30/' , ? , '/' ,?), 103))) = 31 THEN" + " CONVERT(DATE, CONCAT('31/' , ? , '/' ,?), 103)" + " ELSE" + " NULL END AS data" + " ORDER BY DATA ASC");

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
                        preparedStatement.setInt(12, tupla.getCodFuncaoContrato());
                        preparedStatement.setInt(13, vMes);
                        preparedStatement.setInt(14, vAno);
                        preparedStatement.setInt(15, vCodContrato);
                        preparedStatement.setInt(16, tupla.getCodFuncaoContrato());
                        preparedStatement.setInt(17, vMes);
                        preparedStatement.setInt(18, vAno);
                        preparedStatement.setInt(19, vMes);
                        preparedStatement.setInt(20, vMes);
                        preparedStatement.setInt(21, vAno);
                        preparedStatement.setInt(22, vMes);
                        preparedStatement.setInt(23, vAno);
                        preparedStatement.setInt(24, vMes);
                        preparedStatement.setInt(25, vAno);
                        preparedStatement.setInt(26, vMes);
                        preparedStatement.setInt(27, vAno);
                        resultSet = preparedStatement.executeQuery();

                        while (resultSet.next()) {

                            datas.add(resultSet.getDate("data"));

                        }

                    } catch (SQLException e) {

                        throw new NullPointerException("Não foi possível determinar os subperíodos do mês provenientes da alteração de percentuais e da remuneração da função: " + tupla.getCodFuncaoContrato() + " na data referência: " + vDataReferencia);

                    }

                    for (Date data : datas) {

                        /*Definição da data fim do subperíodo.*/

                        vDataFim = data;

                        /*Definição dos dias contidos no subperíodo*/

                        vDiasSubperiodo = (int) ((ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate())) + 1);

                        if (vMes == 2) {

                            if (vDataFim.toLocalDate().getDayOfMonth() == Date.valueOf(vDataReferencia.toLocalDate().withDayOfMonth(vDataReferencia.toLocalDate().lengthOfMonth())).toLocalDate().getDayOfMonth()) {

                                if (vDataFim.toLocalDate().getDayOfMonth() == 28) {

                                    vDiasSubperiodo = vDiasSubperiodo + 2;

                                } else {

                                    vDiasSubperiodo = vDiasSubperiodo + 1;

                                }

                            }

                        }

                        /*Define a remuneração do cargo, que não se altera no período.*/

                        vRemuneracao = remuneracao.RetornaRemuneracaoPeriodo(tupla.getCodFuncaoContrato(), vDataInicio, vDataFim, 2);

                        if (vRemuneracao == 0) {

                            throw new NullPointerException("Erro na execução do procedimento: Remuneração não encontrada. Código -20001");

                        }

                        /*Definição dos percentuais do subperíodo.*/

                        vPercentualFerias = percentual.RetornaPercentualContrato(vCodContrato, 1, vDataInicio, vDataFim, 2);
                        vPercentualTercoConstitucional = percentual.RetornaPercentualContrato(vCodContrato, 2, vDataInicio, vDataFim, 2);
                        vPercentualDecimoTerceiro = percentual.RetornaPercentualContrato(vCodContrato, 3, vDataInicio, vDataFim, 2);
                        vPercentualIncidencia = percentual.RetornaPercentualContrato(vCodContrato, 7, vDataInicio, vDataFim, 2);
                        vPercentualFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 4, vDataInicio, vDataFim, 2);
                        vPercentualPenalidadeFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 6, vDataInicio, vDataFim, 2);
                        vPercentualMultaFGTS = percentual.RetornaPercentualEstatico(vCodContrato, 5, vDataInicio, vDataFim, 2);

                        /*Calculo da porção correspondente ao subperíodo.*/

                        vValorFerias = ((vRemuneracao * (vPercentualFerias / 100)) / 30) * vDiasSubperiodo;
                        vValorTercoConstitucional = ((vRemuneracao * (vPercentualTercoConstitucional / 100)) / 30) * vDiasSubperiodo;
                        vValorDecimoTerceiro = ((vRemuneracao * (vPercentualDecimoTerceiro / 100)) / 30) * vDiasSubperiodo;
                        vValorIncidenciaFerias = (vValorFerias * (vPercentualIncidencia / 100));
                        vValorIncidenciaTerco = (vValorTercoConstitucional * (vPercentualIncidencia / 100));
                        vValorIncidenciaDecimoTerceiro = (vValorDecimoTerceiro * (vPercentualIncidencia / 100));
                        vValorMultaFGTSFerias = ((vValorFerias * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSTerco = ((vValorTercoConstitucional * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSDecimoTerceiro = ((vValorDecimoTerceiro * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;
                        vValorMultaFGTSRemuneracao = ((vRemuneracao * ((vPercentualFGTS / 100) * (vPercentualMultaFGTS / 100) * (vPercentualPenalidadeFGTS / 100))) / 30) * vDiasSubperiodo;

                        /*No caso de mudança de função temos um recolhimento proporcional ao dias trabalhados no cargo,
                         situação similar para a retenção proporcional por menos de 14 dias trabalhados.*/

                        if (retencao.ExisteMudancaFuncao(pCodTerceirizadoContrato, vMes, vAno) || !retencao.FuncaoRetencaoIntegral(tupla.getCod(), vMes, vAno)) {

                            vValorFerias = (vValorFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorTercoConstitucional = (vValorTercoConstitucional / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorDecimoTerceiro = (vValorDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaFerias = (vValorIncidenciaFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaTerco = (vValorIncidenciaTerco / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorIncidenciaDecimoTerceiro = (vValorIncidenciaDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSFerias = (vValorMultaFGTSFerias / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSTerco = (vValorMultaFGTSTerco / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSDecimoTerceiro = (vValorMultaFGTSDecimoTerceiro / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);
                            vValorMultaFGTSRemuneracao = (vValorMultaFGTSRemuneracao / vDiasSubperiodo) * periodo.DiasTrabalhadosPeriodo(tupla.getCod(), vDataInicio, vDataFim);

                        }

                        /*Contabilização do valor calculado.*/

                        vTotalFerias = vTotalFerias + vValorFerias;
                        vTotalTercoConstitucional = vTotalTercoConstitucional + vValorTercoConstitucional;
                        vTotalDecimoTerceiro = vTotalDecimoTerceiro + vValorDecimoTerceiro;
                        vTotalIncidenciaFerias = vTotalIncidenciaFerias + vValorIncidenciaFerias;
                        vTotalIncidenciaTerco = vTotalIncidenciaTerco + vValorIncidenciaTerco;
                        vTotalIncidenciaDecimoTerceiro = vTotalIncidenciaDecimoTerceiro + vValorIncidenciaDecimoTerceiro;
                        vTotalMultaFGTSRemuneracao = vTotalMultaFGTSRemuneracao + vValorMultaFGTSRemuneracao;
                        vTotalMultaFGTSFerias = vTotalMultaFGTSFerias + vValorMultaFGTSFerias;
                        vTotalMultaFGTSTerco = vTotalMultaFGTSTerco + vValorMultaFGTSTerco;
                        vTotalMultaFGTSDecimoTerceiro = vTotalMultaFGTSDecimoTerceiro + vValorMultaFGTSDecimoTerceiro;

                        vDataInicio = Date.valueOf(vDataFim.toLocalDate().plusDays(1));

                    }


                }

            }

            /*Contabilização do valor final (valor calculado menos restituições).*/

            if (vMes == 12 || (vMes == pDataDesligamento.toLocalDate().getMonthValue()) && vAno == pDataDesligamento.toLocalDate().getYear()) {

                vTotalFerias = (vTotalFerias - saldo.SaldoContaVinculada(pCodTerceirizadoContrato, vAno, 2, 1));
                vTotalTercoConstitucional = (vTotalTercoConstitucional - saldo.SaldoContaVinculada(pCodTerceirizadoContrato, vAno, 2, 2));
                vTotalDecimoTerceiro = vTotalDecimoTerceiro - saldo.SaldoContaVinculada(pCodTerceirizadoContrato, vAno, 3, 3);
                vTotalIncidenciaDecimoTerceiro = vTotalIncidenciaDecimoTerceiro - saldo.SaldoContaVinculada(pCodTerceirizadoContrato, vAno, 3, 103);
                vTotalIncidenciaFerias = (vTotalIncidenciaFerias - saldo.SaldoContaVinculada(pCodTerceirizadoContrato, vAno, 2, 101));
                vTotalIncidenciaTerco = (vTotalIncidenciaTerco - saldo.SaldoContaVinculada(pCodTerceirizadoContrato, vAno, 2, 102));

            }

            if (vMes != 12) {

                vMes = vMes + 1;
            } else {

                vMes = 1;
                vAno = vAno + 1;

            }

            vDataReferencia = Date.valueOf(vAno + "-" + vMes + "-" + "01");

        } while (vDataReferencia.before(pDataDesligamento) || vDataReferencia.equals(pDataDesligamento));

//        System.out.println(vTotalFerias);
        //       System.out.println(vTotalTercoConstitucional);
        //      System.out.println(vTotalIncidenciaFerias);
        //     System.out.println(vTotalIncidenciaTerco);

        return new ValorRestituicaoRescisaoModel(vTotalDecimoTerceiro,
                vTotalIncidenciaDecimoTerceiro,
                vTotalMultaFGTSDecimoTerceiro,
                vTotalFerias,
                vTotalTercoConstitucional,
                vTotalIncidenciaFerias,
                vTotalIncidenciaTerco,
                vTotalMultaFGTSFerias,
                vTotalMultaFGTSTerco,
                vTotalMultaFGTSRemuneracao);

    }

    /**
     * Método que registra o calculo do total da rescisão a ser restituído para um
     * determinado empregado.
     *
     * @param pCodTerceirizadoContrato;
     * @param pTipoRestituicao;
     * @param pTipoRescisao;
     * @param pDataDesligamento;
     * @param pValorDecimoTerceiro;
     * @param pValorIncidenciaDecimoTerceiro;
     * @param pValorFGTSDecimoTerceiro;
     * @param pValorFerias;
     * @param pValorTerco;
     * @param pValorIncidenciaFerias;
     * @param pValorIncidenciaTerco;
     * @param pValorFGTSFerias;
     * @param pValorFGTSTerco;
     * @param pValorFGTSSalario;
     * @param pLoginAtualizacao;
     */

     public Integer RegistrarRestituicaoRescisao (int pCodTerceirizadoContrato,
                                                  String pTipoRestituicao,
                                                  String pTipoRescisao,
                                                  Date pDataDesligamento,
                                                  float pValorDecimoTerceiro,
                                                  float pValorIncidenciaDecimoTerceiro,
                                                  float pValorFGTSDecimoTerceiro,
                                                  float pValorFerias,
                                                  float pValorTerco,
                                                  float pValorIncidenciaFerias,
                                                  float pValorIncidenciaTerco,
                                                  float pValorFGTSFerias,
                                                  float pValorFGTSTerco,
                                                  float pValorFGTSSalario,
                                                  String pLoginAtualizacao) {

         ConsultaTSQL consulta = new ConsultaTSQL(connection);
         InsertTSQL insert = new InsertTSQL(connection);

         /*Chaves Primárias*/

         int vCodTbRestituicaoRescisao;
         int vCodTipoRestituicao;
         int vCodTipoRescisao;

         /*Variáveis de controle do saldo reidual.*/

         float vIncidDecTer = 0;
         float vFGTSDecimoTerceiro = 0;
         float vIncidFerias = 0;
         float vIncidTerco = 0;
         float vFGTSFerias = 0;
         float vFGTSTerco = 0;
         float vFGTSRemuneracao = 0;

         /*Atribuição do cod do tipo de restituição.*/

         vCodTipoRestituicao = consulta.RetornaCodTipoRestituicao(pTipoRestituicao);

         /*Atribuição do cod do tipo de rescisão.*/

         vCodTipoRescisao = consulta.RetornaCodTipoRescisao(pTipoRescisao);

        /*Provisionamento da incidência para o saldo residual no caso de movimentação.*/

        if (pTipoRestituicao.equals("MOVIMENTAÇÃO")) {

            vIncidDecTer = pValorIncidenciaDecimoTerceiro;
            vIncidFerias = pValorIncidenciaFerias;
            vIncidTerco = pValorIncidenciaTerco;
            vFGTSDecimoTerceiro = pValorFGTSDecimoTerceiro;
            vFGTSFerias = pValorFGTSFerias;
            vFGTSTerco = pValorFGTSTerco;
            vFGTSRemuneracao = pValorFGTSSalario;

            pValorIncidenciaDecimoTerceiro = 0;
            pValorIncidenciaFerias = 0;
            pValorIncidenciaTerco = 0;
            pValorFGTSDecimoTerceiro = 0;
            pValorFGTSFerias = 0;
            pValorFGTSTerco = 0;
            pValorFGTSSalario = 0;

        }

        /*Gravação no banco*/

        vCodTbRestituicaoRescisao = insert.InsertRestituicaoRescisao(pCodTerceirizadoContrato,
                                                                     vCodTipoRestituicao,
                                                                     vCodTipoRescisao,
                                                                     pDataDesligamento,
                                                                     pValorDecimoTerceiro,
                                                                     pValorIncidenciaDecimoTerceiro,
                                                                     pValorFGTSDecimoTerceiro,
                                                                     pValorFerias,
                                                                     pValorTerco,
                                                                     pValorIncidenciaFerias,
                                                                     pValorIncidenciaTerco,
                                                                     pValorFGTSFerias,
                                                                     pValorFGTSTerco,
                                                                     pValorFGTSSalario,
                                                                     pLoginAtualizacao);

        if (pTipoRestituicao.equals("MOVIMENTAÇÃO")) {

            insert.InsertSaldoResidualRescisao(vCodTbRestituicaoRescisao,
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
                                               pLoginAtualizacao);

        }

        return vCodTbRestituicaoRescisao;

    }

}