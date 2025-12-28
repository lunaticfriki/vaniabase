import { useState, useRef, useEffect } from 'preact/hooks';
import { Link as RouterLink, Match } from 'preact-router/match';
import { route } from 'preact-router';
import type { JSX } from 'preact';
import { container } from '../../infrastructure/di/container';
import { AuthService } from '../../application/auth/auth.service';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

export function Menu() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);

  const authService = container.get(AuthService);
  const currentUser = authService.currentUser.value;

  const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

  const handleLogout = async () => {
    await authService.logout();
    route('/', true);
  };

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        isMenuOpen &&
        menuRef.current &&
        !menuRef.current.contains(event.target as Node) &&
        buttonRef.current &&
        !buttonRef.current.contains(event.target as Node)
      ) {
        setIsMenuOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isMenuOpen]);

  const navLinks = [
    { href: '/', label: 'HOME', matcher: undefined },
    { href: '/collection', label: 'COLLECTION', matcher: undefined },
    { href: '/categories/books', label: 'CATEGORIES', matcher: '/categories/:rest*' },
    { href: '/tags', label: 'TAGS', matcher: '/tags/:rest*' },
    { href: '/topics', label: 'TOPICS', matcher: '/topics/:rest*' },
    { href: '/formats', label: 'FORMATS', matcher: '/formats/:rest*' },
    { href: '/search', label: 'SEARCH', matcher: undefined },
    { href: '/create', label: 'CREATE', matcher: undefined },
    { href: '/about', label: 'ABOUT', matcher: undefined }
  ];

  if (!currentUser) {
    return null;
  }

  return (
    <>
      <nav class="hidden md:block">
        <div class="flex items-center gap-6">
          <div class="flex items-center gap-3 cursor-pointer group relative">
            <img
              src={currentUser.avatar}
              alt={`${currentUser.name}'s avatar`}
              class="w-8 h-8 rounded-full bg-white/10"
              style="image-rendering: pixelated;"
            />
            <span class="text-brand-magenta font-bold group-hover:text-brand-yellow transition-colors">
              Hello, {currentUser.name}!
            </span>
          </div>
          <ul class="flex gap-6 text-sm font-medium">
            {navLinks.map(link => (
              <li key={link.href}>
                <Match path={link.matcher || link.href}>
                  {({ matches }: { matches: boolean }) => {
                    const isActive = matches;
                    return (
                      <Link
                        href={link.href}
                        class={`${isActive ? 'text-brand-yellow' : 'text-white'} hover:text-brand-yellow transition-colors cursor-pointer`}
                      >
                        {link.label}
                      </Link>
                    );
                  }}
                </Match>
              </li>
            ))}
            <li>
              <button
                onClick={handleLogout}
                class="text-white hover:text-brand-yellow transition-colors cursor-pointer"
              >
                LOGOUT
              </button>
            </li>
          </ul>
        </div>
      </nav>

      <button
        ref={buttonRef}
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
        <div
          ref={menuRef}
          class="md:hidden bg-[#242424] border-t border-white/10 absolute w-full left-0 top-16 shadow-2xl animate-in slide-in-from-top-2 z-40"
        >
          <nav class="flex flex-col p-4">
            <div class="flex items-center gap-3 py-3 border-b border-white/5">
              <img
                src={currentUser.avatar}
                alt={`${currentUser.name}'s avatar`}
                class="w-8 h-8 rounded-full bg-white/10"
                style="image-rendering: pixelated;"
              />
              <span class="text-brand-magenta font-bold">Hello, {currentUser.name}!</span>
            </div>
            {navLinks.map(link => (
              <Match key={link.href} path={link.matcher || link.href}>
                {({ matches }: { matches: boolean }) => {
                  const isActive = matches;
                  return (
                    <Link
                      href={link.href}
                      class={`${isActive ? 'text-brand-yellow' : 'text-white'} py-3 hover:text-brand-yellow transition-colors border-b border-white/5 block`}
                      onClick={() => setIsMenuOpen(false)}
                    >
                      {link.label}
                    </Link>
                  );
                }}
              </Match>
            ))}
            <button
              onClick={() => {
                handleLogout();
                setIsMenuOpen(false);
              }}
              class="text-white py-3 hover:text-brand-yellow transition-colors block w-full text-left"
            >
              LOGOUT
            </button>
          </nav>
        </div>
      )}
    </>
  );
}
