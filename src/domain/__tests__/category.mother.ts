import { faker } from '@faker-js/faker';
import { Category } from '../model/entities/category.entity';
import { Id } from '../model/value-objects/id.valueObject';
import { Title } from '../model/value-objects/stringValues.valueObject';

export class CategoryMother {
  static create(id?: Id, name?: Title): Category {
    return Category.create(id ? id : Id.random(), name ? name : Title.create(faker.commerce.department()));
  }

  static books(): Category {
    return this.create(Id.random(), Title.create('Books'));
  }
  static comics(): Category {
    return this.create(Id.random(), Title.create('Comics'));
  }
  static video(): Category {
    return this.create(Id.random(), Title.create('Video'));
  }
  static games(): Category {
    return this.create(Id.random(), Title.create('Games'));
  }
  static music(): Category {
    return this.create(Id.random(), Title.create('Music'));
  }
  static magazines(): Category {
    return this.create(Id.random(), Title.create('Magazines'));
  }

  static all(): Category[] {
    return [this.books(), this.comics(), this.video(), this.games(), this.music(), this.magazines()];
  }

  static empty(): Category {
    return Category.create(Id.empty(), Title.empty());
  }

  static createRandom() {
    return this.create(Id.random(), Title.create(faker.commerce.department()));
  }
}
