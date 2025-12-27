import { useEffect, useState } from 'preact/hooks';

export function Loading() {
  const [text, setText] = useState('');
  const fullText = 'LOADING...';

  useEffect(() => {
    let index = 0;
    const interval = setInterval(() => {
      setText(fullText.slice(0, index + 1));
      index++;
      if (index > fullText.length) {
        index = 0;
      }
    }, 300);

    return () => clearInterval(interval);
  }, []);

  return (
    <div class="flex items-center justify-center min-h-[50vh] w-full">
      <div class="font-mono text-2xl md:text-3xl text-brand-magenta tracking-widest font-bold">
        {text}
        <span class="animate-pulse">_</span>
      </div>
    </div>
  );
}
