import { useState, useEffect } from 'preact/hooks';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/previewCard.component';
import { Loading } from '../components/loading.component';

export function Search() {
  const itemStateService = container.get(ItemStateService);
  const { searchResults, isLoading } = itemStateService;
  const [query, setQuery] = useState('');
  const [debouncedQuery, setDebouncedQuery] = useState('');

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedQuery(query);
    }, 500);

    return () => clearTimeout(timer);
  }, [query]);

  useEffect(() => {
    if (debouncedQuery.trim()) {
      itemStateService.searchItems(debouncedQuery);
    } else {
      itemStateService.searchResults.value = [];
    }
  }, [debouncedQuery]);

  const handleSearchImmediate = () => {
    if (query.trim()) {
      itemStateService.searchItems(query);
    }
  };

  return (
    <div class="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
      <div class="space-y-2 text-center">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          SEARCH ITEMS
        </h1>
        <p class="text-white/60">Find items by title, author, description, or tags.</p>
      </div>

      <div class="max-w-2xl mx-auto flex gap-4">
        <input
          type="text"
          value={query}
          onInput={e => setQuery((e.target as HTMLInputElement).value)}
          placeholder="Search for anything..."
          class="flex-1 bg-zinc-900 border border-white/10 rounded-sm p-4 text-lg text-white placeholder-white/30 focus:border-brand-magenta focus:outline-none transition-colors"
        />
        <button
          onClick={handleSearchImmediate}
          class="px-8 bg-brand-magenta text-white font-bold uppercase tracking-widest rounded-sm hover:bg-brand-magenta/80 transition-all hover:scale-[1.02] active:scale-[0.98] shadow-lg shadow-brand-magenta/20"
        >
          Search
        </button>
      </div>

      <div class="pt-8 space-y-4">
        {isLoading.value ? (
          <div class="flex justify-center py-12">
            <Loading />
          </div>
        ) : (
          <>
            {searchResults.value.length > 0 && (
              <div class="text-center text-white/40 uppercase tracking-widest text-md mb-6">
                Found <span class="font-bold text-brand-magenta">{searchResults.value.length}</span> result
                {searchResults.value.length !== 1 ? 's' : ''}
              </div>
            )}

            {searchResults.value.length > 0 ? (
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {searchResults.value.map(item => (
                  <PreviewCard key={item.id.value} item={item} />
                ))}
              </div>
            ) : (
              query &&
              !isLoading.value && (
                <div class="text-center py-12 text-white/30">
                  <p class="text-xl">No items found matching "{query}"</p>
                  <p class="text-sm mt-2">Try different keywords or check spelling.</p>
                </div>
              )
            )}
          </>
        )}
      </div>
    </div>
  );
}
