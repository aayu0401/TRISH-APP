export const AppTheme = {
    colors: {
        primaryPink: '#FD297B', // Consistent pink
        primaryRed: '#FF385C',
        accentOrange: '#FF655B',
        brandBlue: '#00F2FE', // Renamed from accentBlue
        lightBackground: '#F9FAFB', // Renamed from darkBackground
        darkBackground: '#F9FAFB', // Alias for backward compatibility
        cardBackground: '#FFFFFF',
        surfaceColor: '#FFFFFF',
        textPrimary: '#1F2937',
        textSecondary: '#6B7280',
        textTertiary: '#9CA3AF',
        successGreen: '#10B981',
        errorRed: '#EF4444',
    },
    gradients: {
        primary: 'linear-gradient(135deg, #FD297B 0%, #FF655B 100%)',
        accent: 'linear-gradient(135deg, #FF385C, #E21143)',
        blue: 'linear-gradient(135deg, #00F2FE, #4facfe)',
        dark: 'linear-gradient(180deg, #F9FAFB 0%, #F3F4F6 100%)',
        glass: 'linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.6))',
    },
    shadows: {
        card: '0 10px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01)',
        glow: '0 0 20px rgba(253, 41, 123, 0.15)',
        softBlue: '0 0 30px rgba(0, 242, 254, 0.08)', // Renamed from neonBlue
    },
    borderRadius: {
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '32px',
    }
};
