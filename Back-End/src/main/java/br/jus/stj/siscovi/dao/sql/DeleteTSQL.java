package br.jus.stj.siscovi.dao.sql;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class DeleteTSQL {

    private Connection connection;

    public DeleteTSQL(Connection connection) {

        this.connection = connection;

    }

    /**
     * Método que exclui um registro da tabela de restituição de férias.
     *
     * @param pCodRestituicaoFerias;
     */

    public void DeleteRestituicaoFerias (int pCodRestituicaoFerias) {

        PreparedStatement preparedStatement;

        String query = "DELETE FROM tb_restituicao_ferias WHERE cod = ?";

        try {

            preparedStatement = connection.prepareStatement(query);

            preparedStatement.setInt(1, pCodRestituicaoFerias);

            preparedStatement.executeUpdate();

        } catch (SQLException sqle) {

            throw new RuntimeException("Não foi possível deletar o registro solicitado da restituição de férias.");

        }

    }

    /**
     * Método que exclui um registro da tabela de saldo residual de férias.
     *
     * @param pCodRestituicaoFerias;
     */

    public void DeleteSaldoResidualFerias (int pCodRestituicaoFerias) {

        PreparedStatement preparedStatement;

        String query = "DELETE FROM tb_saldo_residual_ferias WHERE cod_restituicao_ferias = ?";

        try {

            preparedStatement = connection.prepareStatement(query);

            preparedStatement.setInt(1, pCodRestituicaoFerias);

            preparedStatement.executeUpdate();

        } catch (SQLException sqle) {

            throw new RuntimeException("Não foi possível deletar o registro solicitado do saldo residual de férias.");

        }

    }

}
