
import { signal } from '@preact/signals';
import { AuthService } from '../../application/auth/auth.service';
import { route } from 'preact-router';

export class AuthViewModel {
  public loading = signal<boolean>(false);
  public error = signal<string | null>(null);

  constructor(private authService: AuthService) {}

  async loginWithGoogle() {
    this.loading.value = true;
    this.error.value = null;
    try {
      const success = await this.authService.loginWithGoogle();
      if (success) {
        route('/');
      } else {
        this.error.value = 'Failed to login with Google';
      }
    } catch (err: any) {
      this.error.value = err.message || 'An error occurred during login';
    } finally {
      this.loading.value = false;
    }
  }

  async logout() {
      await this.authService.logout();
      route('/login');
  }
}
