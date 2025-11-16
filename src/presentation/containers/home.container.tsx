import { useItemReadService } from '../../app/item.readService';
import { HomeSkeleton } from '../skeletons/home.skeleton';
import { ContentComponent } from '../components/content.component';

export const HomeContainer = () => {
  const { state } = useItemReadService();

  if (state.value.loading) {
    return <HomeSkeleton />;
  }

  return (
    <>
      <ContentComponent />
    </>
  );
};
