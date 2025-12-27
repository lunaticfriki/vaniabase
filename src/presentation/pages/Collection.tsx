import { useEffect, useMemo } from 'preact/hooks';
import { computed } from '@preact/signals';

import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/PreviewCard';
import { Pagination as PaginationDomain } from '../../domain/Pagination';
import { Pagination } from '../components/Pagination';
import { Loading } from '../components/Loading';

interface Props {
  path?: string;
}

export function Collection({ path: _ }: Props) {
  const itemStateService = container.get(ItemStateService);
  const items = itemStateService.items;
  const isLoading = itemStateService.isLoading;

  const pagination = useMemo(() => new PaginationDomain(12), []);

  useEffect(() => {
    itemStateService.loadItems();
  }, []);

  useEffect(() => {
    pagination.setTotalItems(items.value.length);
  }, [items.value.length]);

  const currentItems = computed(() => {
    const start = (pagination.currentPage.value - 1) * pagination.itemsPerPage;
    const end = start + pagination.itemsPerPage;
    return items.value.slice(start, end);
  });

  if (isLoading.value && items.value.length === 0) {
    return <Loading />;
  }

  return (
    <div class="space-y-8">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          TIMELINE COLLECTION{' '}
          <span class="text-2xl md:text-3xl text-white/30 ml-2 align-top">{items.value.length}</span>
        </h1>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {currentItems.value.map(item => (
          <PreviewCard key={item.id.value} item={item} />
        ))}
      </div>

      {items.value.length === 0 && (
        <div class="text-center py-20 text-white/40">
          <p>No items found.</p>
        </div>
      )}

      {items.value.length > 0 && <Pagination pagination={pagination} />}
    </div>
  );
}
