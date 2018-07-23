import {Injectable} from '@angular/core';
import {ConfigService} from '../_shared/config.service';
import {Http, Headers} from '@angular/http';
import {Contrato} from './contrato';
import {FormularioCadastroContrato} from './cadastro-contrato/formulario.cadastro.contrato';

@Injectable()
export class ContratosService {
  private headers: Headers;
  contratos: Contrato[] = [];
  formValido = false;
  formCadContr: FormularioCadastroContrato;
  constructor(private config: ConfigService, private  http: Http) {}

  getContratosDoUsuario() {
    const url = this.config.myApi + '/contrato/getContrato/usuario=' + this.config.user.username;
    return this.http.get(url).map(res => res.json());
  }
  getNomeDoGestor(codigo: number) {
      const url = this.config.myApi + '/contrato/getGestorContrato=' + codigo;
      return this.http.get(url).map(res => res.json());
  }
  cadastrarContrato() {

  }
}
