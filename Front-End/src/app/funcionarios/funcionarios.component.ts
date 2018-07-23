import {Component} from '@angular/core';
import {Contrato} from '../contratos/contrato';
import {ContratosService} from '../contratos/contratos.service';
import {FuncionariosService} from './funcionarios.service';
import {Funcionario} from './funcionario';
import {PagerService} from '../_shared/pager.service';

@Component({
  selector: 'app-funcionarios',
  templateUrl: './funcionarios.component.html',
  styleUrls: ['./funcionarios.components.scss']
})
export class FuncionariosComponent {
  contratos: Contrato[] = [];
  funcionarios: Funcionario[];
  funcServ: FuncionariosService;
  contrSer: ContratosService;
  valid = false;
  index2: number;
  gestor: string;
  pager: any;
  pagedItems: Funcionario[];
  indice = 1;
  constructor(contrSer: ContratosService, funcServ: FuncionariosService, private pagerService: PagerService) {
    this.contrSer = contrSer;
    this.funcServ = funcServ;
    this.contrSer.getContratosDoUsuario().subscribe(res => {
      this.contratos = res;
    });
  }
  onChange(value: string) {
    this.index2 = Number(value.split(',')[1]) - 1 ;
    this.valid = false;
    this.funcServ.getFuncionariosDeUmContrato(Number(value.split(',')[1])).subscribe(res => {
      this.funcionarios = res.funcionarios;
      this.gestor = res.gestor;
      this.indice = Number(value.split(',')[0]);
      this.valid = true;
      this.setPage(1);
    });
  }
    setPage(page: number) {
        // get pager object from service
        this.pager = this.pagerService.getPager(this.funcionarios.length, page);
        // get current page of items
        this.pagedItems = this.funcionarios.slice(this.pager.startIndex, this.pager.endIndex + 1);
    }
}
