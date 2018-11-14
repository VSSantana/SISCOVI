package br.jus.stj.siscovi.controllers;


import br.jus.stj.siscovi.dao.ConnectSQLServer;
import br.jus.stj.siscovi.dao.SaldoTotalContaVincualadaDAO;
import br.jus.stj.siscovi.helpers.ErrorMessage;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.SQLException;

@Path("/saldo")
public class SaldoController {

    @GET
    @Path("/getSaldoTotal/{codigoContrato}/{codigoUsuario}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getSaldoTotal(@PathParam("codigoContrato") int codigoContrato, @PathParam("codigoUsuario") int codigoUsuario) {
        ConnectSQLServer connectSQLServer = new ConnectSQLServer();
        SaldoTotalContaVincualadaDAO saldoTotalContaVincualadaDAO = new SaldoTotalContaVincualadaDAO(connectSQLServer.dbConnect());
        String json;
        Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();
        try{
            json = gson.toJson(saldoTotalContaVincualadaDAO.getSaldoContaVinculadaContrato(codigoContrato, codigoUsuario));
            connectSQLServer.dbConnect().close();
        }catch (SQLException slqe) {
            ErrorMessage errorMessage = new ErrorMessage();
            errorMessage.error = "Houve um erro ao tentar recuperar o saldo da conta vinculada!";
            json = gson.toJson(errorMessage);
            return Response.ok(json, MediaType.APPLICATION_JSON).build();
        }catch (RuntimeException rte) {
            System.err.println(rte.toString());
            ErrorMessage errorMessage = new ErrorMessage();
            errorMessage.error = rte.getMessage();
            json = gson.toJson(errorMessage);
        }
        return Response.ok(json, MediaType.APPLICATION_JSON).build();
    }

}
