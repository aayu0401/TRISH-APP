import api from '../api/axios';

export const subscriptionService = {
    getCurrent: async () => {
        const response = await api.get('/subscription/current');
        return response.data;
    },

    getPlans: async () => {
        const response = await api.get('/subscription/plans');
        return response.data;
    },

    subscribe: async ({ plan, paymentMethod, promoCode } = {}) => {
        const response = await api.post('/subscription/subscribe', { plan, paymentMethod, promoCode });
        return response.data;
    },

    cancel: async () => {
        const response = await api.post('/subscription/cancel');
        return response.data;
    },

    updateAutoRenew: async (autoRenew) => {
        const response = await api.put('/subscription/auto-renew', { autoRenew });
        return response.data;
    },

    getFeatures: async () => {
        const response = await api.get('/subscription/features');
        return response.data;
    },

    validatePromo: async (promoCode) => {
        const response = await api.post('/subscription/validate-promo', { promoCode });
        return response.data;
    },

    getHistory: async () => {
        const response = await api.get('/subscription/history');
        return response.data;
    },
};

