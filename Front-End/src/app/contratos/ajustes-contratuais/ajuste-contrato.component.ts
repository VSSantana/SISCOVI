import {Component, EventEmitter} from '@angular/core';
import {ContratosService} from '../contratos.service';
import {Contrato} from '../contrato';
import {MaterializeAction} from 'angular2-materialize';

@Component({
    selector: 'app-ajuste-contrato-component',
    templateUrl: './ajuste-contrato.component.html',
    styleUrls: ['./ajuste-contrato.component.scss']
})
export class AjusteContratoComponent {
    contratos: Contrato[];
    modalActions = new EventEmitter<string | MaterializeAction>();
    render = false;
    constructor(/*private contratosService: ContratosService*/) {
        /* this.contratosService.getContratosDoUsuario().subscribe(res => {
            this.contratos = res;
        });*/
    }
    openModal() {
        this.render = true;
        this.modalActions.emit({action: 'modal', params: ['open']});
    }
    closeModal() {
        this.render = false;
        this.modalActions.emit({action: 'modal', params: ['close']});
    }
}
