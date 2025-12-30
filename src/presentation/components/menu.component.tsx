import { useState, useRef, useEffect } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
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
  LogoutIcon,
  CompletedIcon
} from './pixel-icons';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a'] & { activeClassName?: string }) => JSX.Element;

export function Menu() {
  const { t, i18n } = useTranslation();
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

  const changeLanguage = (lng: string) => {
    i18n.changeLanguage(lng);
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
    { href: '/', label: t('menu.home'), icon: HomeIcon, matcher: undefined },
    { href: '/collection', label: t('menu.collection'), icon: CollectionIcon, matcher: undefined },
    { href: '/completed', label: t('menu.completed'), icon: CompletedIcon, matcher: undefined },
    { href: '/categories/books', label: t('menu.categories'), icon: CategoriesIcon, matcher: '/categories/:rest*' },
    { href: '/tags', label: t('menu.tags'), icon: TagsIcon, matcher: '/tags/:rest*' },
    { href: '/topics', label: t('menu.topics'), icon: TopicsIcon, matcher: '/topics/:rest*' },
    { href: '/formats', label: t('menu.formats'), icon: FormatsIcon, matcher: '/formats/:rest*' },
    { href: '/search', label: t('menu.search'), icon: SearchIcon, matcher: undefined },
    { href: '/create', label: t('menu.create'), icon: CreateIcon, matcher: undefined },
    { href: '/about', label: t('menu.about'), icon: AboutIcon, matcher: undefined }
  ];

  if (!currentUser) {
    return null;
  }

  return (
    <>
      <div class="flex items-center gap-6 relative">
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
                {t('menu.hello', { name: currentUser.name })}
              </span>
            </Link>
            <ul class="flex gap-6 text-sm font-medium items-center">
              {navLinks.map(link => (
                <li key={link.href} class={link.label !== t('menu.about') ? 'hidden' : ''}>
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
                  {t('menu.logout')}
                </button>
              </li>
              <li>
                <div class="flex gap-2">
                  <button
                    onClick={() => changeLanguage('ca')}
                    class={`text-xs ${i18n.language === 'ca' ? 'text-brand-yellow' : 'text-white'}`}
                  >
                    CA
                  </button>
                  <span class="text-white/20">|</span>
                  <button
                    onClick={() => changeLanguage('en')}
                    class={`text-xs ${i18n.language === 'en' ? 'text-brand-yellow' : 'text-white'}`}
                  >
                    EN
                  </button>
                </div>
              </li>
            </ul>
          </div>
        </nav>

        <button
          ref={buttonRef}
          class="p-2 text-white hover:text-brand-magenta transition-colors focus:outline-none"
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
            class="fixed left-0 top-16 w-full xl:absolute xl:top-full xl:right-0 xl:w-72 xl:left-auto xl:mt-4 z-40 cyberpunk-glow animate-in slide-in-from-top-2"
          >
            <div class="w-full h-full bg-[#242424] border-t border-white/10 xl:border xl:border-white/10 cyberpunk-dropdown shadow-2xl xl:shadow-none">
              <nav class="flex flex-col p-4">
                <Link
                  href="/dashboard"
                  class="flex items-center gap-3 py-3 border-b border-white/5 xl:hidden"
                  onClick={() => setIsMenuOpen(false)}
                >
                  <img
                    src={currentUser.avatar}
                    alt={`${currentUser.name}'s avatar`}
                    class="w-8 h-8 rounded-full bg-white/10"
                    style="image-rendering: pixelated;"
                  />
                  <span class="text-brand-magenta font-bold">{t('menu.hello', { name: currentUser.name })}</span>
                </Link>
                {navLinks.map(link => (
                  <div key={link.href} class={link.label === t('menu.about') ? 'xl:hidden' : ''}>
                    <Match path={link.matcher || link.href}>
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
                  </div>
                ))}
                <button
                  onClick={() => {
                    handleLogout();
                    setIsMenuOpen(false);
                  }}
                  class="text-white py-3 hover:text-brand-yellow transition-colors flex items-center gap-3 w-full text-left xl:hidden"
                >
                  <LogoutIcon size={20} />
                  {t('menu.logout')}
                </button>
                <div class="flex gap-4 p-4 border-t border-white/5 justify-center">
                  <button
                    onClick={() => changeLanguage('en')}
                    class={`text-sm ${i18n.language === 'en' ? 'text-brand-yellow' : 'text-white'}`}
                  >
                    English
                  </button>
                  <button
                    onClick={() => changeLanguage('ca')}
                    class={`text-sm ${i18n.language === 'ca' ? 'text-brand-yellow' : 'text-white'}`}
                  >
                    Català
                  </button>
                </div>
              </nav>
            </div>
          </div>
        )}
      </div>
    </>
  );
}
