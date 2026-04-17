import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaArrowLeft, FaCrown, FaMagic, FaInfoCircle, FaHeart, FaEye } from 'react-icons/fa';
import { useNavigate } from 'react-router-dom';
import { AppTheme } from '../theme/AppTheme';
import { userService } from '../services/user.service';
import BlindProfileCard from '../components/common/BlindProfileCard';
import { useToast } from '../context/ToastContext';

const BlindDate = () => {
    const navigate = useNavigate();
    const { showToast } = useToast();
    const [profiles, setProfiles] = useState([]);
    const [loading, setLoading] = useState(true);
    const [currentIndex, setCurrentIndex] = useState(0);
    const [isMatchReveal, setIsMatchReveal] = useState(false);
    const [matchedUser, setMatchedUser] = useState(null);
    const [matchedMatchId, setMatchedMatchId] = useState(null);

    useEffect(() => {
        const fetchDeepProfiles = async () => {
            try {
                setLoading(true);
                // In a real app, this would call a specific blind date endpoint
                const data = await userService.getRecommendations();
                setProfiles(data || []);
            } catch (err) {
                console.error("Failed to load blind matches:", err);
            } finally {
                setLoading(false);
            }
        };
        fetchDeepProfiles();
    }, []);

    const handleSwipe = async (direction) => {
        if (direction === 'right') {
            try {
                const result = await userService.swipe(profiles[currentIndex].id, 'like', true);
                if (result?.matched) {
                    setMatchedUser(profiles[currentIndex]);
                    setMatchedMatchId(result?.match?.id ?? null);
                    setIsMatchReveal(true);
                } else {
                    showToast("Mystery like sent! 💌", "success");
                }
            } catch (error) {
                console.error("Swipe failed:", error);
            }
        }

        if (currentIndex < profiles.length - 1) {
            setCurrentIndex(prev => prev + 1);
        } else {
            setCurrentIndex(-1); // No more profiles
        }
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: '#0F172A', // Dark mystery background
            color: '#F8FAFC',
            padding: '24px',
            position: 'relative',
            overflow: 'hidden'
        }}>
            {/* Ambient Background Glows */}
            <div style={{ position: 'absolute', top: '-100px', right: '-100px', width: '300px', height: '300px', borderRadius: '50%', background: 'rgba(99, 102, 241, 0.15)', filter: 'blur(80px)' }} />
            <div style={{ position: 'absolute', bottom: '-100px', left: '-100px', width: '300px', height: '300px', borderRadius: '50%', background: 'rgba(236, 72, 153, 0.15)', filter: 'blur(80px)' }} />

            <header style={{ marginBottom: '32px', position: 'relative', zIndex: 10 }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
                    <motion.button
                        whileTap={{ scale: 0.9 }}
                        onClick={() => navigate(-1)}
                        style={{ width: '40px', height: '40px', borderRadius: '12px', background: 'rgba(255,255,255,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', border: '1px solid rgba(255,255,255,0.1)', cursor: 'pointer' }}
                    >
                        <FaArrowLeft size={16} />
                    </motion.button>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', background: 'rgba(251, 191, 36, 0.1)', padding: '8px 16px', borderRadius: '16px', border: '1px solid rgba(251, 191, 36, 0.2)' }}>
                        <FaCrown color="#FBBF24" size={12} />
                        <span style={{ fontSize: '11px', fontWeight: '800', color: '#FBBF24', letterSpacing: '0.5px' }}>PREMIUM MODE</span>
                    </div>
                </div>

                <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                        <h1 style={{ fontSize: '32px', margin: 0, fontWeight: '800', letterSpacing: '-0.5px' }}>Blind Date</h1>
                        <FaMagic color="#6366F1" />
                    </div>
                    <p style={{ color: 'rgba(248, 250, 252, 0.61)', fontSize: '15px', fontWeight: '500', marginTop: '4px' }}>Interests first, faces later.</p>
                </div>
            </header>

            <div style={{ position: 'relative', zIndex: 10 }}>
                {loading ? (
                    <div style={{ textAlign: 'center', padding: '100px 0' }}>
                        <motion.div animate={{ rotate: 360 }} transition={{ duration: 1, repeat: Infinity }} style={{ width: '40px', height: '40px', border: '3px solid rgba(255,255,255,0.1)', borderTop: '3px solid #6366F1', borderRadius: '50%', margin: '0 auto' }} />
                        <p style={{ marginTop: '16px', color: 'rgba(255,255,255,0.5)' }}>Searching for mysterious connections...</p>
                    </div>
                ) : currentIndex >= 0 && profiles[currentIndex] ? (
                    <div style={{ position: 'relative' }}>
                        <BlindProfileCard user={profiles[currentIndex]} onSwipe={handleSwipe} />

                        <div style={{ marginTop: '24px', textAlign: 'center', background: 'rgba(248, 250, 252, 0.03)', padding: '16px', borderRadius: '20px', border: '1px solid rgba(255,255,255,0.05)' }}>
                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', color: 'rgba(248, 250, 252, 0.5)', fontSize: '13px' }}>
                                <FaInfoCircle size={14} />
                                <span>Pictures will reveal automatically once you both match.</span>
                            </div>
                        </div>
                    </div>
                ) : (
                    <div style={{ textAlign: 'center', padding: '100px 40px', background: 'rgba(255,255,255,0.02)', borderRadius: '32px', border: '1px solid rgba(255,255,255,0.05)' }}>
                        <div style={{ width: '80px', height: '80px', borderRadius: '50%', background: 'rgba(99, 102, 241, 0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 24px' }}>
                            <FaEye color="rgba(255,255,255,0.2)" size={32} />
                        </div>
                        <h3 style={{ fontSize: '20px', fontWeight: '800', marginBottom: '8px' }}>No more Mystery Match</h3>
                        <p style={{ color: 'rgba(255,255,255,0.5)', fontSize: '15px' }}>Check back later or try the normal discovery mode.</p>
                        <motion.button
                            whileTap={{ scale: 0.95 }}
                            onClick={() => navigate('/home')}
                            style={{
                                marginTop: '24px',
                                padding: '12px 32px',
                                borderRadius: '16px',
                                background: AppTheme.gradients.primary,
                                border: 'none',
                                color: '#fff',
                                fontWeight: '700',
                                cursor: 'pointer'
                            }}
                        >
                            Back to Home
                        </motion.button>
                    </div>
                )}
            </div>

            {/* Match Reveal Modal */}
            <AnimatePresence>
                {isMatchReveal && matchedUser && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        style={{ position: 'fixed', inset: 0, zIndex: 1000, background: 'rgba(15, 23, 42, 0.95)', backdropFilter: 'blur(20px)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px' }}
                    >
                        <motion.div
                            initial={{ scale: 0.8, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            style={{ width: '100%', maxWidth: '400px', textAlign: 'center' }}
                        >
                            <motion.div
                                animate={{ rotate: [0, 10, -10, 0] }}
                                transition={{ repeat: Infinity, duration: 2 }}
                                style={{ fontSize: '64px', marginBottom: '24px' }}
                            >
                                ✨
                            </motion.div>
                            <h2 style={{ fontSize: '32px', fontWeight: '900', marginBottom: '8px', background: AppTheme.gradients.primary, WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>
                                It's a Reveal!
                            </h2>
                            <p style={{ color: 'rgba(255,255,255,0.6)', marginBottom: '32px' }}>
                                You both swiped blindly. Here is your mystery match!
                            </p>

                            <div style={{ position: 'relative', width: '240px', height: '320px', margin: '0 auto 32px', borderRadius: '32px', overflow: 'hidden', boxShadow: '0 20px 50px rgba(0,0,0,0.5)', border: '1px solid rgba(255,255,255,0.1)' }}>
                                <motion.img
                                    initial={{ filter: 'blur(20px)' }}
                                    animate={{ filter: 'blur(0px)' }}
                                    transition={{ duration: 1.5, delay: 0.5 }}
                                    src={matchedUser.avatar}
                                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                                />
                                <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0, padding: '16px', background: 'linear-gradient(to top, rgba(0,0,0,0.8), transparent)' }}>
                                    <h3 style={{ margin: 0, fontSize: '20px', fontWeight: '800' }}>{matchedUser.name}</h3>
                                </div>
                            </div>

                            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                                <motion.button
                                    whileTap={{ scale: 0.95 }}
                                    onClick={() => matchedMatchId != null ? navigate(`/chat/${matchedMatchId}`) : navigate('/matches')}
                                    style={{ padding: '16px', borderRadius: '16px', background: '#F8FAFC', color: '#0F172A', border: 'none', fontWeight: '700', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '10px' }}
                                >
                                    <FaHeart /> Start Conversing
                                </motion.button>
                                <button
                                    onClick={() => setIsMatchReveal(false)}
                                    style={{ padding: '12px', background: 'transparent', color: 'rgba(255,255,255,0.4)', border: 'none', fontWeight: '600', cursor: 'pointer' }}
                                >
                                    Continue Browsing
                                </button>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default BlindDate;
