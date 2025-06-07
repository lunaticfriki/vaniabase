import { Component } from '@angular/core';
import { FooterComponent } from './presentation/components/shared/footer/footer.component';
import { HeaderComponent } from './presentation/components/shared/header/header.component';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, HeaderComponent, FooterComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css',
})
export class AppComponent {}
