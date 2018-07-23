export class TotalMensal {
    private _funcao: string;
    private _ferias: number;
    private _tercoConstitucional: number;
    private _decimoTerceiro: number;
    private _incidencia: number;
    private _multaFGTS: number;
    private _total: number;
    constructor(funcao: string, ferias: number, tercoConstitucional: number, decimoTerceiro: number, incidencia: number, multaFGTS: number, total: number) {
        this._funcao = funcao;
        this._ferias = ferias;
        this._tercoConstitucional = tercoConstitucional;
        this._decimoTerceiro = decimoTerceiro;
        this._incidencia = incidencia;
        this._multaFGTS = multaFGTS;
        this._total = total;
    }


    get funcao(): string {
        return this._funcao;
    }

    get ferias(): number {
        return this._ferias;
    }

    get tercoConstitucional(): number {
        return this._tercoConstitucional;
    }

    get decimoTerceiro(): number {
        return this._decimoTerceiro;
    }

    get incidencia(): number {
        return this._incidencia;
    }

    get multaFGTS(): number {
        return this._multaFGTS;
    }

    get total(): number {
        return this._total;
    }
}
