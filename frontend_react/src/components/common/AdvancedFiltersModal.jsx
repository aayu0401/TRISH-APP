import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaSlidersH, FaTimes, FaUserFriends, FaMapMarkerAlt, FaRulerVertical, FaPray, FaStar, FaMagic, FaCheck } from 'react-icons/fa';
import { AppTheme } from '../../theme/AppTheme';
import PremiumButton from './PremiumButton';
import GlassCard from './GlassCard';

const AdvancedFiltersModal = ({ isOpen, onClose, onApply, currentFilters }) => {
    const [filters, setFilters] = useState(currentFilters || {
        ageRange: [18, 50],
        maxDistance: 50,
        height: 'Any',
        religion: 'Any',
        zodiac: 'Any',
        aiVibeMatch: false
    });

    const handleApply = () => {
        onApply(filters);
        onClose();
    };

    const religions = ['Any', 'Hinduism', 'Islam', 'Christianity', 'Sikhism', 'Buddhism', 'Jainism', 'Other'];
    const zodiacs = ['Any', 'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];

    return (
        <AnimatePresence>
            {isOpen && (
                <div style={{ position: 'fixed', inset: 0, zIndex: 2000, display: 'flex', alignItems: 'flex-end', justifyContent: 'center' }}>
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.4)', backdropFilter: 'blur(10px)' }}
                    />
                    <motion.div
                        initial={{ y: '100%' }}
                        animate={{ y: 0 }}
                        exit={{ y: '100%' }}
                        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                        style={{
                            width: '100%', maxWidth: '500px', background: AppTheme.colors.lightBackground,
                            borderTopLeftRadius: '32px', borderTopRightRadius: '32px',
                            padding: '32px 24px', position: 'relative', overflowY: 'auto', maxHeight: '90vh',
                            boxShadow: '0 -10px 40px rgba(0,0,0,0.1)'
                        }}
                    >
                        {/* Pull Bar */}
                        <div style={{ width: '40px', height: '4px', background: '#E5E7EB', borderRadius: '2px', margin: '-16px auto 24px' }} />

                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
                            <h2 style={{ fontSize: '24px', fontWeight: '800', margin: 0, color: AppTheme.colors.textPrimary }}>Discovery Filters</h2>
                            <motion.button
                                whileTap={{ scale: 0.9 }}
                                onClick={onClose}
                                style={{ width: '36px', height: '36px', borderRadius: '50%', background: '#F3F4F6', display: 'flex', alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.textSecondary, border: 'none', cursor: 'pointer' }}
                            >
                                <FaTimes size={14} />
                            </motion.button>
                        </div>

                        <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
                            {/* Age Range */}
                            <FilterSection icon={FaUserFriends} title="Age Range">
                                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                                    <div style={{ flex: 1, padding: '16px', background: '#FFF', borderRadius: '16px', border: '1px solid #E5E7EB', textAlign: 'center' }}>
                                        <div style={{ fontSize: '12px', fontWeight: '700', color: AppTheme.colors.textTertiary, marginBottom: '4px' }}>MIN</div>
                                        <div style={{ fontSize: '18px', fontWeight: '800' }}>{filters.ageRange[0]}</div>
                                    </div>
                                    <div style={{ fontWeight: '800', color: AppTheme.colors.textTertiary }}>—</div>
                                    <div style={{ flex: 1, padding: '16px', background: '#FFF', borderRadius: '16px', border: '1px solid #E5E7EB', textAlign: 'center' }}>
                                        <div style={{ fontSize: '12px', fontWeight: '700', color: AppTheme.colors.textTertiary, marginBottom: '4px' }}>MAX</div>
                                        <div style={{ fontSize: '18px', fontWeight: '800' }}>{filters.ageRange[1]}</div>
                                    </div>
                                </div>
                                <input
                                    type="range"
                                    min="18" max="100"
                                    value={filters.ageRange[1]}
                                    onChange={(e) => setFilters(prev => ({ ...prev, ageRange: [prev.ageRange[0], parseInt(e.target.value)] }))}
                                    style={{ width: '100%', marginTop: '16px', accentColor: AppTheme.colors.primaryPink }}
                                />
                            </FilterSection>

                            {/* Distance */}
                            <FilterSection icon={FaMapMarkerAlt} title="Discovery Radius">
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                                    <span style={{ fontSize: '15px', color: AppTheme.colors.textSecondary, fontWeight: '600' }}>
                                        {filters.maxDistance <= 10 ? 'Nearby (Ultra Personal)' :
                                            filters.maxDistance <= 40 ? 'Local (City Scale)' :
                                                filters.maxDistance <= 100 ? 'Regional (Driveable)' : 'Traveler (Long Distance)'}
                                    </span>
                                    <span style={{ fontSize: '18px', fontWeight: '800', color: AppTheme.colors.primaryPink }}>{filters.maxDistance} km</span>
                                </div>
                                <div style={{ position: 'relative', marginBottom: '10px' }}>
                                    <input
                                        type="range"
                                        min="2" max="500"
                                        step="1"
                                        value={filters.maxDistance}
                                        onChange={(e) => setFilters(prev => ({ ...prev, maxDistance: parseInt(e.target.value) }))}
                                        style={{ width: '100%', accentColor: AppTheme.colors.primaryPink, height: '6px', borderRadius: '3px', cursor: 'pointer' }}
                                    />
                                    <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '8px', fontSize: '10px', color: AppTheme.colors.textTertiary, fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                                        <span>Nearby</span>
                                        <span>Local</span>
                                        <span>Regional</span>
                                        <span>Long</span>
                                    </div>
                                </div>
                            </FilterSection>

                            {/* AI Vibe Match (Premium) */}
                            <div style={{
                                padding: '20px', borderRadius: '24px',
                                background: 'linear-gradient(135deg, #1e1b4b 0%, #312e81 100%)',
                                color: '#FFF', position: 'relative', overflow: 'hidden',
                                boxShadow: '0 10px 25px rgba(30, 27, 75, 0.3)',
                                border: '1px solid rgba(255,255,255,0.1)'
                            }}>
                                <div style={{ position: 'absolute', top: '-10px', right: '-10px', width: '60px', height: '60px', borderRadius: '50%', background: 'rgba(99,102,241,0.2)', filter: 'blur(20px)' }} />
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                                        <div style={{ width: '44px', height: '44px', borderRadius: '12px', background: 'rgba(255,255,255,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#FBBF24' }}>
                                            <FaMagic size={20} />
                                        </div>
                                        <div>
                                            <h4 style={{ margin: 0, fontSize: '16px', fontWeight: '800' }}>AI Vibe Match</h4>
                                            <p style={{ margin: 0, fontSize: '12px', color: 'rgba(255,255,255,0.7)', fontWeight: '500' }}>Only show high-compatibility scores.</p>
                                        </div>
                                    </div>
                                    <div
                                        onClick={() => setFilters(prev => ({ ...prev, aiVibeMatch: !prev.aiVibeMatch }))}
                                        style={{
                                            width: '50px', height: '26px', borderRadius: '13px',
                                            background: filters.aiVibeMatch ? AppTheme.colors.successGreen : 'rgba(255,255,255,0.2)',
                                            position: 'relative', cursor: 'pointer', transition: 'all 0.3s'
                                        }}
                                    >
                                        <motion.div
                                            animate={{ x: filters.aiVibeMatch ? 26 : 4 }}
                                            style={{ width: '20px', height: '20px', borderRadius: '50%', background: '#FFF', position: 'absolute', top: '3px' }}
                                        />
                                    </div>
                                </div>
                            </div>

                            {/* Religion Dropdown (Custom UI) */}
                            <FilterSection icon={FaPray} title="Religion">
                                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                                    {religions.map(r => (
                                        <BadgeOption
                                            key={r}
                                            label={r}
                                            selected={filters.religion === r}
                                            onClick={() => setFilters(prev => ({ ...prev, religion: r }))}
                                        />
                                    ))}
                                </div>
                            </FilterSection>

                            {/* Zodiac Dropdown */}
                            <FilterSection icon={FaStar} title="Zodiac Sign">
                                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                                    {zodiacs.map(z => (
                                        <BadgeOption
                                            key={z}
                                            label={z}
                                            selected={filters.zodiac === z}
                                            onClick={() => setFilters(prev => ({ ...prev, zodiac: z }))}
                                        />
                                    ))}
                                </div>
                            </FilterSection>
                        </div>

                        {/* Apply Button */}
                        <div style={{ marginTop: '40px', paddingBottom: '20px' }}>
                            <PremiumButton text="Apply Filters" type="gradient" fullWidth onClick={handleApply} />
                        </div>
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
    );
};

const FilterSection = ({ icon: Icon, title, children }) => (
    <div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <div style={{ width: '32px', height: '32px', borderRadius: '8px', background: `${AppTheme.colors.primaryPink}10`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.primaryPink }}>
                <Icon size={14} />
            </div>
            <h3 style={{ fontSize: '16px', fontWeight: '800', color: AppTheme.colors.textPrimary, margin: 0 }}>{title}</h3>
        </div>
        {children}
    </div>
);

const BadgeOption = ({ label, selected, onClick }) => (
    <motion.div
        whileTap={{ scale: 0.95 }}
        onClick={onClick}
        style={{
            padding: '10px 20px',
            borderRadius: '16px',
            background: selected ? AppTheme.colors.primaryPink : '#FFF',
            color: selected ? '#FFF' : AppTheme.colors.textPrimary,
            border: selected ? 'none' : '1px solid #E5E7EB',
            fontSize: '14px',
            fontWeight: '700',
            cursor: 'pointer',
            boxShadow: selected ? '0 5px 15px rgba(253, 41, 123, 0.2)' : 'none',
            display: 'flex',
            alignItems: 'center',
            gap: '8px'
        }}
    >
        {selected && <FaCheck size={10} />}
        {label}
    </motion.div>
);

export default AdvancedFiltersModal;
