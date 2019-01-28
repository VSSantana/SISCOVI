package br.jus.stj.siscovi.test;

import java.sql.Date;
import br.jus.stj.siscovi.calculos.Ferias;
import br.jus.stj.siscovi.dao.ConnectSQLServer;

public class TestFerias {

    public static void main(String[] args) {

        ConnectSQLServer connectSQLServer = new ConnectSQLServer();

        Date data = null;
        Ferias ferias = new Ferias(connectSQLServer.dbConnect());
        int vCodTerceirizado = 1;

        data = ferias.RetornaDatasPeriodoFeriasRescisao(vCodTerceirizado, Date.valueOf("2019-01-28"), 1);

        System.out.print(data);
        System.out.print("\n");

        data = ferias.RetornaDatasPeriodoFeriasRescisao(vCodTerceirizado, Date.valueOf("2019-01-28"), 2);

        System.out.print(data);
        System.out.print("\n");

        data = ferias.RetornaDatasPeriodoFeriasRescisao(vCodTerceirizado, Date.valueOf("2019-01-28"), 3);

        System.out.print(data);
        System.out.print("\n");

        data = ferias.RetornaDatasPeriodoFeriasRescisao(vCodTerceirizado, Date.valueOf("2019-01-28"), 4);

        System.out.print(data);
        System.out.print("\n");

    }

}
