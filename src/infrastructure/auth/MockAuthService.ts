import { injectable } from 'inversify';
import { signal } from '@preact/signals';
import { AuthService } from '../../application/auth/AuthService';
import { User } from '../../domain/model/entities/User';
import { UserSeed } from '../../domain/seed/UserSeed';

@injectable()
export class MockAuthService implements AuthService {
  currentUser = signal<User | null>(null);

  async login(userId: string): Promise<void> {
    const users = UserSeed.generate();
    const user = users.find(u => u.id.value === userId);
    if (user) {
      this.currentUser.value = user;
    } else {
      throw new Error('User not found');
    }
  }

  async logout(): Promise<void> {
    this.currentUser.value = null;
  }
}
