import { ItemsHttpRepository } from './infrastructure/httpRepository';
import { FetchServiceImpl } from './infrastructure/fetchService';
import { ErrorManagerImpl } from './infrastructure/errorManager';
import { NotificationServiceImpl } from './infrastructure/notificationService';
import { BASE_URL } from './config/endpoints';

const fetchService = new FetchServiceImpl();

export const ItemsDI = {
  repository: new ItemsHttpRepository(BASE_URL, fetchService),
  notification: new NotificationServiceImpl(),
  errorManager: new ErrorManagerImpl(),
};
