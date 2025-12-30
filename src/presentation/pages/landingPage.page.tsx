import type { FunctionalComponent } from 'preact';

import { useTranslation } from 'react-i18next';
import { container } from '../../infrastructure/di/container';
import { AuthService } from '../../application/auth/auth.service';

export const LandingPage: FunctionalComponent = () => {
  const { t } = useTranslation();
  const authService = container.get(AuthService);

  const handleLogin = async () => {
    try {
      await authService.login();
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center  text-white p-4">
      <h1 className="text-5xl font-bold mb-8 text-violet-400">{t('auth.welcome')}</h1>
      <p className="text-xl mb-8 text-gray-300">{t('auth.login_prompt')}</p>

      <div className="bg-gray-800 p-8 rounded-lg shadow-lg flex flex-col gap-4 w-[90%] md:w-[50%] lg:w-[40%] xl:w-[30%]">
        <button
          onClick={handleLogin}
          className="flex items-center justify-center gap-3 px-6 py-3 bg-white text-gray-800 hover:bg-gray-100 rounded font-bold transition-all hover:scale-[1.02] shadow-lg"
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
      </div>
    </div>
  );
};
