import React, { createContext, useState, useEffect, useContext } from 'react';
import { authService } from '../services/auth.service';
import { useToast } from './ToastContext';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
    const { showToast } = useToast();
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        let isMounted = true;
        const initAuth = async () => {
            try {
                const currentUser = authService.getCurrentUser();
                if (isMounted && currentUser) {
                    setUser(currentUser);
                }
            } catch (error) {
                console.error("Auth init failed:", error);
            } finally {
                if (isMounted) setLoading(false);
            }
        };
        initAuth();
        return () => { isMounted = false; };
    }, []);

    const login = async (email, password) => {
        try {
            const data = await authService.login(email, password);
            setUser(data.user);
            showToast(`Welcome back, ${data.user.name}!`, 'success');
            return data;
        } catch (error) {
            showToast(error.message || 'Login failed', 'error');
            throw error;
        }
    };

    const register = async (userData) => {
        try {
            const data = await authService.register(userData);
            setUser(data.user);
            showToast('Account created successfully!', 'success');
            return data;
        } catch (error) {
            showToast(error.message || 'Registration failed', 'error');
            throw error;
        }
    };

    const logout = () => {
        authService.logout();
        setUser(null);
        showToast('Logged out successfully', 'info');
    };

    // ALWAYS render children so they can handle their own loading states or dark backgrounds
    return (
        <AuthContext.Provider value={{ user, setUser, login, register, logout, loading }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
