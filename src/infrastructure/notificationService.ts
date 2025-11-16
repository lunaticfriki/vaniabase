import {
  NotificationService,
  NotificationType,
  type Notification,
} from '../domain/notificationService';

export class NotificationServiceImpl extends NotificationService {
  private notifications: Notification[] = [];
  private listeners: Array<(notifications: Notification[]) => void> = [];

  notify(
    type: NotificationType,
    message: string,
    title?: string,
    duration: number = 5000
  ): Notification {
    const notification: Notification = {
      id: this.generateId(),
      type,
      message,
      title,
      timestamp: new Date(),
      duration,
    };

    this.notifications.push(notification);
    this.notifyListeners();
    this.logNotification(notification);

    if (duration !== undefined && duration > 0) {
      setTimeout(() => {
        this.clearNotification(notification.id);
      }, duration);
    }

    return notification;
  }

  success(message: string, title?: string, duration?: number): Notification {
    return this.notify(NotificationType.SUCCESS, message, title, duration);
  }

  error(message: string, title?: string, duration?: number): Notification {
    return this.notify(NotificationType.ERROR, message, title, duration);
  }

  warning(message: string, title?: string, duration?: number): Notification {
    return this.notify(NotificationType.WARNING, message, title, duration);
  }

  info(message: string, title?: string, duration?: number): Notification {
    return this.notify(NotificationType.INFO, message, title, duration);
  }

  getNotifications(): Notification[] {
    return [...this.notifications];
  }

  clearNotification(id: string): void {
    const index = this.notifications.findIndex((n) => n.id === id);
    if (index !== -1) {
      this.notifications.splice(index, 1);
      this.notifyListeners();
    }
  }

  clearAll(): void {
    this.notifications = [];
    this.notifyListeners();
  }

  subscribe(listener: (notifications: Notification[]) => void): () => void {
    this.listeners.push(listener);
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index !== -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  private notifyListeners(): void {
    this.listeners.forEach((listener) => {
      listener([...this.notifications]);
    });
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  private logNotification(notification: Notification): void {
    const logMessage = `[${notification.type}] ${
      notification.title ? `${notification.title}: ` : ''
    }${notification.message}`;

    switch (notification.type) {
      case NotificationType.ERROR:
        console.error(logMessage);
        break;
      case NotificationType.WARNING:
        console.warn(logMessage);
        break;
      case NotificationType.INFO:
        console.info(logMessage);
        break;
      case NotificationType.SUCCESS:
        console.log(logMessage);
        break;
      default:
        console.log(logMessage);
    }
  }
}
