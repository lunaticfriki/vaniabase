export interface Notification {
  id: string;
  type: 'success' | 'error' | 'info' | 'warning';
  message: string;
  duration?: number;
}

export abstract class NotificationService {
  abstract notify(message: string, type?: Notification['type']): void;
  abstract success(message: string): void;
  abstract error(message: string): void;
  abstract info(message: string): void;
  abstract warning(message: string): void;
}
