import { Outlet } from 'react-router-dom';
import { HeaderComponent } from '../components/header.component';
import { FooterComponent } from '../components/footer.component';

export const MainLayout = () => {
  return (
    <div className="h-screen grid grid-rows-[auto_1fr_auto]">
      <HeaderComponent />
      <main className="overflow-y-auto">
        <Outlet />
      </main>
      <FooterComponent />
    </div>
  );
};
