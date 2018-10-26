import {Component, EventEmitter, Output} from '@angular/core';
import {Contrato} from '../../contratos/contrato';
import {ContratosService} from '../../contratos/contratos.service';
import {DecimoTerceiroService} from '../decimo-terceiro.service';

@Component({
    selector: 'app-calculo-decimo-terceiro-component',
    templateUrl: './calculo-decimo-terceiro.component.html',
    styleUrls: ['./resgate-decimo-terceiro.component.scss']
})
export class CalculoDecimoTerceiroComponent {
    protected contratos: Contrato[];
    protected terceirizados: Object[];
    codigo: number;
    tipoRestituicao: string;
    @Output() navegaParaViewDeCalculos = new EventEmitter();
    constructor(private contratoService: ContratosService, private decimoTerceiroService: DecimoTerceiroService) {
        this.contratoService.getContratosDoUsuario().subscribe(res => {
            this.contratos = res;
        });
    }
    defineCodigoContrato(codigoContrato: number): void {
        this.codigo = codigoContrato;
        if (this.codigo && this.tipoRestituicao) {
            this.decimoTerceiroService.getFuncionariosDecimoTerceiro(this.codigo, this.tipoRestituicao).subscribe(res => {
                this.terceirizados = res;
            });
        }
    }

    defineTipoMovimentacao(tipoMovimentacao: string): void {
        this.tipoRestituicao = tipoMovimentacao;
        if (this.codigo && this.tipoRestituicao) {
            this.decimoTerceiroService.getFuncionariosDecimoTerceiro(this.codigo, this.tipoRestituicao).subscribe(res => {
                this.terceirizados = res;
            });
        }
    }
    eventNav(codigo: number): void {
        console.log(codigo);
        this.navegaParaViewDeCalculos.emit(codigo);
    }
}