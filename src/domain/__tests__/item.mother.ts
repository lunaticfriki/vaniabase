import { faker } from '@faker-js/faker';
import { Item } from '../model/entities/item.entity';
import { Id } from '../model/value-objects/id.valueObject';
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
} from '../model/value-objects/stringValues.valueObject';
import { Tags } from '../model/value-objects/tags.valueObject';
import { Created, Completed, Year } from '../model/value-objects/dateAndNumberValues.valueObject';
import { Category } from '../model/entities/category.entity';
import { CategoryMother } from './category.mother';
import { ImageLookupService } from '../../infrastructure/services/imageLookupService';

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
    }>
  ): Item {
    return Item.create({
      id: data?.id ? data.id : Id.random(),
      title: data?.title ? data.title : Title.create(faker.commerce.productName()),
      description: data?.description ? data.description : Description.create(faker.commerce.productDescription()),
      author: data?.author ? data.author : Author.create(faker.person.fullName()),
      cover: data?.cover ? data.cover : Cover.create(faker.image.url()),
      owner: data?.owner ? data.owner : Owner.create(faker.person.fullName()),
      tags: data?.tags ? data.tags : Tags.create([faker.word.sample()]),
      topic: data?.topic ? data.topic : Topic.create(faker.word.noun()),
      format: data?.format ? data.format : Format.create('Digital'),
      created: data?.created ? data.created : Created.create(faker.date.past()),
      completed: data?.completed ? data.completed : Completed.create(false),
      year: data?.year ? data.year : Year.create(faker.date.past().getFullYear()),
      publisher: data?.publisher ? data.publisher : Publisher.create(faker.company.name()),
      language: data?.language ? data.language : Language.create('English'),
      category: data?.category || CategoryMother.create()
    });
  }

  static empty(): Item {
    return Item.create({
      id: Id.empty(),
      title: Title.empty(),
      description: Description.empty(),
      author: Author.empty(),
      cover: Cover.empty(),
      owner: Owner.empty(),
      tags: Tags.empty(),
      topic: Topic.empty(),
      format: Format.empty(),
      created: Created.empty(),
      completed: Completed.empty(),
      year: Year.empty(),
      publisher: Publisher.empty(),
      language: Language.empty(),
      category: Category.empty()
    });
  }

  static createRandom() {
    const id = Id.random();
    const title = faker.commerce.productName();

    return this.create({
      id,
      title: Title.create(title),
      description: Description.create(faker.commerce.productDescription()),
      author: Author.create(faker.person.fullName()),
      cover: Cover.create(ImageLookupService.getCoverFor(id)),
      owner: Owner.create(faker.person.fullName()),
      tags: Tags.create([faker.word.sample()]),
      topic: Topic.create(faker.word.noun()),
      format: Format.create('Digital'),
      created: Created.create(faker.date.past()),
      completed: Completed.create(Math.random() > 0.5),
      year: Year.create(faker.date.past().getFullYear()),
      publisher: Publisher.create(faker.company.name()),
      language: Language.create('English'),
      category: CategoryMother.create()
    });
  }
}
