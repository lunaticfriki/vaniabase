import { ItemMother } from './objectMothers/item.mother';

describe('item domain tests', () => {
  it('should create an item', () => {
    const item = ItemMother.createRandom();

    expect(item).toBeDefined();
    expect(item.id).toBeDefined();
    expect(item.name).toBeDefined();
    expect(item.author).toBeDefined();
    expect(item.description).toBeDefined();
    expect(item.imageUrl).toBeDefined();
    expect(item.topic).toBeDefined();
    expect(item.tags).toBeDefined();
    expect(item.owner).toBeDefined();
    expect(item.completed).toBeDefined();
    expect(item.year).toBeDefined();
    expect(item.language).toBeDefined();
    expect(item.format).toBeDefined();
  });

  it('should create an empty item', () => {
    const item = ItemMother.createEmpty();

    expect(item).toBeDefined();
    expect(item.id).toBe('');
    expect(item.name).toBe('');
    expect(item.author).toBe('');
    expect(item.description).toBe('');
    expect(item.imageUrl).toBe('');
    expect(item.topic).toBe('');
    expect(item.tags).toEqual([]);
    expect(item.owner).toBe('');
    expect(item.completed).toBe(false);
    expect(item.year).toBe('');
    expect(item.language).toBe('');
    expect(item.format).toBe('');
  });

  it('should create an item with specific data', () => {
    const data = {
      id: '123',
      name: 'Test Item',
      author: 'Test Author',
      description: 'This is a test item',
      imageUrl: 'http://example.com/image.jpg',
      topic: 'Test Topic',
      tags: ['tag1', 'tag2'],
      owner: 'owner123',
      completed: true,
      year: '2023',
      language: 'English',
      format: 'PDF',
    };
    const item = ItemMother.createWithData(data);

    expect(item).toBeDefined();
    expect(item.id).toBe(data.id);
    expect(item.name).toBe(data.name);
    expect(item.author).toBe(data.author);
    expect(item.description).toBe(data.description);
    expect(item.imageUrl).toBe(data.imageUrl);
    expect(item.topic).toBe(data.topic);
    expect(item.tags).toEqual(data.tags);
    expect(item.owner).toBe(data.owner);
    expect(item.completed).toBe(data.completed);
    expect(item.year).toBe(data.year);
    expect(item.language).toBe(data.language);
    expect(item.format).toBe(data.format);
  });

  it('should update item properties', () => {
    const item = ItemMother.createRandom();
    const newName = 'Updated Name';
    const newAuthor = 'Updated Author';

    const updatedItem = item.update(item, {
      name: newName,
      author: newAuthor,
    });
    expect(updatedItem.name).toBe(newName);
    expect(updatedItem.author).toBe(newAuthor);
    expect(updatedItem.id).toBe(item.id);
  });

  it('should mark item as completed', () => {
    const item = ItemMother.createRandom();
    const completedItem = item.markAsCompleted();

    expect(completedItem.completed).toBe(true);
    expect(completedItem.id).toBe(item.id);
  });

  it('should toggle item completion status', () => {
    const item = ItemMother.createRandom();
    const toggledItem = item.toggleComplete();

    expect(toggledItem.completed).toBe(!item.completed);
    expect(toggledItem.id).toBe(item.id);
  });

  it('should get item label', () => {
    const item = ItemMother.createRandom();
    const label = item.getLabel();

    expect(label).toBe(`${item.name} - (${item.author})`);
  });
});
