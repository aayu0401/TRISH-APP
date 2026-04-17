import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { AppTheme } from '../../theme/AppTheme';

const BoostRadar = ({ isActive }) => {
    return (
        <AnimatePresence>
            {isActive && (
                <div style={{
                    position: 'fixed',
                    inset: 0,
                    pointerEvents: 'none',
                    zIndex: 5,
                    overflow: 'hidden',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                }}>
                    {/* Pulsing Rings */}
                    {[1, 2, 3].map((i) => (
                        <motion.div
                            key={i}
                            initial={{ scale: 0.5, opacity: 0.5 }}
                            animate={{
                                scale: [0.5, 4],
                                opacity: [0.5, 0]
                            }}
                            transition={{
                                duration: 4,
                                repeat: Infinity,
                                delay: (i - 1) * 1.3,
                                ease: "easeOut"
                            }}
                            style={{
                                position: 'absolute',
                                width: '300px',
                                height: '300px',
                                borderRadius: '50%',
                                border: `2px solid #8B5CF6`,
                                background: `radial-gradient(circle, rgba(139, 92, 246, 0.1) 0%, transparent 70%)`,
                                boxShadow: `0 0 20px rgba(139, 92, 246, 0.2)`
                            }}
                        />
                    ))}

                    {/* Scanning Line */}
                    <motion.div
                        animate={{ rotate: 360 }}
                        transition={{
                            duration: 5,
                            repeat: Infinity,
                            ease: "linear"
                        }}
                        style={{
                            position: 'absolute',
                            width: '200vw',
                            height: '200vw',
                            background: `conic-gradient(from 0deg, rgba(139, 92, 246, 0.2) 0deg, transparent 40deg, transparent 360deg)`,
                            borderRadius: '50%',
                            zIndex: 1
                        }}
                    />

                    {/* Glowing Center */}
                    <div style={{
                        position: 'absolute',
                        width: '100vw',
                        height: '100vh',
                        background: 'radial-gradient(circle at center, rgba(139, 92, 246, 0.05) 0%, transparent 60%)',
                        zIndex: 0
                    }} />
                </div>
            )}
        </AnimatePresence>
    );
};

export default BoostRadar;
