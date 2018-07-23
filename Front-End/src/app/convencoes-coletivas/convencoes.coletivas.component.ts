import {Component} from '@angular/core';
import {ContratosService} from '../contratos/contratos.service';
import {Contrato} from '../contratos/contrato';
import {ConvencaoService} from './convencao.service';
import {ListaConvencoes} from './lista.convencoes';

@Component({
  selector: 'app-convencao-coletiva',
  templateUrl: 'convencoes-coletivas.component.html',
  styleUrls: ['convencoes.coletivas.component.scss']
})
export class ConvencoesColetivasComponent {
  contratos: Contrato[] = [];
  convServ: ConvencaoService;
  convencoes: ListaConvencoes[] = [];
  valid = false;
  index: number;
  constructor(convServ: ConvencaoService, contService: ContratosService) {
    this.convServ = convServ;
    contService.getContratosDoUsuario().subscribe(res => {
      this.contratos = res;
    });
  }
  onChange(value: number): void {
    this.convServ.getConvencoes(value).subscribe(res => {
      this.convencoes = res;
      this.valid = true;
      this.index = value - 1;
    });
  }
}
