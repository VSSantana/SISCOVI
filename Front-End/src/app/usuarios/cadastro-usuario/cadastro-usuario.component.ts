import {Component, EventEmitter} from '@angular/core';
import {FormBuilder, FormControl, FormGroup, Validators} from '@angular/forms';
import {ActivatedRoute, Router} from '@angular/router';
import {MaterializeAction} from 'angular2-materialize';
import {ConfigService} from '../../_shared/config.service';
import {Usuario} from '../usuario';
import {UsuarioService} from '../usuario.service';
import {Http} from '@angular/http';

@Component({
    selector: 'app-cadastro-usuario',
    templateUrl: './cadastro-usuario.component.html',
    styleUrls: ['./cadastro-usuario.component.scss']
})
export class CadastroUsuarioComponent {
  modalActions = new EventEmitter<string|MaterializeAction>();
  usuario: Usuario;
  usuarioForm: FormGroup;
  usuarioService: UsuarioService;
  nome = '';
  login = '';
  perfil = '';
  id: number;
  route: ActivatedRoute;
  router: Router;
  notValidEdit= true;
  constructor(fb: FormBuilder, usuarioService: UsuarioService, route: ActivatedRoute, router: Router, config: ConfigService, http: Http,) {
    this.route = route;
    this.router = router;
    this.usuarioService = usuarioService;
    this.usuarioForm = fb.group({
      nome: new FormControl('', [Validators.required, Validators.minLength(4)]),
      login: new FormControl('', [ Validators.required, Validators.minLength(4)]),
      perfil: new FormControl('', [Validators.required, Validators.minLength(4)]),
      password: new FormControl('', [Validators.required, Validators.minLength(8), Validators.maxLength(64)]),
      confirmPassword: new FormControl('', [Validators.required, Validators.minLength(8), Validators.maxLength(64)])
    });
    const url = config.myApi + '/usuario/getPerfis/' + config.user.username;
    http.get(url).map(res => res.json()).subscribe(res => {
      this.perfil = res;
    });
    this.route.params.subscribe(params => {
      this.id = params['id'];
      if (this.id) {
        usuarioService.buscarUsuario(this.id).subscribe(res => {
          this.usuario = res;
          this.usuarioForm.controls.nome.setValue(this.usuario.nome);
          this.usuarioForm.controls.login.setValue(this.usuario.login);
          this.usuarioForm.controls.perfil.setValue(this.usuario.perfil);
        });
      }
    });
  }
  openModal() {
    this.modalActions.emit({action: 'modal', params: ['open']});
  }
  closeModal() {
    this.modalActions.emit({action: 'modal', params: ['close']});
  }
  validateForm() {
    if (this.usuarioForm.status === 'VALID') {
      this.usuarioService.nome = this.usuarioForm.controls.nome.value;
      this.usuarioService.login = this.usuarioForm.controls.login.value;
      this.usuarioService.perfil = this.usuarioForm.controls.perfil.value;
      this.usuarioService.password = this.usuarioForm.controls.password.value;
      this.usuarioService.setValidity(false);
    } else {
        this.usuarioService.setValidity(true);
      }
  }
  activateButton(): void {
    if (this.id) {
      if ((this.usuarioService.nome !== this.usuario.nome) ||
        (this.usuarioService.login !== this.usuario.login) ||
        (this.usuarioService.perfil !== this.usuario.perfil)) {
        this.notValidEdit = false;
      } else if ((this.usuarioService.nome === this.usuario.nome) ||
        (this.usuarioService.login === this.usuario.login) ||
        (this.usuarioService.perfil === this.usuario.perfil)) {
        this.notValidEdit = true;
      }
    }
  }
  disableButton() {
    this.notValidEdit = true;
  }
  salvarAlteracao() {
    this.usuario.codigo = this.id;
    this.usuario.nome = this.usuarioForm.controls.nome.value;
    this.usuario.login = this.usuarioForm.controls.login.value;
    this.usuario.perfil = this.usuarioForm.controls.perfil.value;
    this.usuarioService.salvarAlteracao(this.usuario).subscribe(res => {
      if (res === 'Alteração feita com sucesso!') {
        this.closeModal();
        this.router.navigate(['/rubricas']);
      }
    });
  }
  deletarUsuario() {
    this.usuarioService.apagarUsuario(this.id).subscribe(res => {
      if (res === 'Usuário excluído com sucesso!') {
        this.closeModal();
        this.router.navigate(['/usuarios']);
      }
    });
  }
}
