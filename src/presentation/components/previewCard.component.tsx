import { Item } from '../../domain/model/entities/item.entity';

interface PreviewCardProps {
  item: Item;
}

export function PreviewCard({ item }: PreviewCardProps) {
  return (
    <a href={`/item/${item.id.value}`} class="block group relative transition-all duration-300 hover:animate-pulse">
      <div
        class="bg-zinc-900 h-full w-full"
        style="clip-path: polygon(20px 0, 100% 0, 100% calc(100% - 20px), calc(100% - 20px) 100%, 0 100%, 0 20px);"
      >
        <div style="filter: drop-shadow(4px 4px 0px rgba(255, 0, 255, 0.5));">
          <div
            class="aspect-2/3 overflow-hidden bg-black/20 relative"
            style="clip-path: polygon(20px 0, 100% 0, 100% calc(100% - 20px), calc(100% - 20px) 100%, 0 100%, 0 20px);"
          >
            <img
              src={item.cover.value}
              alt={`Cover for ${item.title.value}`}
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
              loading="lazy"
            />
            <div class="absolute inset-0 bg-linear-to-t from-black/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
          </div>
        </div>

        <div class="p-4 space-y-3">
          <div class="text-xs font-bold text-brand-magenta tracking-widest uppercase">{item.category.name.value}</div>

          <h3 class="text-xl font-bold leading-tight text-white group-hover:text-brand-yellow transition-colors">
            {item.title.value}
          </h3>

          <div class="flex items-center justify-between text-white/60 pt-2 border-t border-white/10">
            <span>By {item.author.value}</span>
          </div>
        </div>
      </div>
    </a>
  );
}
