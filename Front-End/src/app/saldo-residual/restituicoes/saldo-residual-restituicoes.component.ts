import {ChangeDetectorRef, Component, Input} from '@angular/core';
import {ContratosService} from '../../contratos/contratos.service';
import {ConfigService} from '../../_shared/config.service';
import {Contrato} from '../../contratos/contrato';
import {SaldoResidualService} from '../saldo-residual.service';

@Component({
  selector: 'app-saldo-residual-restituicoes-component',
  templateUrl: './saldo-residual-restituicoes.component.html',
  styleUrls: ['../saldo-residual.component.scss']
})
export class SaldoResidualRestituicoesComponent {
  contratos: Contrato[];
  @Input() codigoContrato = 0;
  isSelected = false;
  // restituicoesSaldoResidual: FeriasCalculosPendentes[];
  config: ConfigService;
  constructor(private saldoResidualService: SaldoResidualService, private contratoService: ContratosService, config: ConfigService, private ref: ChangeDetectorRef) {
/*    this.config = config;
    this.contratoService.getContratosDoUsuario().subscribe(res => {
      this.contratos = res;
      if (this.codigoContrato) {
        this.feriasService.getRetencoesFerias(this.codigoContrato).subscribe(res2 => {
          this.calculosFerias = res2;
          if (this.calculosFerias.length === 0) {
            this.calculosFerias = null;
            this.ref.markForCheck();
          }
        });
      }
    }); */
  }/*
  defineCodigoContrato(codigoContrato: number): void {
    this.codigoContrato = codigoContrato;
    if (this.codigoContrato) {
      this.feriasService.getRetencoesFerias(this.codigoContrato).subscribe(res2 => {
        this.calculosFerias = res2;
        if (this.calculosFerias.length === 0) {
          this.calculosFerias = null;
          this.ref.markForCheck();
        }
      });
    }
  }*/
}
