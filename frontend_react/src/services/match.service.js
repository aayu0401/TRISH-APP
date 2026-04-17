import api from '../api/axios';
import { normalizeMatch } from '../utils/normalizers';

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

const formatRelativeTime = (isoString) => {
    if (!isoString) return '';
    const date = new Date(isoString);
    if (Number.isNaN(date.getTime())) return '';

    const diffMs = Date.now() - date.getTime();
    const diffMinutes = Math.floor(diffMs / 60000);
    if (diffMinutes < 1) return 'Just now';
    if (diffMinutes < 60) return `${diffMinutes}m ago`;

    const diffHours = Math.floor(diffMinutes / 60);
    if (diffHours < 24) return `${diffHours}h ago`;

    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays}d ago`;
};

export const matchService = {
    getMatches: async () => {
        const response = await api.get('/matches');
        const currentUserId = getCurrentUserId();
        const list = Array.isArray(response.data) ? response.data : [];

        return list.map((m) => {
            const normalized = normalizeMatch(m, currentUserId);
            if (!normalized) return null;

            const opponent = normalized.opponent;
            return {
                id: normalized.id,
                compatibilityScore: normalized.compatibilityScore,
                matchedAt: normalized.matchedAt,
                time: formatRelativeTime(normalized.matchedAt),
                isBlindMatch: normalized.isBlindMatch,
                revealProgress: normalized.revealProgress ?? 0,
                opponent,
                name: opponent?.name ?? 'Match',
                avatar: opponent?.avatar ?? 'https://via.placeholder.com/100',
                photos: opponent?.photos ?? [],
                lastMessage: 'Say hi 👋',
            };
        }).filter(Boolean);
    },

    getMatchDetails: async (matchId) => {
        const matches = await matchService.getMatches();
        return matches.find((m) => String(m.id) === String(matchId)) ?? null;
    },

    rewindLastPass: async () => {
        const response = await api.post('/rewind');
        return response.data;
    },

    updateRevealProgress: async (matchId, progress) => {
        const response = await api.post(`/matches/${matchId}/reveal`, { progress });
        return response.data;
    },
};
