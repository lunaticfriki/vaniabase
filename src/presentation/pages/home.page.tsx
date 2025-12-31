import { useEffect, useMemo, useState } from 'preact/hooks';

import { useTranslation } from 'react-i18next';

import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/previewCard.component';
import { SkeletonItem } from '../components/skeletonItem.component';
import { SearchIcon } from '../components/pixel-icons';

import { HomeViewModel } from '../viewModels/home.viewModel';

interface Props {
  path?: string;
}

export function Home({ path: _ }: Props) {
  const { t } = useTranslation();
  const [isSearchHovered, setIsSearchHovered] = useState(false);

  const viewModel = useMemo(() => {
    return new HomeViewModel(container.get(ItemStateService));
  }, []);

  const { items, isLoading, recentItems } = viewModel;

  useEffect(() => {
    viewModel.loadItems();
  }, []);

  if (isLoading.value && items.value.length === 0) {
    return (
      <div class="space-y-4">
        <SkeletonItem />
        <SkeletonItem />
        <SkeletonItem />
      </div>
    );
  }

  return (
    <div class="space-y-12 animate-in fade-in duration-500">
      <svg width="0" height="0" class="absolute">
        <defs>
          <linearGradient id="search-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stop-color="#ff00ff" />
            <stop offset="100%" stop-color="#ffff00" />
          </linearGradient>
        </defs>
      </svg>
      <div class="flex justify-between items-end">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('home.latest_items')}
        </h1>
        <div class="flex items-center gap-4">
          <a
            href="/search"
            class="text-white/50 transition-colors no-global-hover"
            aria-label={t('menu.search')}
            title={t('menu.search')}
            onMouseEnter={() => setIsSearchHovered(true)}
            onMouseLeave={() => setIsSearchHovered(false)}
          >
            <SearchIcon size={24} fill={isSearchHovered ? 'url(#search-gradient)' : 'currentColor'} />
          </a>
          <a
            href="/collection"
            class="text-xl md:text-2xl font-bold text-white/50 hover:text-brand-magenta transition-colors"
          >
            {t('menu.collection')}
          </a>
        </div>
      </div>

      <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
        {isLoading.value && items.value.length === 0
          ? Array.from({ length: 5 }).map((_, i) => <SkeletonItem key={i} />)
          : recentItems.value.map(item => <PreviewCard key={item.id.value} item={item} />)}
      </div>

      {!isLoading.value && items.value.length === 0 && (
        <div class="text-center py-20 text-white/40">
          <p>{t('home.no_items')}</p>
        </div>
      )}
    </div>
  );
}
