import {Component, EventEmitter} from '@angular/core';
import {Router} from '@angular/router';
import {MaterializeAction} from 'angular2-materialize';
import { Rubrica } from './rubrica';
import {RubricasService} from './rubricas.service';

@Component({
  selector: 'app-rubricas',
  templateUrl: 'rubricas.component.html',
  styleUrls: ['rubricas.component.scss']
})
export class RubricasComponent {
  modalActions = new EventEmitter<string|MaterializeAction>();
  rubricas: Rubrica[];
  rubricaService: RubricasService;
  render = false;
  router: Router;
  constructor(rubricaService: RubricasService, router: Router) {
    this.router = router;
    this.rubricaService = rubricaService;
    rubricaService.getAllrubricas().subscribe(res => {
      this.rubricas = res;
    });
  }
  openModal() {
    this.render = true;
    this.modalActions.emit({action: 'modal', params: ['open']});
  }
  closeModal() {
    this.render = false;
    this.rubricaService.setValdity(true);
    this.modalActions.emit({action: 'modal', params: ['close']});
  }
  cadastraRubrica() {
    this.rubricaService.cadastrarRubrica().subscribe(res => {
      if (res === 'Rubrica Cadastrada Com sucesso !') {
        this.rubricaService.getAllrubricas().subscribe(res2 => {
          this.rubricas.slice();
          this.rubricas = res2;
          this.closeModal();
        });
      }
    });
  }
  editarRubrica(id: number): void {
    this.router.navigate(['/rubricas', id]);
  }
}
