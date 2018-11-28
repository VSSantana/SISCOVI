import {ChangeDetectorRef, Component, Input} from '@angular/core';
import {ContratosService} from '../../contratos/contratos.service';
import {ConfigService} from '../../_shared/config.service';
import {Contrato} from '../../contratos/contrato';
import {SaldoResidualService} from '../saldo-residual.service';
import {SaldoResidualRescisao} from '../restituicoes/saldo-residual-restituicoes-rescisao';

@Component({
  selector: 'app-saldo-residual-rescisao-component',
  templateUrl: './saldo-residual-rescisao.component.html',
  styleUrls: ['../saldo-residual.component.scss']
})
export class SaldoResidualRescisaoComponent {
  contratos: Contrato[];
  @Input() codigoContrato = 0;
  isSelected = false;
  restituicoesSaldoResidualRescisao: SaldoResidualRescisao[];
  config: ConfigService;
  constructor(private saldoResidualService: SaldoResidualService, private contratoService: ContratosService, config: ConfigService, private ref: ChangeDetectorRef) {
    this.config = config;
    this.contratoService.getContratosDoUsuario().subscribe(res => {
      this.contratos = res;
      if (this.codigoContrato) {
        this.saldoResidualService.getRestituicoesRescisao(this.codigoContrato).subscribe(res2 => {
          this.restituicoesSaldoResidualRescisao = res2;
          if (this.restituicoesSaldoResidualRescisao.length === 0) {
            this.restituicoesSaldoResidualRescisao = null;
            this.ref.markForCheck();
          }
        });
      }
    });
  }
  defineCodigoContrato(codigoContrato: number): void {
    this.codigoContrato = codigoContrato;
    if (this.codigoContrato) {
      this.saldoResidualService.getRestituicoesRescisao(this.codigoContrato).subscribe(res2 => {
        this.restituicoesSaldoResidualRescisao = res2;
        if (this.restituicoesSaldoResidualRescisao.length === 0) {
          this.restituicoesSaldoResidualRescisao = null;
          this.ref.markForCheck();
        }
      });
    }
  }
}
