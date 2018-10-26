import {Component, EventEmitter, Output} from '@angular/core';
import {ContratosService} from '../../contratos/contratos.service';
import {Contrato} from '../../contratos/contrato';
import {FormBuilder, FormControl, FormGroup, Validators} from '@angular/forms';
import {MaterializeAction} from 'angular2-materialize';
import {TotalMensalService} from '../total-mensal.service';
import {TotalMensal} from '../totalMensal';

@Component({
  templateUrl: './total-mensal-calculo.component.html',
  selector: 'app-total-mensal-calculo',
  styleUrls: ['./total-mensal-calculo.component.scss']
})
export class TotalMensalCalculoComponent {
  contratos: Contrato[] = [];
  meses = [
      {valor: 1, mes: 'Janeiro'},
      {valor: 2, mes: 'Fevereiro'},
      {valor: 3, mes: 'Março'},
      {valor: 4, mes: 'Abril'},
      {valor: 5, mes: 'Maio'},
      {valor: 6, mes: 'Junho'},
      {valor: 7, mes: 'Julho'},
      {valor: 8, mes: 'Agosto'},
      {valor: 9, mes: 'Setembro'},
      {valor: 10, mes: 'Outubro'},
      {valor: 11, mes: 'Novembro'},
      {valor: 12, mes: 'Dezembro'}
    ];
  years: number[] = [];
  currentYear = new Date().getFullYear();
  anoDoContratoMaisAntigo: number;
  anoDoContratoMaisRecente: number;
  myForm: FormGroup;
  codigoContrato: number;
  validate = true;
  currentMonth = new Date().getMonth() + 1;
  fb: FormBuilder;
  modalActions = new EventEmitter<string | MaterializeAction>();
  tmService: TotalMensalService;
  resultado: TotalMensal[];
  @Output() close = new EventEmitter();
  constructor(contServ: ContratosService, fb: FormBuilder, tmService: TotalMensalService) {
      this.tmService = tmService;
      this.fb = fb;
    if (contServ.contratos.length === 0) {
      contServ.getContratosDoUsuario().subscribe((res) => {
        contServ.contratos = res;
        this.contratos = res;
        this.anoDoContratoMaisAntigo = this.getAnoDoContratoMaisAntigo(this.contratos);
        this.anoDoContratoMaisRecente = this.getAnoDoContratoMaisRecente(this.contratos);
        this.years = this.preencheListaDeAnos(this.anoDoContratoMaisAntigo, this.anoDoContratoMaisRecente);
      });
    }else {
      this.contratos = contServ.contratos;
      this.currentYear = (new Date().getFullYear());
      this.anoDoContratoMaisAntigo = this.getAnoDoContratoMaisAntigo(this.contratos);
      this.anoDoContratoMaisRecente = this.getAnoDoContratoMaisRecente(this.contratos);
      this.years = this.preencheListaDeAnos(this.anoDoContratoMaisAntigo, this.anoDoContratoMaisRecente);
    }
      this.myForm = this.fb.group({
          contrato: new FormControl(this.codigoContrato, [Validators.required]),
          mes: new FormControl(this.currentMonth, [Validators.required]),
          ano: new FormControl(this.currentYear, [Validators.required])
      });
    // this.normalizaDataFim();
  }
  getAnoDoContratoMaisAntigo(contratos: Contrato[]): number {
    let anoDoCMA: number;
    if (contratos.length > 1) {
      for (let i = 1; i < contratos.length; i++) {
        if (contratos[i].anoDoContrato < contratos[i - 1].anoDoContrato) {
          anoDoCMA = contratos[i].anoDoContrato;
        } else {
          anoDoCMA = contratos[i - 1].anoDoContrato;
        }
      }
    } else {
      anoDoCMA = contratos[0].anoDoContrato;
    }
    return anoDoCMA;
  }
  getAnoDoContratoMaisRecente(contratos: Contrato[]): number {
    let anoDOCMR: number;
    if (contratos.length > 1) {
      for (let i = 1; i < contratos.length; i++) {
        if (contratos[i].anoDoContrato > contratos[i - 1].anoDoContrato) {
          anoDOCMR = contratos[i].anoDoContrato;
        } else {
          anoDOCMR = contratos[i - 1].anoDoContrato;
        }
      }
    } else {
      anoDOCMR = contratos[0].anoDoContrato;
    }
    return anoDOCMR;
  }
  preencheListaDeAnos(anoDoContratoMaisAntigo: number, anoDoContratoMaisRecente: number): number[] {
    let currentYear: number = (new Date().getFullYear());
    const years: number[] = [];
    if (anoDoContratoMaisRecente === anoDoContratoMaisAntigo) {
      for (let i = 0; i < 10; i++) {
        years[i] = anoDoContratoMaisAntigo;
        anoDoContratoMaisAntigo = anoDoContratoMaisAntigo + 1;
      }
      return years;
    }
    for (let i = 0; currentYear > anoDoContratoMaisAntigo; i++) {
      currentYear = currentYear - 1;
      years[i] = currentYear;
    }
    currentYear = (new Date().getFullYear());
    for (let i = years.length; currentYear < (anoDoContratoMaisRecente + 6); i++) {
      years[i] = currentYear;
      currentYear = currentYear + 1;
    }
    years.sort((a, b) => (a - b));
    return years;
  }
  onChange(value): void {
    this.codigoContrato = value;
     if (value) {
       this.validate = false;
     }
  }
  calculoTotalMensal() {
      this.tmService.calcularTotalMensal(this.myForm.get('contrato').value, this.myForm.get('mes').value, this.myForm.get('ano').value).subscribe(res => {
          if (!res.error) {
              this.resultado = res;
              this.openModal();
          } else {
              this.myForm.setErrors({'mensagem': res.error});
          }

      });
  }
  openModal() {
      this.modalActions.emit({action: 'modal', params: ['open']});
  }
  closeModal() {
      this.modalActions.emit({action: 'modal', params: ['close']});
      if (this.resultado) {
          this.close.emit(this.myForm.get('contrato').value);
      }
  }
  apagarCalculo() { }
}
