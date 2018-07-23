import {Component} from '@angular/core';
import {HistoricoService} from './historico.service';
import {Contrato} from '../contratos/contrato';
import {ContratosService} from '../contratos/contratos.service';
import {HistoricoGestor} from './historico-gestor';

@Component({
    selector: 'app-historico-gestores-component',
    templateUrl: './historico-gestores.component.html',
    styleUrls: ['./historico-gestores.component.scss']
})
export class HistoricoGestoresComponent {
    contratos: Contrato[];
    historicoGestor: HistoricoGestor[];
    constructor(private histoService: HistoricoService, private contratoService: ContratosService) {
        this.contratoService.getContratosDoUsuario().subscribe(res => {
            this.contratos = res;
        });
    }
    selecionarContrato(value: number) {
        this.histoService.getHistoricoGestores(value).subscribe(res => {
           this.historicoGestor = res;
        });
    }
}
