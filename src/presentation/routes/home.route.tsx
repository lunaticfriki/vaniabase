import { LazyLoadComponent } from '../components/lazyLoad.component';
import { createLazyLoad } from '../utils/createLazyLoad';

const { Component: Home } = createLazyLoad(() =>
  import('../pages/home.page').then((module) => ({ default: module.Home }))
);

export const HomeRoute = () => {
  return <LazyLoadComponent component={Home} />;
};
