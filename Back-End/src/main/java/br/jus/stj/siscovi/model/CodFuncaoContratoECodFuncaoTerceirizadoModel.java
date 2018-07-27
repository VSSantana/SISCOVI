package br.jus.stj.siscovi.model;

public class CodFuncaoContratoECodFuncaoTerceirizadoModel {
    private int codFuncaoTerceirizado;
    private int cod;
    public CodFuncaoContratoECodFuncaoTerceirizadoModel(int cod, int codFuncaoTerceirizado) {
        this.cod = cod;
        this.codFuncaoTerceirizado = codFuncaoTerceirizado;
    }
    public int getCod() {
        return cod;
    }

    public int getCodFuncaoTerceirizado() {
        return codFuncaoTerceirizado;
    }
}
