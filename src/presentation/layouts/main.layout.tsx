import { Outlet } from 'react-router-dom';
import { HeaderComponent } from '../components/header.component';

export const MainLayout = () => {
  return (
    <div className="min-h-screen flex flex-col">
      <HeaderComponent />
      <main className="flex-1">
        <Outlet />
      </main>
    </div>
  );
};
