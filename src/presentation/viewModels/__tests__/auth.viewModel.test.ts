
import 'reflect-metadata';
import type { Mock } from 'vitest';
import { AuthViewModel } from '../auth.viewModel';
import { AuthService } from '../../../application/auth/auth.service';
import { route } from 'preact-router';
import { signal } from '@preact/signals';


vi.mock('preact-router', () => ({
    route: vi.fn()
}));

describe('AuthViewModel', () => {
    let mockLoginWithGoogle: Mock;
    let mockLogout: Mock;
    let mockAuthService: AuthService;
    let viewModel: AuthViewModel;

    beforeEach(() => {
        vi.clearAllMocks();
        mockLoginWithGoogle = vi.fn();
        mockLogout = vi.fn();
        mockAuthService = {
            currentUser: signal(null),
            login: vi.fn(),
            loginWithGoogle: mockLoginWithGoogle,
            logout: mockLogout
        } as unknown as AuthService;

        viewModel = new AuthViewModel(mockAuthService);
    });

    it('should login with google successfully and redirect', async () => {
        mockLoginWithGoogle.mockResolvedValue(true);

        await viewModel.loginWithGoogle();

        expect(mockLoginWithGoogle).toHaveBeenCalledOnce();
        expect(route).toHaveBeenCalledWith('/');
        expect(viewModel.loading.value).toBe(false);
        expect(viewModel.error.value).toBeNull();
    });

    it('should handle login failure', async () => {
        mockLoginWithGoogle.mockResolvedValue(false);

        await viewModel.loginWithGoogle();

        expect(mockLoginWithGoogle).toHaveBeenCalledOnce();
        expect(route).not.toHaveBeenCalled();
        expect(viewModel.error.value).toBe('Failed to login with Google');
        expect(viewModel.loading.value).toBe(false);
    });

    it('should handle login exception', async () => {
        mockLoginWithGoogle.mockRejectedValue(new Error('Network error'));

        await viewModel.loginWithGoogle();

        expect(mockLoginWithGoogle).toHaveBeenCalledOnce();
        expect(route).not.toHaveBeenCalled();
        expect(viewModel.error.value).toBe('Network error');
        expect(viewModel.loading.value).toBe(false);
    });

    it('should logout and redirect', async () => {
        mockLogout.mockResolvedValue(undefined);

        await viewModel.logout();

        expect(mockLogout).toHaveBeenCalledOnce();
        expect(route).toHaveBeenCalledWith('/login');
    });
});

