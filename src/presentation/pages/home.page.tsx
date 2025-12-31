import { useEffect, useMemo } from 'preact/hooks';

import { useTranslation } from 'react-i18next';

import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/previewCard.component';
import { SkeletonItem } from '../components/skeletonItem.component';

import { HomeViewModel } from '../viewModels/home.viewModel';

interface Props {
  path?: string;
}

export function Home({ path: _ }: Props) {
  const { t } = useTranslation();
  const viewModel = useMemo(() => {
    const service = container.get(ItemStateService);
    return new HomeViewModel(service);
  }, []);

  const items = viewModel.items;
  const isLoading = viewModel.isLoading;
  const recentItems = viewModel.recentItems;

  useEffect(() => {
    viewModel.loadItems();
  }, []);

  return (
    <div class="space-y-8">
      <div class="flex justify-between items-end">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('home.latest_items')}
        </h1>
        <a
          href="/collection"
          class="text-xl md:text-2xl font-bold text-white/50 hover:text-brand-magenta transition-colors"
        >
          {t('menu.collection')}
        </a>
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
