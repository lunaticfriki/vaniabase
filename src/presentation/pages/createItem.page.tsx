import { useMemo } from 'preact/hooks';
import { useTranslation } from 'react-i18next';
import { route } from 'preact-router';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { AuthService } from '../../application/auth/auth.service';
import { StorageService } from '../../application/services/storage.service';
import { NotificationService } from '../../domain/services/notification.service';
import { ImageLookupService } from '../../infrastructure/services/imageLookupService';
import { ItemForm } from '../components/itemForm.component';
import type { ItemFormData } from '../components/itemForm.component';
import { CreateItemViewModel } from '../viewModels/createItem.viewModel';

export function CreateItem() {
  const { t } = useTranslation();
  const authService = container.get(AuthService);
  const storageService = container.get(StorageService);
  const notificationService = container.get(NotificationService);

  const viewModel = useMemo(() => {
    return new CreateItemViewModel(container.get(ItemStateService), container.get(ImageLookupService));
  }, []);

  const { formData, isImporting } = viewModel;

  const handleUploadCover = async (file: File): Promise<string> => {
    const currentUser = authService.currentUser.value;
    if (!currentUser) throw new Error('User not authenticated');

    const tempId = crypto.randomUUID();
    const path = `users/${currentUser.id.value}/items/${tempId}/${file.name}`;
    return await storageService.upload(file, path);
  };

  const handleFileUpload = async (e: Event) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    if (!file) return;

    const currentUser = authService.currentUser.value;
    if (!currentUser) {
      notificationService.error('User not authenticated');
      return;
    }

    const success = await viewModel.processExcelFile(file, currentUser.id.value);

    if (success) {
      route('/');
    } else {
      if (viewModel.importError.value === 'no_valid_items') {
        notificationService.error(t('create_item.messages.no_valid_items'));
      } else {
        notificationService.error(t('create_item.messages.parse_error'));
      }
    }
  };

  const handleSubmit = async (data: ItemFormData) => {
    try {
      const currentUser = authService.currentUser.value;
      if (!currentUser) throw new Error('User not authenticated');

      await viewModel.createItem(data, currentUser.id.value);
      route('/');
    } catch (error) {
      notificationService.error(t('create_item.messages.create_error'));
      console.error(error);
    }
  };

  return (
    <div class="max-w-2xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('create_item.title')}
        </h1>
        <p class="text-white/60">{t('create_item.subtitle')}</p>
      </div>

      <ItemForm
        initialValues={formData.value}
        onSubmit={handleSubmit}
        submitLabel={t('create_item.buttons.create')}
        onUploadCover={handleUploadCover}
      />

      <div class="relative py-4">
        <div class="absolute inset-0 flex items-center">
          <div class="w-full border-t border-white/10"></div>
        </div>
        <div class="relative flex justify-center text-xs uppercase tracking-widest">
          <span class="bg-black px-4 text-white/40">{t('create_item.import.or_import')}</span>
        </div>
      </div>

      <div class="space-y-4">
        <div class="p-6 border-2 border-dashed border-white/10 rounded-lg hover:border-brand-magenta/50 transition-colors text-center group cursor-pointer relative">
          <input
            type="file"
            accept=".xlsx, .xls, .ods"
            onChange={handleFileUpload}
            disabled={isImporting.value}
            class="absolute inset-0 w-full h-full opacity-0 cursor-pointer disabled:cursor-not-allowed"
          />
          <div class="space-y-2">
            {isImporting.value ? (
              <p class="text-sm font-bold text-brand-magenta animate-pulse">Processing...</p>
            ) : (
              <>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="w-10 h-10 mx-auto text-white/40 group-hover:text-brand-magenta transition-colors"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                >
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                  <polyline points="17 8 12 3 7 8" />
                  <line x1="12" y1="3" x2="12" y2="15" />
                </svg>
                <p class="text-sm font-bold text-white/60 group-hover:text-white transition-colors">
                  {t('create_item.import.drag_drop')}
                </p>
                <p class="text-xs text-white/30">{t('create_item.import.supported_files')}</p>
              </>
            )}
          </div>
        </div>
        <div class="text-xs text-white/30 space-y-1">
          <p class="font-bold">{t('create_item.import.expected_columns')}</p>
          <p>{t('create_item.import.columns_list')}</p>
        </div>
      </div>
    </div>
  );
}
