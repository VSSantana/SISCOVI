package br.jus.stj.siscovi.calculos;

import br.jus.stj.siscovi.controllers.TotalMensalController;
import br.jus.stj.siscovi.dao.ConnectSQLServer;
import br.jus.stj.siscovi.dao.ContratoDAO;
import br.jus.stj.siscovi.dao.TotalMensalDAO;
import br.jus.stj.siscovi.model.TotalMensal;

import java.sql.Date;
import java.text.SimpleDateFormat;

public class TesteRestituicaoFerias {
    public static void main(String[] args){


        ConnectSQLServer connectSQLServer = new ConnectSQLServer();
        RestituicaoFerias restituicaoFerias = new RestituicaoFerias(connectSQLServer.dbConnect());
        restituicaoFerias.CalculaRestituicaoFerias(417,22,0, Date.valueOf("2017-09-01"),Date.valueOf("2017-09-30"),Date.valueOf("2016-08-05"),Date.valueOf("2017-08-04"),0,'N');
        //TotalMensalDAO totalMensalDAO  = new TotalMensalDAO(connectSQLServer.dbConnect());
        //totalMensalDAO.recuperaAnosDeCalculosAnteriores(1);
        //new TotalMensalController().getValoresCalculados(1,8);

    }
}
