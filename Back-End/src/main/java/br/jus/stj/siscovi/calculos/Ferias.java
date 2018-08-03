package br.jus.stj.siscovi.calculos;

import com.sun.scenario.effect.impl.prism.ps.PPSBlend_REDPeer;
import javax.validation.constraints.Null;
import java.sql.*;
import java.time.format.DateTimeFormatter;

public class Ferias {

    private Connection connection;

    Ferias(Connection connection) {

        this.connection = connection;

    }

    /**
     * Função que retorna o número de dias que um terceirizado possui em um determinado
     * período aquisitivo.
     * @param pCodContrato
     * @param pCodTerceirizadoContrato
     * @param pDataInicio
     * @param pDataFim
     * @return int
     */

    public int DiasPeriodoAquisitivo (int pCodContrato, int pCodTerceirizadoContrato, Date pDataInicio, Date pDataFim) {

        int vDiasAUsufruir = 0;
        int vCodTerceirizado = 0;
        int vMesesFerias = 0;

        return vDiasAUsufruir;

    }

}