import api from '../api/axios';
import { normalizeUser } from '../utils/normalizers';

const USER_KEY = 'user';

const haversineDistanceKm = (lat1, lon1, lat2, lon2) => {
    const R = 6371;
    const dLat = (lat2 - lat1) * (Math.PI / 180);
    const dLon = (lon2 - lon1) * (Math.PI / 180);
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
};

const getCachedUser = () => {
    try {
        const raw = localStorage.getItem(USER_KEY);
        return raw ? JSON.parse(raw) : null;
    } catch (_e) {
        return null;
    }
};

const sanitizeProfileUpdates = (updates) => {
    if (!updates || typeof updates !== 'object') return {};

    const allowed = [
        'name',
        'bio',
        'interests',
        'city',
        'country',
        'religion',
        'zodiacSign',
        'height',
    ];

    const payload = {};
    for (const key of allowed) {
        if (Object.prototype.hasOwnProperty.call(updates, key) && updates[key] != null) {
            payload[key] = updates[key];
        }
    }

    return payload;
};

export const userService = {
    getProfile: async () => {
        const response = await api.get('/users/profile');
        const user = normalizeUser(response.data);
        localStorage.setItem(USER_KEY, JSON.stringify(user));
        return user;
    },

    updateProfile: async (updates) => {
        const response = await api.put('/users/profile', sanitizeProfileUpdates(updates));
        const user = normalizeUser(response.data);
        localStorage.setItem(USER_KEY, JSON.stringify(user));
        return user;
    },

    updateLocation: async (latitude, longitude) => {
        const response = await api.put('/users/location', { latitude, longitude });
        const user = normalizeUser(response.data);
        localStorage.setItem(USER_KEY, JSON.stringify(user));
        return user;
    },

    updatePreferences: async (preferences) => {
        const response = await api.put('/users/preferences', preferences);
        const user = normalizeUser(response.data);
        localStorage.setItem(USER_KEY, JSON.stringify(user));
        return user;
    },

    getRecommendations: async () => {
        const response = await api.get('/recommendations');
        const currentUser = normalizeUser(getCachedUser());

        const list = Array.isArray(response.data) ? response.data : [];
        return list.map((u) => {
            const normalized = normalizeUser(u);
            if (currentUser?.latitude != null && currentUser?.longitude != null &&
                normalized?.latitude != null && normalized?.longitude != null) {
                return {
                    ...normalized,
                    distance: haversineDistanceKm(currentUser.latitude, currentUser.longitude, normalized.latitude, normalized.longitude),
                };
            }
            return normalized;
        }).filter(Boolean);
    },

    swipe: async (targetUserId, action, isBlindDate = false) => {
        const typeMap = {
            like: 'LIKE',
            pass: 'PASS',
            superlike: 'SUPER_LIKE',
            super: 'SUPER_LIKE',
        };
        const type = typeMap[action] || 'LIKE';
        const response = await api.post('/swipes', { targetUserId, type, blindDate: isBlindDate });
        return response.data;
    },
};
