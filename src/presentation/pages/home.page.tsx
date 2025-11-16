import { HomeContainer } from '../containers/home.container';
import { LastItemsContainer } from '../containers/lastItems.container';

export const Home = () => {
  return (
    <div>
      <LastItemsContainer />
      <div className="p-8">
        <HomeContainer />
      </div>
    </div>
  );
};
