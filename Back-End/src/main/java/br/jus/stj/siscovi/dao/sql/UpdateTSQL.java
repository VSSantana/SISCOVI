package br.jus.stj.siscovi.dao.sql;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class UpdateTSQL {

    private Connection connection;

    public UpdateTSQL(Connection connection) {

        this.connection = connection;

    }

    /**
     * Método que atualiza o um registro da tabela de restituição de férias.
     *
     * @param pCodRestituicaoFerias;
     * @param pTipoRestituicao;
     * @param pInicioPeriodoAquisitivo;
     * @param pFimPeriodoAquisitivo;
     * @param pInicioFerias;
     * @param pFimFerias;
     * @param pDiasVendidos;
     * @param pTotalFerias;
     * @param pTotalTercoConstitucional;
     * @param pTotalIncidenciaFerias;
     * @param pTotalIncidenciaTerco;
     * @param pParcela;
     * @param pDataReferencia;
     * @param pAutorizado;
     * @param pRestituido;
     * @param pObservacao;
     * @param pLoginAtualizacao;
     */

    public void UpdateRestituicaoFerias (int pCodRestituicaoFerias,
                                         String pTipoRestituicao,
                                         Date pInicioPeriodoAquisitivo,
                                         Date pFimPeriodoAquisitivo,
                                         Date pInicioFerias,
                                         Date pFimFerias,
                                         int pDiasVendidos,
                                         float pTotalFerias,
                                         float pTotalTercoConstitucional,
                                         float pTotalIncidenciaFerias,
                                         float pTotalIncidenciaTerco,
                                         int pParcela,
                                         Date pDataReferencia,
                                         char pAutorizado,
                                         char pRestituido,
                                         String pObservacao,
                                         String pLoginAtualizacao) {

        PreparedStatement preparedStatement;
        ConsultaTSQL consulta = new ConsultaTSQL(connection);
        int vCodTipoRestituicao = consulta.RetornaCodTipoRestituicao(pTipoRestituicao);

        String vSQLQuerry = "UPDATE tb_restituicao_ferias" +
                " SET COD_TIPO_RESTITUICAO = ?," +
                " DATA_INICIO_PERIODO_AQUISITIVO = ?," +
                " DATA_FIM_PERIODO_AQUISITIVO = ?," +
                " DATA_INICIO_USUFRUTO = ?," +
                " DATA_FIM_USUFRUTO = ?," +
                " DIAS_VENDIDOS = ?," +
                " VALOR_FERIAS = ?," +
                " VALOR_TERCO_CONSTITUCIONAL = ?," +
                " INCID_SUBMOD_4_1_FERIAS = ?," +
                " INCID_SUBMOD_4_1_TERCO = ?," +
                " PARCELA = ?," +
                " DATA_REFERENCIA = ?," +
                " AUTORIZADO = ?," +
                " RESTITUIDO = ?," +
                " OBSERVACAO = ?," +
                " LOGIN_ATUALIZACAO = ?," +
                " DATA_ATUALIZACAO = CURRENT_TIMESTAMP" +
                " WHERE cod = ?";

        try {

            preparedStatement = connection.prepareStatement(vSQLQuerry);
            preparedStatement.setInt(1, vCodTipoRestituicao);
            preparedStatement.setDate(2, pInicioPeriodoAquisitivo);
            preparedStatement.setDate(3, pFimPeriodoAquisitivo);
            preparedStatement.setDate(4, pInicioFerias);
            preparedStatement.setDate(5, pFimFerias);
            preparedStatement.setInt(6, pDiasVendidos);
            preparedStatement.setFloat(7, pTotalFerias);
            preparedStatement.setFloat(8, pTotalTercoConstitucional);
            preparedStatement.setFloat(9, pTotalIncidenciaFerias);
            preparedStatement.setFloat(10, pTotalIncidenciaTerco);
            preparedStatement.setInt(11, pParcela);
            preparedStatement.setDate(12, pDataReferencia);
            preparedStatement.setString(13,String.valueOf(pAutorizado));
            preparedStatement.setString(14, String.valueOf(pRestituido));
            preparedStatement.setString(15, pObservacao);
            preparedStatement.setString(16, pLoginAtualizacao);
            preparedStatement.setInt(17, pCodRestituicaoFerias);

            preparedStatement.executeUpdate();

        } catch (SQLException sqle) {

            throw new NullPointerException("Erro na execução da atualização dos dados da restiuição de férias.");

        }

    }





}
