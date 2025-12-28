interface Props {
  path?: string;
}

export function About({ path: _ }: Props) {
  return (
    <div class="max-w-3xl mx-auto space-y-6">
      <h1 class="text-4xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
        ABOUT VANIABASE
      </h1>
      <div class="prose prose-invert prose-lg">
        <p class="text-white/80 leading-relaxed">
          Version: <span class="font-bold bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">1.0.0</span>
        </p>
        <p class="text-white/80 leading-relaxed">
          Copyright:{' '}
          <span class="font-bold bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
            {new Date().getFullYear()}
          </span>
        </p>
        <p class="text-white/80 leading-relaxed">
          Author:{' '}
          <a href="https://www.github.com/lunaticfriki" target="_blank" rel="noopener noreferrer">
            @lunaticfriki
          </a>
        </p>
      </div>
    </div>
  );
}
