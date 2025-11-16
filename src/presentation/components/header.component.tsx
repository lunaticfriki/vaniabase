import { Link } from 'react-router-dom';
import { MenuComponent } from './menu.component';

export const HeaderComponent = () => {
  return (
    <header className="flex items-center justify-between p-4 text-pink-500">
      <Link to="/" className="text-center hover:text-white transition-opacity">
        <h1 className="text-4xl">VANIABASE</h1>
      </Link>
      <div className="flex-1 flex justify-end">
        <MenuComponent />
      </div>
    </header>
  );
};
