import {Component, EventEmitter} from '@angular/core';
import {FormBuilder, FormControl, FormGroup, Validators} from '@angular/forms';
import {ActivatedRoute, Router} from '@angular/router';
import {MaterializeAction} from 'angular2-materialize';
import {Rubrica} from '../rubrica';
import {RubricasService} from '../rubricas.service';

@Component({
    selector: 'app-cadastrar-rubrica',
    templateUrl: './cadastrar-rubrica.component.html',
    styleUrls: ['./cadastrar-rubrica.component.scss']
})

export class CadastrarRubricaComponent {
  modalActions = new EventEmitter<string|MaterializeAction>();
  rubrica: Rubrica;
  rubricaForm: FormGroup;
  rubricaService: RubricasService;
  id: number;
  route: ActivatedRoute;
  router: Router;
  notValidEdit= true;

  constructor(fb: FormBuilder, rubricaService: RubricasService, route: ActivatedRoute, router: Router) {
    this.route = route;
    this.router = router;
    this.rubricaService = rubricaService;
    this.rubricaForm = fb.group({
      nome: new FormControl('', [Validators.required]),
      sigla: new FormControl('', [Validators.required]),
      descricao: new FormControl('', [Validators.maxLength(200), Validators.minLength(0)])
    });
    this.route.params.subscribe(params => {
      this.id = params['id'];
      if (this.id) {
        rubricaService.buscarRubrica(this.id).subscribe(res => {
          this.rubrica = res;
          this.rubricaForm.controls.nome.setValue(this.rubrica.nome);
          this.rubricaForm.controls.sigla.setValue(this.rubrica.sigla);
          this.rubricaForm.controls.descricao.setValue(this.rubrica.descricao);
        });
      }
    });
  }

  openModal() {
    this.modalActions.emit({action: 'modal', params: ['open']});
  }

  closeModal() {
    this.modalActions.emit({action: 'modal', params: ['close']});
  }

  validateForm() {
    if (this.rubricaForm.status === 'VALID') {
      this.rubricaService.nome = this.rubricaForm.controls.nome.value;
      this.rubricaService.sigla = this.rubricaForm.controls.sigla.value;
      this.rubricaService.descricao = this.rubricaForm.controls.descricao.value;
      this.rubricaService.setValdity(false);
    } else {
        this.rubricaService.setValdity(true);
      }
  }

  activateButton(): void {
    if (this.id) {
      if ((this.rubricaService.nome !== this.rubrica.nome) ||
          (this.rubricaService.sigla !== this.rubrica.sigla) ||
          (this.rubricaService.descricao !== this.rubrica.descricao)) {
        this.notValidEdit = false;
      } else if ((this.rubricaService.nome === this.rubrica.nome) ||
                 (this.rubricaService.sigla === this.rubrica.sigla) ||
                 (this.rubricaService.descricao === this.rubrica.descricao)) {
          this.notValidEdit = true;
        }
    }
  }

  disableButton() {
    this.notValidEdit = true;
  }

  salvarAlteracao() {
    this.rubrica.codigo = this.id;
    this.rubrica.nome = this.rubricaForm.controls.nome.value;
    this.rubrica.sigla = this.rubricaForm.controls.sigla.value;
    this.rubrica.descricao = this.rubricaForm.controls.descricao.value;
    this.rubricaService.salvarAlteracao(this.rubrica).subscribe(res => {
      if (res === 'Alteração feita com sucesso !') {
        this.closeModal();
        this.router.navigate(['/rubricas']);
      }
    });
  }

  deletarRubrica() {
    this.rubricaService.apagarRubrica(this.id).subscribe(res => {
      if (res === 'Rubrica apagada com sucesso!') {
        this.closeModal();
        this.router.navigate(['/rubricas']);
      }
    });
  }

}
