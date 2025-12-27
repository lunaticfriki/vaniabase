import { useState } from 'preact/hooks';
import { Link as RouterLink } from 'preact-router/match';
import type { JSX } from 'preact';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

export function Menu() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

  const navLinks = [
    { href: '/', label: 'HOME' },
    { href: '/collection', label: 'COLLECTION' },
    { href: '/about', label: 'ABOUT' }
  ];

  return (
    <>
      <nav class="hidden md:block">
        <ul class="flex gap-6 text-sm font-medium">
          {navLinks.map(link => (
            <li key={link.href}>
              <Link
                href={link.href}
                class="hover:text-brand-yellow transition-colors"
                activeClassName="text-brand-yellow"
              >
                {link.label}
              </Link>
            </li>
          ))}
        </ul>
      </nav>

      <button
        class="md:hidden p-2 text-white hover:text-brand-magenta transition-colors focus:outline-none"
        onClick={toggleMenu}
        aria-label="Toggle menu"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="w-6 h-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d={isMenuOpen ? 'M6 18L18 6M6 6l12 12' : 'M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5'}
          />
        </svg>
      </button>

      {isMenuOpen && (
        <div class="md:hidden bg-[#242424] border-t border-white/10 absolute w-full left-0 top-16 shadow-2xl animate-in slide-in-from-top-2 z-40">
          <nav class="flex flex-col p-4">
            {navLinks.map(link => (
              <Link
                key={link.href}
                href={link.href}
                class="py-3 hover:text-brand-yellow transition-colors border-b border-white/5 last:border-0"
                onClick={() => setIsMenuOpen(false)}
                activeClassName="text-brand-yellow"
              >
                {link.label}
              </Link>
            ))}
          </nav>
        </div>
      )}
    </>
  );
}
