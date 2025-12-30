import 'reflect-metadata';
import { render } from 'preact';
import './index.css';
import './presentation/i18n';
import { App } from './app.tsx';

render(<App />, document.getElementById('app')!);
