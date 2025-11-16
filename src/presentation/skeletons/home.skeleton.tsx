import { Skeleton } from '@mui/material';

export const HomeSkeleton = () => {
  return (
    <div className="space-y-4">
      {[...Array(5)].map((_, index) => (
        <div key={index} className="space-y-2">
          <Skeleton
            variant="rectangular"
            width="100%"
            height={120}
            sx={{
              bgcolor: 'rgba(255, 255, 255, 0.05)',
              borderRadius: 1,
            }}
          />
          <Skeleton
            variant="text"
            width="60%"
            sx={{
              bgcolor: 'rgba(255, 255, 255, 0.05)',
              fontSize: '1rem',
            }}
          />
          <Skeleton
            variant="text"
            width="40%"
            sx={{
              bgcolor: 'rgba(255, 255, 255, 0.05)',
              fontSize: '0.875rem',
            }}
          />
        </div>
      ))}
    </div>
  );
};
