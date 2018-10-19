package br.jus.stj.siscovi.test;

        import br.jus.stj.siscovi.dao.ConnectSQLServer;
        import br.jus.stj.siscovi.dao.sql.ConsultaTSQL;
        import br.jus.stj.siscovi.model.*;


public class TestConsultaTSQL {

    public static void main (String[] args) {

        ConnectSQLServer connectSQLServer = new ConnectSQLServer();
        ConsultaTSQL consulta = new ConsultaTSQL(connectSQLServer.dbConnect());

        int retorno;

        retorno = consulta.RetornaCodSequenceTable("TB_RUBRICA");

        System.out.print("RetornaCodSequenceTable: " + retorno + "\n\n");

        RegistroRubricaModel registroRubrica = consulta.RetornaRegistroRubrica(1);

        System.out.print("RetornaRegistroRubrica: \n");
        System.out.println(registroRubrica.getpCod());
        System.out.println(registroRubrica.getpNome());
        System.out.println(registroRubrica.getpSigla());
        System.out.println(registroRubrica.getpDescricao());
        System.out.println(registroRubrica.getpLoginAtualizacao());
        System.out.println(registroRubrica.getpDataAtualizacao());

        RegistroContratoModel registroContrato = consulta.RetornaRegistroContrato(1);

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

        RegistroConvencaoColetivaModel registroConvencaoColetiva = consulta.RetornaRegistroConvencaoColetiva(1);

        System.out.print("\nRetornaRegistroConvencaoColetiva: \n");
        System.out.println(registroConvencaoColetiva.getpCod());
        System.out.println(registroConvencaoColetiva.getpSigla());
        System.out.println(registroConvencaoColetiva.getpDataBase());
        System.out.println(registroConvencaoColetiva.getpDescricao());
        System.out.println(registroConvencaoColetiva.getpLoginAtualizacao());
        System.out.println(registroConvencaoColetiva.getpDataAtualizacao());

        RegistroEventoContratualModel registroEventoContratual = consulta.RetornaRegistroEventoContratual(1);

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

        RegistroFuncaoModel registroFuncao = consulta.RetornaRegistroFuncao(1);

        System.out.print("\nRetornaRegistroFuncao: \n");
        System.out.println(registroFuncao.getpCod());
        System.out.println(registroFuncao.getpNome());
        System.out.println(registroFuncao.getpDescricao());
        System.out.println(registroFuncao.getpLoginAtualizacao());
        System.out.println(registroFuncao.getpDataAtualizacao());

        RegistroFuncaoContratoModel registroFuncaoContrato = consulta.RetornaRegistroFuncaoContrato(1);

        System.out.print("\nRetornaRegistroFuncaoContrato: \n");
        System.out.println(registroFuncaoContrato.getpCod());
        System.out.println(registroFuncaoContrato.getpCodContrato());
        System.out.println(registroFuncaoContrato.getpCodFuncao());
        System.out.println(registroFuncaoContrato.getpDescricao());
        System.out.println(registroFuncaoContrato.getpLoginAtualizacao());
        System.out.println(registroFuncaoContrato.getpDataAtualizacao());

        RegistroHistoricoGestaoContrato registroHistoricoGestaoContrato = consulta.RetornaRegistroHistoricoGestaoContrato(1);

        System.out.print("\nRetornaRegistroHistoricoGestaoContrato: \n");
        System.out.println(registroHistoricoGestaoContrato.getpCod());
        System.out.println(registroHistoricoGestaoContrato.getpCodContrato());
        System.out.println(registroHistoricoGestaoContrato.getpCodUsuario());
        System.out.println(registroHistoricoGestaoContrato.getpCodPerfilGestao());
        System.out.println(registroHistoricoGestaoContrato.getpDataInicio());
        System.out.println(registroHistoricoGestaoContrato.getpDataFim());
        System.out.println(registroHistoricoGestaoContrato.getpLoginAtualizacao());
        System.out.println(registroHistoricoGestaoContrato.getpDataAtualizacao());

        RegistroFuncaoTerceirizadoModel registroFuncaoTerceirizado = consulta.RetornaRegistroFuncaoTerceirizado(1);

        System.out.print("\nRetornaRegistroFuncaoTerceirizado: \n");
        System.out.println(registroFuncaoTerceirizado.getpCod());
        System.out.println(registroFuncaoTerceirizado.getpCodTerceirizadoContrato());
        System.out.println(registroFuncaoTerceirizado.getpCodFuncaoContrato());
        System.out.println(registroFuncaoTerceirizado.getpDataInicio());
        System.out.println(registroFuncaoTerceirizado.getpDataFim());
        System.out.println(registroFuncaoTerceirizado.getpLoginAtualizacao());
        System.out.println(registroFuncaoTerceirizado.getpDataAtualizacao());

        RegistroPercentualContrato registroPercentualContrato = consulta.RetornaRegistroPercentualContrato(1);

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

        RegistroPercentualEstatico registroPercentualEstatico = consulta.RetornaRegistroPercentualEstatico(1);

        System.out.print("\nRetornaRegistroPercentualEstatico: \n");
        System.out.println(registroPercentualEstatico.getpCod());
        System.out.println(registroPercentualEstatico.getpCodRubrica());
        System.out.println(registroPercentualEstatico.getpPercentual());
        System.out.println(registroPercentualEstatico.getpDataInicio());
        System.out.println(registroPercentualEstatico.getpDataFim());
        System.out.println(registroPercentualEstatico.getpDataAditamento());
        System.out.println(registroPercentualEstatico.getpLoginAtualizacao());
        System.out.println(registroPercentualEstatico.getpDataAtualizacao());

        RegistroPerfilGestao registroPerfilGestao = consulta.RetornaRegistroPerfilGestao(1);

        System.out.print("\nRetornaRegistroPerfilGestao: \n");
        System.out.println(registroPerfilGestao.getpCod());
        System.out.println(registroPerfilGestao.getpNome());
        System.out.println(registroPerfilGestao.getpSigla());
        System.out.println(registroPerfilGestao.getpDescricao());
        System.out.println(registroPerfilGestao.getpLoginAtualizacao());
        System.out.println(registroPerfilGestao.getpDataAtualizacao());

        RegistroPerfilUsuario registroPerfilUsuario = consulta.RetornaRegistroPerfilUsuario(1);

        System.out.print("\nRetornaRegistroPerfilUsuario: \n");
        System.out.println(registroPerfilUsuario.getpCod());
        System.out.println(registroPerfilUsuario.getpNome());
        System.out.println(registroPerfilUsuario.getpSigla());
        System.out.println(registroPerfilUsuario.getpDescricao());
        System.out.println(registroPerfilUsuario.getpLoginAtualizacao());
        System.out.println(registroPerfilUsuario.getpDataAtualizacao());

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
/*
        RegistroRetroPercentualEstatico registroRetroPercentualEstatico = consulta.RetornaRegistroRetroPercentualEstatico(null);

        System.out.print("\nRetornaRegistroRetroPercentualEstatico: \n");
        System.out.println(registroRetroPercentualEstatico.getpCod());
        System.out.println(registroRetroPercentualEstatico.getpCodContrato());
        System.out.println(registroRetroPercentualEstatico.getpCodPercentualEstatico());
        System.out.println(registroRetroPercentualEstatico.getpDataInicio());
        System.out.println(registroRetroPercentualEstatico.getpDataFim());
        System.out.println(registroRetroPercentualEstatico.getpDataCobranca());
        System.out.println(registroRetroPercentualEstatico.getpLoginAtualizacao());
        System.out.println(registroRetroPercentualEstatico.getpDataAtualizacao());
*/




    }

}
