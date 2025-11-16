import { LastItemsContainer } from '../containers/lastItems.container';
import { BackButtonComponent } from '../components/backButton.component';

export const LastItemsPage = () => {
  return (
    <div className="min-h-screen">
      <div className="pt-8">
        <BackButtonComponent />
      </div>
      <h1 className="text-4xl text-white text-center py-8">Last Items</h1>
      <LastItemsContainer count={10} showTitle={false} />
    </div>
  );
};
