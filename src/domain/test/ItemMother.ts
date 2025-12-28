import { faker } from '@faker-js/faker';
import { Item } from '../model/entities/Item';
import { Id } from '../model/value-objects/Id';
import {
  Title,
  Description,
  Author,
  Cover,
  Owner,
  Topic,
  Format,
  Publisher,
  Language
} from '../model/value-objects/StringValues';
import { Tags } from '../model/value-objects/Tags';
import { Created, Completed, Year } from '../model/value-objects/DateAndNumberValues';
import { Category } from '../model/entities/Category';
import { CategoryMother } from './CategoryMother';

export class ItemMother {
  static create(
    data?: Partial<{
      id: Id;
      title: Title;
      description: Description;
      author: Author;
      cover: Cover;
      owner: Owner;
      tags: Tags;
      topic: Topic;
      format: Format;
      created: Created;
      completed: Completed;
      year: Year;
      publisher: Publisher;
      language: Language;
      category: Category;
      ownerId: Id;
    }>
  ): Item {
    return Item.create(
      data?.id ? data.id : Id.random(),
      data?.title ? data.title : Title.create(faker.commerce.productName()),
      data?.description ? data.description : Description.create(faker.commerce.productDescription()),
      data?.author ? data.author : Author.create(faker.person.fullName()),
      data?.cover ? data.cover : Cover.create(faker.image.url()),
      data?.owner ? data.owner : Owner.create(faker.person.fullName()),
      data?.tags ? data.tags : Tags.create([faker.word.sample()]),
      data?.topic ? data.topic : Topic.create(faker.word.noun()),
      data?.format ? data.format : Format.create('Digital'),
      data?.created ? data.created : Created.create(faker.date.past()),
      data?.completed ? data.completed : Completed.create(null),
      data?.year ? data.year : Year.create(faker.date.past().getFullYear()),
      data?.publisher ? data.publisher : Publisher.create(faker.company.name()),
      data?.language ? data.language : Language.create('English'),
      data?.category || CategoryMother.create(),
      data?.ownerId ? data.ownerId : Id.random()
    );
  }

  static empty(): Item {
    return Item.create(
      Id.empty(),
      Title.empty(),
      Description.empty(),
      Author.empty(),
      Cover.empty(),
      Owner.empty(),
      Tags.empty(),
      Topic.empty(),
      Format.empty(),
      Created.empty(),
      Completed.empty(),
      Year.empty(),
      Publisher.empty(),
      Language.empty(),
      Category.empty(),
      Id.empty()
    );
  }

  static createRandom() {
    const title = faker.commerce.productName();
    const encodedTitle = encodeURIComponent(title);
    return this.create({
      id: Id.random(),
      title: Title.create(title),
      description: Description.create(faker.commerce.productDescription()),
      author: Author.create(faker.person.fullName()),
      cover: Cover.create(`https://placehold.co/400x600/2E004F/FF00FF?text=${encodedTitle}`),
      owner: Owner.create(faker.person.fullName()),
      tags: Tags.create([faker.word.sample()]),
      topic: Topic.create(faker.word.noun()),
      format: Format.create('Digital'),
      created: Created.create(faker.date.past()),
      completed: Completed.create(null),
      year: Year.create(faker.date.past().getFullYear()),
      publisher: Publisher.create(faker.company.name()),
      language: Language.create('English'),
      category: CategoryMother.create(),
      ownerId: Id.random()
    });
  }
}
