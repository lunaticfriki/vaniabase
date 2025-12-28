import { Menu } from './menu.component';

export function Header() {
  return (
    <header class="bg-[#242424] fixed w-full top-0 z-50 border-b border-white/10 shadow-md">
      <div class="container mx-auto px-4 h-16 flex items-center justify-between">
        <a
          href="/"
          class="text-brand-magenta font-bold text-4xl tracking-tighter hover:text-brand-yellow transition-colors"
        >
          VANIABASE
        </a>

        <Menu />
      </div>
    </header>
  );
}
