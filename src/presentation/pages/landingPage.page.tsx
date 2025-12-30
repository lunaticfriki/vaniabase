import type { FunctionalComponent } from 'preact';
import { useSignal } from '@preact/signals';
import { useTranslation } from 'react-i18next';
import { container } from '../../infrastructure/di/container';
import { AuthService } from '../../application/auth/auth.service';
import { UserSeed } from '../../domain/seed/user.seed';

export const LandingPage: FunctionalComponent = () => {
  const { t } = useTranslation();
  const authService = container.get(AuthService);
  const users = UserSeed.generate();
  const selectedUserId = useSignal(users[0].id.value);

  const handleLogin = async () => {
    try {
      await authService.login(selectedUserId.value);
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center  text-white p-4">
      <h1 className="text-5xl font-bold mb-8 text-violet-400">{t('auth.welcome')}</h1>
      <p className="text-xl mb-8 text-gray-300">{t('auth.login_prompt')}</p>

      <div className="bg-gray-800 p-8 rounded-lg shadow-lg flex flex-col gap-4 w-[90%] md:w-[50%] lg:w-[40%] xl:w-[30%]">
        <label className="text-sm font-medium text-gray-400">{t('auth.select_user')}</label>
        <select
          className="p-2 rounded bg-gray-700 border border-gray-600 text-white focus:border-violet-500 outline-none"
          value={selectedUserId.value}
          onChange={e => (selectedUserId.value = (e.currentTarget as HTMLSelectElement).value)}
        >
          {users.map(user => (
            <option key={user.id.value} value={user.id.value}>
              {user.name}
            </option>
          ))}
        </select>

        <button
          onClick={handleLogin}
          className="mt-4 px-6 py-2 bg-violet-600 hover:bg-violet-700 text-white rounded font-bold transition-colors"
        >
          {t('auth.login')}
        </button>
      </div>
    </div>
  );
};
