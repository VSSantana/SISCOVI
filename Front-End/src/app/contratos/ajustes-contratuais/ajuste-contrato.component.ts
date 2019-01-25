import {Component, EventEmitter} from '@angular/core';
import {ContratosService} from '../contratos.service';
import {Contrato} from '../contrato';
import {MaterializeAction} from 'angular2-materialize';
import {EventoContratual} from './evento-contratual';

@Component({
    selector: 'app-ajuste-contrato-component',
    templateUrl: './ajuste-contrato.component.html',
    styleUrls: ['./ajuste-contrato.component.scss']
})
export class AjusteContratoComponent {
    contratos: Contrato[];
    modalActions = new EventEmitter<string | MaterializeAction>();
    render = false;
    eventos: EventoContratual[] = [];
    valid = false;
    constructor(private contratosService: ContratosService) {
        this.contratosService.getContratosDoUsuario().subscribe(res => {
            this.contratos = res;
        });
    }
    onChange(value: number) {
        this.valid = true;
        this.contratosService.getEventosContratuais(value).subscribe(res => {
            this.eventos = res;
        });
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
