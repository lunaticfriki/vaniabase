import { LazyLoadComponent } from '../components/lazyLoad.component';
import { createLazyLoad } from '../utils/createLazyLoad';

const { Component: Search } = createLazyLoad(() =>
  import('../pages/search.page').then((module) => ({
    default: module.SearchPage,
  }))
);

export const SearchRoute = () => {
  return <LazyLoadComponent component={Search} />;
};
