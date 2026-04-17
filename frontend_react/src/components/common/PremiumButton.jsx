import React from 'react';
import { motion } from 'framer-motion';
import { AppTheme } from '../../theme/AppTheme';


const PremiumButton = ({
    text,
    onClick,
    type = 'primary',
    icon: Icon,
    isLoading = false,
    fullWidth = false,
    disabled = false
}) => {

    const getStyle = () => {
        const base = {
            padding: '16px 32px',
            borderRadius: AppTheme.borderRadius.md,
            border: 'none',
            cursor: disabled || isLoading ? 'not-allowed' : 'pointer',
            fontSize: '16px',
            fontWeight: '600',
            fontFamily: 'Poppins, sans-serif',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            color: '#FFF',
            width: fullWidth ? '100%' : 'auto',
            opacity: disabled ? 0.6 : 1,
            position: 'relative',
            overflow: 'hidden',
        };

        switch (type) {
            case 'gradient':
                return {
                    ...base,
                    background: AppTheme.gradients.primary,
                    boxShadow: AppTheme.shadows.card,
                };
            case 'glass':
                return {
                    ...base,
                    background: 'rgba(255, 255, 255, 0.1)',
                    backdropFilter: 'blur(10px)',
                    border: '1px solid rgba(255, 255, 255, 0.2)',
                };
            case 'outline':
                return {
                    ...base,
                    background: 'transparent',
                    border: `2px solid ${AppTheme.colors.primaryPink}`,
                    color: AppTheme.colors.primaryPink,
                };
            case 'primary':
            default:
                return {
                    ...base,
                    backgroundColor: AppTheme.colors.primaryPink,
                };
        }
    };

    return (
        <motion.button
            whileHover={{ scale: disabled ? 1 : 1.02 }}
            whileTap={{ scale: disabled ? 1 : 0.98 }}
            style={getStyle()}
            onClick={!disabled && !isLoading ? onClick : undefined}
            disabled={disabled || isLoading}
        >
            {isLoading ? (
                <div className="spinner" />
            ) : (
                <>
                    {Icon && <Icon size={20} />}
                    {text}
                </>
            )}
        </motion.button>
    );
};

export default PremiumButton;
