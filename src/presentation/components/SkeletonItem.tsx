export function SkeletonItem() {
  return (
    <div class="block relative bg-zinc-900 rounded-sm overflow-hidden animate-pulse">
      <div class="aspect-2/3 bg-zinc-800" />

      <div class="p-4 space-y-3">
        <div class="h-3 w-1/3 bg-zinc-800 rounded-sm" />

        <div class="h-6 w-3/4 bg-zinc-800 rounded-sm" />

        <div class="flex items-center justify-between pt-2 border-t border-white/5">
          <div class="h-3 w-1/2 bg-zinc-800 rounded-sm" />
        </div>
      </div>
    </div>
  );
}
