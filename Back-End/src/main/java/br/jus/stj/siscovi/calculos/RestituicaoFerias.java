package br.jus.stj.siscovi.calculos;

import br.jus.stj.siscovi.model.CodFuncaoContratoECodFuncaoTerceirizadoModel;
import br.jus.stj.siscovi.model.CodTerceirizadoECodFuncaoTerceirizadoModel;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;

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
     * @param pCodTipoRestituicao;
     * @param pDiasVendidos;
     * @param pInicioFerias;
     * @param pFimFerias;
     * @param pInicioPeriodoAquisitivo;
     * @param pFimPeriodoAquisitivo;
     * @param pValorMovimentado;
     * @param pProporcional;
     */
    public void CalculaRestituicaoFerias(int pCodTerceirizadoContrato, int pCodTipoRestituicao, int pDiasVendidos, Date pInicioFerias, Date pFimFerias, Date pInicioPeriodoAquisitivo, Date pFimPeriodoAquisitivo,
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
        int vAno = 0;
        int vMes = 0;

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
/*
        if (pCodTerceirizadoContrato == null ||
            pCodTipoRestituicao == null ||
            pDiasVendidos == null ||
            pInicioFerias == null ||
            pFimFerias == null ||
            pInicioPeriodoAquisitivo == null ||
            pFimPeriodoAquisitivo == null) {

            return;

        }


*/

        //Checagem da existência do terceirizado no contrato.

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

            return;

        }

        //Carrega o código do contrato.
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

        //Define o valor das variáveis vMes e Vano de acordo com a adata de inínio do período aquisitivo.

        vMes = pInicioPeriodoAquisitivo.toLocalDate().getMonthValue();
        vAno = pInicioPeriodoAquisitivo.toLocalDate().getYear();

        //System.out.print(Date.valueOf(LocalDate.now()));

        //Início da contabilização de férias do período.

        do{

            //Definição da data referência (sempre o primeiro dia do mês).

            vDataReferencia = Date.valueOf(vAno + "-" + vMes + "-" + "01");

            //Reset das variáveis que contém valores parciais.

            vValorFerias = 0;
            vValorTercoConstitucional = 0;
            vValorIncidenciaFerias = 0;
            vValorIncidenciaTerco = 0;

            System.out.print(vDataReferencia + "\n");

            //Seleciona as funções que o terceirizado ocupou no mês avaliado.

            ArrayList<CodFuncaoContratoECodFuncaoTerceirizadoModel> tuplas = selecionaFuncaoContratoEFuncaoTerceirizado(pCodTerceirizadoContrato, vDataReferencia);

            Convencao convencao = new Convencao(connection);

            //Para cada função que o terceirizado ocupou no mês avaliado.

            for(int i = 0; i < tuplas.size(); i++){



            }


            if (vMes != 12) {

                vMes = vMes + 1;
            }

            else {

                vMes = 1;
                vAno = vAno + 1;

            }

        } while (vMes != pFimPeriodoAquisitivo.toLocalDate().getMonthValue() && vAno != pFimPeriodoAquisitivo.toLocalDate().getYear());


    }

    //Seleção do código da função terceirizado e da função contrato.

    ArrayList<CodFuncaoContratoECodFuncaoTerceirizadoModel> selecionaFuncaoContratoEFuncaoTerceirizado(int pCodTerceirizadoContrato, Date pDataReferencia) {

        //Busca as funções que um funcionário exerceu no mês de cálculo.

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

            try(ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    CodFuncaoContratoECodFuncaoTerceirizadoModel tupla = new CodFuncaoContratoECodFuncaoTerceirizadoModel(resultSet.getInt("COD_FUNCAO_CONTRATO"), resultSet.getInt("COD"));
                    tuplas.add(tupla);
                }
            }

        }catch(SQLException slqe) {
            //slqe.printStackTrace();
            throw new NullPointerException("Problemas durante a consulta ao banco em relação ao terceirizado: " + pCodTerceirizadoContrato);

        }

        return tuplas;
    }

}