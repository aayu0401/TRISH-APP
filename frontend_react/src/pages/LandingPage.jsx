import React, { useState } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import { FaHeart, FaShieldAlt, FaMagic, FaGem, FaArrowRight, FaCommentDots, FaDiscord, FaTwitter, FaInstagram } from 'react-icons/fa';
import { AppTheme } from '../theme/AppTheme';
import PremiumButton from '../components/common/PremiumButton';

const LandingPage = () => {
    const navigate = useNavigate();
    const { scrollY } = useScroll();

    const headerBlur = useTransform(scrollY, [0, 100], [0, 20]);
    const headerBg = useTransform(scrollY, [0, 100], ['rgba(255, 255, 255, 0)', 'rgba(255, 255, 255, 0.9)']);
    const headerBorder = useTransform(scrollY, [0, 100], ['rgba(0,0,0,0)', 'rgba(0,0,0,0.05)']);
    const heroY = useTransform(scrollY, [0, 500], [0, 150]);

    return (
        <div style={{ minHeight: '100vh', background: AppTheme.colors.lightBackground, overflowX: 'hidden', color: AppTheme.colors.textPrimary }}>
            {/* Friendly Navbar */}
            <motion.nav
                style={{
                    position: 'fixed', top: 0, left: 0, right: 0, zIndex: 1000,
                    height: '80px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                    padding: '0 5%', backdropFilter: `blur(${headerBlur}px)`,
                    background: headerBg, borderBottom: headerBorder
                }}
            >
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }} onClick={() => navigate('/')}>
                    <div style={{ width: '40px', height: '40px', borderRadius: '12px', background: AppTheme.gradients.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: AppTheme.shadows.glow }}>
                        <FaHeart color="white" size={20} />
                    </div>
                    <span style={{ fontSize: '26px', fontWeight: '800', letterSpacing: '-1px', color: AppTheme.colors.primaryPink }}>Trish</span>
                </div>

                <div style={{ display: 'none', lg: 'flex', alignItems: 'center', gap: '40px' }}>
                    {['Features', 'Safety', 'Testimonials', 'Premium'].map(item => (
                        <motion.a href={`#${item.toLowerCase()}`} key={item}
                            whileHover={{ color: AppTheme.colors.primaryPink }}
                            style={{ color: AppTheme.colors.textSecondary, textDecoration: 'none', fontSize: '15px', fontWeight: '600' }}>
                            {item}
                        </motion.a>
                    ))}
                </div>

                <div style={{ display: 'flex', gap: '16px' }}>
                    <button onClick={() => navigate('/login')} style={{ background: 'transparent', border: 'none', color: AppTheme.colors.textPrimary, fontWeight: '700', fontSize: '15px', cursor: 'pointer', padding: '0 16px' }}>Log In</button>
                    <PremiumButton text="Get Started" type="gradient" onClick={() => navigate('/onboarding')} style={{ height: '44px', borderRadius: '22px', padding: '0 24px', fontSize: '15px' }} />
                </div>
            </motion.nav>

            {/* Hero Section */}
            <section style={{ height: '100vh', position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '0 5%' }}>
                <motion.div style={{ position: 'absolute', inset: 0, y: heroY, zIndex: 0 }}>
                    <img
                        src="https://images.unsplash.com/photo-1549490349-8643362247b5?w=1600"
                        alt="Hero Backdrop"
                        style={{ width: '100%', height: '110%', objectFit: 'cover', opacity: 0.1 }}
                    />
                    <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to bottom, transparent 0%, #F9FAFB 100%)' }} />
                </motion.div>

                <div style={{ position: 'relative', zIndex: 10, textAlign: 'center', maxWidth: '800px', marginTop: '40px' }}>
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8, ease: "easeOut" }}
                    >
                        <h1 style={{ fontSize: '72px', lineHeight: '1.1', marginBottom: '24px', fontWeight: '800', color: AppTheme.colors.textPrimary }}>
                            Start something <span style={{ background: AppTheme.gradients.primary, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', color: AppTheme.colors.primaryPink }}>epic.</span>
                        </h1>
                        <p style={{ fontSize: '20px', color: AppTheme.colors.textSecondary, maxWidth: '600px', margin: '0 auto 40px', lineHeight: '1.6', fontWeight: '500' }}>
                            Match, chat, and meet amazing people right in your area. Your next great connection is just a swipe away.
                        </p>

                        <div style={{ display: 'flex', gap: '20px', justifyContent: 'center' }}>
                            <PremiumButton
                                text="Create Account"
                                type="gradient"
                                onClick={() => navigate('/onboarding')}
                                style={{ height: '56px', borderRadius: '28px', padding: '0 40px', fontSize: '18px', fontWeight: '700' }}
                            />
                        </div>
                    </motion.div>
                </div>
            </section>

            {/* Features Section */}
            <section id="features" style={{ padding: '100px 5%', position: 'relative', background: '#FFFFFF' }}>
                <div style={{ textAlign: 'center', marginBottom: '80px' }}>
                    <h2 style={{ fontSize: '48px', marginBottom: '16px', fontWeight: '800' }}>Why Trish?</h2>
                    <p style={{ color: AppTheme.colors.textSecondary, fontSize: '18px' }}>Designed to make dating fun, safe, and effortless.</p>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '30px' }}>
                    <FeatureCard
                        icon={<FaHeart />}
                        title="Smart Matching"
                        desc="Our intelligent algorithm helps you find people you actually click with, saving you time."
                        color={AppTheme.colors.primaryPink}
                    />
                    <FeatureCard
                        icon={<FaShieldAlt />}
                        title="Verified Profiles"
                        desc="We take safety seriously. Photo verification ensures you're talking to the real deal."
                        color={AppTheme.colors.brandBlue}
                    />
                    <FeatureCard
                        icon={<FaCommentDots />}
                        title="Engaging Chats"
                        desc="Break the ice easily with fun prompts and seamless messaging features."
                        color={AppTheme.colors.accentOrange}
                    />
                </div>
            </section>

            {/* Quote Section */}
            <section id="testimonials" style={{ padding: '120px 5%', background: '#F9FAFB', textAlign: 'center' }}>
                <div style={{ maxWidth: '800px', margin: '0 auto' }}>
                    <FaMagic size={40} color={AppTheme.colors.primaryPink} style={{ marginBottom: '32px', opacity: 0.8 }} />
                    <h2 style={{ fontSize: '40px', fontWeight: '700', color: AppTheme.colors.textPrimary, marginBottom: '24px', lineHeight: '1.3' }}>
                        "Trish brings the spark back to dating. It's clean, simple, and the people are genuine."
                    </h2>
                    <span style={{ fontWeight: '700', color: AppTheme.colors.textSecondary, fontSize: '16px' }}>— Real User Review</span>
                </div>
            </section>

            {/* Footer */}
            <footer style={{ padding: '80px 5% 40px', background: '#FFFFFF', borderTop: '1px solid #F3F4F6' }}>
                <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'space-between', gap: '50px', marginBottom: '60px' }}>
                    <div style={{ maxWidth: '300px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '24px' }}>
                            <div style={{ width: '36px', height: '36px', borderRadius: '10px', background: AppTheme.gradients.primary, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                <FaHeart color="white" size={18} />
                            </div>
                            <span style={{ fontSize: '24px', fontWeight: '800', letterSpacing: '-0.5px', color: AppTheme.colors.primaryPink }}>Trish</span>
                        </div>
                        <p style={{ color: AppTheme.colors.textSecondary, lineHeight: '1.6', fontSize: '15px' }}>
                            Bringing people together one match at a time. Safe, fun, and easy to use.
                        </p>
                    </div>

                    <div style={{ display: 'flex', gap: '80px', flexWrap: 'wrap' }}>
                        <FooterCol title="Legal" items={['Privacy Policy', 'Terms of Service', 'Cookie Policy']} />
                        <FooterCol title="Community" items={['Safety Tips', 'Success Stories', 'Guidelines']} />
                    </div>

                    <div>
                        <h4 style={{ marginBottom: '24px', fontSize: '16px', fontWeight: '700', color: AppTheme.colors.textPrimary }}>Follow Us</h4>
                        <div style={{ display: 'flex', gap: '16px' }}>
                            {[FaTwitter, FaInstagram, FaDiscord].map((Icon, i) => (
                                <motion.div key={i} whileHover={{ y: -3, color: AppTheme.colors.primaryPink }} style={{ cursor: 'pointer', color: AppTheme.colors.textTertiary }}>
                                    <Icon size={24} />
                                </motion.div>
                            ))}
                        </div>
                    </div>
                </div>
                <div style={{ textAlign: 'center', paddingTop: '32px', borderTop: '1px solid #F3F4F6', color: AppTheme.colors.textTertiary, fontSize: '14px', fontWeight: '500' }}>
                    &copy; 2026 Trish. All rights reserved.
                </div>
            </footer>
        </div>
    );
};

const FeatureCard = ({ icon, title, desc, color }) => (
    <motion.div
        whileHover={{ y: -5 }}
        style={{ padding: '40px 30px', textAlign: 'center', background: '#FFFFFF', borderRadius: '24px', boxShadow: AppTheme.shadows.card, border: '1px solid rgba(0,0,0,0.02)' }}
    >
        <div style={{
            width: '64px', height: '64px', borderRadius: '20px', background: `${color}15`,
            display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 24px',
            color: color
        }}>
            {React.cloneElement(icon, { size: 28 })}
        </div>
        <h3 style={{ fontSize: '22px', marginBottom: '16px', fontWeight: '700', color: AppTheme.colors.textPrimary }}>{title}</h3>
        <p style={{ color: AppTheme.colors.textSecondary, lineHeight: '1.6', fontSize: '15px' }}>{desc}</p>
    </motion.div>
);

const FooterCol = ({ title, items }) => (
    <div>
        <h4 style={{ marginBottom: '24px', fontSize: '16px', fontWeight: '700', color: AppTheme.colors.textPrimary }}>{title}</h4>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {items.map(item => (
                <span key={item} style={{ color: AppTheme.colors.textSecondary, fontSize: '15px', cursor: 'pointer', transition: 'color 0.2s' }}>{item}</span>
            ))}
        </div>
    </div>
);

export default LandingPage;
