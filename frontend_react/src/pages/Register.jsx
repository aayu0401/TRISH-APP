import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { FaUser, FaEnvelope, FaLock, FaCalendar, FaVenusMars, FaHeart, FaArrowRight, FaArrowLeft } from 'react-icons/fa';
import PremiumButton from '../components/common/PremiumButton';
import { AppTheme } from '../theme/AppTheme';
import { useAuth } from '../context/AuthContext';

const Register = () => {
    const navigate = useNavigate();
    const { register } = useAuth();
    const [step, setStep] = useState(1);
    const [formData, setFormData] = useState({
        name: '', email: '', password: '', dateOfBirth: '', gender: ''
    });
    const [isLoading, setIsLoading] = useState(false);

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const nextStep = () => {
        if (step === 1 && (!formData.name || !formData.dateOfBirth || !formData.gender)) return;
        setStep(prev => prev + 1);
    };

    const prevStep = () => {
        setStep(prev => prev - 1);
    };

    const handleRegister = async (e) => {
        e.preventDefault();
        if (!formData.email || !formData.password) return;
        setIsLoading(true);
        try {
            await register(formData);
            setTimeout(() => {
                setIsLoading(false);
                navigate('/home');
            }, 1500);
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
                    src="https://images.unsplash.com/photo-1516195851888-6f1a981a8a2a?w=1600"
                    alt="Background"
                    style={{ width: '100%', height: '100%', objectFit: 'cover', opacity: 0.05 }}
                />
            </div>

            <motion.div
                initial={{ opacity: 0, scale: 0.95, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                transition={{ duration: 0.6, ease: "easeOut" }}
                style={{ position: 'relative', zIndex: 10, width: '100%', maxWidth: '460px', padding: '20px' }}
            >
                <div style={{
                    background: '#FFFFFF',
                    padding: '40px 32px',
                    borderRadius: '24px',
                    boxShadow: AppTheme.shadows.card,
                    border: '1px solid rgba(0,0,0,0.02)',
                    minHeight: '520px',
                    display: 'flex',
                    flexDirection: 'column'
                }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
                        {step === 2 ? (
                            <motion.button whileTap={{ scale: 0.9 }} onClick={prevStep} style={{ background: 'none', border: 'none', color: AppTheme.colors.textSecondary, cursor: 'pointer', padding: '8px' }}>
                                <FaArrowLeft size={20} />
                            </motion.button>
                        ) : (
                            <div style={{ width: '36px' }} />
                        )}

                        <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                            <div style={{ width: '30px', height: '6px', borderRadius: '3px', background: step >= 1 ? AppTheme.colors.primaryPink : '#E5E7EB', transition: 'background 0.3s' }} />
                            <div style={{ width: '30px', height: '6px', borderRadius: '3px', background: step >= 2 ? AppTheme.colors.primaryPink : '#E5E7EB', transition: 'background 0.3s' }} />
                        </div>
                        <div style={{ width: '36px' }} />
                    </div>

                    <div style={{ textAlign: 'center', marginBottom: '30px' }}>
                        <h1 style={{ fontSize: '28px', fontWeight: '800', color: AppTheme.colors.textPrimary, marginBottom: '8px' }}>
                            {step === 1 ? "Let's get started" : "Secure your account"}
                        </h1>
                        <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px' }}>
                            {step === 1 ? "Help us customize your experience." : "Almost there! Choose a secure password."}
                        </p>
                    </div>

                    <form onSubmit={(e) => e.preventDefault()} style={{ display: 'flex', flexDirection: 'column', gap: '20px', flex: 1 }}>
                        <AnimatePresence mode="wait">
                            {step === 1 && (
                                <motion.div
                                    key="step1"
                                    initial={{ opacity: 0, x: -20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: 20 }}
                                    transition={{ duration: 0.3 }}
                                    style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}
                                >
                                    <div style={{ position: 'relative' }}>
                                        <div style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: AppTheme.colors.textTertiary }}>
                                            <FaUser />
                                        </div>
                                        <input
                                            name="name"
                                            type="text"
                                            placeholder="Your First Name"
                                            value={formData.name}
                                            onChange={handleChange}
                                            style={{
                                                width: '100%', padding: '16px 16px 16px 48px', borderRadius: '16px',
                                                border: '1px solid #E5E7EB', background: '#F9FAFB',
                                                color: AppTheme.colors.textPrimary, fontSize: '15px', outline: 'none'
                                            }}
                                            required
                                        />
                                    </div>
                                    <div style={{ position: 'relative' }}>
                                        <div style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: AppTheme.colors.textTertiary }}>
                                            <FaCalendar />
                                        </div>
                                        <input
                                            name="dateOfBirth"
                                            type="date"
                                            value={formData.dateOfBirth}
                                            onChange={handleChange}
                                            style={{
                                                width: '100%', padding: '16px 16px 16px 48px', borderRadius: '16px',
                                                border: '1px solid #E5E7EB', background: '#F9FAFB',
                                                color: formData.dateOfBirth ? AppTheme.colors.textPrimary : AppTheme.colors.textTertiary,
                                                fontSize: '15px', outline: 'none'
                                            }}
                                            required
                                        />
                                    </div>
                                        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                                            <p style={{ fontSize: '14px', fontWeight: '700', color: AppTheme.colors.textSecondary, marginBottom: '4px', textAlign: 'left', paddingLeft: '4px' }}>I am a...</p>
                                            <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
                                            {[
                                                { label: 'Woman', value: 'FEMALE' },
                                                { label: 'Man', value: 'MALE' },
                                                { label: 'Non-binary', value: 'NON_BINARY' },
                                                { label: 'Other', value: 'OTHER' },
                                            ].map((g) => {
                                                const isSelected = formData.gender === g.value;
                                                return (
                                                    <motion.div
                                                        key={g.value}
                                                        whileTap={{ scale: 0.95 }}
                                                        onClick={() => setFormData({ ...formData, gender: g.value })}
                                                        style={{
                                                            flex: '1 1 calc(50% - 6px)', padding: '12px', borderRadius: '12px', textAlign: 'center', cursor: 'pointer',
                                                            background: isSelected ? AppTheme.colors.primaryPink : '#F9FAFB',
                                                            color: isSelected ? '#FFFFFF' : AppTheme.colors.textPrimary,
                                                            border: isSelected ? 'none' : '1px solid #E5E7EB',
                                                            fontSize: '14px', fontWeight: '700', transition: 'all 0.2s'
                                                        }}
                                                    >
                                                        {g.label}
                                                    </motion.div>
                                                );
                                            })}
                                        </div>
                                    </div>
                                    <div style={{ marginTop: 'auto', paddingTop: '20px' }}>
                                        <PremiumButton
                                            text="Continue"
                                            type="gradient"
                                            fullWidth
                                            onClick={nextStep}
                                            icon={FaArrowRight}
                                            style={{ height: '56px', borderRadius: '16px', fontSize: '16px', fontWeight: '700' }}
                                        />
                                    </div>
                                </motion.div>
                            )}

                            {step === 2 && (
                                <motion.div
                                    key="step2"
                                    initial={{ opacity: 0, x: 20 }}
                                    animate={{ opacity: 1, x: 0 }}
                                    exit={{ opacity: 0, x: -20 }}
                                    transition={{ duration: 0.3 }}
                                    style={{ display: 'flex', flexDirection: 'column', gap: '20px', height: '100%' }}
                                >
                                    <div style={{ position: 'relative' }}>
                                        <div style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: AppTheme.colors.textTertiary }}>
                                            <FaEnvelope />
                                        </div>
                                        <input
                                            name="email"
                                            type="email"
                                            placeholder="Email address"
                                            value={formData.email}
                                            onChange={handleChange}
                                            style={{
                                                width: '100%', padding: '16px 16px 16px 48px', borderRadius: '16px',
                                                border: '1px solid #E5E7EB', background: '#F9FAFB',
                                                color: AppTheme.colors.textPrimary, fontSize: '15px', outline: 'none'
                                            }}
                                            required
                                        />
                                    </div>
                                    <div style={{ position: 'relative' }}>
                                        <div style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: AppTheme.colors.textTertiary }}>
                                            <FaLock />
                                        </div>
                                        <input
                                            name="password"
                                            type="password"
                                            placeholder="Create a password"
                                            value={formData.password}
                                            onChange={handleChange}
                                            style={{
                                                width: '100%', padding: '16px 16px 16px 48px', borderRadius: '16px',
                                                border: '1px solid #E5E7EB', background: '#F9FAFB',
                                                color: AppTheme.colors.textPrimary, fontSize: '15px', outline: 'none'
                                            }}
                                            required
                                        />
                                    </div>

                                    {/* Password Strength Indicator */}
                                    {formData.password && (
                                        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                            <div style={{ display: 'flex', gap: '6px' }}>
                                                {[1, 2, 3, 4].map(level => {
                                                    const strength = formData.password.length >= 12 ? 4 : formData.password.length >= 8 ? 3 : formData.password.length >= 6 ? 2 : 1;
                                                    return (
                                                        <div key={level} style={{
                                                            flex: 1, height: '4px', borderRadius: '2px',
                                                            background: level <= strength
                                                                ? (strength <= 1 ? '#EF4444' : strength === 2 ? '#F59E0B' : strength === 3 ? '#3B82F6' : AppTheme.colors.successGreen)
                                                                : '#E5E7EB',
                                                            transition: 'background 0.3s'
                                                        }} />
                                                    );
                                                })}
                                            </div>
                                            <span style={{ fontSize: '12px', fontWeight: '600', color: AppTheme.colors.textTertiary }}>
                                                {formData.password.length < 6 ? 'Weak' : formData.password.length < 8 ? 'Fair' : formData.password.length < 12 ? 'Good' : 'Strong'}
                                            </span>
                                        </div>
                                    )}

                                    {/* Terms */}
                                    <p style={{ fontSize: '12px', color: AppTheme.colors.textTertiary, lineHeight: '1.5', textAlign: 'center', margin: '8px 0 0 0' }}>
                                        By creating an account, you agree to our{' '}
                                        <span style={{ color: AppTheme.colors.primaryPink, fontWeight: '600', cursor: 'pointer' }}>Terms of Service</span>
                                        {' '}and{' '}
                                        <span style={{ color: AppTheme.colors.primaryPink, fontWeight: '600', cursor: 'pointer' }}>Privacy Policy</span>
                                    </p>

                                    <div style={{ marginTop: 'auto', paddingTop: '16px' }}>
                                        <PremiumButton
                                            text="Create Account"
                                            type="gradient"
                                            fullWidth
                                            isLoading={isLoading}
                                            onClick={handleRegister}
                                            style={{ height: '56px', borderRadius: '16px', fontSize: '16px', fontWeight: '700' }}
                                        />
                                    </div>
                                </motion.div>
                            )}
                        </AnimatePresence>
                    </form>

                    <div style={{ textAlign: 'center', marginTop: '24px' }}>
                        <p style={{ color: AppTheme.colors.textSecondary, fontSize: '14px', fontWeight: '500' }}>
                            Already have an account?{' '}
                            <span
                                style={{ color: AppTheme.colors.primaryPink, cursor: 'pointer', fontWeight: '700', textDecoration: 'none' }}
                                onClick={() => navigate('/login')}
                            >
                                Log in
                            </span>
                        </p>
                    </div>
                </div>
            </motion.div>
        </div >
    );
};

export default Register;
