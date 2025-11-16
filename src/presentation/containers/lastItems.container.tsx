import { useEffect } from 'react';
import { useItemReadService } from '../../app/item.readService';
import { LastItemsComponent } from '../components/lastItems.component';
import { LastItemsSkeleton } from '../skeletons/lastItems.skeleton';

interface LastItemsContainerProps {
  count?: number;
  showTitle?: boolean;
}

export const LastItemsContainer = ({
  count = 5,
  showTitle = true,
}: LastItemsContainerProps) => {
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
    return <div className="p-6 text-pink-500">Error: {error}</div>;
  }

  const lastItems = items.slice(-count).reverse();

  return <LastItemsComponent items={lastItems} showTitle={showTitle} />;
};
