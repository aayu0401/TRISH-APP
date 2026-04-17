import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { motion } from 'framer-motion';
import { FaCheckCircle, FaEnvelopeOpenText, FaExclamationTriangle } from 'react-icons/fa';
import PremiumButton from '../components/common/PremiumButton';
import { AppTheme } from '../theme/AppTheme';
import { authService } from '../services/auth.service';
import { useToast } from '../context/ToastContext';
import { useAuth } from '../context/AuthContext';
import { userService } from '../services/user.service';

const VerifyEmail = () => {
    const navigate = useNavigate();
    const [searchParams] = useSearchParams();
    const token = useMemo(() => searchParams.get('token'), [searchParams]);
    const { showToast } = useToast();
    const { setUser } = useAuth();

    const [status, setStatus] = useState('loading'); // loading | success | error
    const [message, setMessage] = useState('Verifying your email…');

    useEffect(() => {
        let isMounted = true;

        const run = async () => {
            if (!token) {
                if (!isMounted) return;
                setStatus('error');
                setMessage('Missing verification token.');
                return;
            }

            try {
                const result = await authService.verifyEmail(token);
                if (!isMounted) return;

                if (result?.success) {
                    setStatus('success');
                    setMessage(result?.message || 'Email verified successfully.');
                    showToast('Email verified!', 'success');

                    // Refresh profile if user is currently logged in.
                    try {
                        const profile = await userService.getProfile();
                        if (profile) setUser(profile);
                    } catch (_e) {
                        // Not logged in — ignore.
                    }
                } else {
                    setStatus('error');
                    setMessage(result?.error || 'Invalid or expired verification link.');
                    showToast('Verification failed', 'error');
                }
            } catch (e) {
                if (!isMounted) return;
                setStatus('error');
                setMessage(e?.message || 'Verification failed.');
                showToast('Verification failed', 'error');
            }
        };

        run();
        return () => {
            isMounted = false;
        };
    }, [token, showToast, setUser]);

    const icon =
        status === 'success'
            ? <FaCheckCircle size={34} color={AppTheme.colors.successGreen} />
            : status === 'error'
                ? <FaExclamationTriangle size={34} color={AppTheme.colors.errorRed} />
                : <FaEnvelopeOpenText size={34} color={AppTheme.colors.primaryPink} />;

    const title =
        status === 'success'
            ? 'Email Verified'
            : status === 'error'
                ? 'Verification Failed'
                : 'Verifying…';

    return (
        <div style={{
            minHeight: '100vh',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            background: AppTheme.colors.lightBackground,
            position: 'relative',
            overflow: 'hidden',
            padding: '20px'
        }}>
            <div style={{ position: 'absolute', inset: 0, zIndex: 0 }}>
                <img
                    src="https://images.unsplash.com/photo-1516195851888-6f1a981a8a2a?w=1600"
                    alt="Background"
                    style={{ width: '100%', height: '100%', objectFit: 'cover', opacity: 0.05 }}
                />
            </div>

            <motion.div
                initial={{ opacity: 0, scale: 0.98, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                transition={{ duration: 0.5, ease: 'easeOut' }}
                style={{
                    position: 'relative',
                    zIndex: 10,
                    width: '100%',
                    maxWidth: '460px',
                    background: '#fff',
                    borderRadius: '24px',
                    padding: '36px 28px',
                    boxShadow: AppTheme.shadows.card,
                    border: '1px solid rgba(0,0,0,0.04)',
                    textAlign: 'center'
                }}
            >
                <div style={{
                    width: '72px',
                    height: '72px',
                    borderRadius: '18px',
                    background: '#F9FAFB',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    margin: '0 auto 18px'
                }}>
                    {icon}
                </div>

                <h1 style={{ margin: '0 0 10px 0', fontSize: '26px', fontWeight: '900', letterSpacing: '-0.8px', color: AppTheme.colors.textPrimary }}>
                    {title}
                </h1>
                <p style={{ margin: 0, color: AppTheme.colors.textSecondary, fontSize: '15px', lineHeight: '1.6' }}>
                    {message}
                </p>

                <div style={{ marginTop: '28px' }}>
                    <PremiumButton
                        text={status === 'success' ? 'Continue' : 'Go to Login'}
                        type="gradient"
                        fullWidth
                        onClick={() => {
                            if (status === 'success' && authService.getToken()) navigate('/home');
                            else navigate('/login');
                        }}
                        style={{ height: '56px', borderRadius: '16px', fontSize: '16px', fontWeight: '800' }}
                    />
                </div>
            </motion.div>
        </div>
    );
};

export default VerifyEmail;

