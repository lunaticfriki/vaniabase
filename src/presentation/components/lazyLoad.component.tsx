import { Suspense } from 'react';
import type { ComponentType, LazyExoticComponent } from 'react';
import { LoadingComponent } from './loading.component';

interface LazyLoadProps {
  component: LazyExoticComponent<ComponentType>;
  fallback?: React.ReactNode;
}

export const LazyLoadComponent = ({
  component: Component,
  fallback = <LoadingComponent />,
}: LazyLoadProps) => {
  return (
    <Suspense fallback={fallback}>
      <Component />
    </Suspense>
  );
};
