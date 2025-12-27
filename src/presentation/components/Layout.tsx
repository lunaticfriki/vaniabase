import { useState } from 'preact/hooks';
import type { ComponentChildren } from 'preact';

interface LayoutProps {
  children: ComponentChildren;
}

export function Layout({ children }: LayoutProps) {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

  return (
    <div class="min-h-screen bg-[#242424] text-white font-sans flex flex-col">
      <header class="bg-[#242424] fixed w-full top-0 z-50 border-b border-white/10 shadow-md">
        <div class="container mx-auto px-4 h-16 flex items-center justify-between">
          <div class="text-brand-magenta font-bold text-2xl tracking-tighter">
            VANIABASE
          </div>
          
          {/* Desktop Menu */}
          <nav class="hidden md:block">
            <ul class="flex gap-6 text-sm font-medium">
              <li><a href="#" class="hover:text-brand-yellow transition-colors">HOME</a></li>
              <li><a href="#" class="hover:text-brand-yellow transition-colors">COLLECTION</a></li>
              <li><a href="#" class="hover:text-brand-yellow transition-colors">ABOUT</a></li>
            </ul>
          </nav>

          {/* Mobile Menu Button */}
          <button 
            class="md:hidden p-2 text-white hover:text-brand-magenta transition-colors focus:outline-none"
            onClick={toggleMenu}
            aria-label="Toggle menu"
          >
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
              <path stroke-linecap="round" stroke-linejoin="round" d={isMenuOpen ? "M6 18L18 6M6 6l12 12" : "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"} />
            </svg>
          </button>
        </div>

        {/* Mobile Dropdown */}
        {isMenuOpen && (
          <div class="md:hidden bg-[#242424] border-t border-white/10 absolute w-full left-0 top-16 shadow-2xl animate-in slide-in-from-top-2">
            <nav class="flex flex-col p-4">
              <a href="#" class="py-3 hover:text-brand-yellow transition-colors border-b border-white/5" onClick={() => setIsMenuOpen(false)}>HOME</a>
              <a href="#" class="py-3 hover:text-brand-yellow transition-colors border-b border-white/5" onClick={() => setIsMenuOpen(false)}>COLLECTION</a>
              <a href="#" class="py-3 hover:text-brand-yellow transition-colors" onClick={() => setIsMenuOpen(false)}>ABOUT</a>
            </nav>
          </div>
        )}
      </header>

      <main class="grow pt-24 pb-12 px-4 container mx-auto">
        {children}
      </main>

      <footer class="bg-black/20 border-t border-white/10 py-8 mt-auto">
        <div class="container mx-auto px-4 text-center text-white/40 text-sm">
          <p>&copy; {new Date().getFullYear()} Vaniabase. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
