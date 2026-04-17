import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { FaHeart, FaEnvelope, FaLock, FaEye, FaEyeSlash, FaGoogle, FaApple } from 'react-icons/fa';
import PremiumButton from '../components/common/PremiumButton';
import { AppTheme } from '../theme/AppTheme';
import { useAuth } from '../context/AuthContext';

const Login = () => {
    const navigate = useNavigate();
    const { login } = useAuth();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false);

    const handleLogin = async (e) => {
        e.preventDefault();
        setIsLoading(true);
        try {
            await login(email, password);
            setTimeout(() => {
                setIsLoading(false);
                navigate('/home');
            }, 1000);
        } catch (error) {
            console.error(error);
            setIsLoading(false);
        }
    };

    return (
        <div style={{
            minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: AppTheme.colors.lightBackground, position: 'relative', overflow: 'hidden'
        }}>
            {/* Background Aesthetic */}
            <div style={{ position: 'absolute', inset: 0, zIndex: 0 }}>
                <img
                    src="https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=1600"
                    alt="Background"
                    style={{ width: '100%', height: '100%', objectFit: 'cover', opacity: 0.05 }}
                />
            </div>

            <motion.div
                initial={{ opacity: 0, scale: 0.95, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                transition={{ duration: 0.6, ease: "easeOut" }}
                style={{ position: 'relative', zIndex: 10, width: '100%', maxWidth: '420px', padding: '20px' }}
            >
                <div style={{
                    background: '#FFFFFF',
                    padding: '40px 32px',
                    borderRadius: '24px',
                    boxShadow: AppTheme.shadows.card,
                    border: '1px solid rgba(0,0,0,0.02)'
                }}>
                    <div style={{ textAlign: 'center', marginBottom: '40px' }}>
                        <motion.div
                            whileHover={{ scale: 1.05 }}
                            style={{
                                width: '64px', height: '64px', borderRadius: '16px',
                                background: AppTheme.gradients.primary, display: 'flex',
                                alignItems: 'center', justifyContent: 'center', margin: '0 auto 20px',
                                boxShadow: AppTheme.shadows.glow
                            }}
                        >
                            <FaHeart size={28} color="white" />
                        </motion.div>
                        <h1 style={{ fontSize: '28px', fontWeight: '800', color: AppTheme.colors.textPrimary, marginBottom: '8px' }}>
                            Welcome back!
                        </h1>
                        <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px' }}>
                            Ready to find your match?
                        </p>
                    </div>

                    <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                        <div style={{ position: 'relative' }}>
                            <div style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: AppTheme.colors.textTertiary }}>
                                <FaEnvelope />
                            </div>
                            <input
                                type="email"
                                placeholder="Email address"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                style={{
                                    width: '100%', padding: '16px 16px 16px 48px', borderRadius: '16px',
                                    border: '1px solid #E5E7EB', background: '#F9FAFB',
                                    color: AppTheme.colors.textPrimary, fontSize: '15px', outline: 'none', transition: 'border-color 0.2s'
                                }}
                                required
                            />
                        </div>

                        <div style={{ position: 'relative' }}>
                            <div style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: AppTheme.colors.textTertiary }}>
                                <FaLock />
                            </div>
                            <input
                                type={showPassword ? 'text' : 'password'}
                                placeholder="Password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                style={{
                                    width: '100%', padding: '16px 48px 16px 48px', borderRadius: '16px',
                                    border: '1px solid #E5E7EB', background: '#F9FAFB',
                                    color: AppTheme.colors.textPrimary, fontSize: '15px', outline: 'none', transition: 'border-color 0.2s'
                                }}
                                required
                            />
                            <div
                                onClick={() => setShowPassword(!showPassword)}
                                style={{ position: 'absolute', right: '16px', top: '50%', transform: 'translateY(-50%)', color: AppTheme.colors.textTertiary, cursor: 'pointer' }}
                            >
                                {showPassword ? <FaEyeSlash /> : <FaEye />}
                            </div>
                        </div>

                        <div style={{ textAlign: 'right' }}>
                            <span style={{ color: AppTheme.colors.primaryPink, fontSize: '13px', fontWeight: '600', cursor: 'pointer' }}>
                                Forgot password?
                            </span>
                        </div>

                        <div style={{ marginTop: '4px' }}>
                            <PremiumButton
                                text="Log In"
                                type="gradient"
                                fullWidth
                                isLoading={isLoading}
                                onClick={handleLogin}
                                style={{ height: '56px', borderRadius: '16px', fontSize: '16px', fontWeight: '700' }}
                            />
                        </div>

                        {/* Divider */}
                        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', margin: '8px 0' }}>
                            <div style={{ flex: 1, height: '1px', background: '#E5E7EB' }} />
                            <span style={{ color: AppTheme.colors.textTertiary, fontSize: '13px', fontWeight: '600' }}>or continue with</span>
                            <div style={{ flex: 1, height: '1px', background: '#E5E7EB' }} />
                        </div>

                        {/* Social Login */}
                        <div style={{ display: 'flex', gap: '12px' }}>
                            <motion.button
                                whileTap={{ scale: 0.95 }}
                                type="button"
                                style={{
                                    flex: 1, height: '52px', borderRadius: '16px', border: '1px solid #E5E7EB',
                                    background: '#FFFFFF', display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    gap: '10px', cursor: 'pointer', fontSize: '14px', fontWeight: '600',
                                    color: AppTheme.colors.textPrimary, boxShadow: '0 2px 5px rgba(0,0,0,0.02)'
                                }}
                            >
                                <FaGoogle size={18} color="#DB4437" /> Google
                            </motion.button>
                            <motion.button
                                whileTap={{ scale: 0.95 }}
                                type="button"
                                style={{
                                    flex: 1, height: '52px', borderRadius: '16px', border: '1px solid #E5E7EB',
                                    background: '#FFFFFF', display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    gap: '10px', cursor: 'pointer', fontSize: '14px', fontWeight: '600',
                                    color: AppTheme.colors.textPrimary, boxShadow: '0 2px 5px rgba(0,0,0,0.02)'
                                }}
                            >
                                <FaApple size={20} color="#000" /> Apple
                            </motion.button>
                        </div>

                        <div style={{ textAlign: 'center', marginTop: '16px' }}>
                            <p style={{ color: AppTheme.colors.textSecondary, fontSize: '14px', fontWeight: '500' }}>
                                Don't have an account?{' '}
                                <span
                                    style={{ color: AppTheme.colors.primaryPink, cursor: 'pointer', fontWeight: '700', textDecoration: 'none' }}
                                    onClick={() => navigate('/register')}
                                >
                                    Sign Up
                                </span>
                            </p>
                        </div>
                    </form>
                </div>
            </motion.div>
        </div >
    );
};

export default Login;

