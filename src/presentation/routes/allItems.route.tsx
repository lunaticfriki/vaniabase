import { LazyLoadComponent } from '../components/lazyLoad.component';
import { createLazyLoad } from '../utils/createLazyLoad';

const { Component: AllItems } = createLazyLoad(() =>
  import('../pages/allItems.page').then((module) => ({
    default: module.AllItemsPage,
  }))
);

export const AllItemsRoute = () => {
  return <LazyLoadComponent component={AllItems} />;
};
