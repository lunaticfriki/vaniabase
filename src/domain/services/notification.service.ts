export interface Notification {
  id: string;
  type: 'success' | 'error' | 'info' | 'warning';
  message: string;
  duration?: number;
}

export abstract class NotificationService {
  notify(_message: string, _type?: Notification['type']): void {}
  success(_message: string): void {}
  error(_message: string): void {}
  info(_message: string): void {}
  warning(_message: string): void {}
}
