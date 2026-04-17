import React from 'react';
import { motion } from 'framer-motion';
import { FaBrain, FaBolt, FaHeart, FaCheckCircle, FaStar } from 'react-icons/fa';
import { AppTheme } from '../../theme/AppTheme';

const MatchmakerInsight = ({ insightData, matchName }) => {
    // demo fallback if no data provided
    const demoInsights = [
        { title: "Personality Sync", score: 92, icon: FaBrain, desc: `Your MBTI types are highly complementary. ${matchName}'s extroversion balances your introversion perfectly.` },
        { title: "Interest Core", score: 88, icon: FaStar, desc: "You both share deep interests in Travel and Tech, which are strong pillars for long-term bonding." },
        { title: "Conversation Flow", score: 95, icon: FaBolt, desc: "AI predicts extremely high initial conversation quality with minimal effort needed." }
    ];

    const displayData = insightData || demoInsights;

    return (
        <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            style={{
                background: 'rgba(255, 255, 255, 0.05)',
                backdropFilter: 'blur(20px)',
                borderRadius: '24px',
                padding: '24px',
                border: '1px solid rgba(255, 255, 255, 0.1)',
                color: '#fff',
                width: '100%',
                marginTop: '20px'
            }}
        >
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
                <div style={{
                    width: '40px', height: '40px', borderRadius: '12px',
                    background: 'linear-gradient(45deg, #6366F1 0%, #A855F7 100%)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    boxShadow: '0 4px 15px rgba(99, 102, 241, 0.3)'
                }}>
                    <FaBrain size={20} color="white" />
                </div>
                <div>
                    <h3 style={{ margin: 0, fontSize: '18px', fontWeight: '800' }}>AI Personal Matchmaker</h3>
                    <p style={{ margin: 0, fontSize: '12px', opacity: 0.6, fontWeight: '600' }}>Deep analysis into your potential connection</p>
                </div>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                {displayData.map((item, index) => (
                    <motion.div
                        key={index}
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.1 }}
                        style={{ display: 'flex', gap: '16px' }}
                    >
                        <div style={{
                            width: '44px', height: '44px', minWidth: '44px', borderRadius: '14px',
                            background: 'rgba(255, 255, 255, 0.1)',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            color: '#FBBF24'
                        }}>
                            <item.icon size={20} />
                        </div>
                        <div style={{ flex: 1 }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '4px' }}>
                                <span style={{ fontSize: '15px', fontWeight: '700' }}>{item.title}</span>
                                <span style={{
                                    fontSize: '13px', fontWeight: '800',
                                    color: item.score > 90 ? '#34D399' : '#FBBF24',
                                    background: item.score > 90 ? 'rgba(52, 211, 153, 0.1)' : 'rgba(251, 191, 36, 0.1)',
                                    padding: '2px 8px', borderRadius: '8px'
                                }}>
                                    {item.score}% Match
                                </span>
                            </div>
                            <p style={{ margin: 0, fontSize: '13px', opacity: 0.8, lineHeight: '1.5', fontWeight: '500' }}>
                                {item.desc}
                            </p>
                        </div>
                    </motion.div>
                ))}
            </div>

            <div style={{
                marginTop: '24px', padding: '12px', borderRadius: '16px',
                background: 'rgba(99, 102, 241, 0.1)',
                border: '1px dashed rgba(99, 102, 241, 0.3)',
                display: 'flex', alignItems: 'center', gap: '10px'
            }}>
                <FaHeart color="#F472B6" />
                <span style={{ fontSize: '13px', fontWeight: '700', color: '#fff' }}>Highly recommended for your personality type!</span>
            </div>
        </motion.div>
    );
};

export default MatchmakerInsight;
