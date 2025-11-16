import { Routes, Route } from 'react-router-dom';
import { MainLayout } from '../layouts/main.layout';
import { HomeRoute } from './home.route';
import { AboutRoute } from './about.route';
import { ItemRoute } from './item.route';
import { AllItemsRoute } from './allItems.route';
import { LastItemsRoute } from './lastItems.route';
import { SearchRoute } from './search.route';
import { CategoriesRoute } from './categories.route';

export const MainRoutes = () => {
  return (
    <Routes>
      <Route path="/" element={<MainLayout />}>
        <Route index element={<HomeRoute />} />
        <Route path="about" element={<AboutRoute />} />
        <Route path="item/:id" element={<ItemRoute />} />
        <Route path="all-items" element={<AllItemsRoute />} />
        <Route path="last-items" element={<LastItemsRoute />} />
        <Route path="search" element={<SearchRoute />} />
        <Route path="categories" element={<CategoriesRoute />} />
        <Route path="categories/:category" element={<CategoriesRoute />} />
      </Route>
    </Routes>
  );
};
