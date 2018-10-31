import {Component, EventEmitter} from '@angular/core';
import {Router} from '@angular/router';
import {MaterializeAction} from 'angular2-materialize';
import {Usuario} from './usuario';
import {UsuarioService} from './usuario.service';

@Component({
  selector: 'app-usuario',
  templateUrl: 'usuarios.component.html',
  styleUrls: ['usuarios.component.scss']
})
export class UsuariosComponent {
  modalActions = new EventEmitter<string|MaterializeAction>();
  usuarios: Usuario[];
  usuarioService: UsuarioService;
  render = false;
  router: Router;
  constructor(usuarioService: UsuarioService, router: Router) {
    this.router = router;
    this.usuarioService = usuarioService;
    usuarioService.getUsuarios().subscribe(res => {
      this.usuarios = res;
    });
  }
  openModal() {
    this.render = true;
    this.modalActions.emit({action: 'modal', params: ['open']});
  }
  closeModal() {
    this.render = false;
    this.usuarioService.setValidity(true);
    this.modalActions.emit({action: 'modal', params: ['close']});
  }
  cadastraUsuario() {
    this.usuarioService.cadastrarUsuario().subscribe(res => {
      console.log(res);
      if (res.mensagem === 'Usuário cadastrado com sucesso!') {
        // const newUsuarios = this.usuarios.slice(0);
        // newUsuarios.push(this.usuarioService.cadastroUsuario.usuario);
        // this.usuarios = newUsuarios;
        this.usuarioService.getUsuarios().subscribe(array => {
          this.usuarios.slice(0);
          this.usuarios = array;
          this.closeModal();
        });
        // this.closeModal();
      }
    });
  }
  editarUsuario(id: number): void {
    this.router.navigate(['/usuarios', id]);
  }
}
