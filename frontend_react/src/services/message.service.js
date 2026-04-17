import api from '../api/axios';
import { normalizeMessage } from '../utils/normalizers';

const getCurrentUserId = () => {
    try {
        const raw = localStorage.getItem('user');
        if (!raw) return null;
        const user = JSON.parse(raw);
        return typeof user?.id === 'number' ? user.id : Number(user?.id);
    } catch (_e) {
        return null;
    }
};

const formatTime = (isoString) => {
    if (!isoString) return '';
    const date = new Date(isoString);
    if (Number.isNaN(date.getTime())) return '';
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
};

export const messageService = {
    getMessages: async (matchId) => {
        const response = await api.get(`/messages/match/${matchId}`);
        const list = Array.isArray(response.data) ? response.data : [];
        const currentUserId = getCurrentUserId();

        return list.map((m) => {
            const normalized = normalizeMessage(m, currentUserId);
            if (!normalized) return null;
            return {
                id: normalized.id,
                text: normalized.text,
                matchId: normalized.matchId ?? matchId,
                isMe: normalized.isMe,
                time: formatTime(normalized.sentAt),
                status: normalized.isRead ? 'read' : 'sent',
                sentAt: normalized.sentAt,
                senderId: normalized.senderId,
                recipientId: normalized.recipientId,
                isRead: normalized.isRead,
                messageType: normalized.messageType ?? 'TEXT',
                referenceId: normalized.referenceId,
            };
        }).filter(Boolean);
    },

    sendMessage: async (matchId, text) => {
        const response = await api.post('/messages', { matchId, content: text });
        const currentUserId = getCurrentUserId();
        const normalized = normalizeMessage(response.data, currentUserId);
        if (!normalized) return null;
        return {
            id: normalized.id,
            text: normalized.text,
            matchId: normalized.matchId ?? matchId,
            isMe: normalized.isMe,
            time: formatTime(normalized.sentAt),
            status: normalized.isRead ? 'read' : 'sent',
            sentAt: normalized.sentAt,
            senderId: normalized.senderId,
            recipientId: normalized.recipientId,
            isRead: normalized.isRead,
            messageType: normalized.messageType ?? 'TEXT',
            referenceId: normalized.referenceId,
        };
    },

    markAsRead: async (messageId) => {
        await api.put(`/messages/${messageId}/read`);
        return true;
    },

    getUnreadCount: async () => {
        const response = await api.get('/messages/unread-count');
        return response.data?.count ?? 0;
    },

    reportMessage: async (messageId, reason) => {
        console.log(`Reporting message ${messageId} for: ${reason}`);
        return { success: true };
    },

    decryptMessage: async (messageId) => {
        console.log(`Decrypting/Revealing message ${messageId}`);
        return { success: true };
    }
};

