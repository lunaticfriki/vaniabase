import { useEffect } from 'react';
import { Outlet } from 'react-router-dom';
import { HeaderComponent } from '../components/header.component';
import { FooterComponent } from '../components/footer.component';
import { useItemReadService } from '../../app/item.readService';

export const MainLayout = () => {
  const { actions } = useItemReadService();

  useEffect(() => {
    actions.getItems();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

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
