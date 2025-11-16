import { useState, useEffect } from 'react';
import { AboutSkeleton } from '../skeletons/about.skeleton';

export const AboutContainer = () => {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Simulate a brief loading state
    const timer = setTimeout(() => {
      setLoading(false);
    }, 300);

    return () => clearTimeout(timer);
  }, []);

  if (loading) {
    return <AboutSkeleton />;
  }

  return (
    <>
      <p className="text-lg">Welcome to Vaniabase</p>
      <p>Version: 1.0.0</p>
      <p>
        by @lunaticfriki,
        <span className="text-pink-500"> {new Date().getFullYear()}</span>
      </p>
    </>
  );
};
