import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaBolt, FaRocket } from 'react-icons/fa';
import { AppTheme } from '../../theme/AppTheme';

const BoostButton = ({ onBoost, isActive, expiresAt }) => {
    const [timeLeft, setTimeLeft] = useState('');

    useEffect(() => {
        if (!isActive || !expiresAt) return;

        const interval = setInterval(() => {
            const now = new Date();
            const end = new Date(expiresAt);
            const diff = end - now;

            if (diff <= 0) {
                setTimeLeft('');
                clearInterval(interval);
                return;
            }

            const mins = Math.floor(diff / 60000);
            const secs = Math.floor((diff % 60000) / 1000);
            setTimeLeft(`${mins}:${secs < 10 ? '0' : ''}${secs}`);
        }, 1000);

        return () => clearInterval(interval);
    }, [isActive, expiresAt]);

    return (
        <motion.div
            style={{
                position: 'fixed',
                bottom: '100px',
                right: '24px',
                zIndex: 1000
            }}
        >
            <AnimatePresence>
                {isActive && (
                    <motion.div
                        initial={{ opacity: 0, scale: 0.5, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        exit={{ opacity: 0, scale: 0.5, y: 20 }}
                        style={{
                            position: 'absolute',
                            bottom: '70px',
                            right: 0,
                            background: '#8B5CF6',
                            color: '#fff',
                            padding: '8px 16px',
                            borderRadius: '20px',
                            fontSize: '13px',
                            fontWeight: '800',
                            whiteSpace: 'nowrap',
                            boxShadow: '0 10px 20px rgba(139, 92, 246, 0.3)',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '8px'
                        }}
                    >
                        <FaBolt size={12} className="pulse-icon" />
                        BOOSTED {timeLeft}
                    </motion.div>
                )}
            </AnimatePresence>

            <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={onBoost}
                disabled={isActive}
                style={{
                    width: '60px',
                    height: '60px',
                    borderRadius: '50%',
                    background: isActive ? '#8B5CF6' : '#FFFFFF',
                    border: 'none',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: isActive ? '#FFFFFF' : '#8B5CF6',
                    boxShadow: isActive
                        ? '0 0 30px rgba(139, 92, 246, 0.5)'
                        : '0 10px 25px rgba(0,0,0,0.1)',
                    cursor: 'pointer',
                    outline: 'none'
                }}
            >
                {isActive ? <FaRocket size={24} /> : <FaBolt size={24} />}
            </motion.button>
        </motion.div>
    );
};

export default BoostButton;
