import { faker } from '@faker-js/faker';
import { User } from '../model/entities/user.entity';
import { Id } from '../model/value-objects/id.valueObject';

export class UserMother {
  public static create(id?: string, name?: string, email?: string, avatar?: string): User {
    return User.create(
      id ? Id.create(id) : Id.create(faker.string.uuid()),
      name ?? faker.person.fullName(),
      email ?? faker.internet.email(),
      avatar ?? faker.image.avatar()
    );
  }

  public static random(): User {
    return this.create();
  }

  public static empty(): User {
    return User.empty();
  }
}
