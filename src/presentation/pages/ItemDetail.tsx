import { useEffect, useState } from 'preact/hooks';
import { Link as RouterLink } from 'preact-router/match';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { Item } from '../../domain/model/entities/Item';
import { Loading } from '../components/Loading';
import type { JSX } from 'preact';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

interface Props {
  id?: string;
  path?: string;
}

export function ItemDetail({ id }: Props) {
  const [item, setItem] = useState<Item | null>(null);
  const [loading, setLoading] = useState(true);
  const itemStateService = container.get(ItemStateService);

  useEffect(() => {
    if (!id) return;

    const loadItem = async () => {
      setLoading(true);
      const foundItem = await itemStateService.getItem(id);
      if (foundItem) {
        setItem(foundItem);
      } else {
        console.error('Item not found');
      }
      setLoading(false);
    };

    loadItem();
  }, [id]);

  const handleBack = () => {
    history.go(-1);
  };

  if (loading) {
    return <Loading />;
  }

  if (!item) {
    return (
      <div class="flex flex-col items-center justify-center min-h-[50vh] space-y-4">
        <h2 class="text-2xl text-white/50">Item not found</h2>
        <button
          onClick={handleBack}
          class="px-6 py-2 bg-brand-violet text-white rounded hover:bg-brand-violet/80 transition-colors"
        >
          Back
        </button>
      </div>
    );
  }

  return (
    <div class="space-y-8 animate-in fade-in duration-500">
      <div>
        <button
          onClick={handleBack}
          class="flex items-center gap-2 text-white/60 hover:text-brand-magenta transition-colors group"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="group-hover:-translate-x-1 transition-transform"
          >
            <path d="M19 12H5" />
            <path d="M12 19l-7-7 7-7" />
          </svg>
          Back
        </button>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-8 lg:gap-12">
        <div class="space-y-6">
          <div class="aspect-2/3 rounded-sm overflow-hidden bg-zinc-900 border border-brand-violet/30 shadow-[0_0_50px_rgba(46,0,79,0.3)]">
            <img src={item.cover.value} alt={`Cover for ${item.title.value}`} class="w-full h-full object-cover" />
          </div>
        </div>

        <div class="space-y-8">
          <div class="space-y-4">
            <div class="inline-block px-3 py-1 rounded-full text-xs font-bold tracking-widest uppercase bg-brand-violet/20 text-brand-magenta border border-brand-violet/30">
              <Link href={`/categories/${item.category.name.value.toLowerCase()}`}>{item.category.name.value}</Link>
            </div>

            <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-white leading-tight">
              {item.title.value}
            </h1>

            <div class="text-xl text-white/60">
              by <span class="text-white">{item.author.value}</span>
            </div>
          </div>

          <div class="prose prose-invert prose-lg text-white/80">
            <p>{item.description.value}</p>
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-8 border-t border-white/10">
            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">Year</div>
              <div class="text-lg font-medium">{item.year.value}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">Publisher</div>
              <div class="text-lg font-medium">{item.publisher.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">Language</div>
              <div class="text-lg font-medium">{item.language.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">Format</div>
              <div class="text-lg font-medium">{item.format.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">Owner</div>
              <div class="text-lg font-medium">{item.owner.value || '-'}</div>
            </div>

            <div>
              <div class="text-xs text-white/40 uppercase tracking-widest mb-1">Topic</div>
              <div class="text-lg font-medium">{item.topic.value || '-'}</div>
            </div>
          </div>

          {item.tags.value.length > 0 ? (
            <div class="pt-6">
              <div class="text-xs text-white/40 uppercase tracking-widest mb-3">Tags</div>
              <div class="flex flex-wrap gap-2">
                {item.tags.value.map(tag => (
                  <Link
                    key={tag}
                    href={`/tags/${tag.toLowerCase()}`}
                    class="px-3 py-1 bg-white/5 rounded text-sm text-white/70 hover:bg-white/10 hover:text-white transition-colors"
                  >
                    #{tag}
                  </Link>
                ))}
              </div>
            </div>
          ) : (
            <div class="pt-6">
              <div class="text-xs text-white/40 uppercase tracking-widest mb-3">Tags</div>
              <div class="flex flex-wrap gap-2">
                <span class="px-3 py-1 bg-white/5 rounded text-sm text-white/70">No tags</span>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
