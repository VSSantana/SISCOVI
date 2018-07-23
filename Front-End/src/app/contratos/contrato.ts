export class Contrato {
  public cnpj: string;
  public codigo: number;
  public dataInicio: Date;
  public nomeDaEmpresa: string;
  public numeroDoContrato: string;
  public anoDoContrato: number;
  public dataFim: Date;
  public objeto: string;
  public seAtivo: string;

  constructor(nomeDaEmpresa: string, cnpj: string, codigo: number, numeroDoContrato: string,
              anoDoContrato: number, dataInicio: Date, dataFim: Date, objeto: string, seAtivo: string) {
    this.nomeDaEmpresa = nomeDaEmpresa;
    this.cnpj = cnpj;
    this.codigo = codigo;
    this.numeroDoContrato = numeroDoContrato;
    this.anoDoContrato = anoDoContrato;
    this.dataInicio = dataInicio;
    this.dataFim = dataFim;
    this.objeto = objeto;
    this.seAtivo = seAtivo;
  }
}
