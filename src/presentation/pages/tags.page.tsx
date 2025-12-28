import { useEffect, useMemo, useRef } from 'preact/hooks';
import { Link as RouterLink } from 'preact-router/match';
import type { JSX } from 'preact';

import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/previewCard.component';
import { Pagination } from '../components/pagination.component';
import { Loading } from '../components/loading.component';
import { TagsViewModel } from '../viewModels/tags.viewModel';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

interface Props {
  tagName?: string;
  path?: string;
}

export function Tags({ tagName }: Props) {
  const itemsRef = useRef<HTMLDivElement>(null);
  const viewModel = useMemo(() => {
    return new TagsViewModel(container.get(ItemStateService));
  }, []);

  useEffect(() => {
    viewModel.loadItems();
  }, []);

  useEffect(() => {
    viewModel.setTag(tagName);

    if (tagName && window.innerWidth < 1024 && itemsRef.current) {
      itemsRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }, [tagName]);

  if (viewModel.isLoading.value && viewModel.items.value.length === 0) {
    return <Loading />;
  }

  const tagData = viewModel.tagData.value;
  const filteredItemsCount = viewModel.filteredItems.value.length;
  const activeTagName = viewModel.activeTagName.value;

  return (
    <div class="space-y-8">
      <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
        TAGS
      </h1>

      <div class="grid grid-cols-1 lg:grid-cols-4 gap-8 items-start">
        <div class="lg:col-span-1 border-2 border-brand-magenta p-6 min-h-[500px]">
          <div class="flex flex-wrap items-baseline gap-x-4 gap-y-2 content-start">
            {tagData.tags.map(tag => {
              const count = tagData.counts[tag];
              const isActive = tag.toLowerCase() === activeTagName;
              const fontSizeClass = viewModel.getFontSizeClass(count);

              return (
                <Link
                  key={tag}
                  href={`/tags/${tag.toLowerCase()}`}
                  class={`
                    leading-none transition-all duration-300 rounded px-1
                    ${fontSizeClass}
                    ${
                      isActive
                        ? 'text-white/70  bg-brand-magenta/50 hover:text-white/70'
                        : 'text-white/70 hover:text-white hover:bg-brand-magenta/50'
                    }
                  `}
                  title={`${count} items`}
                >
                  {tag}
                </Link>
              );
            })}
          </div>
        </div>

        <div class="lg:col-span-3 space-y-6" ref={itemsRef}>
          <div class="flex items-center justify-between">
            <h2 class="text-2xl font-bold text-white">
              {activeTagName ? `#${activeTagName.toUpperCase()}` : 'ALL ITEMS'}
            </h2>
            <span class="text-2xl md:text-3xl font-black text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow ml-2 relative -top-2">
              [{filteredItemsCount}]
            </span>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {viewModel.currentItems.value.map(item => (
              <PreviewCard key={item.id.value} item={item} />
            ))}
          </div>

          {filteredItemsCount === 0 && !viewModel.isLoading.value && (
            <div class="text-center py-20 text-white/40 border border-white/10 rounded-lg">
              <p>No items found.</p>
            </div>
          )}

          {filteredItemsCount > 0 && <Pagination pagination={viewModel.pagination} />}
        </div>
      </div>
    </div>
  );
}
