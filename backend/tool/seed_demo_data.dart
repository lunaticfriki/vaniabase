import 'dart:io';

import 'package:backend/composition_root.dart';
import 'package:backend/modules/catalog/application/command/create_item_command.dart';
import 'package:backend/modules/catalog/application/item_write_service.dart';
import 'package:backend/modules/identity/application/command/register_user_command.dart';
import 'package:backend/modules/identity/application/identity_write_service.dart';
import 'package:backend/shared/db/database.dart';
import 'package:backend/shared/db/database_config.dart';
import 'package:backend/shared/db/migration_runner.dart';
import 'package:backend/shared/env_config.dart';
import 'package:core/modules/catalog/domain/criteria/item_criteria.dart';
import 'package:core/modules/catalog/domain/repositories/item_repository.dart';
import 'package:core/modules/identity/domain/repositories/user_repository.dart';
import 'package:core/modules/identity/domain/value_objects/email.dart';
import 'package:core/shared/pagination/page_request.dart';

const demoEmail = 'demo@vaniabase.dev';
const demoUsername = 'demo';
const demoPassword = 'demo12345';

final _seedItems = <CreateItemCommand>[
  const CreateItemCommand(
    ownerId: '',
    title: 'Dune',
    creator: ['Frank Herbert'],
    publisher: 'Chilton Books',
    category: 'book',
    format: 'hardcover',
    tags: ['sci-fi', 'classic'],
    topic: 'Science Fiction',
    year: 1965,
    description: 'A desert planet epic of politics, prophecy and ecology.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-1/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'The Hobbit',
    creator: ['J.R.R. Tolkien'],
    publisher: 'Allen & Unwin',
    category: 'book',
    format: 'paperback',
    tags: ['fantasy', 'classic'],
    topic: 'Fantasy',
    year: 1937,
    description: 'A hobbit is swept into an unexpected adventure.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-2/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Neuromancer',
    creator: ['William Gibson'],
    publisher: 'Ace Books',
    category: 'book',
    format: 'ebook',
    tags: ['cyberpunk'],
    topic: 'Science Fiction',
    year: 1984,
    description: 'The novel that defined cyberpunk.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-3/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: '1984',
    creator: ['George Orwell'],
    publisher: 'Secker & Warburg',
    category: 'book',
    format: 'hardcover',
    tags: ['dystopian', 'classic'],
    topic: 'Dystopian Fiction',
    year: 1949,
    description: 'A surveillance-state dystopia.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-4/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Snow Crash',
    creator: ['Neal Stephenson'],
    publisher: 'Bantam Books',
    category: 'book',
    format: 'ebook',
    tags: ['cyberpunk'],
    topic: 'Science Fiction',
    year: 1992,
    description: 'A pizza-delivery hacker saves the metaverse.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-5/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Watchmen',
    creator: ['Alan Moore', 'Dave Gibbons'],
    publisher: 'DC Comics',
    category: 'comic',
    format: 'paperback',
    tags: ['superhero'],
    topic: 'Superhero Fiction',
    year: 1987,
    description: 'A deconstruction of the superhero genre.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-6/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Maus',
    creator: ['Art Spiegelman'],
    publisher: 'Pantheon Books',
    category: 'comic',
    format: 'hardcover',
    tags: ['memoir', 'history'],
    topic: 'Holocaust Memoir',
    year: 1991,
    description: 'A graphic memoir of survival during the Holocaust.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-7/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Saga, Vol. 1',
    creator: ['Brian K. Vaughan', 'Fiona Staples'],
    publisher: 'Image Comics',
    category: 'comic',
    format: 'ebook',
    tags: ['sci-fi', 'fantasy'],
    topic: 'Space Opera',
    year: 2012,
    description: 'Star-crossed lovers from warring galactic factions.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-8/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'National Geographic',
    creator: ['National Geographic Society'],
    publisher: 'National Geographic Partners',
    category: 'magazine',
    format: 'paperback',
    tags: ['nature', 'science'],
    topic: 'Nature',
    year: 2023,
    description: 'Monthly exploration of the natural world.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-9/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'WIRED',
    creator: ['WIRED Staff'],
    publisher: 'Condé Nast',
    category: 'magazine',
    format: 'digitalDownload',
    tags: ['technology'],
    topic: 'Technology',
    year: 2023,
    description: 'Where tomorrow is realized.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-10/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Blade Runner',
    creator: ['Ridley Scott'],
    publisher: 'Warner Bros.',
    category: 'movie',
    format: 'bluRay',
    tags: ['sci-fi', 'noir'],
    topic: 'Science Fiction',
    year: 1982,
    description: 'A blade runner hunts rogue replicants.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-11/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'The Matrix',
    creator: ['Lana Wachowski', 'Lilly Wachowski'],
    publisher: 'Warner Bros.',
    category: 'movie',
    format: 'dvd',
    tags: ['sci-fi', 'action'],
    topic: 'Science Fiction',
    year: 1999,
    description: 'A hacker discovers reality is a simulation.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-12/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Parasite',
    creator: ['Bong Joon-ho'],
    publisher: 'CJ Entertainment',
    category: 'movie',
    format: 'digitalDownload',
    tags: ['thriller', 'drama'],
    topic: 'Social Satire',
    year: 2019,
    description: 'Class conflict between two families.',
    language: 'ko',
    imageUrl: 'https://picsum.photos/seed/vaniabase-13/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Chrono Trigger',
    creator: ['Square'],
    publisher: 'Square',
    category: 'videogame',
    format: 'cartridge',
    tags: ['jrpg', 'time-travel'],
    topic: 'Role-Playing Game',
    year: 1995,
    description: 'A time-traveling JRPG classic.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-14/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'The Last of Us Part II',
    creator: ['Naughty Dog'],
    publisher: 'Sony Interactive Entertainment',
    category: 'videogame',
    format: 'bluRay',
    tags: ['action', 'survival'],
    topic: 'Post-Apocalyptic Fiction',
    year: 2020,
    description: 'A story of revenge in a post-pandemic world.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-15/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Hades',
    creator: ['Supergiant Games'],
    publisher: 'Supergiant Games',
    category: 'videogame',
    format: 'digitalDownload',
    tags: ['roguelike'],
    topic: 'Greek Mythology',
    year: 2020,
    description: 'Escape the underworld, one run at a time.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-16/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Half-Life 2',
    creator: ['Valve'],
    publisher: 'Valve',
    category: 'videogame',
    format: 'dvd',
    tags: ['fps'],
    topic: 'Science Fiction',
    year: 2004,
    description: 'Gordon Freeman returns to fight the Combine.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-17/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'The Dark Side of the Moon',
    creator: ['Pink Floyd'],
    publisher: 'Harvest Records',
    category: 'musicAlbum',
    format: 'vinyl',
    tags: ['progressive-rock'],
    topic: 'Progressive Rock',
    year: 1973,
    description: 'A concept album about conflict and mortality.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-18/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Kind of Blue',
    creator: ['Miles Davis'],
    publisher: 'Columbia Records',
    category: 'musicAlbum',
    format: 'cd',
    tags: ['jazz'],
    topic: 'Jazz',
    year: 1959,
    description: 'A landmark modal jazz recording.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-19/400/600',
  ),
  const CreateItemCommand(
    ownerId: '',
    title: 'Random Access Memories',
    creator: ['Daft Punk'],
    publisher: 'Columbia Records',
    category: 'musicAlbum',
    format: 'digitalDownload',
    tags: ['electronic', 'disco'],
    topic: 'Electronic',
    year: 2013,
    description: 'A homage to late-70s/early-80s American music.',
    language: 'en',
    imageUrl: 'https://picsum.photos/seed/vaniabase-20/400/600',
  ),
];

Future<void> main() async {
  final dbConfig = DatabaseConfig.fromEnvironment();
  final envConfig = EnvConfig.fromEnvironment();
  final pool = createConnectionPool(dbConfig);

  await MigrationRunner(pool, Directory('migrations')).run();
  configureDependencies(pool, envConfig);

  final users = getIt<UserRepository>();
  final identity = getIt<IdentityWriteService>();

  var demoUser = await users.findByEmail(Email.create(demoEmail));
  if (demoUser == null) {
    await identity.register(
      const RegisterUserCommand(
        email: demoEmail,
        username: demoUsername,
        password: demoPassword,
      ),
    );
    demoUser = await users.findByEmail(Email.create(demoEmail));
    print('created demo user: $demoEmail / $demoPassword');
  } else {
    print('demo user already exists: $demoEmail / $demoPassword');
  }

  final ownerId = demoUser!.id;

  final items = getIt<ItemRepository>();
  final existing = await items.list(
    ItemCriteria(ownerId: ownerId, pageRequest: PageRequest.first(pageSize: 1)),
  );
  if (existing.totalItems > 0) {
    print('demo user already has ${existing.totalItems} item(s), skipping seed');
    await pool.close();
    return;
  }

  final writes = getIt<ItemWriteService>();
  for (final item in _seedItems) {
    await writes.create(
      CreateItemCommand(
        ownerId: ownerId.value,
        title: item.title,
        creator: item.creator,
        publisher: item.publisher,
        category: item.category,
        format: item.format,
        tags: item.tags,
        topic: item.topic,
        year: item.year,
        description: item.description,
        language: item.language,
        imageUrl: item.imageUrl,
      ),
    );
  }

  print('seeded ${_seedItems.length} items for $demoEmail');
  await pool.close();
}
