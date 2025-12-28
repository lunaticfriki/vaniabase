import { Signal } from '@preact/signals';
import { User } from '../../domain/model/entities/user.entity';

export abstract class AuthService {
  abstract currentUser: Signal<User | null>;
  abstract login(userId: string): Promise<void>;
  abstract logout(): Promise<void>;
}
