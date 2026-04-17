import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaPhoneSlash, FaMicrophone, FaMicrophoneSlash, FaVideo, FaVideoSlash, FaShieldAlt, FaEllipsisV } from 'react-icons/fa';
import { useNavigate, useLocation } from 'react-router-dom';
import { AppTheme } from '../theme/AppTheme';

const VideoCall = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const { matchName, matchImage } = location.state || { matchName: "Sarah", matchImage: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600" };

    const [aiInsight, setAiInsight] = useState("Initializing AI Security Shield...");
    const [sparkLevel, setSparkLevel] = useState(0);
    const [isConnecting, setIsConnecting] = useState(true);
    const [callDuration, setCallDuration] = useState(0);
    const [isMuted, setIsMuted] = useState(false);
    const [isVideoOff, setIsVideoOff] = useState(false);

    const insights = [
        "Positive sentiment detected. You're both smiling!",
        "Mutual interests found: 'Adventure' & 'Coffee'.",
        "TRISH AI Suggestion: Ask about her recent trip!",
        "Match Compatibility: 94% and rising.",
        "Emotional Resonance: High Sync detected."
    ];

    useEffect(() => {
        const timer = setTimeout(() => setIsConnecting(false), 2500);
        return () => clearTimeout(timer);
    }, []);

    useEffect(() => {
        if (isConnecting) return;
        const interval = setInterval(() => setCallDuration((prev) => prev + 1), 1000);
        return () => clearInterval(interval);
    }, [isConnecting]);

    useEffect(() => {
        if (!isConnecting) {
            const insightInterval = setInterval(() => {
                setAiInsight(insights[Math.floor(Math.random() * insights.length)]);
                setSparkLevel(prev => Math.min(100, prev + Math.floor(Math.random() * 15)));
            }, 6000);
            return () => clearInterval(insightInterval);
        }
    }, [isConnecting]);

    const formatTime = (seconds) => {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    };

    const handleEndCall = () => {
        navigate(-1);
    };

    return (
        <div style={{
            height: '100vh',
            width: '100vw',
            background: '#0F172A',
            position: 'fixed',
            inset: 0,
            zIndex: 9999,
            display: 'flex',
            flexDirection: 'column',
            overflow: 'hidden',
            fontFamily: 'Inter, sans-serif'
        }}>
            {/* Main Remote Video View */}
            <div style={{ flex: 1, position: 'relative' }}>
                <AnimatePresence>
                    {isConnecting ? (
                        <motion.div
                            key="connecting"
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            style={{
                                position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
                                alignItems: 'center', justifyContent: 'center',
                                background: 'radial-gradient(circle at center, #1e1b4b 0%, #0f172a 100%)',
                                zIndex: 10
                            }}
                        >
                            <div style={{ position: 'relative' }}>
                                <motion.div
                                    animate={{
                                        scale: [1, 1.2, 1],
                                        boxShadow: [
                                            '0 0 20px rgba(253, 41, 123, 0.2)',
                                            '0 0 40px rgba(253, 41, 123, 0.5)',
                                            '0 0 20px rgba(253, 41, 123, 0.2)'
                                        ]
                                    }}
                                    transition={{ repeat: Infinity, duration: 3 }}
                                    style={{ width: '140px', height: '140px', borderRadius: '50%', overflow: 'hidden', marginBottom: '32px', border: '5px solid #FFFFFF' }}
                                >
                                    <img src={matchImage} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', filter: 'grayscale(30%)' }} />
                                </motion.div>
                                <motion.div
                                    animate={{ rotate: 360 }}
                                    transition={{ repeat: Infinity, duration: 8, ease: 'linear' }}
                                    style={{ position: 'absolute', inset: '-15px', border: '2px dashed rgba(253, 41, 123, 0.4)', borderRadius: '50%' }}
                                />
                            </div>
                            <h2 style={{ color: '#fff', fontSize: '28px', fontWeight: '900', marginBottom: '8px', letterSpacing: '-0.5px' }}>Calling {matchName}</h2>
                            <motion.p
                                animate={{ opacity: [0.4, 1, 0.4] }}
                                transition={{ repeat: Infinity, duration: 2 }}
                                style={{ color: '#94A3B8', fontSize: '15px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '8px' }}
                            >
                                <FaShieldAlt color="#FDA4AF" /> Establishing Neural Link...
                            </motion.p>
                        </motion.div>
                    ) : (
                        <motion.div
                            key="call"
                            initial={{ opacity: 0, scale: 1.1 }}
                            animate={{ opacity: 1, scale: 1 }}
                            style={{ position: 'absolute', inset: 0 }}
                        >
                            <img src={matchImage} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                            <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(to top, rgba(0,0,0,0.7) 0%, transparent 30%, transparent 70%, rgba(0,0,0,0.5) 100%)' }} />

                            {/* AI Neural HUD */}
                            <motion.div
                                initial={{ opacity: 0, x: -20 }}
                                animate={{ opacity: 1, x: 0 }}
                                style={{
                                    position: 'absolute', left: '24px', bottom: '160px',
                                    maxWidth: '280px', zIndex: 110
                                }}
                            >
                                <div style={{
                                    padding: '16px 20px', background: 'rgba(30, 27, 75, 0.6)',
                                    backdropFilter: 'blur(20px)', borderRadius: '24px',
                                    border: '1px solid rgba(255,255,255,0.15)',
                                    boxShadow: '0 10px 30px rgba(0,0,0,0.3)'
                                }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                                        <FaMagic color="#FBBF24" size={14} />
                                        <span style={{ fontSize: '12px', fontWeight: '900', color: '#FBBF24', textTransform: 'uppercase', letterSpacing: '1px' }}>AI Insight</span>
                                    </div>
                                    <p style={{ margin: 0, color: '#fff', fontSize: '14px', fontWeight: '600', lineHeight: '1.4' }}>
                                        {aiInsight}
                                    </p>
                                </div>
                                <div style={{ marginTop: '12px', display: 'flex', alignItems: 'center', gap: '10px' }}>
                                    <div style={{ flex: 1, height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden' }}>
                                        <motion.div
                                            animate={{ width: `${sparkLevel}%` }}
                                            style={{ height: '100%', background: 'linear-gradient(to right, #FD297B, #FF5864)', boxShadow: '0 0 10px #FD297B' }}
                                        />
                                    </div>
                                    <span style={{ fontSize: '11px', color: '#fff', fontWeight: '800' }}>SPARK {sparkLevel}%</span>
                                </div>
                            </motion.div>
                        </motion.div>
                    )}
                </AnimatePresence>

                {/* Local Video View (PiP) */}
                <motion.div
                    drag
                    dragConstraints={{ left: 10, right: 10, top: 10, bottom: 10 }}
                    initial={{ scale: 0 }}
                    animate={!isConnecting ? { scale: 1 } : { scale: 0 }}
                    style={{
                        position: 'absolute', top: '40px', right: '24px',
                        width: '120px', height: '180px', borderRadius: '24px',
                        background: '#334155', border: '3px solid rgba(255,255,255,0.3)',
                        overflow: 'hidden', boxShadow: '0 15px 35px rgba(0,0,0,0.4)',
                        zIndex: 100, cursor: 'grab'
                    }}
                    whileTap={{ cursor: 'grabbing' }}
                >
                    {isVideoOff ? (
                        <div style={{ width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#1E293B' }}>
                            <FaVideoSlash color="#94A3B8" size={24} />
                        </div>
                    ) : (
                        <>
                            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400" alt="Me" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                            <div style={{ position: 'absolute', top: '10px', left: '10px', padding: '4px 8px', background: 'rgba(0,0,0,0.5)', borderRadius: '8px', fontSize: '10px', color: '#fff', fontWeight: '700' }}>YOU</div>
                        </>
                    )}
                </motion.div>

                {/* Header Info */}
                <div style={{ position: 'absolute', top: '32px', left: '24px', zIndex: 100, display: 'flex', alignItems: 'center', gap: '16px' }}>
                    <div style={{
                        padding: '10px 18px', background: 'rgba(15, 23, 42, 0.6)',
                        backdropFilter: 'blur(20px)', borderRadius: '20px',
                        color: '#fff', fontSize: '15px', fontWeight: '800',
                        display: 'flex', alignItems: 'center', gap: '10px',
                        border: '1px solid rgba(255,255,255,0.1)'
                    }}>
                        <motion.div
                            animate={{ opacity: [0.4, 1, 0.4] }}
                            transition={{ repeat: Infinity, duration: 1 }}
                            style={{ width: '10px', height: '10px', borderRadius: '50%', background: '#EF4444', boxShadow: '0 0 8px #EF4444' }}
                        />
                        {formatTime(callDuration)}
                    </div>
                    <motion.div
                        initial={{ scale: 0.9, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        style={{
                            padding: '10px 18px', background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.2) 0%, rgba(5, 150, 105, 0.2) 100%)',
                            backdropFilter: 'blur(10px)', borderRadius: '20px',
                            color: '#34D399', fontSize: '13px', fontWeight: '900',
                            border: '1px solid rgba(52, 211, 153, 0.3)',
                            display: 'flex', alignItems: 'center', gap: '8px',
                            letterSpacing: '0.5px'
                        }}
                    >
                        <FaShieldAlt size={14} /> AI SECURITY ACTIVE
                    </motion.div>
                </div>
            </div>

            {/* Controls */}
            <div style={{
                height: '140px', background: 'rgba(15, 23, 42, 0.8)', backdropFilter: 'blur(30px)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '24px',
                paddingBottom: '20px', borderTop: '1px solid rgba(255,255,255,0.05)'
            }}>
                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => setIsMuted(!isMuted)}
                    style={{
                        width: '56px', height: '56px', borderRadius: '50%',
                        background: isMuted ? '#EF4444' : 'rgba(255,255,255,0.1)',
                        border: 'none', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer'
                    }}
                >
                    {isMuted ? <FaMicrophoneSlash size={20} /> : <FaMicrophone size={20} />}
                </motion.button>

                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={handleEndCall}
                    style={{
                        width: '72px', height: '72px', borderRadius: '50%',
                        background: '#EF4444', border: 'none', color: '#fff',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        cursor: 'pointer', boxShadow: '0 10px 20px rgba(239, 68, 68, 0.3)'
                    }}
                >
                    <FaPhoneSlash size={28} />
                </motion.button>

                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => setIsVideoOff(!isVideoOff)}
                    style={{
                        width: '56px', height: '56px', borderRadius: '50%',
                        background: isVideoOff ? '#EF4444' : 'rgba(255,255,255,0.1)',
                        border: 'none', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer'
                    }}
                >
                    {isVideoOff ? <FaVideoSlash size={20} /> : <FaVideo size={20} />}
                </motion.button>

                <motion.button
                    whileTap={{ scale: 0.9 }}
                    style={{
                        width: '56px', height: '56px', borderRadius: '50%',
                        background: 'rgba(255,255,255,0.1)',
                        border: 'none', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer'
                    }}
                >
                    <FaEllipsisV size={18} />
                </motion.button>
            </div>
        </div>
    );
};

export default VideoCall;
