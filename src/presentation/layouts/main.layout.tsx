import { Outlet } from 'react-router-dom';
import { HeaderComponent } from '../components/header.component';

export const MainLayout = () => {
  return (
    <div className="h-screen grid grid-rows-[auto_1fr_auto]">
      <HeaderComponent />
      <main className="overflow-y-auto">
        <Outlet />
      </main>
      <footer className="p-4 text-pink-500 text-center">footer</footer>
    </div>
  );
};
