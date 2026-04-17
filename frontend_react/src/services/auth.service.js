import api from '../api/axios';
import { normalizeUser } from '../utils/normalizers';
import { userService } from './user.service';

const TOKEN_KEY = 'token';
const USER_KEY = 'user';

const getApiErrorMessage = (error, fallback) => {
    const data = error?.response?.data;
    if (typeof data === 'string' && data.trim()) return data;
    if (data && typeof data === 'object') {
        if (typeof data.message === 'string' && data.message.trim()) return data.message;
        if (typeof data.error === 'string' && data.error.trim()) return data.error;
    }
    return fallback;
};

export const authService = {
    login: async (email, password) => {
        let response;
        try {
            response = await api.post('/auth/login', { email, password });
        } catch (error) {
            throw new Error(getApiErrorMessage(error, 'Login failed. Please check your credentials.'));
        }
        const { token, userId, name } = response.data || {};
        if (!token) {
            throw new Error('Login failed. Please check your credentials.');
        }

        localStorage.setItem(TOKEN_KEY, token);

        let user = null;
        try {
            const profile = await userService.getProfile();
            user = normalizeUser(profile);
        } catch (_e) {
            user = normalizeUser({ id: userId, email, name });
        }

        localStorage.setItem(USER_KEY, JSON.stringify(user));
        return { token, user };
    },

    register: async (userData) => {
        let response;
        try {
            response = await api.post('/auth/register', userData);
        } catch (error) {
            throw new Error(getApiErrorMessage(error, 'Registration failed. Please try again.'));
        }
        const { token, userId, email, name } = response.data || {};
        if (!token) {
            throw new Error('Registration failed. Please try again.');
        }

        localStorage.setItem(TOKEN_KEY, token);

        let user = null;
        try {
            const profile = await userService.getProfile();
            user = normalizeUser(profile);
        } catch (_e) {
            user = normalizeUser({ id: userId, email, name });
        }

        localStorage.setItem(USER_KEY, JSON.stringify(user));
        return { token, user };
    },

    sendVerificationEmail: async () => {
        const response = await api.post('/auth/send-verification');
        return response.data;
    },

    verifyEmail: async (token) => {
        const response = await api.post(`/auth/verify-email?token=${encodeURIComponent(token)}`);
        return response.data;
    },

    logout: () => {
        localStorage.removeItem(TOKEN_KEY);
        localStorage.removeItem(USER_KEY);
    },

    getToken: () => localStorage.getItem(TOKEN_KEY),

    getCurrentUser: () => {
        try {
            const userStr = localStorage.getItem(USER_KEY);
            return userStr ? JSON.parse(userStr) : null;
        } catch (error) {
            console.error("Failed to parse user from localStorage", error);
            localStorage.removeItem(USER_KEY);
            return null;
        }
    },
};
