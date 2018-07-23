import {Injectable} from '@angular/core';
import {Http} from '@angular/http';
import {ConfigService} from '../_shared/config.service';
import {Contrato} from '../contratos/contrato';

@Injectable()
export class FuncionariosService {
  http: Http;
  config: ConfigService;
  constructor(http: Http, config: ConfigService) {
    this.http = http;
    this.config = config;
  }
  getFuncionarios(contratos: Contrato[]) {
    const url = this.config.myApi + '/funcionarios/getFuncionariosContratos';
    const data = contratos;
    return this.http.post(url, data).map(res => res.json());
  }

  getFuncionariosDeUmContrato(codigoContrato: number) {
    const url = this.config.myApi + '/funcionarios/getFuncionariosContrato=' + codigoContrato;
    return this.http.get(url).map(res => res.json());
  }
}
