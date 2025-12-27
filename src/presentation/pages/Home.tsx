import { useEffect } from 'preact/hooks';

import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { PreviewCard } from '../components/PreviewCard';

export function Home() {
  const itemStateService = container.get(ItemStateService);
  const items = itemStateService.items; // Get the signal itself
  
  useEffect(() => {
    itemStateService.loadItems();
  }, []);

  return (
    <div class="space-y-8">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-6xl font-black tracking-tighter text-transparent bg-clip-text bg-gradient-to-r from-brand-magenta to-brand-yellow">
          LATEST RELEASES
        </h1>
        <p class="text-lg text-white/60 max-w-2xl">
          Explore our curated collection of digital assets, books, and resources.
        </p>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {items.value.map((item) => (
          <PreviewCard key={item.id.value} item={item} />
        ))}
      </div>
      
      {items.value.length === 0 && (
        <div class="text-center py-20 text-white/40">
          <p>No items found. (Check console for errors)</p>
          {/* Debug info */}
          <div class="hidden">{(() => { console.log('Home rendered. Items:', items.value); return null; })()}</div>
        </div>
      )}
    </div>
  );
}
