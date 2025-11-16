import { BackButtonComponent } from '../components/backButton.component';

export const CategoriesPage = () => {
  return (
    <div className="min-h-screen">
      <div className="pt-8">
        <BackButtonComponent />
      </div>
      <h1 className="text-4xl text-white text-center py-8">Categories</h1>
    </div>
  );
};
