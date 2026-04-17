import { resolveMediaUrl } from './url';

export const toNumberOrNull = (value) => {
    if (typeof value === 'number') return value;
    if (typeof value !== 'string') return null;
    const num = Number(value);
    return Number.isFinite(num) ? num : null;
};

export const calculateAge = (dateOfBirth) => {
    if (!dateOfBirth) return null;
    const dob = new Date(dateOfBirth);
    if (Number.isNaN(dob.getTime())) return null;

    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();
    const monthDelta = today.getMonth() - dob.getMonth();
    if (monthDelta < 0 || (monthDelta === 0 && today.getDate() < dob.getDate())) {
        age -= 1;
    }
    return age;
};

export const normalizePhotoUrl = (photo) => {
    if (!photo) return null;
    if (typeof photo === 'string') return resolveMediaUrl(photo);
    if (typeof photo === 'object') {
        if (typeof photo.url === 'string') return resolveMediaUrl(photo.url);
        if (typeof photo.imageUrl === 'string') return resolveMediaUrl(photo.imageUrl);
    }
    return null;
};

export const normalizeUser = (rawUser) => {
    if (!rawUser || typeof rawUser !== 'object') return null;

    const photos = Array.isArray(rawUser.photos)
        ? rawUser.photos.map(normalizePhotoUrl).filter(Boolean)
        : [];

    const age = typeof rawUser.age === 'number' ? rawUser.age : calculateAge(rawUser.dateOfBirth);

    return {
        id: toNumberOrNull(rawUser.id) ?? rawUser.id,
        name: rawUser.name ?? '',
        email: rawUser.email ?? '',
        bio: rawUser.bio ?? '',
        age,
        gender: rawUser.gender ?? null,
        city: rawUser.city ?? null,
        country: rawUser.country ?? null,
        latitude: rawUser.latitude ?? null,
        longitude: rawUser.longitude ?? null,
        interests: Array.isArray(rawUser.interests) ? rawUser.interests : [],
        photos,
        avatar: rawUser.avatar ?? photos[0] ?? null,

        // Feature flags
        isPremium: !!rawUser.isPremium,
        isVerified: !!rawUser.isVerified,
        emailVerified: !!rawUser.emailVerified,

        // Premium extras (optional)
        isBoosted: !!rawUser.isBoosted,
        boostExpiresAt: rawUser.boostExpiresAt ?? null,
        isPassportActive: !!rawUser.isPassportActive,
        passportCity: rawUser.passportCity ?? null,
        passportCountry: rawUser.passportCountry ?? null,
        passportLatitude: rawUser.passportLatitude ?? null,
        passportLongitude: rawUser.passportLongitude ?? null,

        // Preferences (optional)
        interestedInGender: rawUser.interestedInGender ?? null,
        minAge: rawUser.minAge ?? null,
        maxAge: rawUser.maxAge ?? null,
        maxDistance: rawUser.maxDistance ?? null,
    };
};

export const normalizeMatch = (rawMatch, currentUserId) => {
    if (!rawMatch || typeof rawMatch !== 'object') return null;

    const user1 = normalizeUser(rawMatch.user1);
    const user2 = normalizeUser(rawMatch.user2);

    let opponent = null;
    if (currentUserId != null && user1?.id === currentUserId) opponent = user2;
    else if (currentUserId != null && user2?.id === currentUserId) opponent = user1;
    else opponent = user2 ?? user1;

    return {
        id: toNumberOrNull(rawMatch.id) ?? rawMatch.id,
        compatibilityScore: rawMatch.compatibilityScore ?? null,
        matchedAt: rawMatch.matchedAt ?? null,
        isActive: rawMatch.isActive ?? true,
        isBlindMatch: !!rawMatch.isBlindDateMatch,
        revealProgress: typeof rawMatch.revealProgress === 'number' ? rawMatch.revealProgress : Number(rawMatch.revealProgress ?? 0),
        user1,
        user2,
        opponent,
    };
};

export const normalizeMessage = (rawMessage, currentUserId) => {
    if (!rawMessage || typeof rawMessage !== 'object') return null;

    const senderId = toNumberOrNull(rawMessage.sender?.id) ?? toNumberOrNull(rawMessage.senderId) ?? rawMessage.senderId ?? null;
    const recipientId = toNumberOrNull(rawMessage.receiver?.id)
        ?? toNumberOrNull(rawMessage.recipientId)
        ?? toNumberOrNull(rawMessage.receiverId)
        ?? rawMessage.receiverId
        ?? null;
    const matchId = toNumberOrNull(rawMessage.matchId) ?? toNumberOrNull(rawMessage.match?.id) ?? rawMessage.match?.id ?? null;
    const sentAt = rawMessage.sentAt ?? rawMessage.timestamp ?? null;
    const messageType = typeof rawMessage.messageType === 'string'
        ? rawMessage.messageType
        : (typeof rawMessage.messageType?.name === 'string' ? rawMessage.messageType.name : null);
    const referenceId = toNumberOrNull(rawMessage.referenceId) ?? rawMessage.referenceId ?? null;

    return {
        id: toNumberOrNull(rawMessage.id) ?? rawMessage.id,
        text: rawMessage.text ?? rawMessage.content ?? '',
        matchId,
        senderId,
        recipientId,
        isMe: currentUserId != null ? senderId === currentUserId : !!rawMessage.isMe,
        isRead: !!rawMessage.isRead,
        sentAt,
        messageType,
        referenceId,
    };
};
