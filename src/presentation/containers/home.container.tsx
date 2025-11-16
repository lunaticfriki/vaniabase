import { useEffect } from 'react';
import { useItemReadService } from '../../app/item.readService';
import { HomeSkeleton } from '../skeletons/home.skeleton';
import { ContentComponent } from '../components/content.component';

export const HomeContainer = () => {
  const { state, actions } = useItemReadService();

  useEffect(() => {
    actions.getItems();

    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (state.value.loading) {
    return <HomeSkeleton />;
  }

  return (
    <>
      <ContentComponent />
    </>
  );
};
