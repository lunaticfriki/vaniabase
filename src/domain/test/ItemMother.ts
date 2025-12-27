import { faker } from '@faker-js/faker';
import { Item } from '../model/entities/Item';
import { Id } from '../model/value-objects/Id';
import { Title, Description, Author, Cover, Owner, Topic, Format, Publisher, Language } from '../model/value-objects/StringValues';
import { Tags } from '../model/value-objects/Tags';
import { Created, Completed, Year } from '../model/value-objects/DateAndNumberValues';
import { Category } from '../model/entities/Category';
import { CategoryMother } from './CategoryMother';

export class ItemMother {
  static create(data?: Partial<{
    id: string;
    title: string;
    description: string;
    author: string;
    cover: string;
    owner: string;
    tags: string[];
    topic: string;
    format: string;
    created: Date;
    completed: Date | null;
    year: number;
    publisher: string;
    language: string;
    category: Category;
  }>): Item {
    return Item.create(
      data?.id ? Id.create(data.id) : Id.random(),
      Title.create(data?.title || faker.commerce.productName()),
      Description.create(data?.description || faker.commerce.productDescription()),
      Author.create(data?.author || faker.person.fullName()),
      Cover.create(data?.cover || faker.image.url()),
      Owner.create(data?.owner || faker.person.fullName()),
      Tags.create(data?.tags || [faker.word.sample()]),
      Topic.create(data?.topic || faker.word.noun()),
      Format.create(data?.format || 'Digital'),
      Created.create(data?.created || faker.date.past()),
      Completed.create(data?.completed !== undefined ? data.completed : null),
      Year.create(data?.year || faker.date.past().getFullYear()),
      Publisher.create(data?.publisher || faker.company.name()),
      Language.create(data?.language || 'English'),
      data?.category || CategoryMother.create()
    );
  }
}
