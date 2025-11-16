import { useEffect } from 'react';
import { useItemReadService } from '../../app/item.readService';
import { LastItemsComponent } from '../components/lastItems.component';
import { LastItemsSkeleton } from '../skeletons/lastItems.skeleton';
import { ErrorComponent } from '../components/error.component';

export const AllItemsContainer = () => {
  const itemReadService = useItemReadService();
  const items = itemReadService.state.value.items;
  const loading = itemReadService.state.value.loading;
  const error = itemReadService.state.value.error;

  useEffect(() => {
    itemReadService.actions.getItems();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (loading) {
    return <LastItemsSkeleton />;
  }

  if (error) {
    return <ErrorComponent error={error} />;
  }

  return <LastItemsComponent items={items} showTitle={false} />;
};
