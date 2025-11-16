import { Item, type IItem } from '../../item';
import { faker } from '@faker-js/faker';

export class ItemMother {
  static createWIthData(data: IItem): Item {
    return new Item(
      data.id,
      data.name,
      data.author,
      data.description,
      data.imageUrl,
      data.topic,
      data.tags,
      data.owner,
      data.compeleted,
      data.year,
      data.language,
      data.format
    );
  }

  static createEmpty(): Item {
    return new Item('', '', '', '', '', '', [], '', false, '', '', '');
  }

  static createRandom(): Item {
    return new Item(
      faker.string.uuid(),
      faker.lorem.words(3),
      faker.lorem.words(2),
      faker.lorem.sentence(),
      faker.image.url(),
      faker.lorem.word(),
      [faker.lorem.word(), faker.lorem.word()],
      faker.string.uuid(),
      faker.datatype.boolean(),
      faker.date.past().getFullYear().toString(),
      faker.lorem.word(),
      faker.system.fileType()
    );
  }
}
