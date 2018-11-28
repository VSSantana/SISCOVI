import {ChangeDetectorRef, Component, Input} from '@angular/core';
import {ContratosService} from '../../contratos/contratos.service';
import {ConfigService} from '../../_shared/config.service';
import {Contrato} from '../../contratos/contrato';
import {SaldoResidualService} from '../saldo-residual.service';
import {SaldoResidualFerias} from './saldo-residual-restituicoes';
import {SaldoResidualDecimoTerceiro} from './saldo-residual-restituicoes-decimo-terceiro';
import {SaldoResidualRescisao} from './saldo-residual-restituicoes-rescisao';

@Component({
  selector: 'app-saldo-residual-restituicoes-component',
  templateUrl: './saldo-residual-restituicoes.component.html',
  styleUrls: ['../saldo-residual.component.scss']
})
export class SaldoResidualRestituicoesComponent {
  contratos: Contrato[];
  @Input() codigoContrato = 0;
  isSelected = false;
  restituicoesSaldoResidualFerias: SaldoResidualFerias[];
  restituicoesSaldoResidualDecimoTerceiro: SaldoResidualDecimoTerceiro[];
  restituicoesSaldoResidualRescisao: SaldoResidualRescisao[];
  config: ConfigService;
  constructor(private saldoResidualService: SaldoResidualService, private contratoService: ContratosService, config: ConfigService, private ref: ChangeDetectorRef) {
   this.config = config;
    this.contratoService.getContratosDoUsuario().subscribe(res => {
      this.contratos = res;
      if (this.codigoContrato) {
        this.saldoResidualService.getRestituicoesFerias(this.codigoContrato).subscribe(res2 => {
          this.restituicoesSaldoResidualFerias = res2;
          if (this.restituicoesSaldoResidualFerias.length === 0) {
            this.restituicoesSaldoResidualFerias = null;
            this.ref.markForCheck();
          }
        });
        this.saldoResidualService.getRestituicoesDecimoTerceiro(this.codigoContrato).subscribe(res2 => {
          this.restituicoesSaldoResidualDecimoTerceiro = res2;
          if (this.restituicoesSaldoResidualDecimoTerceiro.length === 0) {
            this.restituicoesSaldoResidualDecimoTerceiro = null;
            this.ref.markForCheck();
          }
        });
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
      this.saldoResidualService.getRestituicoesFerias(this.codigoContrato).subscribe(res2 => {
        this.restituicoesSaldoResidualFerias = res2;
        if (this.restituicoesSaldoResidualFerias.length === 0) {
          this.restituicoesSaldoResidualFerias = null;
          this.ref.markForCheck();
        }
      });
      this.saldoResidualService.getRestituicoesDecimoTerceiro(this.codigoContrato).subscribe(res2 => {
        this.restituicoesSaldoResidualDecimoTerceiro = res2;
        if (this.restituicoesSaldoResidualDecimoTerceiro.length === 0) {
          this.restituicoesSaldoResidualDecimoTerceiro = null;
          this.ref.markForCheck();
        }
      });
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
