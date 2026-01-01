import { useEffect, useMemo } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
import { Link as RouterLink } from 'preact-router/match';
import type { JSX } from 'preact';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { CategoryStateService } from '../../application/category/category.stateService';
import { PreviewCard } from '../components/previewCard.component';
import { PaginationViewModel } from '../viewModels/pagination.viewModel';
import { Pagination } from '../components/pagination.component';
import { Loading } from '../components/loading.component';
import { CategoriesViewModel } from '../viewModels/categories.viewModel';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

interface Props {
  categoryName?: string;
  path?: string;
}

export function Categories({ categoryName }: Props) {
  const { t } = useTranslation();

  const categoryStateService = container.get(CategoryStateService);
  const categories = categoryStateService.categories;

  const viewModel = useMemo(() => {
    return new CategoriesViewModel(container.get(ItemStateService));
  }, []);

  const pagination = useMemo(() => new PaginationViewModel(12), []);
  const { totalItems, paginatedItems, isLoading } = viewModel;

  const activeCategoryName = (categoryName || 'books').toLowerCase();

  useEffect(() => {
    categoryStateService.loadCategories();
  }, []);

  useEffect(() => {
    viewModel.selectCategory(activeCategoryName);
  }, [activeCategoryName]);

  useEffect(() => {
    pagination.setTotalItems(totalItems.value);
  }, [totalItems.value]);

  useEffect(() => {
    viewModel.currentPage.value = pagination.currentPage.value;
  }, [pagination.currentPage.value]);

  viewModel.itemsPerPage = 12;

  if (isLoading.value && totalItems.value === 0) {
    return <Loading />;
  }

  return (
    <div class="space-y-8">
      <div class="space-y-6">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('lists.categories.title')}
        </h1>

        <div class="flex flex-wrap gap-4 items-center">
          {categories.value.map(category => {
            const isActive = category.name.value.toLowerCase() === activeCategoryName;
            return (
              <div key={category.id.value} style="filter: drop-shadow(2px 2px 0px rgba(255, 0, 255, 0.5));">
                <Link
                  href={`/categories/${category.name.value.toLowerCase()}`}
                  class={`
                    block px-6 py-2 text-sm font-bold uppercase tracking-wide transition-all duration-300
                    ${
                      isActive
                        ? 'bg-brand-magenta text-white scale-105 hover:bg-none! hover:bg-clip-border! hover:text-white!'
                        : 'bg-zinc-800 text-white/60 hover:bg-brand-magenta! hover:text-white! hover:scale-105! hover:bg-none! hover:bg-clip-border!'
                    }
                  `}
                  style="clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px);"
                >
                  {t(`categories.list.${category.name.value.toLowerCase()}`, category.name.value)}
                </Link>
              </div>
            );
          })}
          <span class="text-2xl md:text-3xl font-black text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow ml-2 relative -top-2">
            [{totalItems.value}]
          </span>
        </div>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {paginatedItems.value.map(item => (
          <PreviewCard key={item.id.value} item={item} />
        ))}
      </div>

      {totalItems.value === 0 && !isLoading.value && (
        <div class="text-center py-20 text-white/40">
          <p>{t('lists.categories.no_items')}</p>
        </div>
      )}

      {totalItems.value > 0 && <Pagination pagination={pagination} />}
    </div>
  );
}
