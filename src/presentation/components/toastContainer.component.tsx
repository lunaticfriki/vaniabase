import { container } from '../../infrastructure/di/container';
import { ToastNotificationService } from '../../infrastructure/services/toastNotification.service';
import { NotificationService } from '../../domain/services/notification.service';
import { Toast } from './toast.component';

export function ToastContainer() {
  const notificationService = container.get(NotificationService) as ToastNotificationService;
  const notifications = notificationService.notifications;

  const handleClose = (id: string) => {
    notificationService.remove(id);
  };

  return (
    <div class="fixed top-4 right-4 z-50 flex flex-col gap-2 w-full max-w-sm pointer-events-none">
      <div class="pointer-events-auto flex flex-col gap-2">
        {notifications.value.map(notification => (
          <Toast key={notification.id} notification={notification} onClose={handleClose} />
        ))}
      </div>
    </div>
  );
}
