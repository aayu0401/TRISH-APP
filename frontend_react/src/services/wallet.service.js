import api from '../api/axios';

const formatFriendlyDate = (iso) => {
    if (!iso) return '';
    const date = new Date(iso);
    if (Number.isNaN(date.getTime())) return '';

    const today = new Date();
    const startOfToday = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const startOfThatDay = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const diffDays = Math.round((startOfToday - startOfThatDay) / (1000 * 60 * 60 * 24));

    if (diffDays === 0) return 'Today';
    if (diffDays === 1) return 'Yesterday';
    return date.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
};

const normalizeTxType = (type) => {
    if (!type || typeof type !== 'string') return 'debit';
    const upper = type.toUpperCase();
    if (upper === 'CREDIT' || upper === 'REFUND') return 'credit';
    return 'debit';
};

const normalizeTransaction = (tx) => {
    if (!tx || typeof tx !== 'object') return null;

    return {
        id: tx.id,
        type: normalizeTxType(tx.type),
        amount: typeof tx.amount === 'number' ? tx.amount : Number(tx.amount ?? 0),
        description: tx.description ?? (tx.type ? String(tx.type) : 'Transaction'),
        date: formatFriendlyDate(tx.createdAt ?? tx.updatedAt),
        status: tx.status ?? null,
        balanceBefore: tx.balanceBefore ?? null,
        balanceAfter: tx.balanceAfter ?? null,
        paymentMethod: tx.paymentMethod ?? null,
        paymentId: tx.paymentId ?? null,
        referenceId: tx.referenceId ?? null,
        createdAt: tx.createdAt ?? null,
    };
};

export const walletService = {
    getBalance: async () => {
        const response = await api.get('/wallet');
        return response.data;
    },

    addMoney: async (amount, paymentMethod) => {
        const response = await api.post('/wallet/add-money', { amount, paymentMethod });
        return response.data;
    },

    withdraw: async (amount, bankDetails = {}) => {
        const response = await api.post('/wallet/withdraw', { amount, ...bankDetails });
        return response.data;
    },

    getTransactions: async ({ page = 0, limit = 20 } = {}) => {
        const response = await api.get('/wallet/transactions', { params: { page, limit } });
        const list = Array.isArray(response.data?.content) ? response.data.content : [];
        return list.map(normalizeTransaction).filter(Boolean);
    },

    getStats: async () => {
        const response = await api.get('/wallet/stats');
        return response.data;
    },
};

