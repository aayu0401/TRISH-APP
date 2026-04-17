import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { FaCrown, FaCheck, FaStar, FaBolt, FaArrowLeft } from 'react-icons/fa';
import GlassCard from '../components/common/GlassCard';
import PremiumButton from '../components/common/PremiumButton';
import { AppTheme } from '../theme/AppTheme';
import { useNavigate } from 'react-router-dom';
import { useToast } from '../context/ToastContext';
import { subscriptionService } from '../services/subscription.service';
import { useAuth } from '../context/AuthContext';
import { userService } from '../services/user.service';

const DEFAULT_PLANS = [
    {
        id: 'basic',
        planCode: 'BASIC',
        name: 'Trish Plus',
        price: '₹599',
        period: '/mo',
        features: ['Unlimited Likes', 'See Who Liked You', '5 Super Likes/week', 'No Ads'],
        color: AppTheme.colors.brandBlue,
        icon: FaStar,
        gradient: 'linear-gradient(135deg, #3B82F6 0%, #2563EB 100%)'
    },
    {
        id: 'premium',
        planCode: 'PREMIUM',
        name: 'Trish Gold',
        price: '₹1499',
        period: '/mo',
        features: ['Everything in Plus', 'AI Personality Insights', 'Passport Global Access', '1 Boost/month', 'New Top Picks Every Day'],
        color: '#FBBF24',
        icon: FaCrown,
        popular: true,
        gradient: 'linear-gradient(135deg, #FBBF24 0%, #D97706 100%)'
    },
    {
        id: 'vip',
        planCode: 'VIP',
        name: 'Trish Platinum',
        price: '₹2999',
        period: '/mo',
        features: ['Everything in Gold', 'Priority Likes', 'Message Before Matching', 'Advanced Matching Filters', 'See Priority Matches'],
        color: '#1E293B',
        icon: FaBolt,
        gradient: 'linear-gradient(135deg, #1E293B 0%, #0F172A 100%)'
    }
];

const Subscription = () => {
    const navigate = useNavigate();
    const { showToast } = useToast();
    const { setUser } = useAuth();
    const [plans, setPlans] = useState(DEFAULT_PLANS);
    const [selectedPlan, setSelectedPlan] = useState('premium');
    const [isLoading, setIsLoading] = useState(false);

    useEffect(() => {
        let isMounted = true;
        const loadPlans = async () => {
            try {
                const apiPlans = await subscriptionService.getPlans();
                if (!isMounted || !Array.isArray(apiPlans)) return;

                const apiByCode = new Map(
                    apiPlans
                        .filter((p) => p && typeof p === 'object' && typeof p.plan === 'string')
                        .map((p) => [p.plan.toUpperCase(), p])
                );

                setPlans((prev) => prev.map((plan) => {
                    const apiPlan = apiByCode.get(plan.planCode);
                    if (!apiPlan) return plan;

                    const apiPrice = typeof apiPlan.price === 'number' ? apiPlan.price : Number(apiPlan.price ?? NaN);
                    const price = Number.isFinite(apiPrice) ? `₹${apiPrice}` : plan.price;
                    const features = Array.isArray(apiPlan.features) ? apiPlan.features : plan.features;

                    return { ...plan, price, features };
                }));
            } catch (_e) {
                // Keep defaults if backend isn't reachable
            }
        };
        loadPlans();
        return () => { isMounted = false; };
    }, []);

    const handleSubscribe = async () => {
        setIsLoading(true);
        try {
            const plan = plans.find((p) => p.id === selectedPlan);
            const planCode = plan?.planCode ?? String(selectedPlan).toUpperCase();

            await subscriptionService.subscribe({ plan: planCode, paymentMethod: 'WALLET' });
            try {
                const refreshed = await userService.getProfile();
                setUser(refreshed);
            } catch (_e) {
                // Non-blocking: subscription succeeded even if refresh fails
            }
            showToast("Subscription Successful! Enjoy your premium benefits.", "success");
            navigate('/profile');
        } catch (error) {
            console.error('Subscription failed:', error);
            showToast("Subscription failed. Please check your wallet balance and try again.", "error");
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            padding: '24px',
            color: AppTheme.colors.textPrimary,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center'
        }}>
            <div style={{ width: '100%', maxWidth: '800px', marginBottom: '20px' }}>
                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => navigate(-1)}
                    style={{ background: '#FFFFFF', border: 'none', color: AppTheme.colors.textPrimary, cursor: 'pointer', padding: '12px', borderRadius: '50%', boxShadow: '0 2px 5px rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                >
                    <FaArrowLeft size={16} />
                </motion.button>
            </div>

            <div style={{ textAlign: 'center', marginBottom: '40px' }}>
                <FaCrown size={48} color="#FBBF24" style={{ marginBottom: '16px' }} />
                <h1 style={{ fontSize: '32px', marginBottom: '8px', fontWeight: '800', color: AppTheme.colors.textPrimary }}>Unlock Trish Premium</h1>
                <p style={{ color: AppTheme.colors.textSecondary, fontSize: '16px' }}>Elevate your dating experience</p>
            </div>

            <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '24px',
                width: '100%',
                maxWidth: '600px',
                marginBottom: '100px'
            }}>
                {plans.map((plan) => {
                    const isSelected = selectedPlan === plan.id;
                    return (
                        <motion.div
                            key={plan.id}
                            whileHover={{ scale: 1.02, y: -5 }}
                            onClick={() => setSelectedPlan(plan.id)}
                            style={{ cursor: 'pointer', position: 'relative' }}
                        >
                            {plan.popular && (
                                <div style={{
                                    position: 'absolute',
                                    top: '-12px',
                                    left: '50%',
                                    transform: 'translateX(-50%)',
                                    background: AppTheme.gradients.primary,
                                    color: '#FFFFFF',
                                    padding: '6px 16px',
                                    borderRadius: '16px',
                                    fontSize: '12px',
                                    fontWeight: '800',
                                    zIndex: 10,
                                    boxShadow: '0 4px 10px rgba(253, 41, 123, 0.3)'
                                }}>
                                    MOST POPULAR
                                </div>
                            )}
                            <div style={{
                                padding: '24px',
                                borderRadius: '24px',
                                border: isSelected ? 'none' : '1px solid #E5E7EB',
                                background: isSelected ? plan.gradient : '#FFFFFF',
                                color: isSelected ? '#FFFFFF' : AppTheme.colors.textPrimary,
                                boxShadow: isSelected ? `0 20px 40px ${plan.id === 'vip' ? 'rgba(30, 41, 59, 0.4)' : 'rgba(251, 191, 36, 0.4)'}` : '0 4px 15px rgba(0,0,0,0.02)',
                                transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                                position: 'relative',
                                overflow: 'hidden'
                            }}>
                                {isSelected && (
                                    <motion.div
                                        initial={{ x: '-100%' }}
                                        animate={{ x: '100%' }}
                                        transition={{ duration: 1.5, repeat: Infinity, ease: "linear" }}
                                        style={{
                                            position: 'absolute', inset: 0,
                                            background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent)',
                                            zIndex: 1
                                        }}
                                    />
                                )}
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px', position: 'relative', zIndex: 2 }}>
                                    <div>
                                        <h3 style={{ fontSize: '22px', fontWeight: '800', color: isSelected ? '#FFFFFF' : plan.color, marginBottom: '4px' }}>{plan.name}</h3>
                                        <div style={{ display: 'flex', alignItems: 'baseline', gap: '4px' }}>
                                            <span style={{ fontSize: '32px', fontWeight: '900' }}>{plan.price}</span>
                                            <span style={{ fontSize: '15px', opacity: 0.8, fontWeight: '500' }}>{plan.period}</span>
                                        </div>
                                    </div>
                                    <div style={{ width: '50px', height: '50px', borderRadius: '16px', background: isSelected ? 'rgba(255,255,255,0.2)' : `${plan.color}15`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                        <plan.icon size={24} color={isSelected ? '#FFFFFF' : plan.color} />
                                    </div>
                                </div>
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', position: 'relative', zIndex: 2 }}>
                                    {plan.features.map((feature, i) => (
                                        <div key={i} style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                                            <div style={{ width: '20px', height: '20px', borderRadius: '50%', background: isSelected ? 'rgba(255,255,255,0.2)' : `${AppTheme.colors.successGreen}20`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                                <FaCheck size={10} color={isSelected ? '#FFFFFF' : AppTheme.colors.successGreen} />
                                            </div>
                                            <span style={{ fontSize: '15px', color: isSelected ? 'rgba(255,255,255,0.9)' : AppTheme.colors.textSecondary, fontWeight: '500' }}>{feature}</span>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </motion.div>
                    );
                })}
            </div>

            <div style={{
                position: 'fixed',
                bottom: 0,
                left: 0,
                right: 0,
                padding: '24px',
                background: 'rgba(255, 255, 255, 0.95)',
                backdropFilter: 'blur(10px)',
                borderTop: '1px solid #E5E7EB',
                display: 'flex',
                justifyContent: 'center',
                boxShadow: '0 -4px 20px rgba(0,0,0,0.05)',
                zIndex: 100
            }}>
                <div style={{ width: '100%', maxWidth: '400px' }}>
                    <PremiumButton
                        text={`Subscribe to ${plans.find(p => p.id === selectedPlan)?.name ?? 'Plan'}`}
                        type="gradient"
                        fullWidth
                        isLoading={isLoading}
                        onClick={handleSubscribe}
                    />
                </div>
            </div>
        </div>
    );
};

export default Subscription;
