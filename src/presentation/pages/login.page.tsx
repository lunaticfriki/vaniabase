import type { FunctionalComponent, JSX } from 'preact';
import { useMemo } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
import { Link as RouterLink } from 'preact-router/match';
import { container } from '../../infrastructure/di/container';
import { AuthService } from '../../application/auth/auth.service';
import { AuthViewModel } from '../viewModels/auth.viewModel';
import { Loading } from '../components/loading.component';

const Link = RouterLink as unknown as (props: JSX.IntrinsicElements['a']) => JSX.Element;

export const Login: FunctionalComponent = () => {
  const { t } = useTranslation();

  const viewModel = useMemo(() => {
    return new AuthViewModel(container.get(AuthService));
  }, []);

  const { loading, error } = viewModel;

  const handleLogin = () => {
    void viewModel.loginWithGoogle();
  };

  if (loading.value) {
    return <Loading />;
  }

  return (
    <div class="flex flex-col items-center justify-center min-h-[80vh] text-white p-4 animate-in fade-in zoom-in duration-500">
      <div class="space-y-2 text-center mb-8">
        <h1 class="text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('auth.login_title')}
        </h1>
        <p class="text-xl text-white/60">{t('auth.login_subtitle')}</p>
      </div>

      <div class="bg-zinc-900/50 border border-white/10 p-8 rounded-lg shadow-2xl backdrop-blur-sm flex flex-col gap-6 w-full max-w-md relative overflow-hidden group">
        <div class="absolute inset-0 bg-linear-to-br from-brand-magenta/5 to-brand-yellow/5 opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none" />

        {error.value && (
          <div class="bg-red-500/10 border border-red-500/50 text-red-500 p-3 rounded text-sm text-center">
            {error.value}
          </div>
        )}

        <button
          onClick={handleLogin}
          disabled={loading.value}
          class="relative flex items-center justify-center gap-3 px-6 py-4 bg-white text-black hover:bg-gray-100 rounded font-bold transition-all hover:scale-[1.02] shadow-[0_0_20px_rgba(255,255,255,0.1)] hover:shadow-[0_0_25px_rgba(255,255,255,0.2)] disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
            <path
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              fill="#4285F4"
            />
            <path
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              fill="#34A853"
            />
            <path
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
              fill="#FBBC05"
            />
            <path
              d="M12 5.38c1.62 0 3.06.56 4.23 1.68l3.17-3.17C17.45 2.05 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
              fill="#EA4335"
            />
          </svg>
          {t('auth.login_google')}
        </button>

        <div class="relative">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-white/10"></div>
          </div>
          <div class="relative flex justify-center text-xs uppercase tracking-widest">
            <span class="bg-[#18181b] px-2 text-white/40">{t('auth.or')}</span>
          </div>
        </div>

        <div class="text-center">
          <Link href="/signup" class="text-sm text-brand-magenta hover:text-brand-yellow transition-colors font-medium">
            {t('auth.to_signup')}
          </Link>
        </div>
      </div>
    </div>
  );
};
