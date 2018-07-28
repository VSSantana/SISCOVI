package br.jus.stj.siscovi.calculos;

import br.jus.stj.siscovi.dao.ConnectSQLServer;

import java.sql.Date;

public class TesteRestituicaoFerias {
    public static void main(String[] args){


        ConnectSQLServer connectSQLServer = new ConnectSQLServer();
        RestituicaoFerias restituicaoFerias = new RestituicaoFerias(connectSQLServer.dbConnect());
        restituicaoFerias.CalculaRestituicaoFerias(53,4,0, Date.valueOf("2017-09-01"),Date.valueOf("2017-09-30"),Date.valueOf("2016-08-05"),Date.valueOf("2017-08-04"),0,'N');
        //TotalMensalDAO totalMensalDAO  = new TotalMensalDAO(connectSQLServer.dbConnect());
        //totalMensalDAO.recuperaAnosDeCalculosAnteriores(1);
        //new TotalMensalController().getValoresCalculados(1,8);

    }
}
