import { ItemsHttpRepository } from './infrastructure/httpRepository';
import { FetchServiceImpl } from './infrastructure/fetchService';
import { ErrorManagerImpl } from './infrastructure/errorManager';
import { NotificationServiceImpl } from './infrastructure/notificationService';

const fetchService = new FetchServiceImpl();

export const ItemsDI = {
  repository: new ItemsHttpRepository('http://localhost:3001', fetchService),
  notification: new NotificationServiceImpl(),
  errorManager: new ErrorManagerImpl(),
};
