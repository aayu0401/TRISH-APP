import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaMapMarkerAlt, FaSearch, FaTimes, FaGlobe, FaPlane } from 'react-icons/fa';
import { AppTheme } from '../../theme/AppTheme';
import GlassCard from './GlassCard';
import PremiumButton from './PremiumButton';
import WorldMap from './WorldMap';

const PassportModal = ({ isOpen, onClose, onSelect, currentCity }) => {
    const [searchQuery, setSearchQuery] = useState('');
    const [isSearching, setIsSearching] = useState(false);

    const popularLocations = [
        { city: 'London', country: 'UK', lat: 51.5074, lon: -0.1278 },
        { city: 'New York', country: 'USA', lat: 40.7128, lon: -74.0060 },
        { city: 'Paris', country: 'France', lat: 48.8566, lon: 2.3522 },
        { city: 'Tokyo', country: 'Japan', lat: 35.6762, lon: 139.6503 },
        { city: 'Dubai', country: 'UAE', lat: 25.2048, lon: 55.2708 },
    ];

    return (
        <AnimatePresence>
            {isOpen && (
                <div style={{ position: 'fixed', inset: 0, zIndex: 2000, display: 'flex', alignItems: 'flex-end', justifyContent: 'center' }}>
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.4)', backdropFilter: 'blur(5px)' }}
                    />

                    <motion.div
                        initial={{ y: '100%' }}
                        animate={{ y: 0 }}
                        exit={{ y: '100%' }}
                        transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                        style={{
                            width: '100%',
                            maxWidth: '500px',
                            background: '#FFFFFF',
                            borderTopLeftRadius: '32px',
                            borderTopRightRadius: '32px',
                            padding: '32px 24px',
                            position: 'relative',
                            boxShadow: '0 -10px 40px rgba(0,0,0,0.1)',
                            maxHeight: '85vh',
                            overflowY: 'auto'
                        }}
                    >
                        <div style={{ width: '40px', height: '4px', background: '#E5E7EB', borderRadius: '2px', margin: '0 auto 24px' }} />

                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                            <div>
                                <h3 style={{ fontSize: '24px', fontWeight: '800', margin: 0 }}>Passport</h3>
                                <p style={{ color: AppTheme.colors.textSecondary, fontSize: '14px', margin: '4px 0 0 0' }}>Current: {currentCity || 'Nearby'}</p>
                            </div>
                            <motion.button
                                whileTap={{ scale: 0.9 }}
                                onClick={onClose}
                                style={{ background: '#F3F4F6', border: 'none', width: '36px', height: '36px', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}
                            >
                                <FaTimes color={AppTheme.colors.textSecondary} />
                            </motion.button>
                        </div>

                        <div style={{ marginBottom: '24px' }}>
                            <WorldMap onSelect={onSelect} selectedCity={currentCity} />
                        </div>

                        <div style={{ position: 'relative', marginBottom: '32px' }}>
                            <div style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: AppTheme.colors.textTertiary }}>
                                <FaSearch size={16} />
                            </div>
                            <input
                                type="text"
                                placeholder="Search for a city..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                style={{
                                    width: '100%',
                                    background: '#F9FAFB',
                                    border: '1px solid #E5E7EB',
                                    padding: '16px 16px 16px 48px',
                                    borderRadius: '16px',
                                    fontSize: '15px',
                                    outline: 'none'
                                }}
                            />
                        </div>

                        <div style={{ marginBottom: '32px' }}>
                            <h4 style={{ fontSize: '14px', fontWeight: '700', color: AppTheme.colors.textTertiary, textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '16px' }}>Popular Destinations</h4>
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                                {popularLocations.map((loc, i) => (
                                    <motion.div
                                        key={i}
                                        whileHover={{ x: 5 }}
                                        onClick={() => onSelect(loc)}
                                        style={{
                                            padding: '16px',
                                            borderRadius: '16px',
                                            border: '1px solid #F3F4F6',
                                            display: 'flex',
                                            alignItems: 'center',
                                            gap: '16px',
                                            cursor: 'pointer'
                                        }}
                                    >
                                        <div style={{ width: '40px', height: '40px', borderRadius: '12px', background: `${AppTheme.colors.brandBlue}20`, color: AppTheme.colors.brandBlue, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                            <FaGlobe size={18} />
                                        </div>
                                        <div style={{ flex: 1 }}>
                                            <div style={{ fontWeight: '700', fontSize: '16px' }}>{loc.city}</div>
                                            <div style={{ fontSize: '13px', color: AppTheme.colors.textSecondary }}>{loc.country}</div>
                                        </div>
                                        <FaPlane color="#E5E7EB" />
                                    </motion.div>
                                ))}
                            </div>
                        </div>

                        <PremiumButton
                            text="Reset to Current Location"
                            type="outline"
                            fullWidth
                            onClick={() => onSelect(null)}
                            style={{ marginBottom: '8px' }}
                        />
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
    );
};

export default PassportModal;
