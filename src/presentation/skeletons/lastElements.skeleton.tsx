export const LastElementsSkeleton = () => {
  return (
    <div className="p-6">
      <div className="h-9 bg-pink-500/20 rounded w-48 mb-6 animate-pulse" />
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="flex flex-col items-center animate-pulse">
            <div className="w-full aspect-2/3 bg-pink-500/20 rounded border-2 border-pink-500/30" />
            <div className="mt-3 h-6 bg-pink-500/20 rounded w-3/4" />
          </div>
        ))}
      </div>
    </div>
  );
};
