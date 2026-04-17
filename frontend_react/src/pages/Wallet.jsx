import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { FaWallet, FaArrowUp, FaArrowDown, FaHistory, FaPlusCircle, FaArrowLeft } from 'react-icons/fa';
import { AppTheme } from '../theme/AppTheme';
import { walletService } from '../services/wallet.service';
import PremiumButton from '../components/common/PremiumButton';
import { useNavigate } from 'react-router-dom';
import { useToast } from '../context/ToastContext';

const Wallet = () => {
    const navigate = useNavigate();
    const { showToast } = useToast();
    const [balance, setBalance] = useState(0);
    const [transactions, setTransactions] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            try {
                setLoading(true);
                const [balanceData, transactionsData] = await Promise.all([
                    walletService.getBalance(),
                    walletService.getTransactions()
                ]);

                setBalance(balanceData?.balance || 0);
                setTransactions(Array.isArray(transactionsData) ? transactionsData : []);
            } catch (error) {
                console.error("Failed to fetch wallet data:", error);
                setBalance(0);
                setTransactions([]);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            padding: '24px',
            paddingBottom: '100px',
            color: AppTheme.colors.textPrimary
        }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '24px' }}>
                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => navigate(-1)}
                    style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#FFFFFF', boxShadow: '0 2px 10px rgba(0,0,0,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.textPrimary, border: 'none', cursor: 'pointer' }}
                >
                    <FaArrowLeft size={16} />
                </motion.button>
                <h1 style={{ fontSize: '28px', margin: 0, fontWeight: '800', color: AppTheme.colors.textPrimary }}>My Wallet</h1>
            </div>

            {/* Premium Credit Card UI */}
            <motion.div
                initial={{ y: 20, opacity: 0, rotateX: 20 }}
                animate={{ y: 0, opacity: 1, rotateX: 0 }}
                style={{ perspective: 1000 }}
            >
                <div style={{
                    background: 'linear-gradient(135deg, #FF6B6B 0%, #FD297B 100%)', // Pink gradient
                    borderRadius: '24px',
                    padding: '24px',
                    marginBottom: '24px',
                    boxShadow: '0 10px 30px rgba(253, 41, 123, 0.3)',
                    position: 'relative',
                    overflow: 'hidden',
                    height: '220px',
                    display: 'flex',
                    flexDirection: 'column',
                    justifyContent: 'space-between',
                    color: '#FFFFFF'
                }}>
                    {/* Decoration */}
                    <div style={{
                        position: 'absolute', top: -50, right: -50, width: '200px', height: '200px',
                        background: 'radial-gradient(circle, rgba(255,255,255,0.2) 0%, transparent 60%)',
                        borderRadius: '50%'
                    }} />

                    {/* Top Row */}
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', zIndex: 1 }}>
                        <div style={{ fontSize: '18px', fontWeight: '800', letterSpacing: '1px' }}>Trish<span style={{ color: '#FFE4E6' }}>Pay</span></div>
                        <FaWallet size={24} style={{ opacity: 0.9 }} />
                    </div>

                    {/* Bottom Row */}
                    <div>
                        <p style={{ opacity: 0.8, fontSize: '14px', marginBottom: '8px', fontWeight: '500' }}>Total Balance</p>
                        <h2 style={{ fontSize: '36px', fontWeight: '900', letterSpacing: '1px', margin: 0 }}>
                            ₹{balance.toLocaleString('en-IN', { minimumFractionDigits: 2 })}
                        </h2>
                    </div>
                </div>

                {/* Actions Row */}
                <div style={{ display: 'flex', gap: '12px', marginBottom: '40px' }}>
                    <PremiumButton
                        text="Add Money"
                        type="gradient"
                        icon={FaPlusCircle}
                        onClick={() => showToast('Payment gateway integration coming soon!', 'info')}
                        fullWidth
                        style={{ height: '56px', borderRadius: '16px', fontSize: '15px', fontWeight: '700' }}
                    />
                    <button
                        onClick={() => showToast('Withdrawal feature coming soon!', 'info')}
                        style={{
                            flex: 1, height: '56px', borderRadius: '16px', fontSize: '15px', fontWeight: '700',
                            background: '#FFFFFF', border: '1px solid #E5E7EB', color: AppTheme.colors.textPrimary,
                            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px',
                            cursor: 'pointer', boxShadow: '0 2px 5px rgba(0,0,0,0.02)'
                        }}
                    >
                        <FaArrowDown size={14} /> Withdraw
                    </button>
                </div>
            </motion.div>

            {/* Transactions */}
            <motion.div
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.2 }}
            >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                    <h3 style={{ fontSize: '18px', fontWeight: '700', color: AppTheme.colors.textPrimary, margin: 0 }}>Recent Transactions</h3>
                    <FaHistory color={AppTheme.colors.textTertiary} />
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                    {loading ? <p style={{ textAlign: 'center', color: AppTheme.colors.textSecondary }}>Loading...</p> : transactions.map((t, i) => (
                        <div key={i} style={{ padding: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: '#FFFFFF', borderRadius: '16px', border: '1px solid #E5E7EB', boxShadow: '0 2px 5px rgba(0,0,0,0.02)' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                                <div style={{
                                    width: '44px', height: '44px', borderRadius: '12px',
                                    background: t.type === 'credit' ? `${AppTheme.colors.successGreen}15` : '#FEF2F2',
                                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    color: t.type === 'credit' ? AppTheme.colors.successGreen : '#EF4444'
                                }}>
                                    {t.type === 'credit' ? <FaArrowDown size={16} /> : <FaArrowUp size={16} />}
                                </div>
                                <div>
                                    <p style={{ fontWeight: '700', fontSize: '15px', margin: '0 0 4px 0', color: AppTheme.colors.textPrimary }}>{t.description}</p>
                                    <p style={{ fontSize: '13px', color: AppTheme.colors.textTertiary, margin: 0, fontWeight: '500' }}>{t.date}</p>
                                </div>
                            </div>
                            <div style={{
                                fontWeight: '800', fontSize: '16px',
                                color: t.type === 'credit' ? AppTheme.colors.successGreen : AppTheme.colors.textPrimary
                            }}>
                                {t.type === 'credit' ? '+' : '-'}₹{t.amount}
                            </div>
                        </div>
                    ))}
                    {transactions.length === 0 && !loading && (
                        <p style={{ textAlign: 'center', color: AppTheme.colors.textSecondary, marginTop: '20px' }}>No recent transactions.</p>
                    )}
                </div>
            </motion.div>
        </div>
    );
};

export default Wallet;
