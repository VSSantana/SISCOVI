import {Component, EventEmitter, Output, ViewChild} from '@angular/core';
import {MaterializeAction} from 'angular2-materialize';
import {TotalMensalRetComponent} from './total-mensal-ret/total-mensal-ret.component';

@Component({
    selector: 'app-total-mensal',
    templateUrl: './total-mensal.component.html',
    styleUrls: ['./total-mensal.component.scss']
})
export class TotalMensalComponent {
    view = true;
    actions1 = new EventEmitter<string|MaterializeAction>();
    contSel: number;
    constructor() {}

    toggleCalculo() {
        this.view = true;
        this.contSel = null;
    }
    toggleRet() {
        this.view = false;
    }
    onCalculated(codigoContrato: number) {
        this.contSel = codigoContrato;
        this.view = false;
        this.actions1.emit({action: 'collapsible', params: ['open', 1]});
        this.actions1.emit({action: 'collapsible', params: ['close', 0]});
    }

}
