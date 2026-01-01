
import 'reflect-metadata';
import { AuthViewModel } from '../auth.viewModel';
import { AuthService } from '../../../application/auth/auth.service';
import { route } from 'preact-router';
import { signal } from '@preact/signals';


vi.mock('preact-router', () => ({
    route: vi.fn()
}));

describe('AuthViewModel', () => {
    let mockAuthService: AuthService;
    let viewModel: AuthViewModel;

    beforeEach(() => {
        vi.clearAllMocks();
        mockAuthService = {
            currentUser: signal(null),
            login: vi.fn(),
            loginWithGoogle: vi.fn(),
            logout: vi.fn()
        } as unknown as AuthService;

        viewModel = new AuthViewModel(mockAuthService);
    });

    it('should login with google successfully and redirect', async () => {
        (mockAuthService.loginWithGoogle as any).mockResolvedValue(true);

        await viewModel.loginWithGoogle();

        expect(mockAuthService.loginWithGoogle).toHaveBeenCalledOnce();
        expect(route).toHaveBeenCalledWith('/');
        expect(viewModel.loading.value).toBe(false);
        expect(viewModel.error.value).toBeNull();
    });

    it('should handle login failure', async () => {
        (mockAuthService.loginWithGoogle as any).mockResolvedValue(false);

        await viewModel.loginWithGoogle();

        expect(mockAuthService.loginWithGoogle).toHaveBeenCalledOnce();
        expect(route).not.toHaveBeenCalled();
        expect(viewModel.error.value).toBe('Failed to login with Google');
        expect(viewModel.loading.value).toBe(false);
    });

    it('should handle login exception', async () => {
        (mockAuthService.loginWithGoogle as any).mockRejectedValue(new Error('Network error'));

        await viewModel.loginWithGoogle();

        expect(mockAuthService.loginWithGoogle).toHaveBeenCalledOnce();
        expect(route).not.toHaveBeenCalled();
        expect(viewModel.error.value).toBe('Network error');
        expect(viewModel.loading.value).toBe(false);
    });

    it('should logout and redirect', async () => {
        (mockAuthService.logout as any).mockResolvedValue(undefined);

        await viewModel.logout();

        expect(mockAuthService.logout).toHaveBeenCalledOnce();
        expect(route).toHaveBeenCalledWith('/login');
    });
});

