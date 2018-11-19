import {Component} from '@angular/core';

@Component({
  selector: 'app-saldo-residual-component',
  templateUrl: './saldo-residual.component.html',
  styleUrls: ['./saldo-residual.component.scss']
})
export class SaldoResidualComponent {
  contentAvailable: Content = Content.Restituicoes;
  tabSelectionParams = ['select_tab', 'tab1'];
  codigoContrato: number;

  constructor() {    }

  feriasPendente(codigoContrato: number) {
    this.codigoContrato = codigoContrato;
    this.tabSelectionParams = ['select_tab', 'tab2'];
    this.setFeriasActive();
  }
  decimoTerceiroPendente(codigoContrato: number) {
    this.codigoContrato = codigoContrato;
    this.tabSelectionParams = ['select_tab', 'tab3'];
    this.setDecimoTerceiroActive();
  }
  rescisaoPendente(codigoContrato: number) {
    this.codigoContrato = codigoContrato;
    this.tabSelectionParams = ['select_tab', 'tab4'];
    this.setRescisaoActive();
  }
  execucaoPendente(codigoContrato: number) {
    this.codigoContrato = codigoContrato;
    this.tabSelectionParams = ['select_tab', 'tab5'];
    this.setExecucaoActive();
  }
  execRestituicoes(): boolean {
    if (this.contentAvailable === Content.Restituicoes) {
      return true;
    }
    return false;
  }
  execFerias() {
    if (this.contentAvailable === Content.Ferias) {
      return true;
    }
    return false;
  }
  execDecimoTericeiro() {
    if (this.contentAvailable === Content.DecimoTerceiro) {
      return true;
    }
    return false;
  }
  execRescisao() {
    if (this.contentAvailable === Content.Rescisao) {
      return true;
    }
    return false;
  }
  execExecucao() {
    if (this.contentAvailable === Content.Execucao) {
      return true;
    }
    return false;
  }
  setRestituicoesActive(): void {
    this.contentAvailable = Content.Restituicoes;
    this.tabSelectionParams = ['select_tab', 'test1'];
  }
  setFeriasActive(): void {
    this.contentAvailable = Content.Ferias;
    this.tabSelectionParams = ['select_tab', 'test2'];
  }
  setDecimoTerceiroActive(): void {
    this.contentAvailable = Content.DecimoTerceiro;
    this.tabSelectionParams = ['select_tab', 'test3'];
  }
  setRescisaoActive(): void {
    this.contentAvailable = Content.Rescisao;
    this.tabSelectionParams = ['select_tab', 'test4'];
  }
  setExecucaoActive(): void {
    this.contentAvailable = Content.Execucao;
    this.tabSelectionParams = ['select_tab', 'test4'];
  }
}

enum Content {Restituicoes, Ferias, DecimoTerceiro, Rescisao, Execucao}
