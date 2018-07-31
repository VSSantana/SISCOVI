package br.jus.stj.siscovi.calculos;

import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Retencao {

    private Connection connection;

    Retencao(Connection connection){

        this.connection = connection;

    }

    /**
     * Função que retorna o tipo de restituição baseado no código passado.
     * @param pCodTipoResgate
     * @return String
     */

    public String TipoDeRestituicao(int pCodTipoResgate) throws SQLException {

        try {

            PreparedStatement preparedStatement = connection.prepareStatement("SELECT NOME" +
                                                                                   " FROM TB_TIPO_RESTITUICAO" +
                                                                                   " WHERE COD=?");

            ResultSet rs;
            preparedStatement.setInt(1, pCodTipoResgate);
            rs = preparedStatement.executeQuery();

            if (rs.next()) {

                return rs.getString("NOME");

            } else {

                return null;

            }

        } catch(SQLException sqle) {

            throw new NullPointerException("Erro ao tentar consultar o tipo de restituição.");

        }

    }

    /**
     * Função que retorna se um terceirizado trabalhou período igual ou superior a 15
     * dias em um determinado mês.
     * @param pCodFuncaoTerceirizado
     * @param pMes
     * @param pAno
     * @return boolean
     */

    public boolean FuncaoRetencaoIntegral(int pCodFuncaoTerceirizado, int pMes, int pAno) {

        PreparedStatement preparedStatement;
        ResultSet resultSet;

        /**Datas utilizadas na análise da integralidade da prestação de serviço do terceirizado.*/

        Date vDataInicio = null;
        Date vDataFim = null;

        /**Define como data referência o primeiro dia do mês e ano passados como argumentos.*/

        Date vDataReferencia = Date.valueOf(pAno + "-" + pMes + "-01");

        /**Variável que guarda o cod_terceirizado_contrato.*/

        int vCodTerceirizadoContrato = 0;

        /**Carrega o cod_terceirizado_contrato.*/

        try {

            preparedStatement = connection.prepareStatement("SELECT cod_terceirizado_contrato" +
                                                                 " FROM tb_funcao_terceirizado" +
                                                                 " WHERE cod = ?");

            preparedStatement.setInt(1, pCodFuncaoTerceirizado);
            resultSet = preparedStatement.executeQuery();

            if(resultSet.next()) {

                vCodTerceirizadoContrato = resultSet.getInt("cod_terceirizado_contrato");

            }

        } catch(SQLException sqle) {

            throw new NullPointerException("Erro ao carregar o 'cod_terceirizado_contrato' na 'FuncaoRetencaoIntegral'");

        }

        /**Carrega as datas de disponibilização e desligamento do terceirizado na função.*/

        if (!ExisteMudancaFuncao(vCodTerceirizadoContrato, pMes, pAno)) {

            try {

                preparedStatement = connection.prepareStatement("SELECT ft.data_inicio, " +
                                                                           "ft.data_fim" +
                                                                     " FROM tb_funcao_terceirizado ft" +
                                                                     " WHERE ft.cod_terceirizado_contrato = ?" +
                                                                       " AND ((((CONVERT(date, CONVERT(varchar, year(ft.data_inicio)) + '-' + CONVERT(varchar, month(ft.data_inicio)) + '-01')) <= ?)" +
                                                                            " AND" +
                                                                            " (ft.data_fim >= ?))" +
                                                                            " OR" +
                                                                            " (((CONVERT(date, CONVERT(varchar, year(ft.data_inicio)) + '-' + CONVERT(varchar, month(ft.data_inicio)) + '-01')) <= ?) " +
                                                                             "AND" +
                                                                            " (ft.data_fim IS NULL)))");

                preparedStatement.setInt(1, vCodTerceirizadoContrato);
                preparedStatement.setDate(2, vDataReferencia);
                preparedStatement.setDate(3, vDataReferencia);
                preparedStatement.setDate(4, vDataReferencia);
                resultSet = preparedStatement.executeQuery();

                if (resultSet.next()) {

                    vDataInicio = resultSet.getDate("DATA_INICIO");
                    vDataFim = resultSet.getDate("DATA_FIM");

                }

            } catch (SQLException sqle) {

                throw new NullPointerException("Erro ao carregar as datas de Inicio e Fim na 'FuncaoRetencaoIntegral'");

            }

        }

        else {

            try {

                preparedStatement = connection.prepareStatement("SELECT ft.data_inicio "  +
                                                                     " FROM tb_funcao_terceirizado ft" +
                                                                     " WHERE ft.cod_terceirizado_contrato = ?" +
                                                                       " AND ft.data_fim = (SELECT MIN(data_fim)" +
                                                                                            " FROM tb_funcao_terceirizado" +
                                                                                            " WHERE cod_terceirizado_contrato = ?" +
                                                                                            "   AND MONTH(data_inicio) = ?" +
                                                                                            "   AND YEAR(data_inicio) = ?");

                preparedStatement.setInt(1, vCodTerceirizadoContrato);
                preparedStatement.setInt(2, vCodTerceirizadoContrato);
                preparedStatement.setInt(3, pMes);
                preparedStatement.setInt(4, pAno);
                resultSet = preparedStatement.executeQuery();

                if (resultSet.next()) {

                    vDataInicio = resultSet.getDate("DATA_INICIO");

                }

            } catch (SQLException sqle) {

                throw new NullPointerException("Erro ao carregar as datas de Inicio e Fim na 'FuncaoRetencaoIntegral'");

            }

            try {

                preparedStatement = connection.prepareStatement("SELECT ft.data_fim "  +
                                                                     " FROM tb_funcao_terceirizado ft" +
                                                                     " WHERE ft.cod_terceirizado_contrato = ?" +
                                                                       " AND ft.data_inicio = (SELECT MAX(data_inicio)" +
                                                                                               " FROM tb_funcao_terceirizado" +
                                                                                               " WHERE cod_terceirizado_contrato = ?" +
                                                                                               "   AND MONTH(data_inicio) = ?" +
                                                                                               "   AND YEAR(data_inicio) = ?");

                preparedStatement.setInt(1, vCodTerceirizadoContrato);
                preparedStatement.setInt(2, vCodTerceirizadoContrato);
                preparedStatement.setInt(3, pMes);
                preparedStatement.setInt(4, pAno);
                resultSet = preparedStatement.executeQuery();

                if (resultSet.next()) {

                    vDataFim = resultSet.getDate("DATA_FIM");

                }

            } catch (SQLException sqle) {

                throw new NullPointerException("Erro ao carregar as datas de Inicio e Fim na 'FuncaoRetencaoIntegral'");

            }

        }

        /**Caso não possua data de desligamento.*/

        if (vDataFim == null) {

            //Se a data de disponibilização é inferior a data referência então o
            //terceirizado trabalhou os 30 dias do mês referência.*/

            if (vDataInicio.before(vDataReferencia)) {

                return true;

            }

            /**Se a data de disponibilização está no mês referência então se verifica
            a quantidade de dias trabalhados pelo terceirizado.*/

            LocalDate dataRef = vDataReferencia.toLocalDate().withDayOfMonth(vDataReferencia.toLocalDate().lengthOfMonth()); //Último dia do mês da data de referência.

            if ((vDataInicio.after(vDataReferencia) || vDataInicio.equals(vDataReferencia)) &&
                (vDataInicio.before(Date.valueOf(dataRef)) || vDataInicio.equals(Date.valueOf(dataRef)))) {

                if(ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), dataRef) + 1 >= 15) {

                    return true;

                }

            }

        }

        /**Caso possua data de desligamento.*/

        if (vDataFim != null) {

            LocalDate dataRef = vDataReferencia.toLocalDate().withDayOfMonth(vDataReferencia.toLocalDate().lengthOfMonth()); // Data com o último dia do mês da data de referência

            /**Se a data de disponibilização é inferior a data referência e a data de
            desligamento é superior ao último dia do mês referência então o
            terceirizado trabalhou os 30 dias.*/

            if (vDataInicio.before(vDataReferencia) && vDataFim.after(Date.valueOf(dataRef))) {

                return true;

            }

            /**Se a data de disponibilização está no mês referência e a data de
            desligamento é superior ao mês referência, então se verifica a quantidade
            de dias trabalhados pelo terceirizado.*/


            if ((vDataInicio.after(vDataReferencia) || vDataInicio.equals(vDataReferencia)) &&
                (vDataInicio.before(Date.valueOf(dataRef)) || vDataFim.equals(Date.valueOf(dataRef))) &&
                 vDataFim.after(Date.valueOf(dataRef))) {

                if (ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), dataRef) + 1 >= 15) {

                    return true;

                }

            }

            /**Se a data de disponibilização está no mês referência e também a data de
            desligamento, então contam-se os dias trabalhados pelo terceirizado.*/

            if ((vDataInicio.after(vDataReferencia) || vDataInicio.equals(vDataReferencia)) &&
                (vDataInicio.before(Date.valueOf(dataRef)) || vDataInicio.equals(Date.valueOf(dataRef)) &&
                (vDataFim.after(vDataReferencia) || vDataFim.equals(vDataReferencia)) &&
                (vDataFim.before(Date.valueOf(dataRef)) || vDataFim.equals(vDataReferencia)))) {

                if(ChronoUnit.DAYS.between(vDataInicio.toLocalDate(), vDataFim.toLocalDate()) + 1 >= 15) {

                    return true;

                }

            }

            /**Se a data da disponibilização for inferior ao mês de cálculo e
            o funcionário tiver desligamento no mês referência, então contam-se
            os dias trabalhados.*/

            if(vDataInicio.before(vDataReferencia) && (vDataFim.after(vDataReferencia) || vDataFim.equals(vDataReferencia)) &&
               (vDataFim.before(Date.valueOf(dataRef)) || vDataFim.equals(Date.valueOf(dataRef)))) {

                if(ChronoUnit.DAYS.between(vDataReferencia.toLocalDate(), vDataFim.toLocalDate()) + 1 >= 15) {

                    return true;

                }

            }

        }

        return false;

    }

    /**
     * Define se um terceirizado teve alterações em seu cargo em um determinado mês.
     * @param pCodTerceirizadoContrato
     * @param pMes
     * @param pAno
     * @return boolean
     */

    public boolean ExisteMudancaFuncao(int pCodTerceirizadoContrato, int pMes, int pAno) {

        /**Definição da data referência como primeiro dia do mês de acordo com os argumentos passados.*/

        Date vDataReferencia = Date.valueOf(pAno + "-" + pMes + "-01");

        int vNumeroRegistros = 0;
        boolean vRetorno = false;

        /**Contagem do número de cargos ocupados por um determinado terceirizado no mês referência.*/

        try (PreparedStatement preparedStatement = connection.prepareStatement("SELECT COUNT(COD)" +
                                                                                    " FROM TB_FUNCAO_TERCEIRIZADO" +
                                                                                    " WHERE COD_TERCEIRIZADO_CONTRATO = ? " +
                                                                                      " AND ((MONTH(DATA_INICIO)=? AND YEAR(DATA_INICIO)=? )" +
                                                                                            " OR" +
                                                                                           " (MONTH(DATA_FIM)=? AND YEAR(DATA_FIM)=?))")) {

            preparedStatement.setInt(1, pCodTerceirizadoContrato);
            preparedStatement.setInt(2, pMes);
            preparedStatement.setInt(3, pAno);
            preparedStatement.setInt(4, pMes);
            preparedStatement.setInt(5, pAno);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {

                if (resultSet.next()) {

                    vNumeroRegistros = resultSet.getInt(1);

                }

            }

        } catch (SQLException e) {

            throw new NullPointerException("Erro ao contar o número de cargos ocupados por um determinado terceirizado no mês referência.");

        }

        if (vNumeroRegistros != 0 && vNumeroRegistros > 1) {

            vRetorno = true;

        }

        else {

            vRetorno = false;

        }

        return vRetorno;

    }

}
