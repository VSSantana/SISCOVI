import {Component, EventEmitter} from '@angular/core';
import {ContratosService} from './contratos.service';
import {Contrato} from './contrato';
import {MaterializeAction} from 'angular2-materialize';

@Component({
  selector: 'app-contrato',
  templateUrl: './contratos.component.html',
  styleUrls: ['./contrato.component.scss']
})
export class ContratosComponent {
  contratos: Contrato[];
  modalActions = new EventEmitter<string | MaterializeAction>();
  private loadComponent = false;
  render = true;
  contServ: ContratosService;
  constructor(contServ: ContratosService) {
      this.contServ = contServ;
      contServ.getContratosDoUsuario().subscribe( res => {
        contServ.contratos = res;
        this.contratos = res;
      });
  }
  loadMyChildComponent() {
    this.loadComponent = true;
  }
  openModal() {
    this.render = true;
    this.modalActions.emit({action: 'modal', params: ['open']});
  }
  closeModal() {
    this.render = false;
    this.modalActions.emit({action: 'modal', params: ['close']});
  }
  cadastrarContrato() {}
}
