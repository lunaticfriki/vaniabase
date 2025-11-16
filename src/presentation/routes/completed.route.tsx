import { LazyLoadComponent } from '../components/lazyLoad.component';
import { createLazyLoad } from '../utils/createLazyLoad';

const { Component: Completed } = createLazyLoad(() =>
  import('../pages/completed.page').then((module) => ({
    default: module.CompletedPage,
  }))
);

export const CompletedRoute = () => {
  return <LazyLoadComponent component={Completed} />;
};
