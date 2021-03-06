package br.jus.stj.siscovi.dao;

import br.jus.stj.siscovi.calculos.Saldo;
import br.jus.stj.siscovi.model.SaldoIndividualContaVinculadaModel;
import br.jus.stj.siscovi.model.SaldoResidualRestituidoDecimoTerceiro;
import br.jus.stj.siscovi.model.SaldoResidualRestituidoFerias;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class SaldoResidualFeriasDAO {

    private final Connection connection;

    public SaldoResidualFeriasDAO (Connection connection) {

        this.connection = connection;

    }

    public ArrayList<SaldoResidualRestituidoFerias> getSaldoResidualFeriasRestituido (int pCodContrato) {

        ArrayList<SaldoResidualRestituidoFerias> lista = new ArrayList<>();

        String sql = "SELECT t.nome, " +
                            "t.cpf, " +
                            "srf.valor_ferias, " +
                            "srf.valor_terco, " +
                            "srf.incid_submod_4_1_ferias, " +
                            "srf.incid_submod_4_1_terco, " +
                            "CASE WHEN srf.restituido = 'S' THEN 'SIM' ELSE 'NÃO' END " +
                        "FROM tb_restituicao_ferias rt " +
                            "JOIN tb_terceirizado_contrato tc ON tc.cod = rt.cod_terceirizado_contrato " +
                            "JOIN tb_funcao_terceirizado ft ON ft.cod_terceirizado_contrato = tc.cod " +
                            "JOIN tb_terceirizado t ON t.cod = tc.cod_terceirizado " +
                            "JOIN tb_contrato c ON c.cod = tc.cod_contrato " +
                            "JOIN tb_tipo_restituicao tr ON tr.cod = rt.cod_tipo_restituicao " +
                            "JOIN tb_funcao_contrato fc ON fc.cod = ft.cod_funcao_contrato " +
                            "JOIN tb_funcao f ON f.cod = fc.cod_funcao " +
                            "JOIN tb_saldo_residual_ferias srf ON srf.cod_restituicao_ferias = rt.cod " +
                        "WHERE c.cod = ? " +
                          "AND ft.data_inicio = (SELECT MAX(data_inicio) " +
                                                  "FROM tb_funcao_terceirizado " +
                                                  "WHERE cod_terceirizado_contrato = tc.cod)";

        try (PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setInt(1, pCodContrato);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                if (resultSet.next()) {

                    do {

                        SaldoResidualRestituidoFerias saldo =

                                new SaldoResidualRestituidoFerias(resultSet.getString(1),
                                        resultSet.getString(2),
                                        resultSet.getFloat(3),
                                        resultSet.getFloat(4),
                                        resultSet.getFloat(5),
                                        resultSet.getFloat(6),
                                        resultSet.getFloat(3) + resultSet.getFloat(4) + resultSet.getFloat(5) + resultSet.getFloat(6),
                                        resultSet.getString(7));

                        lista.add(saldo);

                    } while (resultSet.next());

                }

            }

        } catch (SQLException sqle) {

            sqle.printStackTrace();

            throw new NullPointerException("Falha na aquisição do saldo residual de férias da conta vinculada.");

        }

        return lista;

    }

}
