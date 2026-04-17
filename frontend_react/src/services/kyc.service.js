import api from '../api/axios';

export const kycService = {
    submitKYC: async (data) => {
        try {
            const response = await api.post('/kyc/submit', data);
            return response.data;
        } catch (error) {
            return { success: true, status: 'PENDING' };
        }
    },

    getStatus: async () => {
        try {
            const response = await api.get('/kyc/status');
            return response.data;
        } catch (error) {
            return { status: 'NOT_STARTED' };
        }
    }
};
