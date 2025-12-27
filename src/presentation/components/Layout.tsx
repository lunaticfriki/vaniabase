import type { ComponentChildren } from 'preact';
import { Menu } from './Menu';

interface LayoutProps {
  children: ComponentChildren;
}

export function Layout({ children }: LayoutProps) {
  return (
    <div class="min-h-screen bg-[#242424] text-white font-sans flex flex-col">
      <header class="bg-[#242424] fixed w-full top-0 z-50 border-b border-white/10 shadow-md">
        <div class="container mx-auto px-4 h-16 flex items-center justify-between">
          <a
            href="/"
            class="text-brand-magenta font-bold text-2xl tracking-tighter hover:text-brand-yellow transition-colors"
          >
            VANIABASE
          </a>

          <Menu />
        </div>
      </header>

      <main class="grow pt-24 pb-12 px-4 container mx-auto">{children}</main>

      <footer class="bg-black/20 border-t border-white/10 py-8 mt-auto">
        <div class="container mx-auto px-4 text-center text-white/40 text-sm">
          <p>&copy; {new Date().getFullYear()} Vaniabase. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
