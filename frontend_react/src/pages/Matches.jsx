import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaSearch, FaChevronRight } from 'react-icons/fa';
import GlassCard from '../components/common/GlassCard';
import { AppTheme } from '../theme/AppTheme';
import { Link } from 'react-router-dom';
import { matchService } from '../services/match.service';

const Matches = () => {
    const [matches, setMatches] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');

    useEffect(() => {
        const fetchMatches = async () => {
            try {
                setLoading(true);
                const data = await matchService.getMatches();
                setMatches(Array.isArray(data) ? data : []);
            } catch (error) {
                console.error("Failed to fetch matches:", error);
                setMatches([]);
            } finally {
                setLoading(false);
            }
        };
        fetchMatches();
    }, []);

    const filteredMatches = (matches || []).filter(m =>
        m.name?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            padding: '24px',
            paddingBottom: '110px',
            color: AppTheme.colors.textPrimary
        }}>
            <header style={{ marginBottom: '24px' }}>
                <h1 style={{ fontSize: '32px', margin: 0, fontWeight: '800', letterSpacing: '-1px' }}>Matches</h1>
                <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px', marginTop: '4px' }}>Connect and chat with your matches</p>
            </header>

            {/* Search Bar */}
            <div style={{ position: 'relative', marginBottom: '32px' }}>
                <div style={{
                    position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)',
                    color: AppTheme.colors.textTertiary
                }}>
                    <FaSearch size={16} />
                </div>
                <input
                    type="text"
                    placeholder="Search your matches..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    style={{
                        width: '100%',
                        background: '#FFFFFF',
                        border: '1px solid #E5E7EB',
                        padding: '16px 16px 16px 48px',
                        borderRadius: '16px',
                        color: AppTheme.colors.textPrimary,
                        fontSize: '15px',
                        outline: 'none',
                        transition: 'border-color 0.2s',
                        boxShadow: '0 2px 5px rgba(0,0,0,0.02)'
                    }}
                />
            </div>

            {/* Top Matches Carousel */}
            <section style={{ marginBottom: '40px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                    <h3 style={{ fontSize: '18px', margin: 0, fontWeight: '700' }}>New Matches</h3>
                    <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                        <Link to="/requests" style={{
                            fontSize: '12px',
                            background: `${AppTheme.colors.primaryPink}10`,
                            color: AppTheme.colors.primaryPink,
                            fontWeight: '700',
                            textDecoration: 'none',
                            padding: '6px 12px',
                            borderRadius: '12px'
                        }}>
                            Requests (3)
                        </Link>
                        <Link to="/gifts" style={{
                            fontSize: '12px',
                            background: `${AppTheme.colors.brandBlue}10`,
                            color: AppTheme.colors.brandBlue,
                            fontWeight: '700',
                            textDecoration: 'none',
                            padding: '6px 12px',
                            borderRadius: '12px'
                        }}>
                            Gifts (1)
                        </Link>
                    </div>
                </div>
                <div style={{ display: 'flex', gap: '16px', overflowX: 'auto', paddingBottom: '10px', scrollbarWidth: 'none' }}>
                    {matches.map((match, i) => (
                        <motion.div
                            key={match.id}
                            initial={{ opacity: 0, scale: 0.9 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ delay: i * 0.1 }}
                            style={{ textAlign: 'center', minWidth: '70px', cursor: 'pointer' }}
                        >
                            <div style={{
                                width: '70px', height: '70px', borderRadius: '50%',
                                border: `3px solid ${AppTheme.colors.primaryPink}`, padding: '2px',
                                marginBottom: '8px', position: 'relative'
                            }}>
                                <img src={match.avatar} alt={match.name} style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }} />
                                <div style={{
                                    position: 'absolute', bottom: '2px', right: '2px',
                                    width: '14px', height: '14px', borderRadius: '50%',
                                    background: AppTheme.colors.successGreen, border: '2px solid #FFFFFF'
                                }} />
                            </div>
                            <span style={{ fontSize: '14px', fontWeight: '600', color: AppTheme.colors.textPrimary }}>{match.name.split(' ')[0]}</span>
                        </motion.div>
                    ))}
                    {matches.length === 0 && !loading && (
                        <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px' }}>No matches yet. Keep swiping!</p>
                    )}
                </div>
            </section>

            {/* Conversations Feed */}
            <section>
                <h3 style={{ fontSize: '18px', marginBottom: '20px', fontWeight: '700' }}>Messages</h3>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                    <AnimatePresence>
                        {filteredMatches.map((match, i) => (
                            <motion.div
                                key={match.id}
                                initial={{ opacity: 0, x: -10 }}
                                animate={{ opacity: 1, x: 0 }}
                                exit={{ opacity: 0, x: 10 }}
                                transition={{ delay: i * 0.05 }}
                            >
                                <Link to={`/chat/${match.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                                    <div style={{
                                        padding: '16px',
                                        background: '#FFFFFF',
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: '16px',
                                        borderRadius: '20px',
                                        border: '1px solid #E5E7EB',
                                        boxShadow: '0 2px 8px rgba(0,0,0,0.02)',
                                        transition: 'background 0.2s',
                                        cursor: 'pointer'
                                    }}>
                                        <div style={{ position: 'relative' }}>
                                            <div style={{ width: '60px', height: '60px', borderRadius: '50%', overflow: 'hidden' }}>
                                                <img src={match.avatar} alt={match.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                            </div>
                                            {match.id % 2 === 0 && (
                                                <div style={{
                                                    position: 'absolute', top: 0, right: 0,
                                                    width: '14px', height: '14px', background: AppTheme.colors.primaryPink,
                                                    borderRadius: '50%', border: '2px solid #FFFFFF'
                                                }} />
                                            )}
                                        </div>
                                        <div style={{ flex: 1 }}>
                                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px', alignItems: 'center' }}>
                                                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                                    <h4 style={{ fontSize: '16px', margin: 0, fontWeight: '700', color: AppTheme.colors.textPrimary }}>{match.name}</h4>
                                                    {match.isBlindMatch && (
                                                        <span style={{ fontSize: '10px', background: '#1e1b4b', color: '#fff', padding: '2px 8px', borderRadius: '10px', fontWeight: '800' }}>BLIND</span>
                                                    )}
                                                </div>
                                                <span style={{ fontSize: '12px', color: AppTheme.colors.textTertiary, fontWeight: '500' }}>{match.time}</span>
                                            </div>
                                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                                                <p style={{
                                                    fontSize: '14px', color: AppTheme.colors.textSecondary, margin: 0,
                                                    whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
                                                    maxWidth: '200px'
                                                }}>
                                                    {match.lastMessage}
                                                </p>
                                                {match.id % 3 === 0 ? (
                                                    <span style={{ fontSize: '11px', color: AppTheme.colors.primaryPink, fontWeight: '700' }}>Typing...</span>
                                                ) : (
                                                    <FaChevronRight size={12} color={AppTheme.colors.textTertiary} />
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                </Link>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </div>
            </section>
        </div>
    );
};

export default Matches;
