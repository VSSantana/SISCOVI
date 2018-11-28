import {ChangeDetectorRef, Component, Input} from '@angular/core';
import {ContratosService} from '../../contratos/contratos.service';
import {ConfigService} from '../../_shared/config.service';
import {Contrato} from '../../contratos/contrato';
import {SaldoResidualService} from '../saldo-residual.service';
import {SaldoResidualDecimoTerceiro} from '../restituicoes/saldo-residual-restituicoes-decimo-terceiro';

@Component({
  selector: 'app-saldo-residual-decimo-terceiro-component',
  templateUrl: './saldo-residual-decimo-terceiro.component.html',
  styleUrls: ['../saldo-residual.component.scss']
})
export class SaldoResidualDecimoTerceiroComponent {
  contratos: Contrato[];
  @Input() codigoContrato = 0;
  isSelected = false;
  restituicoesSaldoResidualDecimoTerceiro: SaldoResidualDecimoTerceiro[];
  config: ConfigService;
  constructor(private saldoResidualService: SaldoResidualService, private contratoService: ContratosService, config: ConfigService, private ref: ChangeDetectorRef) {
    this.config = config;
    this.contratoService.getContratosDoUsuario().subscribe(res => {
      this.contratos = res;
      if (this.codigoContrato) {
        this.saldoResidualService.getRestituicoesDecimoTerceiro(this.codigoContrato).subscribe(res2 => {
          this.restituicoesSaldoResidualDecimoTerceiro = res2;
          if (this.restituicoesSaldoResidualDecimoTerceiro.length === 0) {
            this.restituicoesSaldoResidualDecimoTerceiro = null;
            this.ref.markForCheck();
          }
        });
      }
    });
  }
  defineCodigoContrato(codigoContrato: number): void {
    this.codigoContrato = codigoContrato;
    if (this.codigoContrato) {
      this.saldoResidualService.getRestituicoesDecimoTerceiro(this.codigoContrato).subscribe(res2 => {
        this.restituicoesSaldoResidualDecimoTerceiro = res2;
        if (this.restituicoesSaldoResidualDecimoTerceiro.length === 0) {
          this.restituicoesSaldoResidualDecimoTerceiro = null;
          this.ref.markForCheck();
        }
      });
    }
  }
}
