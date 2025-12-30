import { useTranslation } from 'react-i18next';

export function Footer() {
  const { t } = useTranslation();
  return (
    <footer class="bg-black/20 border-t border-white/10 py-8 mt-auto">
      <div class="container mx-auto px-4 text-center text-white/40 text-sm">
        <p>
          &copy; {new Date().getFullYear()} Vaniabase. {t('footer.rights')}
        </p>
      </div>
    </footer>
  );
}
