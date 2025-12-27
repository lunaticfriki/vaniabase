import { faker } from '@faker-js/faker';
import { Category } from '../model/entities/Category';
import { Id } from '../model/value-objects/Id';
import { Title } from '../model/value-objects/StringValues';

export class CategoryMother {
  static create(id?: string, name?: string): Category {
    return Category.create(
      id ? Id.create(id) : Id.random(),
      Title.create(name || faker.commerce.department())
    );
  }

  static books(): Category { return this.create(undefined, 'Books'); }
  static comics(): Category { return this.create(undefined, 'Comics'); }
  static video(): Category { return this.create(undefined, 'Video'); }
  static games(): Category { return this.create(undefined, 'Games'); }
  static music(): Category { return this.create(undefined, 'Music'); }
  static magazines(): Category { return this.create(undefined, 'Magazines'); }
  
  static all(): Category[] {
    return [
        this.books(),
        this.comics(),
        this.video(),
        this.games(),
        this.music(),
        this.magazines()
    ]
  }
}
