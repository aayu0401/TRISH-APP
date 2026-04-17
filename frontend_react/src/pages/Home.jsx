import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { FaEyeSlash, FaHeart, FaMagic, FaMapMarkerAlt, FaSearchLocation, FaSlidersH, FaUser } from 'react-icons/fa';
import GlassCard from '../components/common/GlassCard';
import PremiumButton from '../components/common/PremiumButton';
import BoostButton from '../components/common/BoostButton';
import PassportModal from '../components/common/PassportModal';
import VerifyEmailBanner from '../components/common/VerifyEmailBanner';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { userService } from '../services/user.service';
import { premiumService } from '../services/premium.service';
import BoostRadar from '../components/common/BoostRadar';
import AdvancedFiltersModal from '../components/common/AdvancedFiltersModal';
import ProfileCard from '../components/common/ProfileCard';
import MatchModal from '../components/common/MatchModal';
import { AppTheme } from '../theme/AppTheme';

const Home = () => {
    const navigate = useNavigate();
    const [users, setUsers] = useState([]);
    const [currentIndex, setCurrentIndex] = useState(0);
    const [showMatchModal, setShowMatchModal] = useState(false);
    const [lastMatchedUser, setLastMatchedUser] = useState(null);
    const [lastMatchId, setLastMatchId] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const { user: authUser, setUser } = useAuth();
    const { showToast } = useToast();

    // Premium States
    const [showPassport, setShowPassport] = useState(false);
    const [showFilters, setShowFilters] = useState(false);
    const [isBoosted, setIsBoosted] = useState(false);
    const [boostExpiresAt, setBoostExpiresAt] = useState(null);
    const [currentLocation, setCurrentLocation] = useState(null);
    const [filters, setFilters] = useState({
        ageRange: [18, 50],
        maxDistance: 50,
        height: 'Any',
        religion: 'Any',
        zodiac: 'Any',
        aiVibeMatch: false
    });

    useEffect(() => {
        let isMounted = true;
        const fetchUsers = async () => {
            try {
                const data = await userService.getRecommendations();
                if (isMounted) {
                    setUsers(Array.isArray(data) ? data : []);
                }
            } catch (err) {
                console.error("Failed to fetch recommendations:", err);
                if (isMounted) setError("Could not find people nearby. Please try again.");
            } finally {
                if (isMounted) setLoading(false);
            }
        };
        fetchUsers();
        return () => { isMounted = false; };
    }, []);

    const handleApplyFilters = async (newFilters) => {
        setFilters(newFilters);
        setLoading(true);
        try {
            const payload = {};
            if (Array.isArray(newFilters?.ageRange) && newFilters.ageRange.length >= 2) {
                const [minAge, maxAge] = newFilters.ageRange;
                if (Number.isFinite(minAge)) payload.minAge = Math.round(minAge);
                if (Number.isFinite(maxAge)) payload.maxAge = Math.round(maxAge);
            }
            if (Number.isFinite(newFilters?.maxDistance)) payload.maxDistance = Math.round(newFilters.maxDistance);

            if (Object.keys(payload).length) {
                const updatedUser = await userService.updatePreferences(payload);
                if (updatedUser) setUser(updatedUser);
            }

            const data = await userService.getRecommendations();
            setUsers(data || []);
            showToast("Filters applied successfully! ✨", "success");
        } catch (err) {
            console.error("Failed to apply filters:", err);
            showToast("Failed to apply filters.", "error");
        } finally {
            setLoading(false);
        }
    };

    const handleSwipe = async (direction) => {
        if (direction === 'gift') {
            navigate('/gifts');
            return;
        }
        if (users && currentIndex < users.length) {
            const currentUser = users[currentIndex];
            const action = direction === 'right' ? 'like' : (direction === 'left' ? 'pass' : 'superlike');

            try {
                const result = await userService.swipe(currentUser.id, action);
                if (direction === 'right' && result?.matched) {
                    setLastMatchedUser(currentUser);
                    setLastMatchId(result?.match?.id ?? null);
                    setTimeout(() => setShowMatchModal(true), 300);
                }
            } catch (error) {
                console.error("Swipe action failed:", error);
            }

            setTimeout(() => {
                setCurrentIndex(prev => prev + 1);
            }, 200);
        }
    };

    const handleBoost = async () => {
        try {
            const result = await premiumService.activateBoost(authUser?.id);
            setIsBoosted(true);
            setBoostExpiresAt(result.boostExpiresAt);
            showToast("Profile Boosted! 🚀 You are now a top match.", "success");
        } catch (err) {
            showToast("Premium feature: Upgrade to use Boost.", "error");
        }
    };

    const handlePassportSelect = async (location) => {
        try {
            if (location) {
                await premiumService.updatePassport(authUser?.id, {
                    latitude: location.lat,
                    longitude: location.lon,
                    city: location.city,
                    country: location.country
                });
                setCurrentLocation(location.city);
                showToast(`Passport active: Welcome to ${location.city}! ✈️`, "success");
            } else {
                await premiumService.deactivatePassport(authUser?.id);
                setCurrentLocation(null);
                showToast("Returned to your local area.", "success");
            }
            setShowPassport(false);
            // Refresh feed
            setLoading(true);
            const data = await userService.getRecommendations();
            setUsers(data || []);
            setLoading(false);
        } catch (err) {
            showToast("Premium feature: Upgrade to use Passport.", "error");
        }
    };

    const currentUser = users[currentIndex] || null;

    if (error) {
        return (
            <div className="flex-center" style={{ height: '100vh', background: AppTheme.colors.lightBackground, flexDirection: 'column' }}>
                <h2 style={{ color: AppTheme.colors.primaryPink, fontWeight: '700' }}>{error}</h2>
                <PremiumButton text="Retry" type="outline" onClick={() => window.location.reload()} style={{ marginTop: '20px' }} />
            </div>
        );
    }

    return (
        <div style={{ minHeight: '100vh', background: AppTheme.colors.lightBackground, position: 'relative', overflow: 'hidden' }}>
            <BoostRadar isActive={isBoosted} />
            {/* Friendly Header */}
            <header
                style={{
                    position: 'fixed', top: 0, left: 0, right: 0, zIndex: 1000,
                    padding: '24px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                    background: 'rgba(255, 255, 255, 0.9)', backdropFilter: 'blur(20px)',
                    borderBottom: '1px solid #F3F4F6'
                }}
            >
                <motion.div
                    whileTap={{ scale: 0.9 }}
                    onClick={() => navigate('/profile')}
                    style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#F3F4F6', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
                    <FaUser size={16} color={AppTheme.colors.textSecondary} />
                </motion.div>

                <div
                    onClick={() => setShowPassport(true)}
                    style={{ textAlign: 'center', display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}
                >
                    <div style={{
                        width: '32px', height: '32px', borderRadius: '10px',
                        background: AppTheme.gradients.primary, display: 'flex', alignItems: 'center', justifyContent: 'center'
                    }}>
                        <FaHeart size={14} color="white" />
                    </div>
                    <div>
                        <h1 style={{ fontSize: '20px', margin: 0, fontWeight: '800', letterSpacing: '-0.5px', color: AppTheme.colors.primaryPink }}>
                            Trish
                        </h1>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '10px', color: AppTheme.colors.textSecondary, fontWeight: '700' }}>
                            <FaMapMarkerAlt size={8} /> {currentLocation || 'Nearby'}
                        </div>
                    </div>
                </div>

                <motion.div
                    whileTap={{ scale: 0.9 }}
                    onClick={() => setShowFilters(true)}
                    style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#F3F4F6', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
                    <FaSlidersH size={16} color={AppTheme.colors.textSecondary} />
                </motion.div>
            </header>

            <div style={{ paddingTop: '88px', position: 'fixed', top: 0, left: 0, right: 0, zIndex: 900 }}>
                {!authUser?.emailVerified && <VerifyEmailBanner user={authUser} />}

                {/* Quick Radius Toggle */}
                <div style={{
                    padding: '8px 20px 16px',
                    background: 'rgba(255, 255, 255, 0.9)',
                    backdropFilter: 'blur(20px)',
                    display: 'flex',
                    justifyContent: 'center',
                    gap: '12px'
                }}>
                    {[
                        { label: 'Nearby', value: 10 },
                        { label: 'Local', value: 50 },
                        { label: 'Long', value: 500 }
                    ].map(radius => (
                        <motion.button
                            key={radius.label}
                            whileTap={{ scale: 0.95 }}
                            onClick={() => handleApplyFilters({ ...filters, maxDistance: radius.value })}
                            style={{
                                padding: '6px 16px',
                                borderRadius: '12px',
                                background: filters.maxDistance === radius.value ? AppTheme.colors.primaryPink : '#F3F4F6',
                                color: filters.maxDistance === radius.value ? '#FFF' : AppTheme.colors.textSecondary,
                                border: 'none',
                                fontSize: '12px',
                                fontWeight: '800',
                                cursor: 'pointer',
                                transition: 'all 0.2s',
                                boxShadow: filters.maxDistance === radius.value ? '0 4px 10px rgba(253, 41, 123, 0.2)' : 'none'
                            }}
                        >
                            {radius.label}
                        </motion.button>
                    ))}
                </div>
            </div>

            <main style={{
                paddingTop: '100px', paddingBottom: '120px', display: 'flex', flexDirection: 'column',
                alignItems: 'center', minHeight: '90vh'
            }}>
                <AnimatePresence mode='wait'>
                    {loading ? (
                        <motion.div key="loading" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} style={{ textAlign: 'center', marginTop: '100px' }}>
                            <div style={{ width: '80px', height: '80px', borderRadius: '50%', background: AppTheme.gradients.primary, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 20px', boxShadow: AppTheme.shadows.glow }}>
                                <motion.div
                                    animate={{ scale: [1, 1.2, 1] }}
                                    transition={{ repeat: Infinity, duration: 1.5 }}
                                >
                                    <FaHeart size={32} color="white" />
                                </motion.div>
                            </div>
                            <h3 style={{ fontSize: '18px', fontWeight: '800', color: AppTheme.colors.textPrimary }}>Searching for connections...</h3>
                        </motion.div>
                    ) : currentUser ? (
                        <div key="content" style={{ width: '100%', maxWidth: '420px', padding: '0 16px' }}>
                            {/* Discovery Row */}
                            <motion.div
                                initial={{ opacity: 0, y: -20 }}
                                animate={{ opacity: 1, y: 0 }}
                                style={{ marginBottom: '24px', overflowX: 'auto', display: 'flex', gap: '16px', paddingBottom: '12px', scrollbarWidth: 'none' }}
                            >
                                {users.slice(currentIndex + 1, currentIndex + 6).map((u, i) => (
                                    <motion.div key={u.id} whileHover={{ scale: 1.05 }} style={{ minWidth: '64px', textAlign: 'center' }}>
                                        <div style={{ width: '64px', height: '64px', borderRadius: '20px', border: `2px solid #E5E7EB`, padding: '2px', position: 'relative', overflow: 'hidden' }}>
                                            <img src={u.photos?.[0] || 'https://via.placeholder.com/100'} alt="" style={{ width: '100%', height: '100%', borderRadius: '16px', objectFit: 'cover' }} />
                                            <div style={{ position: 'absolute', bottom: '2px', right: '2px', width: '12px', height: '12px', borderRadius: '50%', background: AppTheme.colors.successGreen, border: '2px solid #FFFFFF' }} />
                                        </div>
                                    </motion.div>
                                ))}
                            </motion.div>

                            {/* Blind Date Premium Banner */}
                            <motion.div
                                whileTap={{ scale: 0.98 }}
                                onClick={() => navigate('/blind-date')}
                                style={{
                                    marginBottom: '24px',
                                    padding: '20px',
                                    borderRadius: '24px',
                                    background: 'linear-gradient(135deg, #1e1b4b 0%, #312e81 100%)',
                                    color: '#fff',
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '16px',
                                    cursor: 'pointer',
                                    position: 'relative',
                                    overflow: 'hidden',
                                    boxShadow: '0 12px 30px rgba(30, 27, 75, 0.4)',
                                    border: '1px solid rgba(255,255,255,0.1)'
                                }}
                            >
                                <div style={{ position: 'absolute', top: '-20px', right: '-20px', width: '80px', height: '80px', borderRadius: '50%', background: 'rgba(99, 102, 241, 0.2)', filter: 'blur(30px)' }} />

                                <div style={{
                                    width: '56px',
                                    height: '56px',
                                    borderRadius: '16px',
                                    background: 'rgba(255,255,255,0.1)',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    color: '#FBBF24',
                                    boxShadow: 'inset 0 0 10px rgba(255,255,255,0.1)'
                                }}>
                                    <FaEyeSlash size={24} />
                                </div>
                                <div style={{ flex: 1 }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                        <h4 style={{ margin: 0, fontSize: '18px', fontWeight: '800' }}>Blind Date Mode</h4>
                                        <span style={{ fontSize: '10px', background: 'rgba(251, 191, 36, 0.2)', color: '#FBBF24', padding: '2px 8px', borderRadius: '10px', fontWeight: '800' }}>PREMIUM</span>
                                    </div>
                                    <p style={{ margin: '4px 0 0 0', fontSize: '13px', color: 'rgba(255,255,255,0.6)', fontWeight: '500' }}>Match based on soul, not just photos.</p>
                                </div>
                                <FaMagic color="#FBBF24" size={16} />
                            </motion.div>

                            <ProfileCard user={currentUser} onSwipe={handleSwipe} />
                        </div>
                    ) : (
                        <motion.div key="empty" initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} style={{ textAlign: 'center', padding: '0 20px', marginTop: '100px' }}>
                            <GlassCard style={{ padding: '40px 30px', borderRadius: '32px', background: '#fff', border: '1px solid #F3F4F6', boxShadow: '0 20px 40px rgba(0,0,0,0.05)' }}>
                                <div style={{ width: '80px', height: '80px', borderRadius: '40px', background: '#F9FAFB', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 24px' }}>
                                    <FaSearchLocation size={32} color={AppTheme.colors.textSecondary} />
                                </div>
                                <h2 style={{ fontSize: '24px', marginBottom: '12px', color: AppTheme.colors.textPrimary, fontWeight: '800' }}>Out of people!</h2>
                                <p style={{ color: AppTheme.colors.textSecondary, marginBottom: '32px', lineHeight: '1.6', fontSize: '15px' }}>Check back later or expand your discovery filters to find more great connections.</p>
                                <PremiumButton text="Adjust Filters" type="gradient" fullWidth onClick={() => setShowFilters(true)} />
                            </GlassCard>
                        </motion.div>
                    )}
                </AnimatePresence>
            </main>

            <MatchModal
                isOpen={showMatchModal}
                user={lastMatchedUser || { name: 'Match', photos: [] }}
                onClose={() => setShowMatchModal(false)}
                onChat={() => {
                    setShowMatchModal(false);
                    if (lastMatchId != null) navigate(`/chat/${lastMatchId}`);
                    else navigate('/matches');
                }}
            />

            <BoostButton
                isActive={isBoosted}
                expiresAt={boostExpiresAt}
                onBoost={handleBoost}
            />

            <PassportModal
                isOpen={showPassport}
                currentCity={currentLocation}
                onClose={() => setShowPassport(false)}
                onSelect={handlePassportSelect}
            />

            <AdvancedFiltersModal
                isOpen={showFilters}
                onClose={() => setShowFilters(false)}
                onApply={handleApplyFilters}
                currentFilters={filters}
            />
        </div>
    );
};

export default Home;
