import {Component, OnInit} from '@angular/core';
import {Router} from '@angular/router';
import {AbstractControl, FormArray, FormBuilder, FormControl, FormGroup, Validators} from '@angular/forms';
import {CargoService} from '../../cargos/cargo.service';
import {Cargo} from '../../cargos/cargo';
import {ContratosService} from '../contratos.service';
import {UserService} from '../../users/user.service';
import {ConfigService} from '../../_shared/config.service';
import {Usuario} from '../../usuarios/usuario';
import {FormularioCadastroContrato} from './formulario.cadastro.contrato';

@Component({
  selector: 'app-cadastro-contrato',
  templateUrl: './cadastro.contrato.component.html',
  styleUrls: ['./cadastro.contrato.component.scss']
})
export class CadastroContratoComponent implements OnInit {

    router: Router;
    carSer: CargoService;
    cargosCadastrados: Cargo[];
    myForm: FormGroup;
    myForm2: FormGroup;
    fb: FormBuilder;
    fb1: FormBuilder;
    contratoService: ContratosService;
    dataInicio = '';
    usuarios: Usuario[];
    meses =  [
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
    constructor(router: Router, carSer: CargoService, fb: FormBuilder, fb1: FormBuilder, contratoService: ContratosService, userService: UserService, config: ConfigService) {
        this.router = router;
        this.fb = fb;
        this.fb1 = fb1;
        this.contratoService = contratoService;
        this.carSer = carSer;
        this.carSer.getAllCargos().subscribe(res => {
            this.cargosCadastrados = res;
            this.initCargos();
        });
        if (userService.user.perfil.sigla === 'ADMINISTRADOR') {
            userService.getUsuarios().subscribe(res => {
                this.usuarios = res;
            });
        }else {
            userService.getGestores().subscribe(res => {
                this.usuarios = res;
            });
        }
    }
    ngOnInit() {
        this.myForm2 = this.fb1.group({
            inicioVigencia: new FormControl('', [Validators.required, this.myDateValidator]),
            fimVigencia: new FormControl('', [Validators.required, this.myDateValidator]),
            assinatura: new FormControl('', [Validators.required, this.myDateValidator]),
            nomeGestor: new FormControl('', [Validators.required, this.nameValidator]),
            nomeEmpresa: new FormControl('', [Validators.required, this.nameValidator]),
            cnpj: new FormControl('', [Validators.required, this.cnpjValidator]),
            ativo: new FormControl('SIM', [Validators.required]),
            objeto: new FormControl(''),
            percentualFerias: new FormControl('', [Validators.required]),
            percentualDecimoTerceiro: new FormControl('', [Validators.required]),
            percentualIncidencia: new FormControl('', [Validators.required, this.percentualValidator]),
            numeroContrato: new FormControl('', [Validators.required]),
            primeiroSubstituto: new FormControl(''),
            segundoSubstituto: new FormControl('')
        });
        this.myForm = this.fb.group({
            cargos: this.fb.array([])
        });
        this.adicionaCargo();
        this.carSer.getAllCargos().subscribe(res => {
            this.cargosCadastrados = res;
            this.initCargos();
        });
        this.contratoService.formValido = this.myForm.valid && this.myForm2.valid;
    }
    initCargos() {
        return this.fb.group({
            nome: new FormControl('', [Validators.required]),
            remuneracao: new FormControl('', [Validators.required]),
            descricao: new FormControl(''),
            // dia: new FormControl('', [Validators.required]),
            // mes: new FormControl('', [Validators.required])
        });
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
    public myDateValidator(control: AbstractControl): {[key: string]: any} {
        const val = control.value;
        const mensagem = [];
        const otherRegex = new RegExp(/^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/);
        if (val.length > 0 ) {
            const dia = Number(val.split('/')[0]);
            const mes = Number(val.split('/')[1]);
            const ano = Number(val.split('/')[2]);
            if (dia <= 0 || dia > 31 ) {
                mensagem.push('O dia da data é inválido.');
            }
            if (mes <= 0 || mes > 12) {
                mensagem.push('O Mês digitado é inválido');
            }
            if (ano < 2000 || ano > (new Date().getFullYear() + 5)) {
                mensagem.push('O Ano digitado é inválido');
            }
            if (val.length === 10 ) {
                if (!otherRegex.test(val)) {
                    mensagem.push('A data digitada é inválida');
                }
            }
        }
        return (mensagem.length > 0) ? {'mensagem': [mensagem]} : null;
    }
    public percentualValidator(control: AbstractControl): {[key: string]: any} {
        const val = control.value.split('%')[0];
        const mensagem = [];
        if (control.value) {
            if ((Number(val.replace(',', '.'))) === 0) {
                mensagem.push('Digite um valor para o percentual de incidência. Valores comuns para este percentual são  36,8 e 35,6');
            }
        }
        return (mensagem.length > 0) ? {'mensagem': [mensagem]} : null;
    }
    isValid() {
        if (this.myForm2.valid && this.myForm.valid) {
           this.contratoService.formValido = true;
           const formCadastroContrato = new FormularioCadastroContrato();
           formCadastroContrato.nomeGestor = this.myForm2.get('nomeGestor').value;
           formCadastroContrato.nomePrimeiroSubstituto = this.myForm2.get('primeiroSubstituto').value;
           formCadastroContrato.nomeSegundoSubstituto = this.myForm2.get('segundoSubstituto').value;
           formCadastroContrato.cnpj = this.myForm2.get('cnpj').value;
           formCadastroContrato.numeroContrato = this.myForm2.get('numeroContrato').value;
           formCadastroContrato.ativo = this.myForm2.get('ativo').value;
           formCadastroContrato.objeto = this.myForm2.get('objeto').value;
           formCadastroContrato.inicioVigencia = this.myForm2.get('inicioVigencia').value;
           formCadastroContrato.fimVigencia = this.myForm2.get('fimVigencia').value;
           formCadastroContrato.assinatura = this.myForm2.get('assinatura').value;
           formCadastroContrato.percentualFerias = this.myForm2.get('percentualFerias').value;
           formCadastroContrato.percentualDecimoTerceiro = this.myForm2.get('percentualDecimoTerceiro').value;
           formCadastroContrato.percentualIncidencia = this.myForm2.get('percentualIncidencia').value;
           formCadastroContrato.cargos = this.myForm.get('cargos').value;
           this.contratoService.formCadContr = formCadastroContrato;
        }else {
            this.contratoService.formValido = false;
        }
    }
    formArrayLength() {
        const control = <FormArray>this.myForm.controls.cargos;
        return control.length;
    }
    getFormArrayItems() {
        const control = <FormArray>this.myForm.controls.cargos;
        return control.controls;
    }
    public nameValidator(control: AbstractControl): {[key: string]: any} {
        const exp = new RegExp(/[a-zA-Z-\u00C0-\u00FF]+$/);
        const mensagem = [];
        if (!exp.test(control.value)) {
            mensagem.push('O nome deve conter apenas letras');
        }
        return (mensagem.length > 0) ? {'mensagem': [mensagem]} : null;
    }
    public cnpjValidator(control: AbstractControl): {[key: string]: any} {
        let cnpj = control.value;
        cnpj = cnpj.replace(/[^\d]+/g, '');
        const mensagem = [];
        const valida = new Array(6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2);
        let dig1 = 0;
        let dig2 = 0;
        const digito = Number(cnpj.charAt(12) + cnpj.charAt(13));

        for (let i = 0; i < valida.length; i++) {
            dig1 += (i > 0 ? (cnpj.charAt(i - 1) * valida[i]) : 0);
            dig2 += cnpj.charAt(i) * valida[i];
        }
        dig1 = (((dig1 % 11) < 2) ? 0 : (11 - (dig1 % 11)));
        dig2 = (((dig2 % 11) < 2) ? 0 : (11 - (dig2 % 11)));

        if (((dig1 * 10) + dig2) !== digito) {
            mensagem.push('CNPJ inválido');
        }
        return (mensagem.length > 0) ? {'mensagem': [mensagem]} : null;
    }
}
