import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaHeart, FaComment, FaTimes } from 'react-icons/fa';
import PremiumButton from './PremiumButton';
import { AppTheme } from '../../theme/AppTheme';

const MatchModal = ({ isOpen, user, onClose, onChat }) => {
    return (
        <AnimatePresence>
            {isOpen && (
                <div style={{
                    position: 'fixed',
                    inset: 0,
                    zIndex: 3000,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    background: 'rgba(15, 23, 42, 0.9)',
                    backdropFilter: 'blur(20px)'
                }}>
                    {/* Confetti-like effects could be added here */}
                    <motion.div
                        initial={{ opacity: 0, scale: 0.8, rotate: -5 }}
                        animate={{ opacity: 1, scale: 1, rotate: 0 }}
                        exit={{ opacity: 0, scale: 0.9, rotate: 5 }}
                        transition={{ type: "spring", bounce: 0.5, duration: 0.8 }}
                        style={{
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            width: '90%',
                            maxWidth: '440px',
                            background: 'linear-gradient(180deg, #FFFFFF 0%, #F8FAFC 100%)',
                            borderRadius: '40px',
                            padding: '48px 32px',
                            boxShadow: '0 30px 60px rgba(0,0,0,0.3)',
                            position: 'relative',
                            overflow: 'hidden'
                        }}
                    >
                        {/* Decorative background circle */}
                        <div style={{ position: 'absolute', top: '-100px', right: '-100px', width: '300px', height: '300px', borderRadius: '50%', background: 'rgba(253, 41, 123, 0.05)', zIndex: 0 }} />

                        <motion.button
                            whileTap={{ scale: 0.9 }}
                            onClick={onClose}
                            style={{ position: 'absolute', top: '24px', right: '24px', background: 'rgba(15, 23, 42, 0.05)', border: 'none', color: '#64748B', width: '40px', height: '40px', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', zIndex: 10 }}
                        >
                            <FaTimes size={16} />
                        </motion.button>

                        <motion.div
                            initial={{ y: -20, opacity: 0 }}
                            animate={{ y: 0, opacity: 1 }}
                            transition={{ delay: 0.3 }}
                        >
                            <h1 style={{
                                fontSize: '42px',
                                fontWeight: '900',
                                marginBottom: '8px',
                                background: 'linear-gradient(45deg, #FD297B 0%, #FF5864 100%)',
                                WebkitBackgroundClip: 'text',
                                WebkitTextFillColor: 'transparent',
                                letterSpacing: '-1.5px',
                                textAlign: 'center'
                            }}>
                                Match Made!
                            </h1>
                            <p style={{ color: '#64748B', fontSize: '16px', marginBottom: '40px', textAlign: 'center', fontWeight: '500' }}>
                                A connection has been sparked! ✨
                            </p>
                        </motion.div>

                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '48px', position: 'relative', width: '100%' }}>
                            <motion.div
                                initial={{ x: -100, opacity: 0, rotate: -15 }}
                                animate={{ x: 25, opacity: 1, rotate: -5 }}
                                transition={{ delay: 0.4, type: 'spring', stiffness: 100 }}
                                style={{
                                    width: '130px', height: '170px', borderRadius: '24px',
                                    border: `6px solid #FFFFFF`,
                                    overflow: 'hidden',
                                    boxShadow: '0 15px 35px rgba(0,0,0,0.2)',
                                    zIndex: 2,
                                    transformOrigin: 'bottom'
                                }}
                            >
                                <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400" alt="You" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                            </motion.div>

                            <motion.div
                                initial={{ scale: 0, rotate: 180 }}
                                animate={{ scale: 1, rotate: 0 }}
                                transition={{ delay: 0.8, type: 'spring', bounce: 0.7 }}
                                style={{
                                    width: '64px', height: '64px',
                                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    background: '#FD297B', borderRadius: '50%',
                                    color: '#FFFFFF',
                                    boxShadow: '0 10px 25px rgba(253, 41, 123, 0.4)',
                                    zIndex: 5,
                                    position: 'absolute',
                                    border: '4px solid #FFF'
                                }}
                            >
                                <FaHeart size={28} />
                                <motion.div
                                    animate={{ scale: [1, 1.5, 1], opacity: [0.5, 0, 0.5] }}
                                    transition={{ duration: 1.5, repeat: Infinity }}
                                    style={{ position: 'absolute', inset: -8, borderRadius: '50%', border: '2px solid #FD297B' }}
                                />
                            </motion.div>

                            <motion.div
                                initial={{ x: 100, opacity: 0, rotate: 15 }}
                                animate={{ x: -25, opacity: 1, rotate: 5 }}
                                transition={{ delay: 0.4, type: 'spring', stiffness: 100 }}
                                style={{
                                    width: '130px', height: '170px', borderRadius: '24px',
                                    border: `6px solid #FFFFFF`,
                                    overflow: 'hidden',
                                    boxShadow: '0 15px 35px rgba(0,0,0,0.2)',
                                    zIndex: 1,
                                    transformOrigin: 'bottom'
                                }}
                            >
                                <img src={user?.photos?.[0] || 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600'} alt={user.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                            </motion.div>
                        </div>

                        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: '16px', zIndex: 10 }}>
                            <PremiumButton
                                text={`Message ${user.name}`}
                                type="gradient"
                                fullWidth
                                onClick={() => { onClose(); onChat(); }}
                                icon={FaComment}
                                style={{
                                    borderRadius: '24px',
                                    height: '64px',
                                    fontSize: '18px',
                                    fontWeight: '800',
                                    boxShadow: '0 15px 30px rgba(253, 41, 123, 0.3)'
                                }}
                            />
                            <motion.button
                                whileHover={{ backgroundColor: 'rgba(15, 23, 42, 0.05)' }}
                                onClick={onClose}
                                style={{ background: 'transparent', border: 'none', color: '#94A3B8', fontWeight: '700', fontSize: '16px', cursor: 'pointer', padding: '16px', borderRadius: '24px' }}
                            >
                                Not now, keep swiping
                            </motion.button>
                        </div>
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
    );
};

export default MatchModal;
