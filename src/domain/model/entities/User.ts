import { Id } from '../value-objects/Id';

export class User {
  private constructor(
    public readonly id: Id,
    public readonly name: string,
    public readonly email: string
  ) {}

  public static create(id: Id, name: string, email: string): User {
    return new User(id, name, email);
  }

  public static empty(): User {
    return new User(Id.empty(), '', '');
  }
}
