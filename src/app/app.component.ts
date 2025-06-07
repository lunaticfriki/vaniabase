import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css',
})
export class AppComponent {
  title = 'vaniabase';
  year = new Date().getFullYear();
  nickname = 'lunaticfriki';
  githubUrl = 'http://www.github.com/lunaticfriki';
}
