import {Injectable} from '@angular/core';
import {Http, Headers, RequestOptions} from '@angular/http';
import {ConfigService} from '../_shared/config.service';
import {Usuario} from './usuario';
import {CadastroUsuario} from './cadastro-usuario/cadastro-usuario';
import {Observable} from 'rxjs/Observable';
import {Rubrica} from "../rubricas/rubrica";
import {CadastroRubrica} from "../rubricas/cadastrar-rubrica/cadastro-rubrica";

@Injectable()
export class UsuarioService {
  private headers: Headers;
  http: Http;
  config: ConfigService;
  cadastroUsuario: CadastroUsuario;
  nome: string;
  login: string;
  perfil: string;
  password: string;
  validity = true;
  constructor(http: Http, config: ConfigService) {
      this.http = http;
      this.config = config;
      this.cadastroUsuario = new CadastroUsuario();
  }
  getValidity() {
      return this.validity;
  }
  setValidity(value: boolean) {
      this.validity = value;
  }
  getUsuarios() {
    const url = this.config.myApi + '/usuario/getUsuarios';
    if (this.config.user.perfil.sigla === 'ADMINISTRADOR') {
      return this.http.get(url, {headers: this.headers}).map(res => res.json());
    }else {
      return null;
    }
  }
  buscarUsuario(codigo: number): Observable<Usuario> {
    const url = this.config.myApi + '/usuario/getUsuario/' + codigo;
    return this.http.get(url).map(res => res.json());
  }
  cadastrarUsuario() {
      this.cadastroUsuario.usuario = new Usuario();
      this.cadastroUsuario.usuario.login = this.login;
      this.cadastroUsuario.usuario.nome = this.nome;
      this.cadastroUsuario.usuario.perfil = this.perfil;
      this.cadastroUsuario.password = this.password;
      this.cadastroUsuario.currentUser = this.config.user.username;
      const headers = new Headers({'Content-type': 'application/json'});
      const options = new RequestOptions({headers: headers});
      const url = this.config.myApi + '/usuario/cadastrarUsuario';
      return this.http.post(url, this.cadastroUsuario, options).map(res => res.json());
  }
  salvarAlteracao(usuario: Usuario) {
    const url = this.config.myApi + '/usuario/alterarUsuario';
    const cadastroUsuario = new CadastroUsuario();
    cadastroUsuario.usuario = new Usuario();
    cadastroUsuario.usuario = usuario;
    cadastroUsuario.currentUser = this.config.user.username;
    const data = cadastroUsuario;
    return this.http.put(url, data).map(res => res.json());
  }
  apagarUsuario(codigo: number) {
      const url = this.config.myApi + '/usuario/deleteUsuario/' + codigo;
      return this.http.delete(url).map(res => res.json());
  }
}
