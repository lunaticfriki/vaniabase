import { useEffect, useMemo } from 'preact/hooks';
import { useTranslation, Trans } from 'react-i18next';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/previewCard.component';
import { Loading } from '../components/loading.component';
import { SearchViewModel } from '../viewModels/search.viewModel';

export function Search() {
  const { t } = useTranslation();

  const viewModel = useMemo(() => {
    return new SearchViewModel(container.get(ItemStateService));
  }, []);

  const { items, loading, query } = viewModel;

  useEffect(() => {
    const timer = setTimeout(() => {
      void viewModel.search(query.value);
    }, 500);

    return () => clearTimeout(timer);
  }, [query.value]);

  const handleSearchImmediate = () => {
    void viewModel.search(query.value);
  };

  return (
    <div class="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
      <div class="space-y-2 text-center">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('search.title')}
        </h1>
        <p class="text-white/60">{t('search.subtitle')}</p>
      </div>

      <div class="max-w-2xl mx-auto flex gap-4">
        <input
          type="text"
          value={query.value}
          onInput={e => (query.value = (e.target as HTMLInputElement).value)}
          placeholder={t('search.placeholder')}
          class="flex-1 bg-zinc-900 border border-white/10 rounded-sm p-4 text-lg text-white placeholder-white/30 focus:border-brand-magenta focus:outline-none transition-colors"
        />
        <button
          onClick={handleSearchImmediate}
          class="px-8 bg-brand-magenta text-white font-bold uppercase tracking-widest rounded-sm hover:bg-brand-magenta/80 transition-all hover:scale-[1.02] active:scale-[0.98] shadow-lg shadow-brand-magenta/20"
        >
          {t('search.button')}
        </button>
      </div>

      <div class="pt-8 space-y-4">
        {loading.value ? (
          <div class="flex justify-center py-12">
            <Loading />
          </div>
        ) : (
          <>
            {items.value.length > 0 && (
              <div class="text-center text-white/40 uppercase tracking-widest text-md mb-6">
                <Trans
                  i18nKey={items.value.length === 1 ? 'search.found_results' : 'search.found_results_plural'}
                  count={items.value.length}
                >
                  Found <span class="font-bold text-brand-magenta">{{ count: items.value.length }}</span> result
                </Trans>
              </div>
            )}

            {items.value.length > 0 ? (
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {items.value.map(item => (
                  <PreviewCard key={item.id.value} item={item} />
                ))}
              </div>
            ) : (
              query.value &&
              !loading.value && (
                <div class="text-center py-12 text-white/30">
                  <p class="text-xl">{t('search.no_results', { query: query.value })}</p>
                  <p class="text-sm mt-2">{t('search.suggestion')}</p>
                </div>
              )
            )}
          </>
        )}
      </div>
    </div>
  );
}
