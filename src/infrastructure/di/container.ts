import 'reflect-metadata';
import { Container } from 'inversify';

import { ItemsRepository } from '../../domain/repositories/items.repository';
import { InMemoryItemsRepository } from '../repositories/inMemoryItems.repository';
import { CategoriesRepository } from '../../domain/repositories/categories.repository';
import { InMemoryCategoriesRepository } from '../repositories/inMemoryCategories.repository';

import { ErrorManager } from '../../domain/services/errorManager.service';
import { ConsoleErrorManager } from '../services/consoleErrorManager.service';
import { NotificationService } from '../../domain/services/notification.service';
import { ToastNotificationService } from '../services/toastNotification.service';

import { AuthService } from '../../application/auth/auth.service';
import { MockAuthService } from '../auth/mockAuth.service';

import { ItemReadService } from '../../application/item/item.readService';
import { ItemWriteService } from '../../application/item/item.writeService';
import { ItemStateService } from '../../application/item/item.stateService';

import { CategoryReadService } from '../../application/category/category.readService';
import { CategoryWriteService } from '../../application/category/category.writeService';
import { CategoryStateService } from '../../application/category/category.stateService';

const container = new Container();

container.bind(ItemsRepository).to(InMemoryItemsRepository).inSingletonScope();
container.bind(CategoriesRepository).to(InMemoryCategoriesRepository).inSingletonScope();

container.bind(ErrorManager).to(ConsoleErrorManager).inSingletonScope();
container.bind(NotificationService).to(ToastNotificationService).inSingletonScope();
container.bind(AuthService).to(MockAuthService).inSingletonScope();

container.bind(ItemReadService).toSelf().inSingletonScope();
container.bind(ItemWriteService).toSelf().inSingletonScope();
container.bind(ItemStateService).toSelf().inSingletonScope();

container.bind(CategoryReadService).toSelf().inSingletonScope();
container.bind(CategoryWriteService).toSelf().inSingletonScope();
container.bind(CategoryStateService).toSelf().inSingletonScope();

export { container };
