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

        //Define o vvalor das variáveis vMes e Vano de acordo com a adata de inínio do período aquisitivo.

        vMes = pInicioPeriodoAquisitivo.toLocalDate().getMonthValue();
        vAno = pInicioPeriodoAquisitivo.toLocalDate().getYear();

        System.out.println(vMes);

    }

}