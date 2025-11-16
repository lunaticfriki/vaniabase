import { Skeleton } from '@mui/material';

export const AboutSkeleton = () => {
  return (
    <div className="space-y-4">
      <Skeleton
        variant="text"
        width="80%"
        sx={{
          bgcolor: 'rgba(255, 255, 255, 0.05)',
          fontSize: '1.125rem',
        }}
      />
      <Skeleton
        variant="text"
        width="40%"
        sx={{
          bgcolor: 'rgba(255, 255, 255, 0.05)',
          fontSize: '1rem',
        }}
      />
      <Skeleton
        variant="text"
        width="50%"
        sx={{
          bgcolor: 'rgba(255, 255, 255, 0.05)',
          fontSize: '1rem',
        }}
      />
    </div>
  );
};
