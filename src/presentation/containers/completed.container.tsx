import { useEffect } from 'react';
import { useItemReadService } from '../../app/item.readService';
import { ErrorComponent } from '../components/error.component';
import type { Item } from '../../domain/item';
import { PreviewItemComponent } from '../components/previewItem.component';
import { CompletedSkeleton } from '../skeletons/completed.skeleton';

export const CompletedContainer = () => {
  const itemReadService = useItemReadService();
  const loading = itemReadService.state.value.loading;
  const error = itemReadService.state.value.error;

  useEffect(() => {
    itemReadService.actions.getItems();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (loading) {
    return <CompletedSkeleton />;
  }

  if (error) {
    return <ErrorComponent error={error} />;
  }

  const completedItems = itemReadService.actions.getCompletedItems();

  return (
    <div className="p-6">
      <div className="text-center mb-4">
        <p className="text-white text-lg">
          Total: <span className="text-pink-500">{completedItems.length}</span>
        </p>
      </div>
      {completedItems.length === 0 ? (
        <div className="text-center text-white text-xl mt-10">
          No completed items yet
        </div>
      ) : (
        <div className="flex flex-wrap justify-center gap-4 md:gap-6">
          {completedItems.map((item: Item) => (
            <PreviewItemComponent key={item.id} item={item} />
          ))}
        </div>
      )}
    </div>
  );
};
