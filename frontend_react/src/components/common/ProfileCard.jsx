import React, { useRef } from 'react';
import { AnimatePresence, motion, useMotionValue, useTransform } from 'framer-motion';
import { FaHeart, FaTimes, FaStar, FaMapMarkerAlt, FaCheckCircle, FaGift, FaBrain } from 'react-icons/fa';
import { AppTheme } from '../../theme/AppTheme';
import MatchmakerInsight from './MatchmakerInsight';

const seededRandom = (seed) => {
    const x = Math.sin(seed) * 10000;
    return x - Math.floor(x);
};

const ActionButton = ({ icon: Icon, color, onClick, small }) => (
    <motion.button
        whileHover={{ scale: 1.1, translateY: -2 }}
        whileTap={{ scale: 0.95 }}
        onClick={(e) => {
            e.stopPropagation();
            onClick();
        }}
        style={{
            width: small ? '50px' : '65px',
            height: small ? '50px' : '65px',
            borderRadius: '50%',
            background: '#FFFFFF',
            border: `1px solid rgba(0,0,0,0.05)`,
            color: color,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            boxShadow: '0 4px 15px rgba(0,0,0,0.1)',
            outline: 'none',
            zIndex: 100
        }}
    >
        <Icon size={small ? 20 : 28} />
    </motion.button>
);

const ProfileCard = ({ user, onSwipe }) => {
    const cardRef = useRef(null);
    const [showAiInsight, setShowAiInsight] = React.useState(false);
    const x = useMotionValue(0);
    const rotate = useTransform(x, [-200, 200], [-10, 10]);
    const opacity = useTransform(x, [-200, -150, 0, 150, 200], [0, 1, 1, 1, 0]);

    // Visual indicators for swipe
    const likeOpacity = useTransform(x, [50, 150], [0, 1]);
    const nopeOpacity = useTransform(x, [-50, -150], [0, 1]);

    const matchPercent = React.useMemo(() => {
        const seed = typeof user?.id === 'number' ? user.id : 1;
        return Math.round(90 + seededRandom(seed) * 8);
    }, [user?.id]);

    const distanceKm = React.useMemo(() => {
        const d = user?.distance;
        if (typeof d !== 'number' || !Number.isFinite(d)) return null;
        return Math.max(0, Math.round(d));
    }, [user?.distance]);

    const locationLabel = React.useMemo(() => {
        const city = typeof user?.city === 'string' ? user.city.trim() : '';
        const country = typeof user?.country === 'string' ? user.country.trim() : '';
        if (city && country) return `${city}, ${country}`;
        return city || country || null;
    }, [user?.city, user?.country]);

    const isNearby = distanceKm != null ? distanceKm < 2 : false;
    const distanceLabel = distanceKm != null ? `${distanceKm} km away` : (locationLabel || 'Nearby');

    const handleDragEnd = (event, info) => {
        const threshold = 80;
        if (info.offset.x > threshold) {
            onSwipe('right');
        } else if (info.offset.x < -threshold) {
            onSwipe('left');
        }
    };

    return (
        <motion.div
            ref={cardRef}
            drag={!showAiInsight ? "x" : false}
            dragConstraints={{ left: 0, right: 0 }}
            dragElastic={1}
            onDragEnd={handleDragEnd}
            style={{
                x,
                rotate,
                opacity,
                cursor: showAiInsight ? 'default' : 'grab',
                width: '100%',
                maxHeight: '680px',
                aspectRatio: '3/4',
                position: 'relative',
                background: '#FFFFFF',
                borderRadius: '24px',
                overflow: 'hidden',
                boxShadow: AppTheme.shadows.card,
                touchAction: 'none'
            }}
            whileTap={{ cursor: showAiInsight ? 'default' : 'grabbing' }}
        >
            <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
                <motion.img
                    src={user?.photos?.[0] || 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=600'}
                    alt={user.name}
                    initial={{ scale: 1.05 }}
                    animate={{ scale: showAiInsight ? 1.1 : 1, filter: showAiInsight ? 'blur(10px) brightness(0.5)' : 'none' }}
                    transition={{ duration: 0.5 }}
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                    draggable="false"
                />

                <div style={{
                    position: 'absolute',
                    inset: 0,
                    background: showAiInsight ? 'rgba(0,0,0,0.6)' : 'linear-gradient(to top, rgba(0,0,0,0.8) 0%, rgba(0,0,0,0.4) 30%, transparent 60%)',
                }} />
            </div>

            <AnimatePresence>
                {showAiInsight && (
                    <motion.div
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.9 }}
                        style={{
                            position: 'absolute', inset: 0, zIndex: 50,
                            padding: '24px', display: 'flex', flexDirection: 'column',
                            justifyContent: 'center', alignItems: 'center', pointerEvents: 'auto'
                        }}
                    >
                        <MatchmakerInsight matchName={user.name} />
                        <motion.button
                            whileTap={{ scale: 0.95 }}
                            onClick={() => setShowAiInsight(false)}
                            style={{
                                marginTop: '20px', padding: '12px 24px', borderRadius: '16px',
                                background: 'rgba(255,255,255,0.1)', border: '1px solid rgba(255,255,255,0.2)',
                                color: '#fff', fontSize: '14px', fontWeight: '800', cursor: 'pointer',
                                backdropFilter: 'blur(10px)'
                            }}
                        >
                            Back to Profile
                        </motion.button>
                    </motion.div>
                )}
            </AnimatePresence>

            <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: showAiInsight ? 0 : 1, y: 0 }}
                style={{
                    position: 'absolute', top: '16px', left: '16px',
                    padding: '6px 12px', borderRadius: '20px',
                    background: isNearby ? 'linear-gradient(135deg, #10B981 0%, #059669 100%)' : 'rgba(255, 255, 255, 0.9)',
                    boxShadow: '0 4px 10px rgba(0,0,0,0.1)',
                    zIndex: 20,
                    display: 'flex', alignItems: 'center', gap: '6px'
                }}
            >
                <div style={{ width: '8px', height: '8px', borderRadius: '4px', background: isNearby ? '#fff' : AppTheme.colors.primaryPink }} />
                <span style={{ fontSize: '12px', fontWeight: '800', color: isNearby ? '#fff' : '#1F2937' }}>
                    {isNearby ? 'NEARBY' : `${matchPercent}% Match`}
                </span>
            </motion.div>

            <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: showAiInsight ? 0 : 1, scale: 1 }}
                onClick={(e) => { e.stopPropagation(); setShowAiInsight(true); }}
                style={{
                    position: 'absolute', top: '16px', right: '16px',
                    width: '40px', height: '40px', borderRadius: '50%',
                    background: 'rgba(255, 255, 255, 0.9)',
                    boxShadow: '0 4px 15px rgba(0,0,0,0.2)',
                    zIndex: 20,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    cursor: 'pointer', color: '#6366F1'
                }}
            >
                <FaBrain size={20} />
            </motion.div>

            {user.isBoosted && (
                <motion.div
                    initial={{ opacity: 0, scale: 0.8 }}
                    animate={{ opacity: 1, scale: 1 }}
                    style={{
                        position: 'absolute', top: '16px', right: '16px',
                        padding: '6px 12px', borderRadius: '20px',
                        background: 'linear-gradient(135deg, #8B5CF6 0%, #7C3AED 100%)',
                        boxShadow: '0 4px 15px rgba(139, 92, 246, 0.4)',
                        zIndex: 20,
                        display: 'flex', alignItems: 'center', gap: '6px',
                        color: '#fff'
                    }}
                >
                    <svg stroke="currentColor" fill="currentColor" strokeWidth="0" viewBox="0 0 16 16" height="12px" width="12px" xmlns="http://www.w3.org/2000/svg"><path d="M5.5 0A.5.5 0 0 1 6 .5v1.2a.5.5 0 0 1-1 0V.5a.5.5 0 0 1 .5-.5zm5 0a.5.5 0 0 1 .5.5v1.2a.5.5 0 0 1-1 0V.5a.5.5 0 0 1 .5-.5zm5 2.5a.5.5 0 0 1 .5.5v1.2a.5.5 0 0 1-1 0V3a.5.5 0 0 1 .5-.5zm0 5a.5.5 0 0 1 .5.5v1.2a.5.5 0 0 1-1 0V8a.5.5 0 0 1 .5-.5zm-13-5a.5.5 0 0 1 .5.5v1.2a.5.5 0 0 1-1 0V3a.5.5 0 0 1 .5-.5zm0 5a.5.5 0 0 1 .5.5v1.2a.5.5 0 0 1-1 0V8a.5.5 0 0 1 .5-.5zm5 5a.5.5 0 0 1 .5.5v1.2a.5.5 0 0 1-1 0v-1.2a.5.5 0 0 1 .5-.5zm5 0a.5.5 0 0 1 .5.5v1.2a.5.5 0 0 1-1 0v-1.2a.5.5 0 0 1 .5-.5zM8 7a1 1 0 1 0 0-2 1 1 0 0 0 0 2z" /><path d="M8 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zm0 1A5 5 0 1 1 8 3a5 5 0 0 1 0 10z" /></svg>
                    <span style={{ fontSize: '10px', fontWeight: '800', letterSpacing: '0.5px' }}>BOOSTED</span>
                </motion.div>
            )}

            {/* Swipe Overlays */}
            <motion.div
                className="swipe-indicator"
                style={{
                    left: 40,
                    top: 80,
                    position: 'absolute',
                    border: `4px solid ${AppTheme.colors.successGreen}`,
                    color: AppTheme.colors.successGreen,
                    borderRadius: '10px',
                    padding: '8px 16px',
                    fontWeight: '800',
                    fontSize: '28px',
                    transform: 'rotate(-15deg)',
                    opacity: likeOpacity,
                    zIndex: 30
                }}
            >
                LIKE
            </motion.div>
            <motion.div
                className="swipe-indicator"
                style={{
                    right: 40,
                    top: 80,
                    position: 'absolute',
                    border: `4px solid ${AppTheme.colors.errorRed}`,
                    color: AppTheme.colors.errorRed,
                    borderRadius: '10px',
                    padding: '8px 16px',
                    fontWeight: '800',
                    fontSize: '28px',
                    transform: 'rotate(15deg)',
                    opacity: nopeOpacity,
                    zIndex: 30
                }}
            >
                NOPE
            </motion.div>

            <div style={{
                position: 'absolute',
                bottom: 0,
                left: 0,
                right: 0,
                padding: '24px',
                paddingBottom: '90px',
                color: '#FFF',
                zIndex: 5,
                pointerEvents: 'none'
            }}>
                <div style={{ marginBottom: '12px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                        <h2 style={{ fontSize: '32px', fontWeight: '800', margin: 0, textShadow: '0 2px 4px rgba(0,0,0,0.5)' }}>
                            {user.name}, {user.age}
                        </h2>
                        {user.isVerified && (
                            <FaCheckCircle color="#3B82F6" size={20} style={{ filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.3))' }} />
                        )}
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <p style={{ display: 'flex', alignItems: 'center', gap: '4px', opacity: 0.9, fontSize: '14px', fontWeight: '600', margin: 0 }}>
                            <FaMapMarkerAlt color="#fff" size={12} /> {distanceLabel}
                        </p>
                    </div>
                </div>

                <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.9)', marginBottom: '16px', fontWeight: '400', lineHeight: '1.4' }}>
                    {user.bio || 'Looking for someone to share beautiful moments.'}
                </p>

                <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
                    {user.interests && user.interests.slice(0, 3).map((interest, i) => (
                        <span key={i} style={{
                            padding: '6px 12px',
                            borderRadius: '20px',
                            background: 'rgba(255, 255, 255, 0.2)',
                            backdropFilter: 'blur(10px)',
                            border: '1px solid rgba(255,255,255,0.3)',
                            fontSize: '12px',
                            fontWeight: '600',
                            color: '#fff',
                        }}>
                            {interest}
                        </span>
                    ))}
                </div>
            </div>

            <div style={{
                position: 'absolute',
                bottom: '24px',
                left: 0,
                right: 0,
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                gap: '12px',
                zIndex: 20
            }}>
                <ActionButton icon={FaTimes} color="#EF4444" onClick={() => onSwipe('left')} />
                <ActionButton icon={FaGift} color={AppTheme.colors.primaryPink} onClick={() => onSwipe('gift')} small />
                <ActionButton icon={FaStar} color="#3B82F6" onClick={() => onSwipe('super')} small />
                <ActionButton icon={FaHeart} color="#10B981" onClick={() => onSwipe('right')} />
            </div>
        </motion.div>
    );
};

export default ProfileCard;
