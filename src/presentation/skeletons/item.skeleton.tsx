export const ItemSkeleton = () => {
  return (
    <div className="max-w-2xl mx-auto p-6 animate-pulse">
      {/* Image skeleton */}
      <div className="w-full max-w-md mx-auto aspect-2/3 bg-pink-500/20 rounded border-2 border-pink-500/30 mb-6" />

      {/* Title skeleton */}
      <div className="h-10 bg-pink-500/20 rounded w-3/4 mb-2" />

      {/* Author skeleton */}
      <div className="h-8 bg-pink-500/20 rounded w-1/2 mb-6" />

      {/* Info items skeleton */}
      <div className="space-y-3">
        {[...Array(8)].map((_, i) => (
          <div key={i} className="flex gap-2">
            <div className="h-6 bg-pink-500/20 rounded w-24" />
            <div className="h-6 bg-pink-500/20 rounded flex-1" />
          </div>
        ))}
      </div>
    </div>
  );
};
