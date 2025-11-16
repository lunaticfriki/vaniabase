import { BackButtonComponent } from '../components/backButton.component';
import { CompletedContainer } from '../containers/completed.container';

export const CompletedPage = () => {
  return (
    <div className="min-h-screen">
      <div className="pt-8">
        <BackButtonComponent />
      </div>
      <h1 className="text-4xl text-white text-center py-8">Completed Items</h1>
      <CompletedContainer />
    </div>
  );
};
