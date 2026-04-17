import React from 'react';
import { motion } from 'framer-motion';

const GlassCard = ({ children, className = '', style = {}, ...props }) => {
    return (
        <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 10 }}
            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
            className={`glass-panel ${className}`}
            style={{
                padding: '28px',
                width: '100%',
                ...style
            }}
            {...props}
        >
            {children}
        </motion.div>
    );
};

export default GlassCard;
