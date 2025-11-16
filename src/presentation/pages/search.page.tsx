import { BackButtonComponent } from '../components/backButton.component';

export const SearchPage = () => {
  return (
    <div className="min-h-screen">
      <div className="pt-8">
        <BackButtonComponent />
      </div>
      <h1 className="text-4xl text-white text-center py-8">Search</h1>
    </div>
  );
};
