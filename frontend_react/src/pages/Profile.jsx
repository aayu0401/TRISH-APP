import React from 'react';
import { motion } from 'framer-motion';
import { FaEdit, FaCog, FaCamera, FaCrown, FaCheckCircle, FaBrain, FaArrowLeft, FaBriefcase, FaGraduationCap, FaGlobe, FaStar, FaWineGlassAlt, FaSmoking, FaChild, FaPaw, FaSearch, FaHeart, FaGift, FaEyeSlash } from 'react-icons/fa';
import GlassCard from '../components/common/GlassCard';
import { AppTheme } from '../theme/AppTheme';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

const Profile = () => {
    const { user: authUser } = useAuth();
    const navigate = useNavigate();

    const user = authUser || {
        name: 'Trish User',
        age: 26,
        bio: 'Coffee lover, and weekend hiker. Looking for someone to explore the city with!',
        photos: [
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600',
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600'
        ],
        interests: ['Hiking', 'Coffee', 'Tech', 'Music', 'Travel', 'Art'],
        lifestyle: {
            job: 'Designer',
            education: 'University',
            zodiac: 'Scorpio',
            languages: ['English', 'Spanish'],
            drinking: 'Socially',
            smoking: 'Never',
            kids: 'Not sure yet',
            pets: 'Dog lover'
        },
        mbti: 'INTJ',
        enneagram: '5w6'
    };

    const displayPhotos = user.photos && user.photos.length > 0 ? user.photos : ['https://via.placeholder.com/500'];

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            paddingBottom: '100px',
            color: AppTheme.colors.textPrimary
        }}>
            {/* Cover / Header */}
            <div style={{ position: 'relative', height: '320px' }}>
                <div style={{
                    position: 'absolute', top: '24px', left: '24px', right: '24px', zIndex: 100,
                    display: 'flex', justifyContent: 'space-between', alignItems: 'center'
                }}>
                    <motion.div whileTap={{ scale: 0.9 }} onClick={() => navigate('/home')} style={{ background: 'rgba(255,255,255,0.9)', padding: '10px', borderRadius: '50%', boxShadow: '0 4px 10px rgba(0,0,0,0.1)', cursor: 'pointer', color: AppTheme.colors.textPrimary }}>
                        <FaArrowLeft size={16} />
                    </motion.div>
                    <motion.div whileTap={{ scale: 0.9 }} onClick={() => navigate('/settings')} style={{ background: 'rgba(255,255,255,0.9)', padding: '10px', borderRadius: '50%', boxShadow: '0 4px 10px rgba(0,0,0,0.1)', cursor: 'pointer', color: AppTheme.colors.textPrimary }}>
                        <FaCog size={16} />
                    </motion.div>
                </div>
                <img
                    src={displayPhotos[0]}
                    alt="Cover"
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
                <div style={{
                    position: 'absolute', bottom: 0, left: 0, right: 0, height: '100px',
                    background: 'linear-gradient(to top, #F9FAFB, transparent)'
                }} />
            </div>

            {/* Content */}
            <div style={{ marginTop: '-40px', padding: '0 24px', position: 'relative', zIndex: 11 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: '24px' }}>
                    <div>
                        <h1 style={{ fontSize: '32px', fontWeight: '800', margin: 0, color: AppTheme.colors.textPrimary }}>{user.name}, {user.age}</h1>
                        {user.isVerified ? (
                            <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: AppTheme.colors.successGreen, fontSize: '13px', marginTop: '4px', fontWeight: '600' }}>
                                <FaCheckCircle size={14} /> Profile Verified
                            </div>
                        ) : (
                            <motion.div
                                whileTap={{ scale: 0.95 }}
                                onClick={() => navigate('/kyc')}
                                style={{
                                    display: 'flex', alignItems: 'center', gap: '8px',
                                    background: `${AppTheme.colors.brandBlue}15`,
                                    padding: '6px 12px', borderRadius: '12px',
                                    color: AppTheme.colors.brandBlue, fontSize: '12px',
                                    marginTop: '8px', fontWeight: '800', cursor: 'pointer',
                                    width: 'fit-content', border: `1px solid ${AppTheme.colors.brandBlue}20`
                                }}
                            >
                                <FaShieldAlt size={12} /> Get Verified
                            </motion.div>
                        )}
                    </div>
                    <motion.button
                        whileTap={{ scale: 0.9 }}
                        onClick={() => navigate('/profile/edit')}
                        style={{
                            width: '48px', height: '48px', borderRadius: '50%',
                            background: AppTheme.gradients.primary, border: 'none', color: '#fff',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            boxShadow: '0 8px 20px rgba(253, 41, 123, 0.3)', cursor: 'pointer'
                        }}
                    >
                        <FaEdit size={18} />
                    </motion.button>
                </div>

                <div style={{ display: 'flex', gap: '8px', marginBottom: '24px', overflowX: 'auto', scrollbarWidth: 'none', paddingBottom: '10px' }}>
                    <ActionBadge icon={FaCrown} label="Premium" color={AppTheme.colors.primaryPink} />
                    <ActionBadge icon={FaSearch} label="Looking for love" color={AppTheme.colors.brandBlue} />
                </div>

                {/* Quick Actions Grid */}
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '12px', marginBottom: '32px' }}>
                    <QuickAction icon={FaGift} label="Gifts" color="#6366F1" onClick={() => navigate('/gifts')} badge="1" />
                    <QuickAction icon={FaCrown} label="Premium" color="#FBBF24" onClick={() => navigate('/subscription')} />
                    <QuickAction icon={FaHeart} label="Requests" color={AppTheme.colors.primaryPink} onClick={() => navigate('/requests')} badge="3" />
                    <QuickAction icon={FaEyeSlash} label="Blind Date" color="#8B5CF6" onClick={() => navigate('/blind-date')} />
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
                    {/* Personality Section */}
                    <section>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                            <h3 style={{ fontSize: '18px', fontWeight: '700', color: AppTheme.colors.textPrimary, margin: 0 }}>Personality Analysis</h3>
                            <motion.div
                                whileTap={{ scale: 0.95 }}
                                onClick={() => navigate('/personality')}
                                style={{ fontSize: '13px', color: AppTheme.colors.primaryPink, fontWeight: '700', cursor: 'pointer' }}
                            >
                                Retake Quiz
                            </motion.div>
                        </div>
                        <div style={{ display: 'flex', gap: '12px' }}>
                            <div style={{ flex: 1, padding: '16px', borderRadius: '16px', background: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)', color: '#fff' }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', opacity: 0.8 }}>
                                    <FaBrain size={14} /> <span style={{ fontSize: '12px', fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px' }}>MBTI</span>
                                </div>
                                <div style={{ fontSize: '24px', fontWeight: '900' }}>{user.mbti}</div>
                                <div style={{ fontSize: '12px', marginTop: '4px', opacity: 0.9 }}>Architect</div>
                            </div>
                            <div style={{ flex: 1, padding: '16px', borderRadius: '16px', background: 'linear-gradient(135deg, #EC4899 0%, #EF4444 100%)', color: '#fff' }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', opacity: 0.8 }}>
                                    <FaStar size={14} /> <span style={{ fontSize: '12px', fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Enneagram</span>
                                </div>
                                <div style={{ fontSize: '24px', fontWeight: '900' }}>{user.enneagram}</div>
                                <div style={{ fontSize: '12px', marginTop: '4px', opacity: 0.9 }}>Investigator</div>
                            </div>
                        </div>
                    </section>

                    {/* Bio Section */}
                    <section>
                        <h3 style={{ fontSize: '18px', marginBottom: '16px', fontWeight: '700', color: AppTheme.colors.textPrimary }}>About Me</h3>
                        <p style={{ color: AppTheme.colors.textSecondary, lineHeight: '1.6', fontSize: '15px' }}>{user.bio}</p>
                    </section>

                    {/* Interests Section */}
                    <section>
                        <h3 style={{ fontSize: '18px', marginBottom: '16px', fontWeight: '700', color: AppTheme.colors.textPrimary }}>Interests</h3>
                        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                            {user?.interests?.map((interest, i) => (
                                <div key={i} style={{
                                    padding: '8px 16px', borderRadius: '20px',
                                    background: '#FFFFFF',
                                    border: '1px solid #E5E7EB',
                                    fontSize: '14px', color: AppTheme.colors.textPrimary,
                                    fontWeight: '500', boxShadow: '0 2px 5px rgba(0,0,0,0.02)'
                                }}>
                                    {interest}
                                </div>
                            )) || <p style={{ color: AppTheme.colors.textTertiary }}>No interests listed</p>}
                        </div>
                    </section>

                    {/* Lifestyle Essentials */}
                    <section>
                        <h3 style={{ fontSize: '18px', marginBottom: '16px', fontWeight: '700', color: AppTheme.colors.textPrimary }}>The Essentials</h3>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px' }}>
                            <EssentialItem icon={FaBriefcase} label={user?.lifestyle?.job || 'Not specified'} />
                            <EssentialItem icon={FaGraduationCap} label={user?.lifestyle?.education || 'Not specified'} />
                            <EssentialItem icon={FaStar} label={user?.lifestyle?.zodiac || 'Not specified'} />
                            <EssentialItem icon={FaGlobe} label={user?.lifestyle?.languages?.join(', ') || 'Not specified'} />
                            <EssentialItem icon={FaWineGlassAlt} label={user?.lifestyle?.drinking || 'Not specified'} />
                            <EssentialItem icon={FaSmoking} label={user?.lifestyle?.smoking || 'Not specified'} />
                            <EssentialItem icon={FaChild} label={user?.lifestyle?.kids || 'Not specified'} />
                            <EssentialItem icon={FaPaw} label={user?.lifestyle?.pets || 'Not specified'} />
                        </div>
                    </section>

                    {/* Photos Grid */}
                    <section>
                        <h3 style={{ fontSize: '18px', marginBottom: '16px', fontWeight: '700', color: AppTheme.colors.textPrimary }}>Photos</h3>
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px' }}>
                            {displayPhotos?.map((photo, i) => (
                                <motion.div
                                    key={i}
                                    whileHover={{ scale: 1.02 }}
                                    style={{
                                        borderRadius: '16px', overflow: 'hidden', height: '220px',
                                        gridColumn: i === 0 ? 'span 2' : 'span 1',
                                        boxShadow: '0 4px 15px rgba(0,0,0,0.05)'
                                    }}
                                >
                                    <img src={photo} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                </motion.div>
                            ))}
                        </div>
                    </section>
                </div>
            </div>
        </div>
    );
};

const ActionBadge = ({ icon: Icon, label, color }) => (
    <div style={{
        display: 'flex', alignItems: 'center', gap: '6px',
        padding: '8px 16px', borderRadius: '20px',
        background: `${color}10`, border: `1px solid ${color}20`,
        color: color, fontSize: '14px', fontWeight: '600',
        whiteSpace: 'nowrap'
    }}>
        <Icon size={12} /> {label}
    </div>
);

const EssentialItem = ({ icon: Icon, label }) => (
    <div style={{
        display: 'flex', alignItems: 'center', gap: '12px',
        padding: '12px 16px', borderRadius: '16px',
        background: '#FFFFFF',
        border: '1px solid #E5E7EB',
        boxShadow: '0 2px 5px rgba(0,0,0,0.02)'
    }}>
        <Icon color={AppTheme.colors.textSecondary} size={16} />
        <span style={{ fontSize: '14px', color: AppTheme.colors.textPrimary, fontWeight: '500', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{label}</span>
    </div>
);

const QuickAction = ({ icon: Icon, label, color, onClick, badge }) => (
    <motion.div
        whileTap={{ scale: 0.95 }}
        onClick={onClick}
        style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '8px',
            padding: '16px 8px', borderRadius: '20px', background: '#FFFFFF',
            border: '1px solid #F3F4F6', cursor: 'pointer',
            boxShadow: '0 2px 10px rgba(0,0,0,0.02)', position: 'relative'
        }}
    >
        {badge && (
            <div style={{
                position: 'absolute', top: '8px', right: '8px',
                background: AppTheme.colors.primaryPink, color: '#fff',
                width: '18px', height: '18px', borderRadius: '50%',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: '10px', fontWeight: '800'
            }}>
                {badge}
            </div>
        )}
        <div style={{
            width: '44px', height: '44px', borderRadius: '14px',
            background: `${color}15`, display: 'flex',
            alignItems: 'center', justifyContent: 'center', color: color
        }}>
            <Icon size={20} />
        </div>
        <span style={{ fontSize: '11px', fontWeight: '700', color: AppTheme.colors.textSecondary, textAlign: 'center' }}>{label}</span>
    </motion.div>
);

export default Profile;
