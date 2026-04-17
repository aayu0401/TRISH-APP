import React from 'react';
import { NavLink } from 'react-router-dom';
import { FaHeart, FaCommentAlt, FaUser, FaGift, FaWallet, FaSearch } from 'react-icons/fa';
import { AppTheme } from '../../theme/AppTheme';
import { motion } from 'framer-motion';

const BottomNav = () => {
    return (
        <div style={{
            position: 'fixed',
            bottom: '24px',
            left: '20px',
            right: '20px',
            height: '72px',
            background: 'rgba(255, 255, 255, 0.85)',
            backdropFilter: 'blur(20px)',
            borderRadius: '24px',
            display: 'flex',
            justifyContent: 'space-around',
            alignItems: 'center',
            zIndex: 2000,
            boxShadow: '0 15px 35px rgba(0,0,0,0.1)',
            border: '1px solid rgba(255, 255, 255, 0.3)',
            padding: '0 10px'
        }}>
            <NavItem to="/home" icon={FaHeart} label="Discover" />
            <NavItem to="/matches" icon={FaCommentAlt} label="Matches" />
            <NavItem to="/gifts" icon={FaGift} label="Gifts" />
            <NavItem to="/wallet" icon={FaWallet} label="Wallet" />
            <NavItem to="/profile" icon={FaUser} label="Profile" />
        </div>
    );
};

const NavItem = ({ to, icon: Icon, label }) => (
    <NavLink
        to={to}
        style={({ isActive }) => ({
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '4px',
            textDecoration: 'none',
            color: isActive ? AppTheme.colors.primaryPink : '#94A3B8',
            transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
            flex: 1,
            padding: '10px 0',
            position: 'relative'
        })}
    >
        {({ isActive }) => (
            <>
                <motion.div
                    animate={isActive ? {
                        y: -4,
                        scale: 1.2,
                        filter: `drop-shadow(0 4px 8px ${AppTheme.colors.primaryPink}40)`
                    } : {
                        y: 0,
                        scale: 1,
                        filter: 'none'
                    }}
                    transition={{ type: 'spring', stiffness: 400, damping: 25 }}
                >
                    <Icon size={20} />
                </motion.div>

                {isActive && (
                    <motion.span
                        initial={{ opacity: 0, scale: 0.8 }}
                        animate={{ opacity: 1, scale: 1 }}
                        style={{
                            fontSize: '10px',
                            fontWeight: '800',
                            letterSpacing: '0.3px',
                            textTransform: 'uppercase'
                        }}
                    >
                        {label}
                    </motion.span>
                )}

                {isActive && (
                    <motion.div
                        layoutId="activeTabUnderline"
                        style={{
                            position: 'absolute',
                            bottom: '6px',
                            width: '4px',
                            height: '4px',
                            borderRadius: '50%',
                            background: AppTheme.colors.primaryPink,
                            boxShadow: `0 0 10px ${AppTheme.colors.primaryPink}`
                        }}
                        transition={{ type: 'spring', stiffness: 400, damping: 30 }}
                    />
                )}
            </>
        )}
    </NavLink>
);

export default BottomNav;
