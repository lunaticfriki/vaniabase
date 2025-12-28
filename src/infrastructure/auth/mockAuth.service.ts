import { injectable } from 'inversify';
import { signal } from '@preact/signals';
import { AuthService } from '../../application/auth/auth.service';
import { User } from '../../domain/model/entities/user.entity';
import { UserSeed } from '../../domain/seed/user.seed';

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
