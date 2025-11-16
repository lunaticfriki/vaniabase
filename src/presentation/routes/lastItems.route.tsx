import { LazyLoadComponent } from '../components/lazyLoad.component';
import { createLazyLoad } from '../utils/createLazyLoad';

const { Component: LastItems } = createLazyLoad(() =>
  import('../pages/lastItems.page').then((module) => ({
    default: module.LastItemsPage,
  }))
);

export const LastItemsRoute = () => {
  return <LazyLoadComponent component={LastItems} />;
};
