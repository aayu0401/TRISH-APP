import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaGift, FaSearch, FaHeart, FaTimes, FaCheck, FaTruck, FaUserFriends, FaArrowLeft } from 'react-icons/fa';
import GlassCard from '../components/common/GlassCard';
import { AppTheme } from '../theme/AppTheme';
import PremiumButton from '../components/common/PremiumButton';
import { giftService } from '../services/gift.service';
import { matchService } from '../services/match.service';
import { useNavigate } from 'react-router-dom';
import { useToast } from '../context/ToastContext';

const GIFT_CATEGORIES = ['All', 'Flowers', 'Chocolates', 'Teddy', 'Jewelry', 'Virtual'];

const Gifts = () => {
    const navigate = useNavigate();
    const { showToast } = useToast();
    const [gifts, setGifts] = useState([]);
    const [sentGifts, setSentGifts] = useState([]);
    const [receivedGifts, setReceivedGifts] = useState([]);
    const [matches, setMatches] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedCategory, setSelectedCategory] = useState('All');
    const [activeTab, setActiveTab] = useState('Catalog');

    // Send Flow State
    const [isSelectingMatch, setIsSelectingMatch] = useState(false);
    const [selectedGift, setSelectedGift] = useState(null);
    const [sending, setSending] = useState(false);

    useEffect(() => {
        const fetchData = async () => {
            try {
                setLoading(true);
                const [catalogData, sentData, receivedData, matchData] = await Promise.all([
                    giftService.getCatalog(),
                    giftService.getSentGifts(),
                    giftService.getReceivedGifts(),
                    matchService.getMatches()
                ]);
                setGifts(Array.isArray(catalogData) ? catalogData : []);
                setSentGifts(Array.isArray(sentData) ? sentData : []);
                setReceivedGifts(Array.isArray(receivedData) ? receivedData : []);
                setMatches(Array.isArray(matchData) ? matchData : []);
            } catch (error) {
                console.error("Failed to fetch gifts data:", error);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    const handleSendGift = (gift) => {
        setSelectedGift(gift);
        setIsSelectingMatch(true);
    };

    const confirmSend = async (matchId) => {
        if (!selectedGift?.id) {
            showToast('Please select a gift first.', 'error');
            return;
        }

        const match = matches.find((m) => String(m.id) === String(matchId));
        const receiverId = match?.opponent?.id;
        if (!receiverId) {
            showToast("Couldn't determine the recipient for this match.", "error");
            return;
        }

        setSending(true);
        try {
            await giftService.sendGift({ receiverId, giftId: selectedGift.id });
            showToast("Gift sent successfully!", "success");

            const updatedSent = await giftService.getSentGifts();
            setSentGifts(Array.isArray(updatedSent) ? updatedSent : []);
        } catch (error) {
            console.error('Send gift failed:', error);
            showToast("Failed to send gift. Please try again.", "error");
        } finally {
            setSending(false);
            setIsSelectingMatch(false);
            setSelectedGift(null);
        }
    };

    const handleAcceptReceived = async (giftId) => {
        await giftService.acceptGift(giftId);
        showToast("Gift accepted! Check your wallet/inventory.", "success");
        setReceivedGifts(prev => prev.map(g => g.id === giftId ? { ...g, status: 'accepted' } : g));
    };

    const handleDeclineReceived = async (giftId) => {
        await giftService.cancelGift(giftId);
        showToast("Gift declined.", "info");
        setReceivedGifts(prev => prev.filter(g => g.id !== giftId));
    };

    const filteredGifts = selectedCategory === 'All'
        ? gifts
        : gifts.filter(g => g.category === selectedCategory);


    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            padding: '24px',
            paddingBottom: '120px',
            color: AppTheme.colors.textPrimary,
            position: 'relative',
            overflowX: 'hidden'
        }}>
            <header style={{ marginBottom: '32px', position: 'relative', zIndex: 10 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '24px' }}>
                    <motion.button
                        whileTap={{ scale: 0.9 }}
                        onClick={() => navigate(-1)}
                        style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#FFFFFF', boxShadow: '0 2px 10px rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.textPrimary, border: 'none', cursor: 'pointer' }}
                    >
                        <FaArrowLeft size={16} />
                    </motion.button>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '16px' }}>
                    <div>
                        <h1 style={{ fontSize: '32px', margin: 0, fontWeight: '800', letterSpacing: '-0.5px', color: AppTheme.colors.textPrimary }}>Gifts</h1>
                        <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px', fontWeight: '500', marginTop: '4px' }}>Send & Receive Tokens of Affection</p>
                    </div>
                    <div style={{
                        display: 'flex', background: '#FFFFFF',
                        borderRadius: '20px', padding: '4px', border: '1px solid #E5E7EB',
                        boxShadow: '0 2px 10px rgba(0,0,0,0.02)'
                    }}>
                        {['Catalog', 'Sent', 'Received'].map(tab => (
                            <button
                                key={tab}
                                onClick={() => setActiveTab(tab)}
                                style={{
                                    padding: '8px 16px', borderRadius: '14px', border: 'none',
                                    background: activeTab === tab ? AppTheme.gradients.primary : 'transparent',
                                    color: activeTab === tab ? '#FFFFFF' : AppTheme.colors.textSecondary,
                                    fontSize: '13px', fontWeight: '700', cursor: 'pointer', transition: 'all 0.3s'
                                }}
                            >
                                {tab}
                                {tab === 'Received' && receivedGifts.filter(g => g.status === 'pending').length > 0 && (
                                    <span style={{ marginLeft: '4px', background: '#FFFFFF', color: AppTheme.colors.primaryPink, borderRadius: '50%', padding: '2px 6px', fontSize: '10px' }}>
                                        {receivedGifts.filter(g => g.status === 'pending').length}
                                    </span>
                                )}
                            </button>
                        ))}
                    </div>
                </div>
            </header>

            {activeTab === 'Catalog' && (
                <>
                    {/* Categories Scroller */}
                    <div style={{ display: 'flex', overflowX: 'auto', gap: '12px', paddingBottom: '24px', scrollbarWidth: 'none', position: 'relative', zIndex: 10 }}>
                        {GIFT_CATEGORIES.map(cat => (
                            <motion.button
                                key={cat}
                                whileTap={{ scale: 0.95 }}
                                onClick={() => setSelectedCategory(cat)}
                                style={{
                                    padding: '12px 24px', borderRadius: '20px', border: selectedCategory === cat ? 'none' : '1px solid #E5E7EB',
                                    background: selectedCategory === cat ? AppTheme.colors.primaryPink : '#FFFFFF',
                                    color: selectedCategory === cat ? '#fff' : AppTheme.colors.textSecondary,
                                    whiteSpace: 'nowrap', cursor: 'pointer', fontSize: '14px', fontWeight: '600',
                                    transition: 'all 0.2s', boxShadow: selectedCategory === cat ? '0 4px 10px rgba(253, 41, 123, 0.2)' : '0 2px 5px rgba(0,0,0,0.02)'
                                }}
                            >
                                {cat}
                            </motion.button>
                        ))}
                    </div>

                    <motion.div
                        layout
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(160px, 1fr))', gap: '20px', position: 'relative', zIndex: 10 }}
                    >
                        {filteredGifts.map((gift, i) => (
                            <motion.div layout key={gift.id} initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: i * 0.05 }} >
                                <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', alignItems: 'center', background: '#FFFFFF', borderRadius: '24px', border: '1px solid #E5E7EB', boxShadow: '0 4px 15px rgba(0,0,0,0.02)' }}>
                                    <motion.div whileHover={{ scale: 1.1, rotate: 5 }} style={{ width: '90px', height: '90px', borderRadius: '24px', background: '#F9FAFB', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '44px', marginBottom: '20px', overflow: 'hidden' }}>
                                        {gift.imageUrl ? (
                                            <img src={gift.imageUrl} alt={gift.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                        ) : (
                                            <span style={{ lineHeight: 1 }}>{getGiftEmoji(gift)}</span>
                                        )}
                                    </motion.div>
                                    <h3 style={{ fontSize: '16px', fontWeight: '800', textAlign: 'center', marginBottom: '8px', color: AppTheme.colors.textPrimary }}>{gift.name}</h3>
                                    <span style={{ color: AppTheme.colors.primaryPink, fontWeight: '800', fontSize: '18px', marginBottom: '16px' }}>₹{gift.price}</span>
                                    <PremiumButton text="Send Gift" type="gradient" fullWidth onClick={() => handleSendGift(gift)} style={{ height: '44px', borderRadius: '16px' }} />
                                </div>
                            </motion.div>
                        ))}
                    </motion.div>
                </>
            )}

            {activeTab === 'Sent' && (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                    {sentGifts.length === 0 ? (
                        <EmptyGifts message="Your sent gifts history will appear here." />
                    ) : (
                        sentGifts.map((gift, i) => <SentGiftCard key={gift.id} gift={gift} index={i} />)
                    )}
                </motion.div>
            )}

            {activeTab === 'Received' && (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                    {receivedGifts.length === 0 ? (
                        <EmptyGifts message="No gifts received yet." />
                    ) : (
                        receivedGifts.map((gift, i) => (
                            <ReceivedGiftCard
                                key={gift.id}
                                gift={gift}
                                index={i}
                                onAccept={() => handleAcceptReceived(gift.id)}
                                onDecline={() => handleDeclineReceived(gift.id)}
                            />
                        ))
                    )}
                </motion.div>
            )}

            {/* Premium Match Selection Overlay */}
            <AnimatePresence>
                {isSelectingMatch && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        style={{
                            position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)',
                            backdropFilter: 'blur(8px)', zIndex: 1000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px'
                        }}
                    >
                        <motion.div
                            initial={{ scale: 0.95, y: 20 }}
                            animate={{ scale: 1, y: 0 }}
                            exit={{ scale: 0.95, y: 20 }}
                            style={{ width: '100%', maxWidth: '400px' }}
                        >
                            <div style={{ padding: '32px', position: 'relative', borderRadius: '32px', border: '1px solid #E5E7EB', background: '#FFFFFF', boxShadow: '0 20px 40px rgba(0,0,0,0.1)' }}>
                                <motion.button
                                    whileTap={{ scale: 0.9 }}
                                    onClick={() => setIsSelectingMatch(false)}
                                    style={{ position: 'absolute', top: '24px', right: '24px', background: '#F3F4F6', border: 'none', color: AppTheme.colors.textSecondary, cursor: 'pointer', width: '36px', height: '36px', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
                                >
                                    <FaTimes size={16} />
                                </motion.button>

                                <div style={{ textAlign: 'center', marginBottom: '32px' }}>
                                    <div style={{ width: '96px', height: '96px', margin: '0 auto 16px', borderRadius: '28px', background: '#F9FAFB', overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                        {selectedGift?.imageUrl ? (
                                            <img src={selectedGift.imageUrl} alt={selectedGift.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                        ) : (
                                            <span style={{ fontSize: '48px', lineHeight: 1 }}>{getGiftEmoji(selectedGift)}</span>
                                        )}
                                    </div>
                                    <h3 style={{ fontSize: '24px', fontWeight: '800', margin: 0, color: AppTheme.colors.textPrimary }}>Select Recipient</h3>
                                    <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px', marginTop: '8px' }}>Who should receive this {selectedGift?.name}?</p>
                                </div>

                                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', maxHeight: '350px', overflowY: 'auto', paddingRight: '4px' }}>
                                    {matches.map(match => (
                                        <motion.div
                                            key={match.id}
                                            whileTap={{ scale: 0.98 }}
                                            onClick={() => confirmSend(match.id)}
                                            style={{
                                                display: 'flex', alignItems: 'center', gap: '16px', padding: '16px',
                                                background: '#F9FAFB', borderRadius: '20px', cursor: 'pointer',
                                                border: '1px solid #E5E7EB', transition: 'all 0.2s',
                                                boxShadow: '0 2px 5px rgba(0,0,0,0.02)'
                                            }}
                                        >
                                            <div style={{ position: 'relative' }}>
                                                <img src={match.avatar} style={{ width: '48px', height: '48px', borderRadius: '50%', objectFit: 'cover' }} alt="" />
                                                <div style={{ position: 'absolute', bottom: '0', right: '0', width: '14px', height: '14px', background: AppTheme.colors.successGreen, borderRadius: '50%', border: '2px solid #FFFFFF' }} />
                                            </div>
                                            <div style={{ flex: 1 }}>
                                                <span style={{ display: 'block', fontWeight: '700', fontSize: '16px', color: AppTheme.colors.textPrimary }}>{match.name}</span>
                                            </div>
                                            <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: `${AppTheme.colors.primaryPink}15`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                                <FaHeart color={AppTheme.colors.primaryPink} size={14} />
                                            </div>
                                        </motion.div>
                                    ))}
                                    {matches.length === 0 && !loading && (
                                        <p style={{ textAlign: 'center', color: AppTheme.colors.textSecondary, fontSize: '15px' }}>No matches yet to send a gift to.</p>
                                    )}
                                </div>
                                {sending && (
                                    <div style={{ position: 'absolute', inset: 0, background: 'rgba(255,255,255,0.7)', borderRadius: '32px', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 10 }}>
                                        <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1, ease: 'linear' }} style={{ width: '40px', height: '40px', border: `4px solid ${AppTheme.colors.primaryPink}`, borderTopColor: 'transparent', borderRadius: '50%' }} />
                                    </div>
                                )}
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>

            <AnimatePresence>
                {sending && <FloatingParticles count={15} />}
            </AnimatePresence>
        </div>
    );
};

const seededRandom = (seed) => {
    const x = Math.sin(seed) * 10000;
    return x - Math.floor(x);
};

const getGiftEmoji = (gift) => {
    const category = gift?.category;
    const map = {
        Flowers: '🌹',
        Chocolates: '🍫',
        Jewelry: '💍',
        Teddy: '🧸',
        Perfume: '🧴',
        Gadgets: '📱',
        Experiences: '🎟️',
        Virtual: '💌',
        Other: '🎁',
    };
    return map[category] ?? '🎁';
};

const FloatingParticles = ({ count }) => (
    <div style={{ position: 'fixed', inset: 0, pointerEvents: 'none', zIndex: 9999 }}>
        {[...Array(count)].map((_, i) => (
            <motion.div
                key={i}
                initial={{
                    opacity: 0,
                    x: seededRandom(i + 1) * window.innerWidth,
                    y: window.innerHeight + 100,
                    scale: seededRandom(i + 2) * 0.5 + 0.5
                }}
                animate={{
                    opacity: [0, 1, 0.5, 0],
                    y: -100,
                    x: seededRandom(i + 3) * window.innerWidth,
                    rotate: seededRandom(i + 4) * 360
                }}
                transition={{
                    duration: seededRandom(i + 5) * 3 + 2,
                    ease: "easeOut",
                    repeat: Infinity,
                    delay: seededRandom(i + 6) * 2
                }}
                style={{
                    position: 'absolute',
                    fontSize: `${seededRandom(i + 7) * 30 + 10}px`,
                    filter: 'drop-shadow(0 0 10px rgba(253, 41, 123, 0.5))'
                }}
            >
                {['💖', '✨', '💎', '🌸', '🎁'][Math.floor(seededRandom(i + 8) * 5)]}
            </motion.div>
        ))}
    </div>
);

const EmptyGifts = ({ message }) => (
    <div style={{ textAlign: 'center', padding: '60px 40px', background: '#FFFFFF', borderRadius: '32px', border: '1px solid #E5E7EB' }}>
        <FaGift size={40} color={AppTheme.colors.textTertiary} style={{ marginBottom: '16px' }} />
        <h3 style={{ fontSize: '20px', fontWeight: '800', marginBottom: '8px', color: AppTheme.colors.textPrimary }}>No Gifts</h3>
        <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px' }}>{message}</p>
    </div>
);

const SentGiftCard = ({ gift, index }) => (
    <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: index * 0.1 }}>
        <div style={{ padding: '20px', display: 'flex', alignItems: 'center', gap: '20px', borderRadius: '24px', border: '1px solid #E5E7EB', background: '#FFFFFF', boxShadow: '0 2px 10px rgba(0,0,0,0.02)' }}>
            <div style={{ fontSize: '32px', background: '#F9FAFB', width: '64px', height: '64px', borderRadius: '16px', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 4px 10px rgba(0,0,0,0.05)', border: '1px solid #F3F4F6', overflow: 'hidden' }}>
                {gift.imageUrl ? (
                    <img src={gift.imageUrl} alt={gift.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                ) : (
                    <span style={{ lineHeight: 1 }}>{getGiftEmoji(gift)}</span>
                )}
            </div>
            <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                    <h4 style={{ margin: 0, fontSize: '16px', fontWeight: '800', color: AppTheme.colors.textPrimary }}>{gift.name}</h4>
                    <span style={{ fontSize: '11px', padding: '4px 10px', borderRadius: '10px', background: `${AppTheme.colors.primaryPink}15`, color: AppTheme.colors.primaryPink, fontWeight: '800' }}>{gift.status}</span>
                </div>
                <p style={{ margin: '0', fontSize: '14px', color: AppTheme.colors.textSecondary }}>Sent to <span style={{ color: AppTheme.colors.textPrimary, fontWeight: '700' }}>{gift.matchName}</span></p>
                <div style={{ marginTop: '8px', display: 'flex', alignItems: 'center', gap: '6px', color: AppTheme.colors.textTertiary, fontSize: '13px' }}>
                    <FaTruck size={14} /> <span>Est. Delivery: {gift.deliveryDate}</span>
                </div>
            </div>
        </div>
    </motion.div>
);

const ReceivedGiftCard = ({ gift, index, onAccept, onDecline }) => (
    <motion.div initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: index * 0.1 }}>
        <div style={{ padding: '20px', borderRadius: '24px', border: '1px solid #E5E7EB', background: '#FFFFFF', boxShadow: '0 4px 20px rgba(0,0,0,0.03)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '20px', marginBottom: gift.status === 'pending' ? '20px' : '0' }}>
                <div style={{ fontSize: '40px', background: AppTheme.gradients.primary, width: '70px', height: '70px', borderRadius: '20px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', boxShadow: AppTheme.shadows.glow, overflow: 'hidden' }}>
                    {gift.imageUrl ? (
                        <img src={gift.imageUrl} alt={gift.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    ) : (
                        <span style={{ lineHeight: 1 }}>{getGiftEmoji(gift)}</span>
                    )}
                </div>
                <div style={{ flex: 1 }}>
                    <h4 style={{ margin: 0, fontSize: '18px', fontWeight: '800', color: AppTheme.colors.textPrimary }}>{gift.name}</h4>
                    <p style={{ margin: '4px 0', fontSize: '14px', color: AppTheme.colors.textSecondary }}>From <span style={{ color: AppTheme.colors.primaryPink, fontWeight: '700' }}>{gift.senderName}</span></p>
                    <span style={{ fontSize: '12px', color: AppTheme.colors.textTertiary }}>{gift.date}</span>
                </div>
                {gift.status !== 'pending' && (
                    <div style={{ padding: '8px 16px', borderRadius: '12px', background: `${AppTheme.colors.successGreen}15`, color: AppTheme.colors.successGreen, fontWeight: '700', fontSize: '13px' }}>
                        Accepted
                    </div>
                )}
            </div>

            {gift.status === 'pending' && (
                <div style={{ display: 'flex', gap: '12px' }}>
                    <motion.button
                        whileTap={{ scale: 0.95 }}
                        onClick={onAccept}
                        style={{ flex: 1, height: '44px', borderRadius: '14px', background: AppTheme.colors.primaryPink, color: '#fff', border: 'none', fontWeight: '700', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}
                    >
                        <FaCheck /> Accept
                    </motion.button>
                    <motion.button
                        whileTap={{ scale: 0.95 }}
                        onClick={onDecline}
                        style={{ flex: 1, height: '44px', borderRadius: '14px', background: '#F3F4F6', color: AppTheme.colors.textSecondary, border: 'none', fontWeight: '700', cursor: 'pointer' }}
                    >
                        Decline
                    </motion.button>
                </div>
            )}
        </div>
    </motion.div>
);

export default Gifts;
