import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { authService } from '../../services/auth.service';
import { FaEnvelope, FaTimes } from 'react-icons/fa';

const VerifyEmailBanner = ({ user }) => {
    const [isVisible, setIsVisible] = useState(true);
    const [sent, setSent] = useState(false);

    if (!user || user.emailVerified || !isVisible) return null;

    const handleResend = async () => {
        try {
            await authService.sendVerificationEmail();
            setSent(true);
            setTimeout(() => setSent(false), 5000);
        } catch (e) {
            console.error(e);
        }
    };

    return (
        <AnimatePresence>
            <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                style={{
                    background: 'linear-gradient(90deg, #4F46E5 0%, #7C3AED 100%)',
                    color: '#fff',
                    padding: '12px 20px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    gap: '12px',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
                    position: 'relative',
                    zIndex: 1100
                }}
            >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <div style={{ background: 'rgba(255,255,255,0.2)', padding: '8px', borderRadius: '10px' }}>
                        <FaEnvelope size={14} />
                    </div>
                    <div>
                        <span style={{ fontSize: '14px', fontWeight: '700' }}>Confirm your email address</span>
                        <p style={{ margin: 0, fontSize: '12px', opacity: 0.9 }}>Check your inbox to unlock all premium features.</p>
                    </div>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <motion.button
                        whileTap={{ scale: 0.95 }}
                        onClick={handleResend}
                        disabled={sent}
                        style={{
                            background: '#fff',
                            color: '#4F46E5',
                            border: 'none',
                            padding: '6px 14px',
                            borderRadius: '12px',
                            fontSize: '12px',
                            fontWeight: '700',
                            cursor: 'pointer'
                        }}
                    >
                        {sent ? 'Sent! check inbox' : 'Resend Email'}
                    </motion.button>
                    <FaTimes
                        onClick={() => setIsVisible(false)}
                        style={{ cursor: 'pointer', opacity: 0.7 }}
                        size={14}
                    />
                </div>
            </motion.div>
        </AnimatePresence>
    );
};

export default VerifyEmailBanner;
