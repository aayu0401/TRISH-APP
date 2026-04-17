import api from '../api/axios';

export const premiumService = {
    activateBoost: async (_userId) => {
        const response = await api.post('/premium/boost');
        return response.data;
    },

    updatePassport: async (userIdOrPassportData, maybePassportData) => {
        const passportData = (maybePassportData && typeof userIdOrPassportData !== 'object')
            ? maybePassportData
            : userIdOrPassportData;

        const payload = passportData && typeof passportData === 'object' ? passportData : {};
        const response = await api.post('/premium/passport', { active: true, ...payload });
        return response.data;
    },

    deactivatePassport: async (_userId) => {
        const response = await api.post('/premium/passport', { active: false });
        return response.data;
    },
};
