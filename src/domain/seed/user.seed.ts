import { Id } from '../model/value-objects/id.valueObject';
import { User } from '../model/entities/user.entity';

export const USER_IDS = ['user-1', 'user-2', 'user-3'];

export class UserSeed {
  public static generate(): User[] {
    return [
      User.create(
        Id.create('user-1'),
        'Vania',
        'vania@example.com',
        'https://api.dicebear.com/9.x/pixel-art/svg?seed=Vania'
      ),
      User.create(
        Id.create('user-2'),
        'Rodia',
        'rodia@example.com',
        'https://api.dicebear.com/9.x/pixel-art/svg?seed=Rodia'
      ),
      User.create(
        Id.create('user-3'),
        'Hylia',
        'hylia@example.com',
        'https://api.dicebear.com/9.x/pixel-art/svg?seed=Hylia'
      )
    ];
  }
}
