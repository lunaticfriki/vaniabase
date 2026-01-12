import 'reflect-metadata';
import { mock, instance, when, verify, resetCalls, anything } from 'ts-mockito';
import { DashboardViewModel } from '../dashboard.viewModel';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemsRepository } from '../../../domain/repositories/items.repository';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { CategoryMother } from '../../../domain/__tests__/category.mother';
import { UserMother } from '../../../domain/__tests__/user.mother';
import { Tags } from '../../../domain/model/value-objects/tags.valueObject';
import { Topic, Format, Title, Publisher } from '../../../domain/model/value-objects/stringValues.valueObject';
import { Created } from '../../../domain/model/value-objects/dateAndNumberValues.valueObject';

describe('DashboardViewModel', () => {
  let mockItemsRepository: ItemsRepository;
  let mockAuthService: AuthService;
  let viewModel: DashboardViewModel;

  beforeEach(() => {
    mockItemsRepository = mock<ItemsRepository>();
    mockAuthService = mock(AuthService);

    const user = UserMother.create();
    when(mockAuthService.currentUser).thenReturn(signal(user));

    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve([]);

    viewModel = new DashboardViewModel(instance(mockItemsRepository), instance(mockAuthService));
  });

  it('should not load data if user is not logged in', async () => {
    when(mockAuthService.currentUser).thenReturn(signal(null));
    resetCalls(mockItemsRepository);

    viewModel = new DashboardViewModel(instance(mockItemsRepository), instance(mockAuthService));
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(viewModel.totalItems.value).toBe(0);
    verify(mockItemsRepository.findAll(anything() as unknown as string)).never();
  });

  it('should load data when initialized with logged in user', async () => {
    const items = [ItemMother.create()];
    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve(items);

    resetCalls(mockItemsRepository);

    viewModel = new DashboardViewModel(instance(mockItemsRepository), instance(mockAuthService));

    await new Promise(resolve => setTimeout(resolve, 0));

    expect(viewModel.totalItems.value).toBe(1);
    verify(mockItemsRepository.findAll(anything() as unknown as string)).once();
  });

  it('should calculate total items correctly', async () => {
    const items = [ItemMother.create(), ItemMother.create()];
    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve(items);

    await viewModel.loadData();

    expect(viewModel.totalItems.value).toBe(2);
  });

  it('should aggregate categories correctly', async () => {
    const cat1 = CategoryMother.create(undefined, Title.create('Books'));
    const cat2 = CategoryMother.create(undefined, Title.create('Video'));

    const item1 = ItemMother.create({ category: cat1 });
    const item2 = ItemMother.create({ category: cat1 });
    const item3 = ItemMother.create({ category: cat2 });

    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve([item1, item2, item3]);

    await viewModel.loadData();

    const categories = viewModel.categories.value;
    expect(categories).toHaveLength(2);

    expect(categories[0].name).toBe('Books');
    expect(categories[0].count).toBe(2);
    expect(categories[1].name).toBe('Video');
    expect(categories[1].count).toBe(1);

    expect(viewModel.totalCategories.value).toBe(2);
  });

  it('should aggregate tags correctly', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['tag1', 'tag2']) });
    const item2 = ItemMother.create({ tags: Tags.create(['tag2', 'tag3']) });

    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve([item1, item2]);

    await viewModel.loadData();

    const tags = viewModel.tags.value;
    expect(tags).toHaveLength(3);
    expect(tags[0]).toEqual({ name: 'tag2', count: 2 });
    expect(tags[1]).toEqual({ name: 'tag1', count: 1 });
    expect(tags[2]).toEqual({ name: 'tag3', count: 1 });
    expect(viewModel.totalTags.value).toBe(3);
  });

  it('should aggregate topics correctly', async () => {
    const item1 = ItemMother.create({ topic: Topic.create('Topic A') });
    const item2 = ItemMother.create({ topic: Topic.create('Topic B') });
    const item3 = ItemMother.create({ topic: Topic.create('Topic A') });

    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve([item1, item2, item3]);

    await viewModel.loadData();

    const topics = viewModel.topics.value;
    expect(topics).toHaveLength(2);
    expect(topics[0]).toEqual({ name: 'Topic A', count: 2 });
    expect(topics[1]).toEqual({ name: 'Topic B', count: 1 });
    expect(viewModel.totalTopics.value).toBe(2);
  });

  it('should aggregate formats correctly', async () => {
    const item1 = ItemMother.create({ format: Format.create('Digital') });
    const item2 = ItemMother.create({ format: Format.create('Physical') });
    const item3 = ItemMother.create({ format: Format.create('Digital') });

    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve([item1, item2, item3]);

    await viewModel.loadData();

    const formats = viewModel.formats.value;
    expect(formats).toHaveLength(2);
    expect(formats[0]).toEqual({ name: 'Digital', count: 2 });
    expect(formats[1]).toEqual({ name: 'Physical', count: 1 });
    expect(viewModel.totalFormats.value).toBe(2);
  });

  it('should aggregate publishers correctly', async () => {
    const item1 = ItemMother.create({ publisher: Publisher.create('Publisher A') });
    const item2 = ItemMother.create({ publisher: Publisher.create('Publisher B') });
    const item3 = ItemMother.create({ publisher: Publisher.create('Publisher A') });

    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve([item1, item2, item3]);

    await viewModel.loadData();

    const publishers = viewModel.publishers.value;
    expect(publishers).toHaveLength(2);
    expect(publishers[0]).toEqual({ name: 'Publisher A', count: 2 });
    expect(publishers[1]).toEqual({ name: 'Publisher B', count: 1 });
    expect(viewModel.totalPublishers.value).toBe(2);
  });

  it('should return last 5 created items sorted by date', async () => {
    const now = new Date();
    const item1 = ItemMother.create({ created: Created.create(new Date(now.getTime() - 1000)) });
    const item2 = ItemMother.create({ created: Created.create(new Date(now.getTime() - 2000)) });
    const item3 = ItemMother.create({ created: Created.create(new Date(now.getTime() - 3000)) });
    const item4 = ItemMother.create({ created: Created.create(new Date(now.getTime() - 4000)) });
    const item5 = ItemMother.create({ created: Created.create(new Date(now.getTime() - 5000)) });
    const item6 = ItemMother.create({ created: Created.create(new Date(now.getTime() - 6000)) });

    when(mockItemsRepository.findAll(anything() as unknown as string)).thenResolve([
      item6,
      item5,
      item4,
      item3,
      item2,
      item1
    ]);

    await viewModel.loadData();

    const lastCreated = viewModel.lastCreatedItems.value;
    expect(lastCreated).toHaveLength(5);
    expect(lastCreated[0].id.value).toBe(item1.id.value);
    expect(lastCreated[1].id.value).toBe(item2.id.value);
    expect(lastCreated[2].id.value).toBe(item3.id.value);
    expect(lastCreated[3].id.value).toBe(item4.id.value);
    expect(lastCreated[4].id.value).toBe(item5.id.value);
  });
});
