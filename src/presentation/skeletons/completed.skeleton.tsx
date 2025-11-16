export const CompletedSkeleton = () => {
  return (
    <div className="p-6">
      <div className="h-9 bg-pink-500/20 rounded w-48 mb-6 animate-pulse mx-auto" />
      <div className="flex flex-wrap justify-center gap-4 md:gap-6">
        {[...Array(8)].map((_, i) => (
          <div key={i} className="flex flex-col items-center animate-pulse">
            <div className="w-48 aspect-2/3 bg-pink-500/20 rounded border-2 border-pink-500/30" />
            <div className="mt-3 h-6 bg-pink-500/20 rounded w-3/4" />
          </div>
        ))}
      </div>
    </div>
  );
};
