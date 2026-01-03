import { useMemo } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
import type { JSX } from 'preact';
import { container } from '../../infrastructure/di/container';
import { DashboardViewModel } from '../viewModels/dashboard.viewModel';
import { ItemsRepository } from '../../domain/repositories/items.repository';
import { AuthService } from '../../application/auth/auth.service';
import { Link as RouterLink } from 'preact-router/match';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

export function Dashboard() {
  const { t } = useTranslation();
  const viewModel = useMemo(() => {
    return new DashboardViewModel(container.get(ItemsRepository), container.get(AuthService));
  }, []);

  const {
    currentUser,
    isLoading,
    totalItems,
    totalCategories,
    categories,
    totalTags,
    tags,
    totalTopics,
    topics,
    formats
  } = viewModel;

  if (isLoading.value) {
    return (
      <div class="flex items-center justify-center min-h-[50vh]">
        <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-brand-magenta"></div>
      </div>
    );
  }

  const user = currentUser.value;

  if (!user) return null;

  return (
    <div class="space-y-12 animate-in fade-in duration-500">
      <div class="flex flex-col md:flex-row items-center gap-8 border-b border-white/10 pb-12">
        <div class="relative group">
          <div class="absolute -inset-1 bg-linear-to-r from-brand-magenta to-brand-yellow rounded-full opacity-75 group-hover:opacity-100 blur transition duration-500"></div>
          <img
            src={user.avatar}
            alt={user.name}
            class="relative w-32 h-32 rounded-full border-4 border-[#1a1a1a] object-cover"
            style="image-rendering: pixelated;"
          />
        </div>
        <div class="text-center md:text-left space-y-2">
          <h1 class="text-4xl md:text-5xl font-black text-white tracking-tight">
            {t('dashboard.welcome_back')},{' '}
            <span class="text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
              {user.name}
            </span>
          </h1>
          <p class="text-xl text-white/60">{t('dashboard.overview')}</p>
        </div>
      </div>

      <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6">
        <StatCard label={t('dashboard.stats.total_items')} value={totalItems.value} color="text-brand-yellow" />
        <StatCard
          label={t('dashboard.stats.completed')}
          value={viewModel.totalCompleted.value}
          color="text-green-500"
        />
        <StatCard label={t('dashboard.stats.categories')} value={totalCategories.value} color="text-brand-magenta" />
        <StatCard label={t('dashboard.stats.authors')} value={viewModel.totalAuthors.value} color="text-orange-500" />
        <StatCard label={t('dashboard.stats.tags')} value={totalTags.value} color="text-cyan-400" />
        <StatCard label={t('dashboard.stats.topics')} value={totalTopics.value} color="text-purple-400" />
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <ListSection
          title={t('dashboard.sections.categories')}
          items={categories.value}
          linkPrefix="/categories"
          color="border-brand-magenta"
          translationScope="categories.list"
        />
        <ListSection
          title={t('dashboard.sections.topics')}
          items={topics.value}
          linkPrefix="/topics"
          color="border-purple-400"
        />
        <ListSection
          title={t('dashboard.sections.tags')}
          items={tags.value}
          linkPrefix="/tags"
          color="border-cyan-400"
        />
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <ListSection
          title={t('dashboard.sections.formats')}
          items={formats.value}
          linkPrefix="/formats"
          color="border-brand-yellow"
        />
        <ListSection
          title={t('dashboard.sections.authors')}
          items={viewModel.authors.value}
          linkPrefix="/authors"
          color="border-orange-500"
        />
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div class="space-y-4">
          <h2 class="text-xl font-bold text-white border-l-4 border-green-500 pl-4">
            {t('dashboard.sections.recently_completed')}
          </h2>
          <div class="bg-white/5 border border-white/10 rounded-lg max-h-[400px] overflow-y-auto custom-scrollbar relative">
            <div class="sticky top-0 z-10 backdrop-blur-md bg-[#303030]/90 p-4 border-b border-white/10">
              <Link
                href="/completed"
                class="text-green-400 hover:text-green-300 text-sm font-bold uppercase tracking-widest flex items-center gap-2 group no-global-hover"
              >
                {t('dashboard.view_all_completed')}
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="group-hover:translate-x-1 transition-transform"
                >
                  <path d="M5 12h14" />
                  <path d="M12 5l7 7-7 7" />
                </svg>
              </Link>
            </div>
            <div class="p-4 pt-4">
              {viewModel.completedItems.value.length === 0 ? (
                <p class="text-white/30 italic">{t('dashboard.sections.no_completed')}</p>
              ) : (
                <ul class="space-y-2">
                  {viewModel.completedItems.value.map(item => (
                    <li key={item.id.value}>
                      <Link
                        href={`/item/${item.id.value}`}
                        class="text-white/70 hover:text-brand-yellow hover:bg-white/5 px-3 py-2 rounded transition-colors truncate flex justify-between items-center"
                      >
                        <span>{item.title.value}</span>
                      </Link>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div class="bg-white/5 border border-white/10 p-6 rounded-lg hover:bg-white/10 transition-colors group">
      <div class={`text-4xl font-black ${color} mb-2 group-hover:scale-110 transition-transform origin-left`}>
        {value}
      </div>
      <div class="text-sm uppercase tracking-widest text-white/60 font-medium group-hover:text-white transition-colors">
        {label}
      </div>
    </div>
  );
}

function ListSection({
  title,
  items,
  linkPrefix,
  color,
  translationScope
}: {
  title: string;
  items: (string | { name: string; count: number })[];
  linkPrefix: string;
  color: string;
  translationScope?: string;
}) {
  const { t } = useTranslation();
  return (
    <div class={`space-y-4`}>
      <h2 class={`text-xl font-bold text-white border-l-4 ${color} pl-4`}>{title}</h2>
      <div class="bg-white/5 border border-white/10 rounded-lg p-4 max-h-[400px] overflow-y-auto custom-scrollbar">
        {items.length === 0 ? (
          <p class="text-white/30 italic">{t('dashboard.sections.no_found', { title: title.toLowerCase() })}</p>
        ) : (
          <ul class="space-y-2">
            {items.map(item => {
              const name = typeof item === 'string' ? item : item.name;
              const count = typeof item === 'string' ? null : item.count;

              return (
                <li key={name}>
                  <Link
                    href={`${linkPrefix}/${name.toLowerCase()}`}
                    class="text-white/70 hover:text-brand-yellow hover:bg-white/5 px-3 py-2 rounded transition-colors truncate flex justify-between items-center"
                    title={name}
                  >
                    <span>{translationScope ? t(`${translationScope}.${name.toLowerCase()}`, name) : name}</span>
                    {count !== null && (
                      <span class="text-white/30 text-xs bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow font-mono ml-2">
                        [{count}]
                      </span>
                    )}
                  </Link>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </div>
  );
}
