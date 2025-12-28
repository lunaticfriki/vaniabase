import { useState, useRef, useEffect } from 'preact/hooks';
import { Link as RouterLink, Match } from 'preact-router/match';
import { route } from 'preact-router';
import type { JSX } from 'preact';
import { container } from '../../infrastructure/di/container';
import { AuthService } from '../../application/auth/auth.service';
import {
  HomeIcon,
  CollectionIcon,
  CategoriesIcon,
  TagsIcon,
  TopicsIcon,
  FormatsIcon,
  SearchIcon,
  CreateIcon,
  AboutIcon,
  LogoutIcon
} from './pixel-icons';

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
    { href: '/', label: 'HOME', icon: HomeIcon, matcher: undefined },
    { href: '/collection', label: 'COLLECTION', icon: CollectionIcon, matcher: undefined },
    { href: '/categories/books', label: 'CATEGORIES', icon: CategoriesIcon, matcher: '/categories/:rest*' },
    { href: '/tags', label: 'TAGS', icon: TagsIcon, matcher: '/tags/:rest*' },
    { href: '/topics', label: 'TOPICS', icon: TopicsIcon, matcher: '/topics/:rest*' },
    { href: '/formats', label: 'FORMATS', icon: FormatsIcon, matcher: '/formats/:rest*' },
    { href: '/search', label: 'SEARCH', icon: SearchIcon, matcher: undefined },
    { href: '/create', label: 'CREATE', icon: CreateIcon, matcher: undefined },
    { href: '/about', label: 'ABOUT', icon: AboutIcon, matcher: undefined }
  ];

  if (!currentUser) {
    return null;
  }

  return (
    <>
      <nav class="hidden xl:block">
        <div class="flex items-center gap-6">
          <Link href="/dashboard" class="flex items-center gap-3 cursor-pointer group relative">
            <img
              src={currentUser.avatar}
              alt={`${currentUser.name}'s avatar`}
              class="w-8 h-8 rounded-full bg-white/10"
              style="image-rendering: pixelated;"
            />
            <span class="text-brand-magenta font-bold group-hover:text-brand-yellow transition-colors">
              Hello, {currentUser.name}!
            </span>
          </Link>
          <ul class="flex gap-6 text-sm font-medium items-center">
            {navLinks.map(link => (
              <li key={link.href}>
                <Match path={link.matcher || link.href}>
                  {({ matches }: { matches: boolean }) => {
                    const isActive = matches;
                    return (
                      <Link
                        href={link.href}
                        class={`${isActive ? 'text-brand-yellow' : 'text-white'} hover:text-brand-yellow transition-colors cursor-pointer flex items-center gap-2 group`}
                      >
                        <link.icon size={16} className="group-hover:text-brand-yellow transition-colors" />
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
                class="text-white hover:text-brand-yellow transition-colors cursor-pointer flex items-center gap-2"
              >
                <LogoutIcon size={16} />
                LOGOUT
              </button>
            </li>
          </ul>
        </div>
      </nav>

      <button
        ref={buttonRef}
        class="xl:hidden p-2 text-white hover:text-brand-magenta transition-colors focus:outline-none"
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
          class="xl:hidden bg-[#242424] border-t border-white/10 absolute w-full left-0 top-16 shadow-2xl animate-in slide-in-from-top-2 z-40"
        >
          <nav class="flex flex-col p-4">
            <Link
              href="/dashboard"
              class="flex items-center gap-3 py-3 border-b border-white/5"
              onClick={() => setIsMenuOpen(false)}
            >
              <img
                src={currentUser.avatar}
                alt={`${currentUser.name}'s avatar`}
                class="w-8 h-8 rounded-full bg-white/10"
                style="image-rendering: pixelated;"
              />
              <span class="text-brand-magenta font-bold">Hello, {currentUser.name}!</span>
            </Link>
            {navLinks.map(link => (
              <Match key={link.href} path={link.matcher || link.href}>
                {({ matches }: { matches: boolean }) => {
                  const isActive = matches;
                  return (
                    <Link
                      href={link.href}
                      class={`${isActive ? 'text-brand-yellow' : 'text-white'} py-3 hover:text-brand-yellow transition-colors border-b border-white/5 flex items-center gap-3 group`}
                      onClick={() => setIsMenuOpen(false)}
                    >
                      <link.icon size={20} className="group-hover:text-brand-yellow transition-colors" />
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
              class="text-white py-3 hover:text-brand-yellow transition-colors flex items-center gap-3 w-full text-left"
            >
              <LogoutIcon size={20} />
              LOGOUT
            </button>
          </nav>
        </div>
      )}
    </>
  );
}
