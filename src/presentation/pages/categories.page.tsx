import { BackButtonComponent } from '../components/backButton.component';
import { CategoriesContainer } from '../containers/categories.container';

export const CategoriesPage = () => {
  return (
    <div className="min-h-screen">
      <div className="pt-8">
        <BackButtonComponent />
      </div>
      <CategoriesContainer />
    </div>
  );
};
