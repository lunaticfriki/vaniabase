import { Component } from '@angular/core';

@Component({
  selector: 'app-footer',
  templateUrl: './footer.component.html',
  styleUrls: ['./footer.component.css'],
})
export class FooterComponent {
  year = new Date().getFullYear();
  nickname = 'lunaticfriki';
  githubUrl = 'http://www.github.com/lunaticfriki';
}
