import { useEffect } from 'preact/hooks';
import { computed } from '@preact/signals';
import { useTranslation } from 'react-i18next';

import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/previewCard.component';
import { SkeletonItem } from '../components/skeletonItem.component';

interface Props {
  path?: string;
}

export function Home({ path: _ }: Props) {
  const { t } = useTranslation();
  const itemStateService = container.get(ItemStateService);
  const items = itemStateService.items;
  const isLoading = itemStateService.isLoading;

  const recentItems = computed(() => {
    return items.value.slice(-5).reverse();
  });

  useEffect(() => {
    itemStateService.loadItems();
  }, []);

  return (
    <div class="space-y-8">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('home.latest_items')}
        </h1>
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
