import { lazy } from 'react';
import type { ComponentType } from 'react';

type Loader = () => Promise<{ default: ComponentType }>;

export const createLazyLoad = (loader: Loader) => {
  const Component = lazy(loader);

  return {
    Component,
    preload: loader,
  };
};
