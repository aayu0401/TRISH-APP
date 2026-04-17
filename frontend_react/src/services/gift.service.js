import api from '../api/axios';
import { resolveMediaUrl } from '../utils/url';

const toTitleCase = (value) => {
    if (!value || typeof value !== 'string') return '';
    const lower = value.toLowerCase();
    return lower.charAt(0).toUpperCase() + lower.slice(1);
};

const normalizeGiftCategoryLabel = (category) => {
    if (!category || typeof category !== 'string') return 'Other';
    const upper = category.toUpperCase();
    const map = {
        FLOWERS: 'Flowers',
        CHOCOLATES: 'Chocolates',
        JEWELRY: 'Jewelry',
        PERFUME: 'Perfume',
        GADGETS: 'Gadgets',
        EXPERIENCES: 'Experiences',
        VIRTUAL: 'Virtual',
        OTHER: 'Other',
        TEDDY: 'Teddy',
    };
    return map[upper] ?? toTitleCase(upper);
};

const normalizeGift = (gift) => {
    if (!gift || typeof gift !== 'object') return null;
    return {
        id: gift.id,
        name: gift.name ?? '',
        description: gift.description ?? '',
        price: typeof gift.price === 'number' ? gift.price : Number(gift.price ?? 0),
        imageUrl: typeof gift.imageUrl === 'string' ? resolveMediaUrl(gift.imageUrl) : null,
        category: normalizeGiftCategoryLabel(gift.category),
        type: gift.type ?? null,
        popularityScore: gift.popularityScore ?? null,
        isAvailable: gift.isAvailable ?? true,
    };
};

const formatDate = (iso) => {
    if (!iso) return '';
    const date = new Date(iso);
    if (Number.isNaN(date.getTime())) return '';
    return date.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
};

const normalizeGiftTransaction = (transaction, mode) => {
    if (!transaction || typeof transaction !== 'object') return null;
    const gift = normalizeGift(transaction.gift) ?? {};
    const status = typeof transaction.status === 'string' ? transaction.status.toLowerCase() : 'pending';

    if (mode === 'sent') {
        return {
            id: transaction.id,
            transactionId: transaction.id,
            status,
            date: formatDate(transaction.createdAt),
            matchName: transaction.receiver?.name ?? 'Match',
            deliveryDate: transaction.deliveredAt ? formatDate(transaction.deliveredAt) : (transaction.trackingNumber ? 'In transit' : 'Processing'),
            ...gift,
        };
    }

    // received
    return {
        id: transaction.id,
        transactionId: transaction.id,
        status,
        date: formatDate(transaction.createdAt),
        senderName: transaction.sender?.name ?? 'Someone',
        ...gift,
    };
};

export const giftService = {
    getCatalog: async ({ category, type } = {}) => {
        const params = {};
        if (category && category !== 'All') params.category = String(category).toUpperCase();
        if (type) params.type = String(type).toUpperCase();

        const response = await api.get('/gifts', { params });
        const list = Array.isArray(response.data) ? response.data : [];
        return list.map(normalizeGift).filter(Boolean);
    },

    getPopular: async () => {
        const response = await api.get('/gifts/popular');
        const list = Array.isArray(response.data) ? response.data : [];
        return list.map(normalizeGift).filter(Boolean);
    },

    getGiftById: async (giftId) => {
        const response = await api.get(`/gifts/${giftId}`);
        return normalizeGift(response.data);
    },

    sendGift: async ({ receiverId, giftId, message, deliveryAddress } = {}) => {
        const response = await api.post('/gifts/send', { receiverId, giftId, message, deliveryAddress });
        return response.data;
    },

    acceptGift: async (transactionId) => {
        const response = await api.post(`/gifts/accept/${transactionId}`);
        return response.data;
    },

    cancelGift: async (transactionId) => {
        const response = await api.post(`/gifts/cancel/${transactionId}`);
        return response.data;
    },

    trackGift: async (transactionId) => {
        const response = await api.get(`/gifts/track/${transactionId}`);
        return response.data;
    },

    getSentGifts: async () => {
        const response = await api.get('/gifts/sent');
        const list = Array.isArray(response.data) ? response.data : [];
        return list.map((t) => normalizeGiftTransaction(t, 'sent')).filter(Boolean);
    },

    getReceivedGifts: async () => {
        const response = await api.get('/gifts/received');
        const list = Array.isArray(response.data) ? response.data : [];
        return list.map((t) => normalizeGiftTransaction(t, 'received')).filter(Boolean);
    },
};
