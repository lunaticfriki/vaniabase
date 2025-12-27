import { defineConfig } from 'vitest/config';
import preact from '@preact/preset-vite';

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    preact({
      babel: {
        plugins: [
          ['babel-plugin-transform-typescript-metadata'],
          ['@babel/plugin-proposal-decorators', { legacy: true }],
          ['@babel/plugin-proposal-class-properties', { loose: true }]
        ]
      }
    })
  ],
  test: {
    globals: true
  }
});
