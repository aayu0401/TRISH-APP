import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaChevronRight, FaBell, FaLock, FaUserShield, FaSignOutAlt, FaQuestionCircle, FaChevronLeft, FaRobot, FaHeart, FaCommentDots } from 'react-icons/fa';
import { AppTheme } from '../theme/AppTheme';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import { useToast } from '../context/ToastContext';

const Settings = () => {
    const { logout, user } = useAuth();
    const navigate = useNavigate();
    const { showToast } = useToast();
    const [activeSubView, setActiveSubView] = useState('main'); // 'main', 'notifications'

    const [notifSettings, setNotifSettings] = useState({
        newMatches: true,
        messages: true,
        likes: false,
        aiInsights: true,
        smartSuggestions: true
    });

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    const toggleNotif = (key) => {
        setNotifSettings(prev => ({ ...prev, [key]: !prev[key] }));
        showToast('Settings saved successfully', 'success');
    };

    const renderMainSettings = () => (
        <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.95 }}
            style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}
        >
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '16px' }}>
                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => navigate(-1)}
                    style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#FFFFFF', boxShadow: '0 2px 10px rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.textPrimary, border: 'none', cursor: 'pointer' }}
                >
                    <FaChevronLeft size={16} />
                </motion.button>
                <h1 style={{ fontSize: '28px', fontWeight: '800', margin: 0, color: AppTheme.colors.textPrimary }}>Settings</h1>
            </div>

            {/* Profile Header Summary */}
            <section style={{ textAlign: 'center', marginBottom: '16px', background: '#FFFFFF', padding: '24px', borderRadius: '24px', boxShadow: '0 2px 10px rgba(0,0,0,0.02)' }}>
                <div style={{ position: 'relative', width: '90px', height: '90px', margin: '0 auto 16px' }}>
                    <img
                        src={user?.avatar || "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&h=400&fit=crop"}
                        alt="Profile"
                        style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover', border: `3px solid ${AppTheme.colors.primaryPink}` }}
                    />
                </div>
                <h2 style={{ fontSize: '22px', fontWeight: '800', margin: 0, color: AppTheme.colors.textPrimary }}>{user?.name || "Trish User"}</h2>
                <p style={{ color: AppTheme.colors.textSecondary, fontSize: '14px', marginTop: '4px' }}>Premium Member</p>
            </section>

            <SettingsGroup title="Account">
                <SettingsItem icon={FaBell} label="Notifications" onClick={() => setActiveSubView('notifications')} />
                <SettingsItem icon={FaLock} label="Privacy & Safety" />
                <SettingsItem icon={FaUserShield} label="Security" />
            </SettingsGroup>

            <SettingsGroup title="Support">
                <SettingsItem icon={FaQuestionCircle} label="Help Center" />
                <SettingsItem icon={FaQuestionCircle} label="Contact Us" />
            </SettingsGroup>

            <SettingsGroup title="Login">
                <motion.button
                    whileTap={{ scale: 0.98 }}
                    onClick={handleLogout}
                    style={{
                        width: '100%',
                        background: '#FEF2F2',
                        border: '1px solid #FECACA',
                        padding: '16px',
                        borderRadius: '16px',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        gap: '12px',
                        color: '#EF4444',
                        fontSize: '16px',
                        fontWeight: '700',
                        cursor: 'pointer',
                        marginTop: '10px'
                    }}
                >
                    <FaSignOutAlt />
                    Log Out
                </motion.button>
            </SettingsGroup>

            <div style={{ textAlign: 'center', padding: '20px', color: AppTheme.colors.textTertiary }}>
                <div style={{ fontSize: '14px', fontWeight: '700', letterSpacing: '1px' }}>TRISH APP V1.0</div>
            </div>
        </motion.div>
    );

    const renderNotificationSettings = () => (
        <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 50 }}
        >
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '32px' }}>
                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => setActiveSubView('main')}
                    style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#FFFFFF', boxShadow: '0 2px 10px rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.textPrimary, border: 'none', cursor: 'pointer' }}
                >
                    <FaChevronLeft size={16} />
                </motion.button>
                <div>
                    <h2 style={{ margin: 0, fontSize: '24px', fontWeight: '800', color: AppTheme.colors.textPrimary }}>Notifications</h2>
                    <p style={{ margin: 0, fontSize: '14px', color: AppTheme.colors.textSecondary }}>Manage your alerts</p>
                </div>
            </div>

            <SettingsGroup title="Push Notifications">
                <ToggleItem
                    icon={FaHeart}
                    label="New Matches"
                    active={notifSettings.newMatches}
                    onToggle={() => toggleNotif('newMatches')}
                />
                <ToggleItem
                    icon={FaCommentDots}
                    label="Messages"
                    active={notifSettings.messages}
                    onToggle={() => toggleNotif('messages')}
                />
                <ToggleItem
                    icon={FaHeart}
                    label="Likes"
                    active={notifSettings.likes}
                    onToggle={() => toggleNotif('likes')}
                />
            </SettingsGroup>

            <SettingsGroup title="Smart Alerts">
                <ToggleItem
                    icon={FaRobot}
                    label="AI Match Insights"
                    active={notifSettings.aiInsights}
                    onToggle={() => toggleNotif('aiInsights')}
                />
                <ToggleItem
                    icon={FaRobot}
                    label="Conversation Starters"
                    active={notifSettings.smartSuggestions}
                    onToggle={() => toggleNotif('smartSuggestions')}
                />
            </SettingsGroup>
        </motion.div>
    );

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            padding: '24px',
            paddingBottom: '120px',
            color: AppTheme.colors.textPrimary
        }}>
            <AnimatePresence mode="wait">
                {activeSubView === 'main' ? renderMainSettings() : renderNotificationSettings()}
            </AnimatePresence>
        </div>
    );
};

const SettingsGroup = ({ title, children }) => (
    <div style={{ marginBottom: '32px' }}>
        <h3 style={{ fontSize: '14px', textTransform: 'uppercase', letterSpacing: '1px', color: AppTheme.colors.textTertiary, marginBottom: '16px', paddingLeft: '8px', fontWeight: '700' }}>
            {title}
        </h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {children}
        </div>
    </div>
);

const SettingsItem = ({ icon: Icon, label, onClick }) => (
    <div onClick={onClick} style={{ padding: '16px', background: '#FFFFFF', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer', borderRadius: '16px', border: '1px solid #E5E7EB', boxShadow: '0 2px 5px rgba(0,0,0,0.02)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{
                width: '40px', height: '40px', borderRadius: '12px',
                background: `${AppTheme.colors.primaryPink}15`, display: 'flex',
                alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.primaryPink
            }}>
                <Icon size={18} />
            </div>
            <span style={{ fontWeight: '600', fontSize: '16px', color: AppTheme.colors.textPrimary }}>{label}</span>
        </div>
        <FaChevronRight size={14} color={AppTheme.colors.textTertiary} />
    </div>
);

const ToggleItem = ({ icon: Icon, label, active, onToggle }) => (
    <div style={{ padding: '16px', background: '#FFFFFF', display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderRadius: '16px', border: '1px solid #E5E7EB', boxShadow: '0 2px 5px rgba(0,0,0,0.02)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{
                width: '40px', height: '40px', borderRadius: '12px',
                background: active ? `${AppTheme.colors.successGreen}15` : '#F3F4F6',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: active ? AppTheme.colors.successGreen : AppTheme.colors.textTertiary
            }}>
                <Icon size={18} />
            </div>
            <span style={{ fontWeight: '600', fontSize: '16px', color: AppTheme.colors.textPrimary }}>{label}</span>
        </div>
        <div
            onClick={onToggle}
            style={{
                width: '50px', height: '26px', borderRadius: '13px',
                background: active ? AppTheme.colors.successGreen : '#E5E7EB',
                position: 'relative', cursor: 'pointer', transition: 'all 0.3s'
            }}
        >
            <motion.div
                animate={{ x: active ? 26 : 4 }}
                style={{
                    width: '20px', height: '20px', borderRadius: '50%',
                    background: '#fff', position: 'absolute', top: '3px',
                    boxShadow: '0 2px 4px rgba(0,0,0,0.2)'
                }}
            />
        </div>
    </div>
);

export default Settings;
