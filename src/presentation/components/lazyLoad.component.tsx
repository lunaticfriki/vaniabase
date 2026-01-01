import { useState, useEffect } from 'preact/hooks';
import type { ComponentType, FunctionalComponent } from 'preact';

export function createLazy<T>(loader: () => Promise<ComponentType<T>>) {
  let cachedPromise: Promise<ComponentType<T>> | null = null;
  let CachedComponent: ComponentType<T> | null = null;

  const preload = () => {
    if (!cachedPromise) {
      cachedPromise = loader().then(module => {
        CachedComponent = module;
        return module;
      });
    }
    return cachedPromise;
  };

  const LazyComponent: FunctionalComponent<T> = props => {
    const [Comp, setComp] = useState<ComponentType<T> | null>(() => CachedComponent);

    useEffect(() => {
      if (!Comp) {
        preload().then(c => setComp(() => c));
      }
    }, []);

    if (!Comp) {
      return (
        <div class="flex h-full w-full items-center justify-center p-10">
          <div class="h-8 w-8 animate-spin rounded-full border-4 border-violet-500 border-t-transparent"></div>
        </div>
      );
    }

    return <Comp {...props} />;
  };

  return { Component: LazyComponent, preload };
}
