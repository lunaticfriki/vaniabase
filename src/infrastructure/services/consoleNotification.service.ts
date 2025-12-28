import { injectable } from 'inversify';
import { NotificationService } from '../../domain/services/notification.service';
import type { Notification } from '../../domain/services/notification.service';

@injectable()
export class ConsoleNotificationService implements NotificationService {
  notify(message: string, type: Notification['type'] = 'info'): void {
    console.log(`[Notification] [${type.toUpperCase()}] ${message}`);
  }

  success(message: string): void {
    this.notify(message, 'success');
  }

  error(message: string): void {
    console.error(`[Notification] [ERROR] ${message}`);
  }

  info(message: string): void {
    this.notify(message, 'info');
  }

  warning(message: string): void {
    console.warn(`[Notification] [WARNING] ${message}`);
  }
}
