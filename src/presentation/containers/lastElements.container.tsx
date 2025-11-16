import { useEffect } from 'react';
import { useItemReadService } from '../../app/item.readService';
import { LastElementsComponent } from '../components/lastElements.component';
import { LastElementsSkeleton } from '../skeletons/lastElements.skeleton';

export const LastElementsContainer = () => {
  const itemReadService = useItemReadService();
  const items = itemReadService.state.value.items;
  const loading = itemReadService.state.value.loading;
  const error = itemReadService.state.value.error;

  useEffect(() => {
    itemReadService.actions.getItems();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (loading) {
    return <LastElementsSkeleton />;
  }

  if (error) {
    return <div className="p-6 text-pink-500">Error: {error}</div>;
  }

  const lastFiveItems = items.slice(-5).reverse();

  return <LastElementsComponent items={lastFiveItems} />;
};
