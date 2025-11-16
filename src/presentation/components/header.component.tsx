import { MenuComponent } from './menu.component';

export const HeaderComponent = () => {
  return (
    <header className="flex items-center justify-between p-4 text-pink-500">
      <div className="flex-1"></div>
      <h1 className="text-4xl flex-1 text-center">VANIABASE</h1>
      <div className="flex-1 flex justify-end">
        <MenuComponent />
      </div>
    </header>
  );
};
