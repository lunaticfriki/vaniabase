import { Id } from '../value-objects/Id';
import { Title } from '../value-objects/StringValues';

export class Category {
  private constructor(
    public readonly id: Id,
    public readonly name: Title
  ) {}

  public static create(id: Id, name: Title): Category {
    return new Category(id, name);
  }

  public static empty(): Category {
    return new Category(Id.empty(), Title.empty());
  }
}
