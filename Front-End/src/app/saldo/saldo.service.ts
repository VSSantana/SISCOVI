import {EventEmitter, Injectable, Output} from '@angular/core';
import {Http} from '@angular/http';
import {ConfigService} from '../_shared/config.service';
import {Observable} from 'rxjs/Observable';
import {TerceirizadoDecimoTerceiro} from './terceirizado-decimo-terceiro';
import {DecimoTerceiroPendente} from './decimo-terceiro-pendente/decimo-terceiro-pendente';

@Injectable()
export class SaldoService {
  constructor(private http: Http, private config: ConfigService) {}
  getFuncionariosDecimoTerceiro(codigoContrato: number, tipoRestituicao: string) {
    const url = this.config.myApi + '/decimo-terceiro/getTerceirizadosDecimoTerceiro=' + codigoContrato + '/' + tipoRestituicao;
    return this.http.get(url).map(res => res.json());
  }

  calculaDecimoTerceiroTerceirizados(tercerizadosDecimoTerceiro: TerceirizadoDecimoTerceiro[]) {
    const url = this.config.myApi + '/decimo-terceiro/calcularDecimoTerceiroTerceirizados';
    const data = tercerizadosDecimoTerceiro;
    const headers = new Headers({'Content-type': 'application/json'});
    return this.http.post(url, data, headers).map(res => res.json());
  }
  protected encapsulaDatas(value: any): Date {
    const a = value.split('/');
    const dia = Number(a[0]);
    const mes = Number(a[1]) - 1;
    const ano = Number(a[2]);
    return new Date(ano, mes, dia);
  }
  registrarCalculoDecimoTerceiro(calculosDecimoTerceiro: TerceirizadoDecimoTerceiro[]) {
    const url = this.config.myApi + '/decimo-terceiro/registrarCalculoDecimoTerceiro';
    calculosDecimoTerceiro.forEach(item => {
      item.id = this.config.user.username;
    });
    const data = calculosDecimoTerceiro;
    const headers = new Headers({'Content-type': 'application/json'});
    return this.http.post(url, data, headers).map(res => res.json());
  }

  getCalculosPendentes(codigoContrato: number) {
    const url = this.config.myApi + '/decimo-terceiro/getCalculosPendentes/' + codigoContrato + '/' + this.config.user.id;
    return this.http.get(url).map(res => res.json());
  }

  getCalculosPendentesNegados(codigoContrato: number) {
    const url = this.config.myApi + '/decimo-terceiro/getCalculosPendentesNegados/' + codigoContrato + '/' + this.config.user.id;
    return this.http.get(url).map(res => res.json());
  }

  salvarDecimoTerceiroAvaliados(codigoContrato: number, calculosAvaliados: DecimoTerceiroPendente[]) {
    const url = this.config.myApi + '/decimo-terceiro/avaliarCalculosPendentes';
    const object = {
      decimosTerceirosPendentes: calculosAvaliados,
      user: this.config.user,
      codigoContrato: codigoContrato

    };
    return this.http.put(url, object).map(res => res.json());
  }

  executarDecimoTerceiroAvaliados(codigoContrato: number, calculosAvaliados: DecimoTerceiroPendente[]) {
    const url = this.config.myApi + '/decimo-terceiro/executarCalculos';
    const object = {
      decimosTerceirosPendentes: calculosAvaliados,
      user: this.config.user,
      codigoContrato: codigoContrato

    };
    return this.http.put(url, object).map(res => res.json());
  }

  getCalculosPendentesExecucao(codigoContrato: number) {
    const url = this.config.myApi + '/decimo-terceiro/getCalculosPendentesExecucao/' + codigoContrato + '/' + this.config.user.id;
    return this.http.get(url).map(res => res.json());
  }

  getCalculosNaoPendentesNegados(codigoContrato: number) {
    const url = this.config.myApi + '/decimo-terceiro/getCalculosNaoPendentesNegados/' + codigoContrato + '/' + this.config.user.id;
    return this.http.get(url).map(res => res.json());
  }

  getRestituicoesDecimoTerceiro(codigoContrato: number) {
    const url = this.config.myApi + '/decimo-terceiro/getRestituicoes/' + codigoContrato + '/' + this.config.user.id;
    return this.http.get(url).map(res => res.json());
  }
}
