import { injectable } from 'inversify';
import { NotificationService } from '../../domain/services/NotificationService';

@injectable()
export class ConsoleNotificationService implements NotificationService {
    notify(message: string): void {
        console.log('Notification:', message);
    }
}
