import { Item } from '@app/domain/item/item';

export const ITEM_SEED: Item[] = [
  Item.create(
    'item1',
    'Clean Code',
    'Robert C. Martin',
    'book',
    'A Handbook of Agile Software Craftsmanship.',
    'https://example.com/cleancode.jpg',
    'Programming',
    'Software Engineering',
    ['clean code', 'best practices', 'agile'],
    false,
    new Date('2023-01-01T10:00:00Z'),
    new Date('2023-01-01T10:00:00Z'),
    'user_abc123'
  ),
  Item.create(
    'item2',
    'Angular in Action',
    'Jeremy Wilken',
    'book',
    'Comprehensive guide to Angular framework.',
    'https://example.com/angular.jpg',
    'Programming',
    'Web Development',
    ['angular', 'typescript', 'frontend'],
    true,
    new Date('2023-02-15T12:00:00Z'),
    new Date('2023-03-01T09:00:00Z'),
    'user_xyz789'
  ),
  Item.create(
    'item3',
    'React Podcast',
    'Michael Chan',
    'podcast',
    'Conversations about React and frontend development.',
    'https://example.com/reactpodcast.jpg',
    'Programming',
    'Frontend',
    ['react', 'podcast', 'javascript'],
    false,
    new Date('2023-04-10T08:30:00Z'),
    new Date('2023-04-10T08:30:00Z'),
    'user_abc123'
  ),
  Item.create(
    'item4',
    "You Don't Know JS",
    'Kyle Simpson',
    'book',
    'A deep dive into JavaScript core mechanisms.',
    'https://example.com/ydkjs.jpg',
    'Programming',
    'JavaScript',
    ['javascript', 'deep dive', 'programming'],
    false,
    new Date('2023-05-01T11:00:00Z'),
    new Date('2023-05-01T11:00:00Z'),
    'user_xyz789'
  ),
  Item.create(
    'item5',
    'The Pragmatic Programmer',
    'Andrew Hunt & David Thomas',
    'book',
    'Classic tips for effective software development.',
    'https://example.com/pragmatic.jpg',
    'Programming',
    'Software Engineering',
    ['pragmatic', 'tips', 'software'],
    true,
    new Date('2023-06-10T09:00:00Z'),
    new Date('2023-06-15T09:00:00Z'),
    'user_abc123'
  ),
  Item.create(
    'item6',
    'Refactoring UI',
    'Adam Wathan & Steve Schoger',
    'book',
    'Practical design advice for developers.',
    'https://example.com/refactoringui.jpg',
    'Design',
    'UI/UX',
    ['ui', 'ux', 'design'],
    false,
    new Date('2023-07-20T14:00:00Z'),
    new Date('2023-07-20T14:00:00Z'),
    'user_xyz789'
  ),
  Item.create(
    'item7',
    'Syntax Podcast',
    'Wes Bos & Scott Tolinski',
    'podcast',
    'A podcast for web developers.',
    'https://example.com/syntax.jpg',
    'Programming',
    'Web Development',
    ['podcast', 'web', 'javascript'],
    false,
    new Date('2023-08-05T16:00:00Z'),
    new Date('2023-08-05T16:00:00Z'),
    'user_abc123'
  ),
  Item.create(
    'item8',
    'Atomic Habits',
    'James Clear',
    'book',
    'An easy & proven way to build good habits.',
    'https://example.com/atomichabits.jpg',
    'Self-Development',
    'Habits',
    ['habits', 'self-improvement', 'productivity'],
    true,
    new Date('2023-09-12T10:00:00Z'),
    new Date('2023-09-20T10:00:00Z'),
    'user_xyz789'
  ),
  Item.create(
    'item9',
    'The Changelog',
    'Adam Stacoviak & Jerod Santo',
    'podcast',
    'Conversations with the hackers, leaders, and innovators.',
    'https://example.com/changelog.jpg',
    'Programming',
    'Open Source',
    ['podcast', 'opensource', 'development'],
    false,
    new Date('2023-10-01T13:00:00Z'),
    new Date('2023-10-01T13:00:00Z'),
    'user_abc123'
  ),
  Item.create(
    'item10',
    'Deep Work',
    'Cal Newport',
    'book',
    'Rules for focused success in a distracted world.',
    'https://example.com/deepwork.jpg',
    'Self-Development',
    'Productivity',
    ['focus', 'productivity', 'work'],
    false,
    new Date('2023-11-15T08:00:00Z'),
    new Date('2023-11-15T08:00:00Z'),
    'user_xyz789'
  ),
];
