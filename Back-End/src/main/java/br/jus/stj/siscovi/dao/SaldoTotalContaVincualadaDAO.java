package br.jus.stj.siscovi.dao;

import br.jus.stj.siscovi.model.SaldoTotalContaVinculada;
import java.util.ArrayList;
import java.sql.Connection;

public class SaldoTotalContaVincualadaDAO {

    private final Connection connection;

    public SaldoTotalContaVincualadaDAO (Connection connection) {

        this.connection = connection;

    }

    public ArrayList<SaldoTotalContaVinculada> getSaldoContaVinculadaContrato (int codContrato, int codGestorContrato) {

        ArrayList<SaldoTotalContaVinculada> lista = new ArrayList<>();

        int vCodFuncaoContrato = 0;

        //String sql = "";

        return lista;

    }



}
