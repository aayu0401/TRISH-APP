import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaRobot, FaMagic, FaLightbulb, FaTimes, FaHeart, FaBolt, FaStar, FaShieldAlt, FaComments, FaUserEdit } from 'react-icons/fa';
import { AppTheme } from '../../theme/AppTheme';
import { aiService } from '../../services/ai.service';

const AIAssistantOverlay = ({ context = 'general', suggestions = [], onAction }) => {
    const [isOpen, setIsOpen] = useState(false);
    const [showTip, setShowTip] = useState(false);
    const [currentTip, setCurrentTip] = useState("");
    const [aiStatus, setAiStatus] = useState('offline');
    const [isWingmanMode, setIsWingmanMode] = useState(context === 'chat');

    const wingmanTips = [
        "She just mentioned her dog. Ask for its name to show genuine interest!",
        "You're doing great! Your sentiment score is perfectly balanced.",
        "Pro tip: Mentioning a specific detail from her bio increases response rates by 40%.",
        "It might be a good time to suggest a coffee date. She seems engaged!",
        "Neural Clarity: Keep the conversation flowing to reveal her profile photo! 🌫️✨"
    ];

    const defaultTips = {
        home: "I've prioritized high compatibility profiles for you today!",
        chat: "Activating Wingman Mode... I'll analyze the vibe in real-time.",
        blind_chat: "This is a Blind Match. Every message sent reveals a bit of clarity!",
        profile: "Adding one more photo increases your match rate by 20%.",
        general: "Hi! I'm Trish AI. Tap here for premium insights."
    };

    useEffect(() => {
        const checkAI = async () => {
            try {
                const isOnline = await aiService.checkHealth();
                setAiStatus(isOnline ? 'online' : 'offline');
            } catch {
                setAiStatus('offline');
            }
        };
        checkAI();
        const interval = setInterval(checkAI, 15000);
        return () => clearInterval(interval);
    }, []);

    useEffect(() => {
        if (!isOpen) {
            const timer = setTimeout(() => {
                const tipList = isWingmanMode ? wingmanTips : [defaultTips[context] || defaultTips.general];
                setCurrentTip(tipList[Math.floor(Math.random() * tipList.length)]);
                setShowTip(true);
            }, 3000);
            return () => clearTimeout(timer);
        }
    }, [context, isOpen, isWingmanMode]);

    return (
        <>
            {/* HUD Toggle Hub */}
            <motion.div
                style={{
                    position: 'fixed',
                    bottom: '100px',
                    right: '24px',
                    zIndex: 2500
                }}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
            >
                <div style={{ position: 'relative' }}>
                    <AnimatePresence>
                        {showTip && !isOpen && (
                            <motion.div
                                initial={{ opacity: 0, x: 20, y: 10 }}
                                animate={{ opacity: 1, x: 0, y: 0 }}
                                exit={{ opacity: 0, x: 20, scale: 0.9 }}
                                onClick={() => { setIsOpen(true); setShowTip(false); }}
                                style={{
                                    position: 'absolute',
                                    bottom: '80px',
                                    right: '0',
                                    width: '260px',
                                    cursor: 'pointer'
                                }}
                            >
                                <div style={{
                                    padding: '16px',
                                    borderRadius: '24px',
                                    background: isWingmanMode ? 'linear-gradient(135deg, #1e1b4b 0%, #312e81 100%)' : '#FFFFFF',
                                    color: isWingmanMode ? '#FFFFFF' : AppTheme.colors.textPrimary,
                                    fontSize: '14px',
                                    fontWeight: '600',
                                    boxShadow: '0 15px 35px rgba(0,0,0,0.15)',
                                    border: isWingmanMode ? '1px solid rgba(255,255,255,0.1)' : '1px solid #E5E7EB',
                                    lineHeight: '1.4',
                                    position: 'relative'
                                }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', color: isWingmanMode ? '#FBBF24' : AppTheme.colors.primaryPink }}>
                                        {isWingmanMode ? <FaBolt size={14} /> : <FaStar size={14} />}
                                        <span style={{ fontSize: '12px', fontWeight: '800', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                                            {isWingmanMode ? "Wingman Alert" : "AI Intelligence"}
                                        </span>
                                    </div>
                                    <span style={{ opacity: 0.9 }}>{currentTip}</span>
                                    <div style={{
                                        position: 'absolute', bottom: '-8px', right: '28px',
                                        width: '16px', height: '16px',
                                        background: isWingmanMode ? '#312e81' : '#FFFFFF',
                                        borderBottom: isWingmanMode ? 'none' : '1px solid #E5E7EB',
                                        borderRight: isWingmanMode ? 'none' : '1px solid #E5E7EB',
                                        transform: 'rotate(45deg)',
                                        zIndex: -1
                                    }} />
                                </div>
                            </motion.div>
                        )}
                    </AnimatePresence>

                    <button
                        onClick={() => {
                            setIsOpen(!isOpen);
                            setShowTip(false);
                        }}
                        style={{
                            width: '68px',
                            height: '68px',
                            borderRadius: '50%',
                            background: isWingmanMode ? 'linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%)' : AppTheme.gradients.primary,
                            color: '#fff',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            boxShadow: '0 12px 25px rgba(0,0,0,0.2)',
                            border: '4px solid #FFFFFF',
                            cursor: 'pointer',
                            position: 'relative'
                        }}
                    >
                        <motion.div
                            animate={{
                                rotate: isOpen ? 90 : 0,
                                scale: [1, 1.1, 1]
                            }}
                            transition={{
                                rotate: { type: 'spring', damping: 20 },
                                scale: { repeat: Infinity, duration: 4 }
                            }}
                        >
                            {isOpen ? <FaTimes size={26} /> : (isWingmanMode ? <FaRobot size={28} /> : <FaMagic size={26} />)}
                        </motion.div>

                        <div style={{
                            position: 'absolute',
                            top: '10px',
                            right: '10px',
                            width: '14px',
                            height: '14px',
                            background: aiStatus === 'online' ? AppTheme.colors.successGreen : '#FF385C',
                            borderRadius: '50%',
                            border: '3px solid #FFFFFF'
                        }} />
                    </button>
                </div>
            </motion.div>

            {/* AI Assistant Overlay Content */}
            <AnimatePresence>
                {isOpen && (
                    <>
                        <motion.div
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            onClick={() => setIsOpen(false)}
                            style={{ position: 'fixed', inset: 0, background: 'rgba(0, 0, 0, 0.4)', backdropFilter: 'blur(12px)', zIndex: 2998 }}
                        />
                        <motion.div
                            initial={{ y: '100%', opacity: 0 }}
                            animate={{ y: 0, opacity: 1 }}
                            exit={{ y: '100%', opacity: 0 }}
                            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                            style={{
                                position: 'fixed', bottom: '0', left: '0', width: '100%',
                                background: AppTheme.colors.lightBackground,
                                borderTopLeftRadius: '36px', borderTopRightRadius: '36px',
                                zIndex: 2999, padding: '32px 24px 48px',
                                boxShadow: '0 -15px 50px rgba(0,0,0,0.15)',
                                display: 'flex', flexDirection: 'column',
                                maxHeight: '90vh', overflowY: 'auto'
                            }}
                        >
                            <div style={{ width: '44px', height: '6px', background: '#E5E7EB', borderRadius: '3px', margin: '-12px auto 28px' }} />

                            <div style={{ display: 'flex', alignItems: 'center', gap: '20px', marginBottom: '40px' }}>
                                <div style={{
                                    width: '72px', height: '72px', borderRadius: '24px',
                                    background: isWingmanMode ? 'linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%)' : `${AppTheme.colors.primaryPink}15`,
                                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    color: isWingmanMode ? '#FFFFFF' : AppTheme.colors.primaryPink,
                                    boxShadow: '0 8px 16px rgba(0,0,0,0.05)'
                                }}>
                                    <FaRobot size={36} />
                                </div>
                                <div style={{ flex: 1 }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                        <h2 style={{ fontSize: '26px', fontWeight: '900', margin: 0, color: AppTheme.colors.textPrimary, letterSpacing: '-0.5px' }}>
                                            {isWingmanMode ? "Wingman AI" : "Trish Intelligence"}
                                        </h2>
                                        {isWingmanMode && <span style={{ fontSize: '10px', background: '#FBBF24', color: '#1e1b4b', padding: '2px 8px', borderRadius: '10px', fontWeight: '900' }}>PREMIUM</span>}
                                    </div>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '4px' }}>
                                        <div style={{ width: '8px', height: '8px', borderRadius: '50%', background: aiStatus === 'online' ? AppTheme.colors.successGreen : '#FF385C' }} />
                                        <span style={{ fontSize: '13px', color: AppTheme.colors.textSecondary, fontWeight: '700' }}>
                                            {aiStatus === 'online' ? 'Active & Analyzing' : 'Systems Offline'}
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
                                {/* Smart Insights Card */}
                                <section style={{ background: '#FFFFFF', padding: '24px', borderRadius: '28px', border: '1px solid #E5E7EB', boxShadow: '0 4px 15px rgba(0,0,0,0.02)' }}>
                                    <h3 style={{ fontSize: '16px', color: AppTheme.colors.textPrimary, fontWeight: '800', marginBottom: '20px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                                        <FaLightbulb color="#FBBF24" size={18} /> Deep Match Analytics
                                    </h3>
                                    <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                        {(isWingmanMode ? wingmanTips : (suggestions.length > 0 ? suggestions : [
                                            "Your profile compatibility is peaking with creative professionals.",
                                            "Match quality has improved by 40% after your Recent Verification.",
                                            "Pro Tip: Sunday evenings are the most active times for matches nearby."
                                        ])).map((tip, i) => (
                                            <motion.div
                                                key={i}
                                                initial={{ opacity: 0, x: -10 }}
                                                animate={{ opacity: 1, x: 0 }}
                                                transition={{ delay: i * 0.1 }}
                                                style={{
                                                    padding: '16px', background: '#F9FAFB', borderRadius: '18px',
                                                    fontSize: '14px', lineHeight: '1.6', color: AppTheme.colors.textSecondary,
                                                    fontWeight: '600', position: 'relative', paddingLeft: '44px'
                                                }}
                                            >
                                                <div style={{ position: 'absolute', left: '16px', top: '18px', color: AppTheme.colors.brandBlue }}>
                                                    <FaStar size={12} />
                                                </div>
                                                {tip}
                                            </motion.div>
                                        ))}
                                    </div>
                                </section>

                                {/* Action Grid */}
                                <section>
                                    <h3 style={{ fontSize: '15px', color: AppTheme.colors.textTertiary, fontWeight: '800', marginBottom: '20px', textTransform: 'uppercase', letterSpacing: '1px', paddingLeft: '8px' }}>
                                        Neural Commands
                                    </h3>
                                    <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '14px' }}>
                                        <ActionButton
                                            text={isWingmanMode ? "Analyze Chat Vibe" : "Optimize My Profile"}
                                            icon={isWingmanMode ? <FaComments /> : <FaUserEdit />}
                                            onClick={() => onAction?.(isWingmanMode ? 'analyze' : 'optimize')}
                                        />
                                        <ActionButton
                                            text="Safety Security Audit"
                                            icon={<FaShieldAlt />}
                                            onClick={() => onAction?.('security')}
                                        />
                                        <ActionButton
                                            text="Magic Icebreaker"
                                            icon={<FaBolt />}
                                            onClick={() => onAction?.('magic')}
                                        />
                                    </div>
                                </section>
                            </div>
                        </motion.div>
                    </>
                )}
            </AnimatePresence>
        </>
    );
};

const ActionButton = ({ text, icon, onClick }) => (
    <motion.button
        whileHover={{ scale: 1.02, background: '#F8FAFC' }}
        whileTap={{ scale: 0.98 }}
        onClick={onClick}
        style={{
            width: '100%', padding: '20px', borderRadius: '24px',
            border: '1px solid #E5E7EB', background: '#FFFFFF',
            color: AppTheme.colors.textPrimary, fontSize: '16px', fontWeight: '800',
            textAlign: 'left', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '20px',
            boxShadow: '0 4px 12px rgba(0,0,0,0.03)', transition: 'all 0.2s'
        }}
    >
        <div style={{
            width: '44px', height: '44px', borderRadius: '14px',
            background: `${AppTheme.colors.brandBlue}10`, display: 'flex',
            alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.brandBlue
        }}>
            {icon}
        </div>
        <span style={{ flex: 1 }}>{text}</span>
        <div style={{ color: AppTheme.colors.textTertiary }}>
            <FaStar size={12} />
        </div>
    </motion.button>
);

export default AIAssistantOverlay;
