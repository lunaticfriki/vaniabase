import { Id } from '../value-objects/id.valueObject';

export class User {
  private constructor(
    public readonly id: Id,
    public readonly name: string,
    public readonly email: string,
    public readonly avatar: string
  ) {}

  public static create(id: Id, name: string, email: string, avatar: string): User {
    return new User(id, name, email, avatar);
  }

  public static empty(): User {
    return new User(Id.empty(), '', '', '');
  }
}
