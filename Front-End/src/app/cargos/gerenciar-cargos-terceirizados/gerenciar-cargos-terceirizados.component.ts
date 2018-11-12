
import {Component} from '@angular/core';
import {Contrato} from '../../contratos/contrato';
import {ContratosService} from '../../contratos/contratos.service';
import {FuncionariosService} from '../../funcionarios/funcionarios.service';
import {CargoService} from '../cargo.service';
import {Funcionario} from '../../funcionarios/funcionario';

@Component({
    selector: 'app-gerenciar-cargos-terceirizados-component',
    templateUrl: './gerenciar-cargos-terceirizados.component.html',
    styleUrls: ['./gerenciar-cargos-terceirizados.component.scss']
})
export class GerenciarCargosTerceirizadosComponent {
    modoOperacao: string;
    contratos: Contrato[];
    codigo: number;
    terceirizados: Funcionario[];
    constructor(private contServ: ContratosService, private funcServ: FuncionariosService, private cargosService: CargoService) {
        this.contServ.getContratosDoUsuario().subscribe(res => {
            this.contratos = res;
        });
    }

    defineCodigoContrato(codigoContrato: number): void {
        this.codigo = codigoContrato;
        if (this.modoOperacao) {
            this.funcServ.getTerceirizadosNaoAlocados().subscribe(res => {
                this.terceirizados = res;
            });
        }
    }

    selecionaModo(modoOperacao: string) {
        this.modoOperacao = modoOperacao;
        if (this.codigo) {
            this.funcServ.getTerceirizadosNaoAlocados().subscribe(res => {
                this.terceirizados = res;
            });
            this.cargosService.getFuncoesContrato(this.codigo).subscribe(res => {

            });
        }

    }
}
