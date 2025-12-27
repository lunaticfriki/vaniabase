import { useEffect, useMemo } from 'preact/hooks';
import { computed } from '@preact/signals';
import { Link as RouterLink } from 'preact-router/match';
import type { JSX } from 'preact';

import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/PreviewCard';
import { PaginationViewModel } from '../viewModels/PaginationViewModel';
import { Pagination } from '../components/Pagination';
import { Loading } from '../components/Loading';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

interface Props {
  tagName?: string;
  path?: string;
}

export function Tags({ tagName }: Props) {
  const itemStateService = container.get(ItemStateService);

  const items = itemStateService.items;
  const isItemsLoading = itemStateService.isLoading;

  useEffect(() => {
    itemStateService.loadItems();
  }, []);

  const allTags = computed(() => {
    const tags = new Set<string>();
    items.value.forEach(item => {
      item.tags.value.forEach(tag => tags.add(tag));
    });
    return Array.from(tags).sort();
  });

  const activeTagName = (tagName || allTags.value[0] || '').toLowerCase();

  const pagination = useMemo(() => new PaginationViewModel(12), []);

  const filteredItems = computed(() => {
    if (!items.value.length) return [];
    if (!activeTagName) return items.value;
    return items.value.filter(item => item.tags.value.some(tag => tag.toLowerCase() === activeTagName));
  });

  useEffect(() => {
    pagination.goToPage(1);
  }, [activeTagName]);

  useEffect(() => {
    pagination.setTotalItems(filteredItems.value.length);
  }, [filteredItems.value.length]);

  const currentItems = computed(() => {
    const start = (pagination.currentPage.value - 1) * pagination.itemsPerPage;
    const end = start + pagination.itemsPerPage;
    return filteredItems.value.slice(start, end);
  });

  if (isItemsLoading.value && items.value.length === 0) {
    return <Loading />;
  }

  return (
    <div class="space-y-8">
      <div class="space-y-6">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          TAGS
        </h1>

        <div class="flex flex-wrap gap-4 items-center">
          {allTags.value.map(tag => {
            const isActive = tag.toLowerCase() === activeTagName;
            return (
              <Link
                key={tag}
                href={`/tags/${tag.toLowerCase()}`}
                class={`
                  px-4 py-2 rounded-full text-sm font-bold uppercase tracking-wide transition-all duration-300
                  ${
                    isActive
                      ? 'bg-brand-magenta text-white shadow-lg shadow-brand-magenta/30 scale-105'
                      : 'bg-white/5 text-white/60 hover:bg-white/10 hover:text-white'
                  }
                `}
              >
                #{tag}
              </Link>
            );
          })}
          <span class="text-2xl md:text-3xl font-black text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow ml-2 align-top">
            {filteredItems.value.length}
          </span>
        </div>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {currentItems.value.map(item => (
          <PreviewCard key={item.id.value} item={item} />
        ))}
      </div>

      {filteredItems.value.length === 0 && !isItemsLoading.value && (
        <div class="text-center py-20 text-white/40">
          <p>No items found with this tag.</p>
        </div>
      )}

      {filteredItems.value.length > 0 && <Pagination pagination={pagination} />}
    </div>
  );
}
