import {Injectable} from '@angular/core';
import {Http, Headers, RequestOptions} from '@angular/http';
import {ConfigService} from '../_shared/config.service';
import {Contrato} from '../contratos/contrato';
import {Cargo} from './cargo';

@Injectable()
export class CargoService {
  http: Http;
  private _enabled = false;
  config: ConfigService;
  headers: Headers;
  loading = false;
  displayCargos = false;
  cargos: Cargo[];
  constructor(http: Http, config: ConfigService) {
    this.http = http;
    this.config = config;
    this.headers = new Headers(
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    );
  }
  getAllCargos() {
    const url = this.config.myApi + '/cargo/getAllCargos';
    return this.http.get(url, {headers: this.headers}).map(res => res.json());
  }
  getCargosDosContratos(contrato: Contrato[]) {
    const url = this.config.myApi + '/cargo/getCargosDosContratos';
    const data = contrato;
    return this.http.post(url, data).map(res => res.json());
  }
  getCargosFuncionarios (codigo: number) {
    const url = this.config.myApi + '/funcionarios/getFuncioECargos=' + codigo;
    return this.http.get(url).map(res => res.json());
  }
  get enabled (): boolean {
      return this._enabled;
  }
  set enabled (enabled: boolean) {
      this._enabled = enabled;
  }
  cadastrarCargos() {
      const headers = new Headers({'Content-type': 'application/json'});
      const options = new RequestOptions({headers: headers});
      const data = new ListaCargos();
      data.cargos = this.cargos;
      data.currentUser = this.config.user.username;
      const url = this.config.myApi + '/cargo/cadastrarCargos';
      return this.http.post(url, data, options).map(res => res.json());
  }
}
export class ListaCargos {
    currentUser: string;
    cargos: Cargo[];
}
