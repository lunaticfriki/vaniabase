import { useEffect, useMemo } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { Loading } from '../components/loading.component';
import { PreviewCard } from '../components/previewCard.component';
import { Pagination } from '../components/pagination.component';
import { PaginationViewModel } from '../viewModels/pagination.viewModel';
import { CompletedItemsViewModel } from '../viewModels/completedItems.viewModel';

export function CompletedItems() {
  const { t } = useTranslation();

  const viewModel = useMemo(() => {
    return new CompletedItemsViewModel(container.get(ItemStateService));
  }, []);

  const paginationViewModel = useMemo(() => new PaginationViewModel(12), []);
  const { allCompletedItems, isLoading, totalItems } = viewModel;

  useEffect(() => {
    paginationViewModel.setTotalItems(totalItems.value);
  }, [totalItems.value]);

  const currentItems = useMemo(() => {
    return allCompletedItems.value.slice(
      (paginationViewModel.currentPage.value - 1) * paginationViewModel.itemsPerPage,
      paginationViewModel.currentPage.value * paginationViewModel.itemsPerPage
    );
  }, [allCompletedItems.value, paginationViewModel.currentPage.value, paginationViewModel.itemsPerPage]);

  if (isLoading.value && totalItems.value === 0) {
    return <Loading />;
  }

  return (
    <div class="space-y-8 animate-in fade-in duration-500">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('completed_items.title')}
        </h1>
        <p class="text-white/60">{t('completed_items.subtitle')}</p>
      </div>

      {totalItems.value === 0 ? (
        <div class="text-center py-20 text-white/40">
          <p>{t('completed_items.no_items')}</p>
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
