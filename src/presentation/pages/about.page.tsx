import { AboutContainer } from '../containers/about.container';
import { BackButtonComponent } from '../components/backButton.component';

export const About = () => {
  return (
    <div className="p-8">
      <BackButtonComponent />
      <h2 className="text-3xl font-bold mb-4">About</h2>
      <AboutContainer />
    </div>
  );
};
