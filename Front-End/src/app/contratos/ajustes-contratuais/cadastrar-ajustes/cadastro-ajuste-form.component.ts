import {Component, Input, OnInit} from '@angular/core';
import {Contrato} from '../../contrato';
import {FormArray, FormBuilder, FormControl, FormGroup, Validators} from '@angular/forms';
import {Percentual} from '../../../percentuais/percentual';
import {Usuario} from '../../../usuarios/usuario';
import {Convencao} from '../../../convencoes-coletivas/convencao';
import {Cargo} from '../../../cargos/cargo';

@Component({
    selector: 'app-cadastro-ajuste-form-component',
    templateUrl: './cadastro-ajuste-form.component.html'
})
export class CadastroAjusteFormComponent implements OnInit {
    @Input() contrato: Contrato;
    @Input() nomeGestorContrato: string;
    @Input() usuarios: Usuario[];
    @Input() convencoesColetivas: Convencao[];
    @Input() cargosCadastrados: Cargo[];
    @Input() percentuaisFerias: Percentual[];
    @Input() percentuaisDecimoTerceiro: Percentual[];
    myForm: FormGroup;
    percentualFerias: number;
    percentualDecimoTerceiro: number;
    percentualIncidencia: number;
    constructor(private fb: FormBuilder) {}
    ngOnInit() {
        this.initForm();
    }
    getFormArrayItems() {
        const control = <FormArray>this.myForm.controls.cargos;
        return control.controls;
    }
    formArrayLength() {
        const control = <FormArray>this.myForm.controls.cargos;
        return control.length;
    }
    initForm() {
        this.myForm = this.fb.group({
            cargos: this.fb.array([]),
            tipoAjuste: new FormControl('', [Validators.required]),
            prorrogacao: new FormControl('Não', [Validators.required]),
            gestor: new FormControl('', [Validators.required]),
            primeiroSubstituto: new FormControl(''),
            segundoSubstituto: new FormControl(''),
            assinatura: new FormControl('', [Validators.required]),
            inicioVigencia: new FormControl('', [Validators.required]),
            fimVigencia: new FormControl('', [Validators.required]),
            assunto: new FormControl(''),
            percentualFerias: new FormControl(''),
            percentualDecimoTerceiro: new FormControl(''),
            percentualIncidencia: new FormControl(''),
            numeroContrato: new FormControl('', [Validators.required]),
            nomeEmpresa: new FormControl('', [Validators.required]),
            cnpj: new FormControl('', [Validators.required]),
            ativo: new FormControl('', [Validators.required]),
            objeto: new FormControl('', [Validators.required])
        });
        this.startView();
    }
    adicionaCargo(): void {
        const control = <FormArray>this.myForm.controls.cargos;
        const addCtrl = this.initCargos();
        control.push(addCtrl);
    }
    removeCargo(i: number) {
        const control = <FormArray>this.myForm.controls.cargos;
        control.removeAt(i);
    }
    initCargos() {
        return this.fb.group({
            nome: new FormControl('', [Validators.required]),
            remuneracao: new FormControl('', [Validators.required]),
            descricao: new FormControl(''),
            trienios: new FormControl(''),
            adicionais: new FormControl(''),
            convencao: new FormControl('')
            // mes: new FormControl('', [Validators.required])
        });
    }
    startView() {
        // this.adicionaCargo();
        /* this.cargoService.getAllCargos().subscribe(resposta => {
            this.cargosCadastrados = resposta;
            this.initCargos();
        }); */
        console.log(this.contrato);
        this.myForm.controls.numeroContrato.setValue(this.contrato.numeroDoContrato);
        this.myForm.controls.nomeEmpresa.setValue(this.contrato.nomeDaEmpresa);
        this.myForm.controls.cnpj.setValue(this.contrato.cnpj);
        this.myForm.controls.objeto.setValue(this.contrato.objeto);
        this.initCargos(); // deixar assim por enquanto
        if (this.contrato.seAtivo === 'S' || this.contrato.seAtivo === 'SIM') {
            this.myForm.controls.ativo.setValue('Sim');
        } else {
            this.myForm.controls.ativo.setValue('Não');
        }
        this.myForm.controls.objeto.setValue(this.contrato.objeto);
        this.myForm.controls.gestor.setValue(this.nomeGestorContrato);
        for (let i = 0; i < this.contrato.percentuais.length; i++) {
            const percentual: Percentual = this.contrato.percentuais[i];
            if (percentual.nome.includes('Férias')) {
                this.percentualFerias = percentual.percentual;
                this.myForm.controls.percentualFerias.setValue(percentual.percentual);
            }
            if (percentual.nome.includes('Décimo terceiro')) {
                this.percentualDecimoTerceiro = percentual.percentual;
                this.myForm.controls.percentualDecimoTerceiro.setValue(percentual.percentual);
            }
            if (percentual.nome.includes('Incidência')) {
                this.percentualIncidencia = percentual.percentual;
                this.myForm.controls.percentualIncidencia.setValue(percentual.percentual);
            }
        }
    }
}
