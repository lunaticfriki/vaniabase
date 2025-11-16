export enum NotificationType {
  SUCCESS = 'SUCCESS',
  ERROR = 'ERROR',
  WARNING = 'WARNING',
  INFO = 'INFO',
}

export interface Notification {
  id: string;
  type: NotificationType;
  message: string;
  title?: string;
  timestamp: Date;
  duration?: number;
}

export abstract class NotificationService {
  abstract notify(
    type: NotificationType,
    message: string,
    title?: string,
    duration?: number
  ): Notification;

  abstract success(
    message: string,
    title?: string,
    duration?: number
  ): Notification;
  abstract error(
    message: string,
    title?: string,
    duration?: number
  ): Notification;
  abstract warning(
    message: string,
    title?: string,
    duration?: number
  ): Notification;
  abstract info(
    message: string,
    title?: string,
    duration?: number
  ): Notification;

  abstract getNotifications(): Notification[];
  abstract clearNotification(id: string): void;
  abstract clearAll(): void;
}
