import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaHeart, FaTimes, FaUserCheck, FaBolt, FaArrowLeft, FaCheck } from 'react-icons/fa';
import { AppTheme } from '../theme/AppTheme';
import { useNavigate } from 'react-router-dom';
import { useToast } from '../context/ToastContext';
import PremiumButton from '../components/common/PremiumButton';

// Mock service for pending requests
const matchRequestService = {
    getPendingRequests: async () => {
        return [
            { id: 101, name: 'Elena', age: 24, bio: 'Love travel and coffee!', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400', location: '2 km away', compatibility: '92%' },
            { id: 102, name: 'Marcus', age: 27, bio: 'Fitness enthusiast & foodie', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400', location: '5 km away', compatibility: '88%' },
            { id: 103, name: 'Sofia', age: 22, bio: 'Artist and music lover', avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400', location: '1 km away', compatibility: '96%' },
        ];
    },
    respondToRequest: async (requestId, action) => {
        return new Promise(resolve => setTimeout(() => resolve({ success: true }), 800));
    }
};

const MatchRequests = () => {
    const navigate = useNavigate();
    const { showToast } = useToast();
    const [requests, setRequests] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchRequests = async () => {
            try {
                const data = await matchRequestService.getPendingRequests();
                setRequests(data);
            } catch (err) {
                console.error(err);
            } finally {
                setLoading(false);
            }
        };
        fetchRequests();
    }, []);

    const handleAction = async (id, name, action) => {
        try {
            await matchRequestService.respondToRequest(id, action);
            setRequests(prev => prev.filter(r => r.id !== id));
            showToast(action === 'accept' ? `Matched with ${name}!` : `Request declined`, action === 'accept' ? 'success' : 'info');
            if (action === 'accept') {
                // Potential navigate to chat or show match modal
            }
        } catch (err) {
            showToast('Something went wrong', 'error');
        }
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            padding: '24px',
            paddingBottom: '100px',
            color: AppTheme.colors.textPrimary
        }}>
            <header style={{ marginBottom: '32px', display: 'flex', alignItems: 'center', gap: '16px' }}>
                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => navigate(-1)}
                    style={{
                        width: '44px', height: '44px', borderRadius: '50%',
                        background: '#FFFFFF', border: 'none',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                        boxShadow: AppTheme.shadows.card, cursor: 'pointer', color: AppTheme.colors.textPrimary
                    }}
                >
                    <FaArrowLeft size={18} />
                </motion.button>
                <div>
                    <h1 style={{ fontSize: '28px', margin: 0, fontWeight: '800', letterSpacing: '-0.5px' }}>Match Requests</h1>
                    <p style={{ color: AppTheme.colors.textSecondary, fontSize: '14px', margin: '4px 0 0 0' }}>People who want to connect with you</p>
                </div>
            </header>

            {loading ? (
                <div style={{ display: 'flex', justifyContent: 'center', padding: '100px 0' }}>
                    <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                        style={{ width: '40px', height: '40px', border: `3px solid ${AppTheme.colors.primaryPink}20`, borderTopColor: AppTheme.colors.primaryPink, borderRadius: '50%' }}
                    />
                </div>
            ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                    <AnimatePresence>
                        {requests.map((req) => (
                            <motion.div
                                key={req.id}
                                layout
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                style={{
                                    background: '#FFFFFF',
                                    borderRadius: '24px',
                                    padding: '16px',
                                    boxShadow: AppTheme.shadows.card,
                                    border: '1px solid #F3F4F6',
                                    display: 'flex',
                                    flexDirection: 'column',
                                    gap: '16px'
                                }}
                            >
                                <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                                    <div style={{ position: 'relative' }}>
                                        <img src={req.avatar} alt={req.name} style={{ width: '80px', height: '80px', borderRadius: '20px', objectFit: 'cover' }} />
                                        <div style={{
                                            position: 'absolute', top: '-8px', right: '-8px',
                                            background: AppTheme.gradients.primary, color: '#fff',
                                            padding: '4px 8px', borderRadius: '10px', fontSize: '10px', fontWeight: '800'
                                        }}>
                                            {req.compatibility}
                                        </div>
                                    </div>
                                    <div style={{ flex: 1 }}>
                                        <h3 style={{ margin: '0 0 4px 0', fontSize: '20px', fontWeight: '800' }}>{req.name}, {req.age}</h3>
                                        <p style={{ margin: '0 0 8px 0', fontSize: '14px', color: AppTheme.colors.textSecondary, fontWeight: '500' }}>{req.location}</p>
                                        <p style={{ margin: 0, fontSize: '13px', color: AppTheme.colors.textTertiary, fontStyle: 'italic' }}>"{req.bio}"</p>
                                    </div>
                                </div>

                                <div style={{ display: 'flex', gap: '12px' }}>
                                    <button
                                        onClick={() => handleAction(req.id, req.name, 'decline')}
                                        style={{
                                            flex: 1, height: '48px', borderRadius: '14px',
                                            background: '#F9FAFB', border: '1px solid #E5E7EB',
                                            color: AppTheme.colors.textSecondary, fontWeight: '700',
                                            cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px'
                                        }}
                                    >
                                        <FaTimes /> Decline
                                    </button>
                                    <button
                                        onClick={() => handleAction(req.id, req.name, 'accept')}
                                        style={{
                                            flex: 1.5, height: '48px', borderRadius: '14px',
                                            background: AppTheme.gradients.primary, border: 'none',
                                            color: '#FFFFFF', fontWeight: '700',
                                            cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px',
                                            boxShadow: '0 4px 12px rgba(253, 41, 123, 0.2)'
                                        }}
                                    >
                                        <FaHeart /> Accept Match
                                    </button>
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>

                    {requests.length === 0 && !loading && (
                        <div style={{ textAlign: 'center', padding: '60px 20px' }}>
                            <div style={{
                                width: '80px', height: '80px', borderRadius: '50%',
                                background: '#F3F4F6', display: 'flex', alignItems: 'center',
                                justifyContent: 'center', margin: '0 auto 24px'
                            }}>
                                <FaUserCheck size={32} color={AppTheme.colors.textTertiary} />
                            </div>
                            <h2 style={{ fontSize: '20px', fontWeight: '800', marginBottom: '8px' }}>All Caught Up!</h2>
                            <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px' }}>No new match requests at the moment. Keep exploring!</p>
                            <PremiumButton
                                text="Explore More"
                                type="gradient"
                                onClick={() => navigate('/home')}
                                style={{ marginTop: '24px', height: '48px', borderRadius: '24px', padding: '0 32px' }}
                            />
                        </div>
                    )}
                </div>
            )}
        </div>
    );
};

export default MatchRequests;
