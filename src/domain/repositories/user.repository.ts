import { User } from '../model/entities/user.entity';
import { Id } from '../model/value-objects/id.valueObject';

export abstract class UserRepository {
  abstract save(user: User): Promise<void>;
  abstract findById(id: Id): Promise<User | undefined>;
}
