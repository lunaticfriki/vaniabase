import { injectable } from 'inversify';
import { signal } from '@preact/signals';
import { AuthService } from '../../application/auth/auth.service';
import { User } from '../../domain/model/entities/user.entity';
import { UserSeed } from '../../domain/seed/user.seed';

@injectable()
export class MockAuthService implements AuthService {
  currentUser = signal<User | null>(null);

  login(userId?: string): Promise<void> {
    if (!userId) return Promise.resolve();
    const users = UserSeed.generate();
    const user = users.find(u => u.id.value === userId);
    if (user) {
      this.currentUser.value = user;
    } else {
      throw new Error('User not found');
    }
    return Promise.resolve();
  }

  loginWithGoogle(): Promise<boolean> {
    const users = UserSeed.generate();
    if (users.length > 0) {
      this.currentUser.value = users[0];
      return Promise.resolve(true);
    }
    return Promise.resolve(false);
  }

  logout(): Promise<void> {
    this.currentUser.value = null;
    return Promise.resolve();
  }
}
