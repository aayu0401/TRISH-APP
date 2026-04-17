const trimTrailingSlash = (value) => value.replace(/\/+$/, '');

export const getBackendOrigin = () => {
    const explicitBackendUrl = import.meta.env.VITE_BACKEND_URL;
    if (explicitBackendUrl) return trimTrailingSlash(explicitBackendUrl);

    const apiUrl = import.meta.env.VITE_API_URL;
    if (!apiUrl) return '';

    try {
        return new URL(apiUrl).origin;
    } catch (_e) {
        return '';
    }
};

export const resolveMediaUrl = (url) => {
    if (!url || typeof url !== 'string') return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    if (url.startsWith('/')) {
        const origin = getBackendOrigin();
        return origin ? `${origin}${url}` : url;
    }

    return url;
};

