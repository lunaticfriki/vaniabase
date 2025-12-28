import 'reflect-metadata';
import { Container } from 'inversify';

import { ItemsRepository } from '../../domain/repositories/ItemsRepository';
import { InMemoryItemsRepository } from '../repositories/InMemoryItemsRepository';
import { CategoriesRepository } from '../../domain/repositories/CategoriesRepository';
import { InMemoryCategoriesRepository } from '../repositories/InMemoryCategoriesRepository';

import { ErrorManager } from '../../domain/services/ErrorManager';
import { ConsoleErrorManager } from '../services/ConsoleErrorManager';
import { NotificationService } from '../../domain/services/NotificationService';
import { ToastNotificationService } from '../services/ToastNotificationService';

import { AuthService } from '../../application/auth/AuthService';
import { MockAuthService } from '../auth/MockAuthService';

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
