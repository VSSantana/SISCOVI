import {Injectable} from '@angular/core';
import {Http} from '@angular/http';
import {ConfigService} from '../_shared/config.service';

@Injectable()
export class HistoricoService {
    constructor(private http: Http, private config: ConfigService) {}
    getHistoricoGestores(codigo: number) {
        const url = this.config.myApi + '/historico/getHistoricoGestores=' + codigo;
        return this.http.get(url).map(res => res.json());
    }
}