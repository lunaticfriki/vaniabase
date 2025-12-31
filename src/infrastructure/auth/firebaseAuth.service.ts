import { injectable, inject } from 'inversify';
import { signal } from '@preact/signals';
import { AuthService } from '../../application/auth/auth.service';
import { User } from '../../domain/model/entities/user.entity';
import { UserRepository } from '../../domain/repositories/user.repository';
import { Id } from '../../domain/model/value-objects/id.valueObject';
import { auth, googleProvider } from '../firebase/firebaseConfig';
import { signInWithPopup, signOut, onAuthStateChanged } from 'firebase/auth';

@injectable()
export class FirebaseAuthService implements AuthService {
  currentUser = signal<User | null>(null);

  constructor(@inject(UserRepository) private userRepository: UserRepository) {
    onAuthStateChanged(auth, async firebaseUser => {
      if (firebaseUser) {
        const user = User.create(
          Id.create(firebaseUser.uid),
          firebaseUser.displayName || 'Unknown User',
          firebaseUser.email || '',
          firebaseUser.photoURL || ''
        );
        this.currentUser.value = user;
        this.userRepository.save(user).catch(err => {
          console.error('[FirebaseAuthService] Failed to save user profile', err);
        });
      } else {
        this.currentUser.value = null;
      }
    });
  }

  async login(_userId?: string): Promise<void> {
    try {
      await signInWithPopup(auth, googleProvider);
    } catch (error) {
      console.error('Error signing in with Google', error);
      throw error;
    }
  }

  async logout(): Promise<void> {
    await signOut(auth);
  }
}
