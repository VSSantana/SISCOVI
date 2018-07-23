import {Injectable} from '@angular/core';
import {Http} from '@angular/http';
import {ConfigService} from '../_shared/config.service';

@Injectable()
export class TotalMensalService {
    private http: Http;
    private configService: ConfigService;
    constructor(http: Http, config: ConfigService) {
        this.configService = config;
       this.http = http;
    }
    public getValoresCalculados(codigoContrato: number, codigoUsuario: number) {
        const url = this.configService.myApi + '/total-mensal-a-reter/getValoresRetidos/' + codigoContrato + '/' + codigoUsuario;
        return this.http.get(url).map(res => res.json());
    }
    public calcularTotalMensal(codigoContrato: number, mes: number, ano: number) {
        const url = this.configService.myApi + '/total-mensal-a-reter/calculaTotalMensal=' + this.configService.user.id + '/codigo=' + codigoContrato + '/mes=' + mes + '/ano=' + ano;
        return this.http.get(url).map(res => res.json());
    }
}
