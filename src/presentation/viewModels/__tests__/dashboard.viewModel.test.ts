
import 'reflect-metadata';
import { mock, instance, when, verify, resetCalls } from 'ts-mockito';
import { DashboardViewModel } from '../dashboard.viewModel';
import { AuthService } from '../../../application/auth/auth.service';
import { ItemsRepository } from '../../../domain/repositories/items.repository';
import { signal } from '@preact/signals';
import { ItemMother } from '../../../domain/__tests__/item.mother';
import { CategoryMother } from '../../../domain/__tests__/category.mother';
import { UserMother } from '../../../domain/__tests__/user.mother';
import { Tags } from '../../../domain/model/value-objects/tags.valueObject';
import { Topic, Format, Title } from '../../../domain/model/value-objects/stringValues.valueObject';

describe('DashboardViewModel', () => {
  let mockItemsRepository: ItemsRepository;
  let mockAuthService: AuthService;
  let viewModel: DashboardViewModel;

  beforeEach(() => {
    mockItemsRepository = mock<ItemsRepository>();
    mockAuthService = mock(AuthService);
    
    const user = UserMother.create();
    when(mockAuthService.currentUser).thenReturn(signal(user));

    when(mockItemsRepository.findAll()).thenResolve([]);

    viewModel = new DashboardViewModel(
      instance(mockItemsRepository),
      instance(mockAuthService)
    );
  });

  it('should not load data if user is not logged in', async () => {
    when(mockAuthService.currentUser).thenReturn(signal(null));
    resetCalls(mockItemsRepository);

    viewModel = new DashboardViewModel(
      instance(mockItemsRepository),
      instance(mockAuthService)
    );
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(viewModel.totalItems.value).toBe(0);
    verify(mockItemsRepository.findAll()).never();
  });

  it('should load data when initialized with logged in user', async () => {
    const items = [ItemMother.create()];
    when(mockItemsRepository.findAll()).thenResolve(items);
    
    resetCalls(mockItemsRepository);

    viewModel = new DashboardViewModel(
      instance(mockItemsRepository),
      instance(mockAuthService)
    );

    await new Promise(resolve => setTimeout(resolve, 0)); 

    expect(viewModel.totalItems.value).toBe(1);
    verify(mockItemsRepository.findAll()).once();
  });

  it('should calculate total items correctly', async () => {
    const items = [ItemMother.create(), ItemMother.create()];
    when(mockItemsRepository.findAll()).thenResolve(items);
    
    await viewModel.loadData();
    
    expect(viewModel.totalItems.value).toBe(2);
  });

  it('should aggregate categories correctly', async () => {
    const cat1 = CategoryMother.create(undefined, Title.create('Books'));
    const cat2 = CategoryMother.create(undefined, Title.create('Movies'));
    
    const item1 = ItemMother.create({ category: cat1 });
    const item2 = ItemMother.create({ category: cat1 }); 
    const item3 = ItemMother.create({ category: cat2 });

    when(mockItemsRepository.findAll()).thenResolve([item1, item2, item3]);
    
    await viewModel.loadData();
    
    const categories = viewModel.categories.value;
    expect(categories).toHaveLength(2);
    
    expect(categories[0].name).toBe('Books');
    expect(categories[0].count).toBe(2);
    expect(categories[1].name).toBe('Movies');
    expect(categories[1].count).toBe(1);
    
    expect(viewModel.totalCategories.value).toBe(2);
  });

  it('should aggregate tags correctly', async () => {
    const item1 = ItemMother.create({ tags: Tags.create(['tag1', 'tag2']) });
    const item2 = ItemMother.create({ tags: Tags.create(['tag2', 'tag3']) });
    
    when(mockItemsRepository.findAll()).thenResolve([item1, item2]);
    
    await viewModel.loadData();
    
    const tags = viewModel.tags.value;
    expect(tags).toHaveLength(3); 
    expect(tags).toEqual(['tag1', 'tag2', 'tag3']); 
    expect(viewModel.totalTags.value).toBe(3);
  });

  it('should aggregate topics correctly', async () => {
    const item1 = ItemMother.create({ topic: Topic.create('Topic A') });
    const item2 = ItemMother.create({ topic: Topic.create('Topic B') });
    const item3 = ItemMother.create({ topic: Topic.create('Topic A') }); 
    
    when(mockItemsRepository.findAll()).thenResolve([item1, item2, item3]);
    
    await viewModel.loadData();
    
    const topics = viewModel.topics.value;
    expect(topics).toHaveLength(2);
    expect(topics).toEqual(['Topic A', 'Topic B']); 
    expect(viewModel.totalTopics.value).toBe(2);
  });

  it('should aggregate formats correctly', async () => {
    const item1 = ItemMother.create({ format: Format.create('Digital') });
    const item2 = ItemMother.create({ format: Format.create('Physical') });
    const item3 = ItemMother.create({ format: Format.create('Digital') }); 
    
    when(mockItemsRepository.findAll()).thenResolve([item1, item2, item3]);
    
    await viewModel.loadData();
    
    const formats = viewModel.formats.value;
    expect(formats).toHaveLength(2);
    expect(formats).toEqual(['Digital', 'Physical']); 
    expect(viewModel.totalFormats.value).toBe(2);
  });
});
