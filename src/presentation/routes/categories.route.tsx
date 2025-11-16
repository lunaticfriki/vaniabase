import { LazyLoadComponent } from '../components/lazyLoad.component';
import { createLazyLoad } from '../utils/createLazyLoad';

const { Component: Categories } = createLazyLoad(() =>
  import('../pages/categories.page').then((module) => ({
    default: module.CategoriesPage,
  }))
);

export const CategoriesRoute = () => {
  return <LazyLoadComponent component={Categories} />;
};
