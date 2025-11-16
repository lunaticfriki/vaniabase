import { Suspense } from 'react';
import type { ComponentType, LazyExoticComponent } from 'react';

interface LazyLoadProps {
  component: LazyExoticComponent<ComponentType>;
  fallback?: React.ReactNode;
}

export const LazyLoadComponent = ({
  component: Component,
  fallback = <></>,
}: LazyLoadProps) => {
  return (
    <Suspense fallback={fallback}>
      <Component />
    </Suspense>
  );
};
