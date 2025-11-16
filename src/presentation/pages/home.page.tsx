import { HomeContainer } from '../containers/home.container';
import { LastElementsContainer } from '../containers/lastElements.container';

export const Home = () => {
  return (
    <div>
      <LastElementsContainer />
      <div className="p-8">
        <HomeContainer />
      </div>
    </div>
  );
};
