import React from 'react';
import { motion, useMotionValue, useTransform } from 'framer-motion';
import { FaHeart, FaTimes, FaQuestion, FaMapMarkerAlt, FaMagic } from 'react-icons/fa';
import { AppTheme } from '../../theme/AppTheme';

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
            background: 'rgba(255, 255, 255, 0.1)',
            backdropFilter: 'blur(10px)',
            border: `1px solid rgba(255, 255, 255, 0.2)`,
            color: color,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            cursor: 'pointer',
            boxShadow: '0 8px 32px rgba(0,0,0,0.3)',
            outline: 'none',
            zIndex: 100
        }}
    >
        <Icon size={small ? 20 : 28} />
    </motion.button>
);

const BlindProfileCard = ({ user, onSwipe }) => {
    const x = useMotionValue(0);
    const rotate = useTransform(x, [-200, 200], [-10, 10]);
    const opacity = useTransform(x, [-200, -150, 0, 150, 200], [0, 1, 1, 1, 0]);

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
            drag="x"
            dragConstraints={{ left: 0, right: 0 }}
            dragElastic={1}
            onDragEnd={handleDragEnd}
            style={{
                x,
                rotate,
                opacity,
                cursor: 'grab',
                width: '100%',
                maxHeight: '680px',
                aspectRatio: '3/4',
                position: 'relative',
                background: 'linear-gradient(135deg, #1e1b4b 0%, #312e81 100%)',
                borderRadius: '32px',
                overflow: 'hidden',
                boxShadow: '0 20px 50px rgba(0,0,0,0.4)',
                touchAction: 'none'
            }}
            whileTap={{ cursor: 'grabbing' }}
        >
            {/* Blurred Background Image */}
            <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
                <img
                    src={user?.photos?.[0] || 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=600'}
                    alt="Blurred Match"
                    style={{
                        width: '100%',
                        height: '100%',
                        objectFit: 'cover',
                        filter: 'blur(40px) brightness(0.6)',
                        transform: 'scale(1.2)'
                    }}
                />

                {/* Aura Effect */}
                <div style={{
                    position: 'absolute',
                    inset: 0,
                    background: 'radial-gradient(circle at center, transparent 0%, rgba(30, 27, 75, 0.8) 100%)',
                }} />
            </div>

            {/* Mystery Avatar */}
            <div style={{
                position: 'absolute',
                top: '40%',
                left: '50%',
                transform: 'translate(-50%, -50%)',
                width: '120px',
                height: '120px',
                borderRadius: '50%',
                background: 'rgba(255,255,255,0.05)',
                border: '2px dashed rgba(255,255,255,0.2)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: 'rgba(255,255,255,0.3)',
                zIndex: 10
            }}>
                <FaQuestion size={48} />
                <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 10, repeat: Infinity, ease: "linear" }}
                    style={{ position: 'absolute', inset: -15, border: '1px solid rgba(255,255,255,0.1)', borderRadius: '50%' }}
                />
            </div>

            {/* Match Indicator */}
            <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                style={{
                    position: 'absolute', top: '24px', left: '24px',
                    padding: '8px 16px', borderRadius: '24px',
                    background: 'rgba(255, 255, 255, 0.1)',
                    backdropFilter: 'blur(10px)',
                    border: '1px solid rgba(255, 255, 255, 0.2)',
                    zIndex: 20,
                    display: 'flex', alignItems: 'center', gap: '8px'
                }}
            >
                <FaMagic color="#FBBF24" size={14} />
                <span style={{ fontSize: '13px', fontWeight: '800', color: '#fff', letterSpacing: '0.5px' }}>MYSTERY MATCH</span>
            </motion.div>

            {/* Content Section */}
            <div style={{
                position: 'absolute',
                bottom: 0,
                left: 0,
                right: 0,
                padding: '32px',
                paddingBottom: '100px',
                color: '#FFF',
                zIndex: 15,
                background: 'linear-gradient(to top, rgba(30,27,75,0.95) 0%, rgba(30,27,75,0.5) 50%, transparent 100%)'
            }}>
                <div style={{ marginBottom: '16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '6px' }}>
                        <h2 style={{ fontSize: '28px', fontWeight: '800', margin: 0, letterSpacing: '-0.5px' }}>
                            Secret Explorer, {user.age}
                        </h2>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <p style={{ display: 'flex', alignItems: 'center', gap: '4px', opacity: 0.7, fontSize: '14px', fontWeight: '600', margin: 0 }}>
                            <FaMapMarkerAlt size={12} /> Somewhere Nearby
                        </p>
                    </div>
                </div>

                <div style={{ marginBottom: '24px' }}>
                    <p style={{ fontSize: '15px', color: 'rgba(255,255,255,0.8)', margin: 0, lineHeight: '1.6', fontStyle: 'italic' }}>
                        "I love discovering new places and talking about philosophy..."
                    </p>
                </div>

                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px' }}>
                    {user.interests && user.interests.map((interest, i) => (
                        <span key={i} style={{
                            padding: '10px 18px',
                            borderRadius: '24px',
                            background: 'rgba(255, 255, 255, 0.08)',
                            border: '1px solid rgba(255, 255, 255, 0.15)',
                            fontSize: '13px',
                            fontWeight: '700',
                            color: '#fff',
                        }}>
                            {interest}
                        </span>
                    ))}
                </div>
            </div>

            {/* Actions */}
            <div style={{
                position: 'absolute',
                bottom: '32px',
                left: 0,
                right: 0,
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                gap: '24px',
                zIndex: 30
            }}>
                <ActionButton icon={FaTimes} color="#94A3B8" onClick={() => onSwipe('left')} />
                <motion.div
                    animate={{ scale: [1, 1.1, 1] }}
                    transition={{ duration: 2, repeat: Infinity }}
                >
                    <ActionButton icon={FaHeart} color="#F472B6" onClick={() => onSwipe('right')} />
                </motion.div>
            </div>
        </motion.div>
    );
};

export default BlindProfileCard;
