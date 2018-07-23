import { Component } from '@angular/core';
import { Router } from '@angular/router';

import { ConfigService } from '../_shared/config.service';

declare var $: any;

@Component(
{
  selector: 'app-footer',
  templateUrl: './footer.component.html'
}
)
export class FooterComponent {
  title: string = this.configService.title;
  subtitle: string = this.configService.subtitle;
  constructor(
    private configService: ConfigService,
    private router: Router
  ) { }
}
