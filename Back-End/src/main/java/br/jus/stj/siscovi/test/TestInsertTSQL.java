package br.jus.stj.siscovi.test;

import br.jus.stj.siscovi.dao.ConnectSQLServer;
import br.jus.stj.siscovi.dao.sql.ConsultaTSQL;
import br.jus.stj.siscovi.dao.sql.DeleteTSQL;
import br.jus.stj.siscovi.dao.sql.InsertTSQL;
import br.jus.stj.siscovi.model.*;

import java.sql.Date;

public class TestInsertTSQL {

    public static void main (String[] args) {

        ConnectSQLServer connectSQLServer = new ConnectSQLServer();
        InsertTSQL insert = new InsertTSQL(connectSQLServer.dbConnect());
        ConsultaTSQL consulta = new ConsultaTSQL((connectSQLServer.dbConnect()));
        DeleteTSQL delete = new DeleteTSQL(connectSQLServer.dbConnect());

        int vCodRetorno;

        vCodRetorno = insert.InsertRubrica("Teste", "TESTE", "Nada.", "VSSOUSA");

        RegistroRubricaModel registroRubrica = consulta.RetornaRegistroRubrica(vCodRetorno);

        System.out.print("RetornaRegistroRubrica: \n");
        System.out.println(registroRubrica.getpCod());
        System.out.println(registroRubrica.getpNome());
        System.out.println(registroRubrica.getpSigla());
        System.out.println(registroRubrica.getpDescricao());
        System.out.println(registroRubrica.getpLoginAtualizacao());
        System.out.println(registroRubrica.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_RUBRICA");

        System.out.print("RetornaRegistroRubrica - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertContrato("LalaLand", "0321458741596", "030/2016", "0216579/2016", "S", "Lápis","VSSOUSA");

        RegistroContrato registroContrato = consulta.RetornaRegistroContrato(vCodRetorno);

        System.out.print("\nRetornaRegistroContrato: \n");
        System.out.println(registroContrato.getpCod());
        System.out.println(registroContrato.getpNomeEmpresa());
        System.out.println(registroContrato.getpCnpj());
        System.out.println(registroContrato.getpNumeroContrato());
        System.out.println(registroContrato.getpNumeroProcessoStj());
        System.out.println(registroContrato.getpSeAtivo());
        System.out.println(registroContrato.getpObjeto());
        System.out.println(registroContrato.getpLoginAtualizacao());
        System.out.println(registroContrato.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_CONTRATO");

        System.out.print("RetornaRegistroContrato - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertConvencaoColetiva("LalaLand", "Teste", Date.valueOf("2018-05-01"), "Description", "VSSOUSA");

        RegistroConvencaoColetiva registroConvencaoColetiva = consulta.RetornaRegistroConvencaoColetiva(vCodRetorno);

        System.out.print("\nRetornaRegistroConvencaoColetiva: \n");
        System.out.println(registroConvencaoColetiva.getpCod());
        System.out.println(registroConvencaoColetiva.getpSigla());
        System.out.println(registroConvencaoColetiva.getpDataBase());
        System.out.println(registroConvencaoColetiva.getpDescricao());
        System.out.println(registroConvencaoColetiva.getpLoginAtualizacao());
        System.out.println(registroConvencaoColetiva.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_CONVENCAO_COLETIVA");

        System.out.print("RetornaRegistroConvencaoColetiva - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertEventoContratual(1, 1, "S", "Assunto", Date.valueOf("2018-05-01"), Date.valueOf("2018-05-02"), Date.valueOf("2018-05-03"), "VSSOUSA");

        RegistroEventoContratual registroEventoContratual = consulta.RetornaRegistroEventoContratual(vCodRetorno);

        System.out.print("\nRetornaRegistroEventoContratual: \n");
        System.out.println(registroEventoContratual.getpCod());
        System.out.println(registroEventoContratual.getpCodContrato());
        System.out.println(registroEventoContratual.getpCodTipoEvento());
        System.out.println(registroEventoContratual.getpProrrogacao());
        System.out.println(registroEventoContratual.getpAssunto());
        System.out.println(registroEventoContratual.getpDataInicioVigencia());
        System.out.println(registroEventoContratual.getpDataFimVigencia());
        System.out.println(registroEventoContratual.getpDataAssinatura());
        System.out.println(registroEventoContratual.getpLoginAtualizacao());
        System.out.println(registroEventoContratual.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_EVENTO_CONTRATUAL");

        System.out.print("RetornaRegistroEventoContratual - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertFuncao("TESTE", "teste", "VSSOUSA");

        RegistroFuncao registroFuncao = consulta.RetornaRegistroFuncao(vCodRetorno);

        System.out.print("\nRetornaRegistroFuncao: \n");
        System.out.println(registroFuncao.getpCod());
        System.out.println(registroFuncao.getpNome());
        System.out.println(registroFuncao.getpDescricao());
        System.out.println(registroFuncao.getpLoginAtualizacao());
        System.out.println(registroFuncao.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_FUNCAO");

        System.out.print("RetornaRegistroFuncao - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertFuncaoContrato(1, 55, "TESTE","VSSOUSA");

        RegistroFuncaoContrato registroFuncaoContrato = consulta.RetornaRegistroFuncaoContrato(vCodRetorno);

        System.out.print("\nRetornaRegistroFuncaoContrato: \n");
        System.out.println(registroFuncaoContrato.getpCod());
        System.out.println(registroFuncaoContrato.getpCodContrato());
        System.out.println(registroFuncaoContrato.getpCodFuncao());
        System.out.println(registroFuncaoContrato.getpDescricao());
        System.out.println(registroFuncaoContrato.getpLoginAtualizacao());
        System.out.println(registroFuncaoContrato.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_FUNCAO_CONTRATO");

        System.out.print("RetornaRegistroFuncaoContrato - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertFuncaoTerceirizado(1, 4, Date.valueOf("2018-01-01"),null, "VSSOUSA");

        RegistroFuncaoTerceirizado registroFuncaoTerceirizado = consulta.RetornaRegistroFuncaoTerceirizado(vCodRetorno);

        System.out.print("\nRetornaRegistroFuncaoTerceirizado: \n");
        System.out.println(registroFuncaoTerceirizado.getpCod());
        System.out.println(registroFuncaoTerceirizado.getpCodTerceirizadoContrato());
        System.out.println(registroFuncaoTerceirizado.getpCodFuncaoContrato());
        System.out.println(registroFuncaoTerceirizado.getpDataInicio());
        System.out.println(registroFuncaoTerceirizado.getpDataFim());
        System.out.println(registroFuncaoTerceirizado.getpLoginAtualizacao());
        System.out.println(registroFuncaoTerceirizado.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_FUNCAO_TERCEIRIZADO");

        System.out.print("RetornaRegistroFuncaoTerceirizado - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertHistoricoGestaoContrato(1, 7, 3, Date.valueOf("2018-01-01"),null, "VSSOUSA");

        RegistroHistoricoGestaoContrato registroHistoricoGestaoContrato = consulta.RetornaRegistroHistoricoGestaoContrato(vCodRetorno);

        System.out.print("\nRetornaRegistroHistoricoGestaoContrato: \n");
        System.out.println(registroHistoricoGestaoContrato.getpCod());
        System.out.println(registroHistoricoGestaoContrato.getpCodContrato());
        System.out.println(registroHistoricoGestaoContrato.getpCodUsuario());
        System.out.println(registroHistoricoGestaoContrato.getpCodPerfilGestao());
        System.out.println(registroHistoricoGestaoContrato.getpDataInicio());
        System.out.println(registroHistoricoGestaoContrato.getpDataFim());
        System.out.println(registroHistoricoGestaoContrato.getpLoginAtualizacao());
        System.out.println(registroHistoricoGestaoContrato.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_HISTORICO_GESTAO_CONTRATO");

        System.out.print("RetornaRegistroHistoricoGestaoContrato - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertPercentualContrato(1, 1, 3, Date.valueOf("2018-01-01"),null, Date.valueOf("2018-01-01"),"VSSOUSA");

        RegistroPercentualContrato registroPercentualContrato = consulta.RetornaRegistroPercentualContrato(vCodRetorno);

        System.out.print("\nRetornaRegistroPercentualContrato: \n");
        System.out.println(registroPercentualContrato.getpCod());
        System.out.println(registroPercentualContrato.getpCodContrato());
        System.out.println(registroPercentualContrato.getpCodRubrica());
        System.out.println(registroPercentualContrato.getpPercentual());
        System.out.println(registroPercentualContrato.getpDataInicio());
        System.out.println(registroPercentualContrato.getpDataFim());
        System.out.println(registroPercentualContrato.getpDataAditamento());
        System.out.println(registroPercentualContrato.getpLoginAtualizacao());
        System.out.println(registroPercentualContrato.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_PERCENTUAL_CONTRATO");

        System.out.print("RetornaRegistroPercentualContrato - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertPercentualEstatico( 1, 3, Date.valueOf("2018-01-01"),null, Date.valueOf("2018-01-01"),"VSSOUSA");

        RegistroPercentualEstatico registroPercentualEstatico = consulta.RetornaRegistroPercentualEstatico(vCodRetorno);

        System.out.print("\nRetornaRegistroPercentualEstatico: \n");
        System.out.println(registroPercentualEstatico.getpCod());
        System.out.println(registroPercentualEstatico.getpCodRubrica());
        System.out.println(registroPercentualEstatico.getpPercentual());
        System.out.println(registroPercentualEstatico.getpDataInicio());
        System.out.println(registroPercentualEstatico.getpDataFim());
        System.out.println(registroPercentualEstatico.getpDataAditamento());
        System.out.println(registroPercentualEstatico.getpLoginAtualizacao());
        System.out.println(registroPercentualEstatico.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_PERCENTUAL_ESTATICO");

        System.out.print("RetornaRegistroPercentualEstatico - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertPerfilGestao( "NAME", "NICK", "DESCRIPTION","VSSOUSA");

        RegistroPerfilGestao registroPerfilGestao = consulta.RetornaRegistroPerfilGestao(vCodRetorno);

        System.out.print("\nRetornaRegistroPerfilGestao: \n");
        System.out.println(registroPerfilGestao.getpCod());
        System.out.println(registroPerfilGestao.getpNome());
        System.out.println(registroPerfilGestao.getpSigla());
        System.out.println(registroPerfilGestao.getpDescricao());
        System.out.println(registroPerfilGestao.getpLoginAtualizacao());
        System.out.println(registroPerfilGestao.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_PERFIL_GESTAO");

        System.out.print("RetornaRegistroPerfilGestao - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertPerfilUsuario( "NAME1", "NICK2", "DESCRIPTION3","VSSOUSA");

        RegistroPerfilUsuario registroPerfilUsuario = consulta.RetornaRegistroPerfilUsuario(vCodRetorno);

        System.out.print("\nRetornaRegistroPerfilUsuario: \n");
        System.out.println(registroPerfilUsuario.getpCod());
        System.out.println(registroPerfilUsuario.getpNome());
        System.out.println(registroPerfilUsuario.getpSigla());
        System.out.println(registroPerfilUsuario.getpDescricao());
        System.out.println(registroPerfilUsuario.getpLoginAtualizacao());
        System.out.println(registroPerfilUsuario.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_PERFIL_USUARIO");

        System.out.print("RetornaRegistroPerfilUsuario - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertRemuneracaoFunCon( 1, null, Date.valueOf("2018-01-01"), null, Date.valueOf("2018-01-01"), 1800, 500, 0, "VSSOUSA");

        RegistroRemuneracaoFunCon registroRemuneracaoFunCon = consulta.RetornaRegistroRemuneracaoFunCon(vCodRetorno);

        System.out.print("\nRetornaRegistroRemuneracaoFunCon: \n");
        System.out.println(registroRemuneracaoFunCon.getpCod());
        System.out.println(registroRemuneracaoFunCon.getpCodFuncaoContrato());
        System.out.println(registroRemuneracaoFunCon.getpCodConvencaoColetiva());
        System.out.println(registroRemuneracaoFunCon.getpDataInicio());
        System.out.println(registroRemuneracaoFunCon.getpDataFim());
        System.out.println(registroRemuneracaoFunCon.getpDataAditamento());
        System.out.println(registroRemuneracaoFunCon.getpRemuneracao());
        System.out.println(registroRemuneracaoFunCon.getpTrienios());
        System.out.println(registroRemuneracaoFunCon.getpAdicionais());
        System.out.println(registroRemuneracaoFunCon.getpLoginAtualizacao());
        System.out.println(registroRemuneracaoFunCon.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_REMUNERACAO_FUN_CON");

        System.out.print("RetornaRegistroRemuneracaoFunCon - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertRetroPercentualEstatico( 1, 1, Date.valueOf("2018-01-01"), Date.valueOf("2018-02-28"), Date.valueOf("2018-03-01"), "VSSOUSA");

        RegistroRetroPercentualEstatico registroRetroPercentualEstatico = consulta.RetornaRegistroRetroPercentualEstatico(vCodRetorno);

        System.out.print("\nRetornaRegistroRetroPercentualEstatico: \n");
        System.out.println(registroRetroPercentualEstatico.getpCod());
        System.out.println(registroRetroPercentualEstatico.getpCodContrato());
        System.out.println(registroRetroPercentualEstatico.getpCodPercentualEstatico());
        System.out.println(registroRetroPercentualEstatico.getpDataInicio());
        System.out.println(registroRetroPercentualEstatico.getpDataFim());
        System.out.println(registroRetroPercentualEstatico.getpDataCobranca());
        System.out.println(registroRetroPercentualEstatico.getpLoginAtualizacao());
        System.out.println(registroRetroPercentualEstatico.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_RETRO_PERCENTUAL_ESTATICO");

        System.out.print("RetornaRegistroRetroPercentualEstatico - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertRetroatividadePercentual( 2, Date.valueOf("2018-01-01"), Date.valueOf("2018-02-28"), Date.valueOf("2018-04-01"), "VSSOUSA");

        RegistroRetroatividadePercentual registroRetroatividadePercentual = consulta.RetornaRegistroRetroatividadePercentual(vCodRetorno);

        System.out.print("\nRetornaRegistroRetroatividadePercentual: \n");
        System.out.println(registroRetroatividadePercentual.getpCod());
        System.out.println(registroRetroatividadePercentual.getpCodPercentualContrato());
        System.out.println(registroRetroatividadePercentual.getpInicio());
        System.out.println(registroRetroatividadePercentual.getpFim());
        System.out.println(registroRetroatividadePercentual.getpDataCobranca());
        System.out.println(registroRetroatividadePercentual.getpLoginAtualizacao());
        System.out.println(registroRetroatividadePercentual.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_RETROATIVIDADE_PERCENTUAL");

        System.out.print("RetornaRegistroRetroatividadePercentual - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertRetroatividadeRemuneracao( 1, Date.valueOf("2018-01-01"), Date.valueOf("2018-02-28"), Date.valueOf("2018-05-01"), "VSSOUSA");

        RegistroRetroatividadeRemuneracao registroRetroatividadeRemuneracao = consulta.RetornaRegistroRetroatividadeRemuneracao(vCodRetorno);

        System.out.print("\nRetornaRegistroRetroatividadeRemuneracao: \n");
        System.out.println(registroRetroatividadeRemuneracao.getpCod());
        System.out.println(registroRetroatividadeRemuneracao.getpCodRemFuncaoContrato());
        System.out.println(registroRetroatividadeRemuneracao.getpInicio());
        System.out.println(registroRetroatividadeRemuneracao.getpFim());
        System.out.println(registroRetroatividadeRemuneracao.getpDataCobranca());
        System.out.println(registroRetroatividadeRemuneracao.getpLoginAtualizacao());
        System.out.println(registroRetroatividadeRemuneracao.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_RETROATIVIDADE_REMUNERACAO");

        System.out.print("RetornaRegistroRetroatividadeRemuneracao - Cod deleção: " + vCodRetorno + "\n");

        vCodRetorno = insert.InsertRetroatividadeTotalMensal( 1, 547, 258, 321, 456, 741, 789, "VSSOUSA");

        RegistroRetroatividadeTotalMensal registroRetroatividadeTotalMensal = consulta.RetornaRegistroRetroatividadeTotalMensal(vCodRetorno);

        System.out.print("\nRetornaRegistroRetroatividadeTotalMensal: \n");
        System.out.println(registroRetroatividadeTotalMensal.getpCod());
        System.out.println(registroRetroatividadeTotalMensal.getpCodTotalMensalAReter());
        System.out.println(registroRetroatividadeTotalMensal.getpFerias());
        System.out.println(registroRetroatividadeTotalMensal.getpTercoConstitucional());
        System.out.println(registroRetroatividadeTotalMensal.getpDecimoTerceiro());
        System.out.println(registroRetroatividadeTotalMensal.getpIncidenciaSubmodulo41());
        System.out.println(registroRetroatividadeTotalMensal.getpMultaFgts());
        System.out.println(registroRetroatividadeTotalMensal.getpTotal());
        System.out.println(registroRetroatividadeTotalMensal.getpLoginAtualizacao());
        System.out.println(registroRetroatividadeTotalMensal.getpDataAtualizacao());

        vCodRetorno = delete.DeleteRegistro(vCodRetorno, "TB_RETROATIVIDADE_TOTAL_MENSAL");

        System.out.print("RetornaRegistroRetroatividadeTotalMensal - Cod deleção: " + vCodRetorno + "\n");

           /*

        RegistroRemuneracaoFunCon registroRemuneracaoFunCon = consulta.RetornaRegistroRemuneracaoFunCon(1);

        System.out.print("\nRetornaRegistroRemuneracaoFunCon: \n");
        System.out.println(registroRemuneracaoFunCon.getpCod());
        System.out.println(registroRemuneracaoFunCon.getpCodFuncaoContrato());
        System.out.println(registroRemuneracaoFunCon.getpCodConvencaoColetiva());
        System.out.println(registroRemuneracaoFunCon.getpDataInicio());
        System.out.println(registroRemuneracaoFunCon.getpDataFim());
        System.out.println(registroRemuneracaoFunCon.getpDataAditamento());
        System.out.println(registroRemuneracaoFunCon.getpRemuneracao());
        System.out.println(registroRemuneracaoFunCon.getpTrienios());
        System.out.println(registroRemuneracaoFunCon.getpAdicionais());
        System.out.println(registroRemuneracaoFunCon.getpLoginAtualizacao());
        System.out.println(registroRemuneracaoFunCon.getpDataAtualizacao());

        RegistroTerceirizado registroTerceirizado = consulta.RetornaRegistroTerceirizado(1);

        System.out.print("\nRetornaRegistroTerceirizado: \n");
        System.out.println(registroTerceirizado.getpCod());
        System.out.println(registroTerceirizado.getpCpf());
        System.out.println(registroTerceirizado.getpAtivo());
        System.out.println(registroTerceirizado.getpLoginAtualizacao());
        System.out.println(registroTerceirizado.getpDataAtualizacao());

        RegistroTerceirizadoContrato registroTerceirizadoContrato = consulta.RetornaRegistroTerceirizadoContrato(1);

        System.out.print("\nRetornaRegistroTerceirizadoContrato: \n");
        System.out.println(registroTerceirizadoContrato.getpCod());
        System.out.println(registroTerceirizadoContrato.getpCodContrato());
        System.out.println(registroTerceirizadoContrato.getpCodTerceirizado());
        System.out.println(registroTerceirizadoContrato.getpDataDisponibilizacao());
        System.out.println(registroTerceirizadoContrato.getpDataDesligamento());
        System.out.println(registroTerceirizadoContrato.getpLoginAtualizacao());
        System.out.println(registroTerceirizadoContrato.getpDataAtualizacao());

        RegistroTipoEventoContratual registroTipoEventoContratual = consulta.RetornaRegistroTipoEventoContratual(1);

        System.out.print("\nRetornaRegistroTipoEventoContratual: \n");
        System.out.println(registroTipoEventoContratual.getpCod());
        System.out.println(registroTipoEventoContratual.getpTipo());
        System.out.println(registroTipoEventoContratual.getpLoginAtualizacao());
        System.out.println(registroTipoEventoContratual.getpDataAtualizacao());

        RegistroTipoRescisao registroTipoRescisao = consulta.RetornaRegistroTipoRescisao(1);

        System.out.print("\nRetornaRegistroTipoRescisao: \n");
        System.out.println(registroTipoRescisao.getpCod());
        System.out.println(registroTipoRescisao.getpTipoRescisao());
        System.out.println(registroTipoRescisao.getpLoginAtualizacao());
        System.out.println(registroTipoRescisao.getpDataAtualizacao());

        RegistroTipoRestituicao registroTipoRestituicao = consulta.RetornaRegistroTipoRestituicao(1);

        System.out.print("\nRetornaRegistroTipoRestituicao: \n");
        System.out.println(registroTipoRestituicao.getpCod());
        System.out.println(registroTipoRestituicao.getpNome());
        System.out.println(registroTipoRestituicao.getpLoginAtualizacao());
        System.out.println(registroTipoRestituicao.getpDataAtualizacao());

        RegistroTotalMensalAReter registroTotalMensalAReter = consulta.RetornaRegistroTotalMensalAReter(1);

        System.out.print("\nRetornaRegistroTotalMensalAReter: \n");
        System.out.println(registroTotalMensalAReter.getpCod());
        System.out.println(registroTotalMensalAReter.getpCodTerceirizadoContrato());
        System.out.println(registroTotalMensalAReter.getpCodFuncaoTerceirizado());
        System.out.println(registroTotalMensalAReter.getpFerias());
        System.out.println(registroTotalMensalAReter.getpTercoConstitucional());
        System.out.println(registroTotalMensalAReter.getpDecimoTerceiro());
        System.out.println(registroTotalMensalAReter.getpIncidenciaSubmodulo41());
        System.out.println(registroTotalMensalAReter.getpMultaFgts());
        System.out.println(registroTotalMensalAReter.getpTotal());
        System.out.println(registroTotalMensalAReter.getpDataReferencia());
        System.out.println(registroTotalMensalAReter.getpAutorizado());
        System.out.println(registroTotalMensalAReter.getpRetido());
        System.out.println(registroTotalMensalAReter.getpObservacao());
        System.out.println(registroTotalMensalAReter.getpLoginAtualizacao());
        System.out.println(registroTotalMensalAReter.getpDataAtualizacao());

        RegistroUsuario registroUsuario = consulta.RetornaRegistroUsuario(1);

        System.out.print("\nRetornaRegistroUsuario: \n");
        System.out.println(registroUsuario.getpCod());
        System.out.println(registroUsuario.getpNome());
        System.out.println(registroUsuario.getpLogin());
        System.out.println(registroUsuario.getpPassword());
        System.out.println(registroTotalMensalAReter.getpLoginAtualizacao());
        System.out.println(registroTotalMensalAReter.getpDataAtualizacao());
*/
    }



}