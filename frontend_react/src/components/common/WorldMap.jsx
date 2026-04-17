import React from 'react';
import { motion } from 'framer-motion';

const WorldMap = ({ onSelect, selectedCity }) => {
    // Basic representation of continents for the premium feel
    // In a real app, this would be a detailed topoJSON or GeoJSON
    const pins = [
        { city: 'London', x: '48%', y: '30%' },
        { city: 'New York', x: '25%', y: '40%' },
        { city: 'Paris', x: '50%', y: '35%' },
        { city: 'Tokyo', x: '85%', y: '45%' },
        { city: 'Dubai', x: '65%', y: '55%' },
        { city: 'Mumbai', x: '70%', y: '60%' },
        { city: 'Sydney', x: '88%', y: '80%' },
        { city: 'Rio', x: '35%', y: '75%' },
    ];

    return (
        <div style={{
            width: '100%',
            height: '240px',
            background: '#1E293B',
            borderRadius: '24px',
            position: 'relative',
            overflow: 'hidden',
            boxShadow: 'inset 0 0 40px rgba(0,0,0,0.4)',
            border: '1px solid rgba(255,255,255,0.05)'
        }}>
            {/* World Map SVG Background (Simplified) */}
            <svg viewBox="0 0 800 400" style={{ width: '100%', height: '100%', opacity: 0.3 }}>
                <path
                    fill="#475569"
                    d="M150,100 L200,80 L250,90 L280,120 L270,180 L220,220 L180,210 L140,160 Z 
                       M450,80 L520,70 L580,90 L620,130 L600,200 L550,230 L480,210 L440,150 Z
                       M300,250 L350,230 L400,250 L420,320 L380,380 L320,360 L280,310 Z
                       M650,280 L720,260 L780,280 L800,340 L750,390 L680,370 L640,320 Z"
                />
            </svg>

            {/* Scanning Grid Line */}
            <motion.div
                animate={{ x: ['0%', '100%'] }}
                transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
                style={{
                    position: 'absolute', top: 0, bottom: 0, width: '2px',
                    background: 'linear-gradient(to bottom, transparent, #FD297B, transparent)',
                    boxShadow: '0 0 15px #FD297B', zIndex: 2
                }}
            />

            {/* Pins */}
            {pins.map((pin, i) => (
                <motion.div
                    key={i}
                    whileHover={{ scale: 1.5 }}
                    onClick={() => onSelect({ city: pin.city })}
                    style={{
                        position: 'absolute',
                        left: pin.x,
                        top: pin.y,
                        width: '12px',
                        height: '12px',
                        borderRadius: '50%',
                        background: selectedCity === pin.city ? '#FD297B' : '#fff',
                        boxShadow: selectedCity === pin.city ? '0 0 15px #FD297B' : '0 0 10px rgba(0,0,0,0.5)',
                        cursor: 'pointer',
                        zIndex: 10,
                        border: '2px solid rgba(255,255,255,0.2)'
                    }}
                >
                    {selectedCity === pin.city && (
                        <motion.div
                            initial={{ scale: 0 }}
                            animate={{ scale: [1, 2, 1], opacity: [1, 0, 1] }}
                            transition={{ repeat: Infinity, duration: 2 }}
                            style={{
                                position: 'absolute', inset: -4, borderRadius: '50%',
                                border: '1px solid #FD297B'
                            }}
                        />
                    )}
                </motion.div>
            ))}

            <div style={{
                position: 'absolute', bottom: '12px', right: '12px',
                background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(10px)',
                padding: '4px 10px', borderRadius: '10px',
                fontSize: '10px', color: '#fff', fontWeight: '700', letterSpacing: '1px'
            }}>
                GLOBAL DISCOVERY ACTIVE
            </div>
        </div>
    );
};

export default WorldMap;
