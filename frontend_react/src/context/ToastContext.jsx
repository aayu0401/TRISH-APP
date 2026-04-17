import React, { createContext, useContext, useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaCheckCircle, FaExclamationCircle, FaInfoCircle, FaTimes } from 'react-icons/fa';
import { AppTheme } from '../theme/AppTheme';

const ToastContext = createContext();

export const useToast = () => {
    const context = useContext(ToastContext);
    if (!context) {
        throw new Error('useToast must be used within a ToastProvider');
    }
    return context;
};

export const ToastProvider = ({ children }) => {
    const [toasts, setToasts] = useState([]);

    const showToast = useCallback((message, type = 'success') => {
        const id = Math.random().toString(36).substr(2, 9);
        setToasts((prev) => [...prev, { id, message, type }]);

        setTimeout(() => {
            setToasts((prev) => prev.filter((t) => t.id !== id));
        }, 4000);
    }, []);

    const removeToast = useCallback((id) => {
        setToasts((prev) => prev.filter((t) => t.id !== id));
    }, []);

    return (
        <ToastContext.Provider value={{ showToast }}>
            {children}
            <div style={{
                position: 'fixed',
                top: '40px',
                left: '50%',
                transform: 'translateX(-50%)',
                zIndex: 9999,
                display: 'flex',
                flexDirection: 'column',
                gap: '12px',
                pointerEvents: 'none', // Allow clicks to pass through empty space
                width: '90%',
                maxWidth: '400px',
                alignItems: 'center'
            }}>
                <AnimatePresence>
                    {toasts.map((toast) => (
                        <ToastMessage
                            key={toast.id}
                            toast={toast}
                            onRemove={() => removeToast(toast.id)}
                        />
                    ))}
                </AnimatePresence>
            </div>
        </ToastContext.Provider>
    );
};

const ToastMessage = ({ toast, onRemove }) => {
    const getIcon = () => {
        switch (toast.type) {
            case 'success':
                return <FaCheckCircle color={AppTheme.colors.successGreen} size={20} />;
            case 'error':
                return <FaExclamationCircle color={AppTheme.colors.errorRed} size={20} />;
            case 'info':
            default:
                return <FaInfoCircle color={AppTheme.colors.primaryPink} size={20} />;
        }
    };

    return (
        <motion.div
            initial={{ opacity: 0, y: -20, scale: 0.9 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9, transition: { duration: 0.2 } }}
            layout
            style={{
                background: '#FFFFFF',
                padding: '16px 20px',
                borderRadius: '20px',
                boxShadow: '0 10px 30px rgba(0,0,0,0.08)',
                border: '1px solid #E5E7EB',
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                pointerEvents: 'auto',
                width: '100%',
                cursor: 'pointer'
            }}
            onClick={onRemove}
        >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                {getIcon()}
            </div>
            <p style={{ margin: 0, color: AppTheme.colors.textPrimary, fontSize: '15px', fontWeight: '600', flex: 1 }}>
                {toast.message}
            </p>
        </motion.div>
    );
};
