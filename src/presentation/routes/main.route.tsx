import { Routes, Route } from 'react-router-dom';
import { MainLayout } from '../layouts/main.layout';
import { HomeRoute } from './home.route';
import { AboutRoute } from './about.route';
import { ItemRoute } from './item.route';

export const MainRoutes = () => {
  return (
    <Routes>
      <Route path="/" element={<MainLayout />}>
        <Route index element={<HomeRoute />} />
        <Route path="about" element={<AboutRoute />} />
        <Route path="item/:id" element={<ItemRoute />} />
      </Route>
    </Routes>
  );
};
