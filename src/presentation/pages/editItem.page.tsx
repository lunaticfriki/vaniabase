import { useMemo, useEffect } from 'preact/hooks';
import { route } from 'preact-router';
import { useTranslation } from 'react-i18next';
import { container } from '../../infrastructure/di/container';
import { ItemStateService } from '../../application/item/item.stateService';
import { StorageService } from '../../application/services/storage.service';
import { AuthService } from '../../application/auth/auth.service';
import { NotificationService } from '../../domain/services/notification.service';
import { ImageLookupService } from '../../infrastructure/services/imageLookupService';
import { ItemForm } from '../components/itemForm.component';
import type { ItemFormData } from '../components/itemForm.component';
import { Loading } from '../components/loading.component';
import { EditItemViewModel } from '../viewModels/editItem.viewModel';

interface Props {
  id?: string;
  path?: string;
}

export function EditItem({ id }: Props) {
  const { t } = useTranslation();
  const notificationService = container.get(NotificationService);
  const authService = container.get(AuthService);
  const storageService = container.get(StorageService);

  const viewModel = useMemo(() => {
    return new EditItemViewModel(container.get(ItemStateService), container.get(ImageLookupService));
  }, []);

  const { loading, item, formData } = viewModel;

  useEffect(() => {
    if (id) {
      viewModel.loadItem(id).then(() => {
        if (!viewModel.item.value) {
          notificationService.error(t('item_detail.not_found'));
          route('/');
        }
      });
    }
  }, [id]);

  const handleUploadCover = async (file: File): Promise<string> => {
    const currentUser = authService.currentUser.value;
    if (!currentUser) throw new Error('User not authenticated');

    const itemIdToUse = item.value?.id.value || id;
    if (!itemIdToUse) throw new Error('Item ID unavailable');

    const path = `users/${currentUser.id.value}/items/${itemIdToUse}/${file.name}`;
    return await storageService.upload(file, path);
  };

  const handleSubmit = async (data: ItemFormData) => {
    if (!item.value) return;
    try {
      await viewModel.updateItem(data);
      route(`/item/${id}`);
    } catch (error) {
      notificationService.error(t('create_item.messages.create_error'));
      console.error(error);
    }
  };

  if (loading.value) return <Loading />;
  if (!item.value || !formData.value) return null;

  return (
    <div class="max-w-2xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
      <div class="space-y-2">
        <h1 class="text-4xl md:text-5xl font-black tracking-tighter text-transparent bg-clip-text bg-linear-to-r from-brand-magenta to-brand-yellow">
          {t('edit_item.title', { title: item.value.title.value })}
        </h1>
        <p class="text-white/60">{t('edit_item.subtitle')}</p>
      </div>
      <ItemForm
        initialValues={formData.value}
        onSubmit={handleSubmit}
        submitLabel={t('edit_item.buttons.save')}
        onUploadCover={handleUploadCover}
      />
    </div>
  );
}
