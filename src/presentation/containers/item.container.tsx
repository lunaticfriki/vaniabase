import { useEffect } from 'react';
import { useParams, Navigate } from 'react-router-dom';
import { useItemReadService } from '../../app/item.readService';
import { ItemComponent } from '../components/item.component';
import { ItemSkeleton } from '../skeletons/item.skeleton';

export const ItemContainer = () => {
  const { id } = useParams<{ id: string }>();
  const itemReadService = useItemReadService();
  const items = itemReadService.state.value.items;
  const loading = itemReadService.state.value.loading;
  const error = itemReadService.state.value.error;

  const item = items.find((i) => i.id === id);

  useEffect(() => {
    if (id) {
      itemReadService.actions.getItem(id);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  if (loading || (!item && !error)) {
    return <ItemSkeleton />;
  }

  if (error) {
    return <div className="p-6 text-pink-500">Error: {error}</div>;
  }

  if (!item) {
    return <Navigate to="/" replace />;
  }

  return <ItemComponent item={item} />;
};
