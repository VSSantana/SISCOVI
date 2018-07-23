import {Component} from '@angular/core';
import {ConfigService} from '../../_shared/config.service';
import {FuncionariosService} from '../../funcionarios/funcionarios.service';
import {CargoService} from '../cargo.service';
import {Contrato} from '../../contratos/contrato';
import {ContratosService} from '../../contratos/contratos.service';
import {ListaCargosFuncionarios} from './lista.cargos.funcionarios';

@Component({
  selector: 'app-cargos-funcionarios',
  templateUrl: './cargos.dos.funcionarios.html',
  styleUrls: ['./cargos.dos.funcionarios.scss']
})
export class CargosDosFuncionariosComponent {
  contratos: Contrato[] = [];
  cargServ: CargoService;
  listaCargosFuncionarios: ListaCargosFuncionarios[] = [];
  valid = false;
  constructor(config: ConfigService, funcServ: FuncionariosService, cargServ: CargoService, contServ: ContratosService) {
    this.cargServ = cargServ;
    contServ.getContratosDoUsuario().subscribe(res => {
      this.contratos = res;
    });
  }
  onChange (value: number) {
    this.valid = true;
    this.cargServ.getCargosFuncionarios(value).subscribe(res => {
      this.listaCargosFuncionarios = res;
    });
  }
}
