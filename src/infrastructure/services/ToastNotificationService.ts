import { injectable } from 'inversify';
import { signal, computed } from '@preact/signals';
import { NotificationService } from '../../domain/services/NotificationService';
import type { Notification } from '../../domain/services/NotificationService';
import { v4 as uuidv4 } from 'uuid';

@injectable()
export class ToastNotificationService implements NotificationService {
  private _notifications = signal<Notification[]>([]);

  public notifications = computed(() => this._notifications.value);

  notify(message: string, type: Notification['type'] = 'info', duration = 3000): void {
    const id = uuidv4();
    const notification: Notification = { id, type, message, duration };
    
    this._notifications.value = [...this._notifications.value, notification];

    if (duration > 0) {
      setTimeout(() => {
        this.remove(id);
      }, duration);
    }
  }

  success(message: string): void {
    this.notify(message, 'success');
  }

  error(message: string): void {
    this.notify(message, 'error', 5000);
  }

  info(message: string): void {
    this.notify(message, 'info');
  }

  warning(message: string): void {
    this.notify(message, 'warning');
  }

  remove(id: string): void {
    this._notifications.value = this._notifications.value.filter(n => n.id !== id);
  }
}
