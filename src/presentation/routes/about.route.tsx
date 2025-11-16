import { LazyLoadComponent } from '../components/lazyLoad.component';
import { createLazyLoad } from '../utils/createLazyLoad';

const { Component: About } = createLazyLoad(() =>
  import('../pages/about.page').then((module) => ({ default: module.About }))
);

export const AboutRoute = () => {
  return <LazyLoadComponent component={About} />;
};
