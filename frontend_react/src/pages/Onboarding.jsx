import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { FaHeart, FaShieldAlt, FaCommentDots } from 'react-icons/fa';
import { AppTheme } from '../theme/AppTheme';
import PremiumButton from '../components/common/PremiumButton';

const STEPS = [
    {
        title: "Find Your Match",
        desc: "Join a vibrant community of people looking for genuine connections.",
        icon: FaHeart,
        color: AppTheme.colors.primaryPink,
        image: "https://images.unsplash.com/photo-1511733351957-230a10d99901?w=800"
    },
    {
        title: "Spark Conversations",
        desc: "Break the ice instantly and chat seamlessly with your matches.",
        icon: FaCommentDots,
        color: AppTheme.colors.accentOrange,
        image: "https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?w=800"
    },
    {
        title: "Stay Safe",
        desc: "Your safety is our priority. Verified profiles and secure messaging built-in.",
        icon: FaShieldAlt,
        color: AppTheme.colors.brandBlue,
        image: "https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37?w=800"
    }
];

const Onboarding = () => {
    const [currentStep, setCurrentStep] = useState(0);
    const navigate = useNavigate();

    const handleNext = () => {
        if (currentStep < STEPS.length - 1) {
            setCurrentStep(prev => prev + 1);
        } else {
            navigate('/register');
        }
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            color: AppTheme.colors.textPrimary,
            display: 'flex',
            flexDirection: 'column',
            position: 'relative',
            overflow: 'hidden'
        }}>
            <AnimatePresence mode="wait">
                <motion.div
                    key={currentStep}
                    initial={{ opacity: 0, x: 50 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -50 }}
                    transition={{ duration: 0.4 }}
                    style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
                >
                    {/* Background Image Area */}
                    <div style={{ height: '55vh', position: 'relative' }}>
                        <img
                            src={STEPS[currentStep].image}
                            alt={STEPS[currentStep].title}
                            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                        />
                        <div style={{
                            position: 'absolute', inset: 0,
                            background: 'linear-gradient(to top, #F9FAFB 0%, transparent 100%)'
                        }} />
                    </div>

                    {/* Content Area */}
                    <div style={{ padding: '0 24px', flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'flex-start', textAlign: 'center', marginTop: '-40px', zIndex: 10 }}>
                        <div style={{
                            width: '80px', height: '80px', borderRadius: '50%',
                            background: '#FFFFFF',
                            boxShadow: '0 10px 25px rgba(0,0,0,0.05)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            margin: '0 auto 24px', color: STEPS[currentStep].color
                        }}>
                            {React.createElement(STEPS[currentStep].icon, { size: 40 })}
                        </div>
                        <h1 style={{ fontSize: '32px', fontWeight: '800', marginBottom: '16px', color: AppTheme.colors.textPrimary }}>{STEPS[currentStep].title}</h1>
                        <p style={{ fontSize: '18px', color: AppTheme.colors.textSecondary, lineHeight: '1.6', maxWidth: '300px', margin: '0 auto' }}>
                            {STEPS[currentStep].desc}
                        </p>
                    </div>
                </motion.div>
            </AnimatePresence>

            {/* Bottom Controls */}
            <div style={{ padding: '24px', background: AppTheme.colors.lightBackground }}>
                {/* Progress Dots */}
                <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginBottom: '32px' }}>
                    {STEPS.map((_, i) => (
                        <div key={i} style={{
                            width: i === currentStep ? '24px' : '8px',
                            height: '8px',
                            borderRadius: '4px',
                            background: i === currentStep ? AppTheme.colors.primaryPink : '#E5E7EB',
                            transition: 'all 0.3s'
                        }} />
                    ))}
                </div>

                <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                    <button
                        onClick={() => navigate('/register')}
                        style={{
                            flex: 1, background: 'transparent', border: 'none', color: AppTheme.colors.textSecondary,
                            fontWeight: '600', fontSize: '16px', cursor: 'pointer'
                        }}
                    >
                        Skip
                    </button>
                    <div style={{ flex: 2 }}>
                        <PremiumButton
                            text={currentStep === STEPS.length - 1 ? "Get Started" : "Next"}
                            type="gradient"
                            fullWidth
                            onClick={handleNext}
                        />
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Onboarding;
