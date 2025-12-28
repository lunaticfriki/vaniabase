import { useEffect, useMemo } from 'preact/hooks';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { Loading } from '../components/loading.component';
import { PreviewCard } from '../components/previewCard.component';
import { Pagination } from '../components/pagination.component';
import { PaginationViewModel } from '../viewModels/pagination.viewModel';

export function CompletedItems() {
  const itemStateService = container.get(ItemStateService);
  const itemsPerPage = 12;

  const paginationViewModel = useMemo(() => new PaginationViewModel(itemsPerPage), []);

  useEffect(() => {
    if (itemStateService.items.value.length === 0) {
      itemStateService.loadItems();
    }
  }, []);

  const allItems = itemStateService.items.value;
  const isLoading = itemStateService.isLoading.value;

  const completedItems = allItems
    .filter(item => item.completed.value === true)
    .sort((a, b) => b.created.value.getTime() - a.created.value.getTime());

  useEffect(() => {
    paginationViewModel.setTotalItems(completedItems.length);
  }, [completedItems.length]);

  const currentPage = paginationViewModel.currentPage.value;

  const currentItems = completedItems.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);

  if (isLoading) {
    return <Loading />;
  }

  return (
    <div class="space-y-8 animate-in fade-in duration-500">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          COMPLETED ITEMS
        </h1>
        <p class="text-white/60">Items you have finished reading, watching, or playing.</p>
      </div>

      {completedItems.length === 0 ? (
        <div class="text-center py-20 text-white/40">
          <p>No completed items yet.</p>
        </div>
      ) : (
        <>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {currentItems.map(item => (
              <PreviewCard key={item.id.value} item={item} />
            ))}
          </div>

          {paginationViewModel.totalPages.value > 1 && <Pagination pagination={paginationViewModel} />}
        </>
      )}
    </div>
  );
}
