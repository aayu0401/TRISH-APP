import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaArrowLeft, FaCamera, FaMagic, FaCheck, FaTimes, FaPlus, FaBriefcase, FaGraduationCap, FaStar, FaGlobe, FaWineGlassAlt, FaSmoking, FaChild, FaPaw, FaSpinner } from 'react-icons/fa';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useToast } from '../context/ToastContext';
import { userService } from '../services/user.service';
import { aiService } from '../services/ai.service';
import { AppTheme } from '../theme/AppTheme';

const ProfileEdit = () => {
    const { user: authUser, setUser } = useAuth();
    const navigate = useNavigate();
    const { showToast } = useToast();
    const [loading, setLoading] = useState(false);
    const [isGenerating, setIsGenerating] = useState(false);

    const [form, setForm] = useState({
        name: authUser?.name || '',
        bio: authUser?.bio || '',
        interests: authUser?.interests || [],
        lifestyle: authUser?.lifestyle || {
            job: '',
            education: '',
            zodiac: '',
            languages: [],
            drinking: '',
            smoking: '',
            kids: '',
            pets: ''
        }
    });

    const [newInterest, setNewInterest] = useState('');
    const [selectedTone, setSelectedTone] = useState('witty');

    const handleSave = async () => {
        setLoading(true);
        try {
            const updatedUser = await userService.updateProfile(form);
            setUser(updatedUser);
            showToast("Profile updated successfully! ✨", "success");
            navigate('/profile');
        } catch (error) {
            showToast("Failed to update profile.", "error");
        } finally {
            setLoading(false);
        }
    };

    const handleGenerateBio = async () => {
        setIsGenerating(true);
        try {
            const traits = {
                mbti: authUser?.mbti || 'INTJ',
                enneagram: authUser?.enneagram || '5w6',
                interests: form.interests,
                lifestyle: form.lifestyle,
                tone: selectedTone
            };
            const aiBio = await aiService.generateBio(traits);
            setForm(prev => ({ ...prev, bio: aiBio }));
            showToast("AI Bio Generated! 🤖✨", "success");
        } catch (error) {
            showToast("AI Generation failed. Try again.", "error");
        } finally {
            setIsGenerating(false);
        }
    };

    const addInterest = () => {
        if (newInterest && !form.interests.includes(newInterest)) {
            setForm(prev => ({ ...prev, interests: [...prev.interests, newInterest] }));
            setNewInterest('');
        }
    };

    const removeInterest = (interest) => {
        setForm(prev => ({ ...prev, interests: prev.interests.filter(i => i !== interest) }));
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            paddingBottom: '120px'
        }}>
            {/* Header */}
            <div style={{
                position: 'fixed', top: 0, left: 0, right: 0, zIndex: 1000,
                padding: '20px', display: 'flex', justifyContent: 'space-between',
                alignItems: 'center', background: 'rgba(255, 255, 255, 0.9)',
                backdropFilter: 'blur(20px)', borderBottom: '1px solid #F3F4F6'
            }}>
                <motion.div whileTap={{ scale: 0.9 }} onClick={() => navigate(-1)} style={{ cursor: 'pointer', color: AppTheme.colors.textPrimary }}>
                    <FaArrowLeft size={20} />
                </motion.div>
                <h2 style={{ fontSize: '18px', fontWeight: '800', margin: 0 }}>Edit Profile</h2>
                <motion.button
                    whileTap={{ scale: 0.95 }}
                    onClick={handleSave}
                    disabled={loading}
                    style={{
                        background: 'none', border: 'none', color: AppTheme.colors.primaryPink,
                        fontWeight: '800', fontSize: '16px', cursor: 'pointer'
                    }}
                >
                    {loading ? <FaSpinner className="spin" /> : 'Save'}
                </motion.button>
            </div>

            <main style={{ paddingTop: '100px', padding: '100px 24px 24px' }}>
                {/* Photo Upload Placeholder */}
                <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '32px' }}>
                    <div style={{ position: 'relative' }}>
                        <img
                            src={authUser?.photos?.[0] || 'https://via.placeholder.com/150'}
                            style={{ width: '120px', height: '120px', borderRadius: '32px', objectFit: 'cover', border: `4px solid #fff`, boxShadow: '0 10px 25px rgba(0,0,0,0.1)' }}
                        />
                        <div style={{
                            position: 'absolute', bottom: '-10px', right: '-10px',
                            width: '40px', height: '40px', borderRadius: '50%',
                            background: AppTheme.colors.primaryPink, color: '#fff',
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            boxShadow: '0 4px 10px rgba(253, 41, 123, 0.3)', cursor: 'pointer'
                        }}>
                            <FaCamera size={16} />
                        </div>
                    </div>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
                    {/* Bio Section with AI */}
                    <section>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                            <label style={{ fontSize: '14px', fontWeight: '800', color: AppTheme.colors.textSecondary, textTransform: 'uppercase', letterSpacing: '1px' }}>About Me</label>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                <select
                                    value={selectedTone}
                                    onChange={(e) => setSelectedTone(e.target.value)}
                                    style={{
                                        padding: '4px 8px', borderRadius: '8px', border: '1px solid #E5E7EB',
                                        fontSize: '12px', fontWeight: '600', outline: 'none'
                                    }}
                                >
                                    <option value="witty">Witty</option>
                                    <option value="romantic">Romantic</option>
                                    <option value="casual">Casual</option>
                                    <option value="professional">Professional</option>
                                </select>
                                <motion.button
                                    whileHover={{ scale: 1.05 }}
                                    whileTap={{ scale: 0.95 }}
                                    onClick={handleGenerateBio}
                                    disabled={isGenerating}
                                    style={{
                                        display: 'flex', alignItems: 'center', gap: '6px',
                                        background: 'linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%)',
                                        padding: '6px 12px', borderRadius: '12px', border: 'none',
                                        color: '#fff', fontSize: '11px', fontWeight: '800', cursor: 'pointer',
                                        boxShadow: '0 4px 10px rgba(99, 102, 241, 0.3)'
                                    }}
                                >
                                    {isGenerating ? <FaSpinner className="spin" size={12} /> : <FaMagic size={12} />}
                                    AI GEN
                                </motion.button>
                            </div>
                        </div>
                        <textarea
                            value={form.bio}
                            onChange={(e) => setForm(prev => ({ ...prev, bio: e.target.value }))}
                            placeholder="Write something about yourself..."
                            style={{
                                width: '100%', minHeight: '120px', padding: '16px', borderRadius: '20px',
                                background: '#fff', border: '1px solid #E5E7EB', fontSize: '15px',
                                lineHeight: '1.6', outline: 'none', resize: 'vertical'
                            }}
                        />
                    </section>

                    {/* Interests Chips */}
                    <section>
                        <label style={{ fontSize: '14px', fontWeight: '800', color: AppTheme.colors.textSecondary, textTransform: 'uppercase', letterSpacing: '1px', display: 'block', marginBottom: '16px' }}>Interests</label>
                        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '16px' }}>
                            {form.interests.map(interest => (
                                <motion.div
                                    key={interest}
                                    initial={{ scale: 0.8 }}
                                    animate={{ scale: 1 }}
                                    style={{
                                        padding: '8px 16px', borderRadius: '20px', background: '#fff',
                                        border: `1px solid ${AppTheme.colors.primaryPink}40`,
                                        color: AppTheme.colors.primaryPink, fontSize: '13px', fontWeight: '700',
                                        display: 'flex', alignItems: 'center', gap: '8px'
                                    }}
                                >
                                    {interest}
                                    <FaTimes onClick={() => removeInterest(interest)} style={{ cursor: 'pointer', opacity: 0.6 }} />
                                </motion.div>
                            ))}
                        </div>
                        <div style={{ position: 'relative' }}>
                            <input
                                type="text"
                                placeholder="Add an interest..."
                                value={newInterest}
                                onChange={(e) => setNewInterest(e.target.value)}
                                onKeyPress={(e) => e.key === 'Enter' && addInterest()}
                                style={{
                                    width: '100%', padding: '16px 50px 16px 20px', borderRadius: '20px',
                                    background: '#fff', border: '1px solid #E5E7EB', fontSize: '15px',
                                    outline: 'none'
                                }}
                            />
                            <div
                                onClick={addInterest}
                                style={{
                                    position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)',
                                    width: '32px', height: '32px', borderRadius: '50%',
                                    background: AppTheme.colors.primaryPink, color: '#fff',
                                    display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer'
                                }}
                            >
                                <FaPlus size={12} />
                            </div>
                        </div>
                    </section>

                    {/* Lifestyle Essentials */}
                    <section>
                        <label style={{ fontSize: '14px', fontWeight: '800', color: AppTheme.colors.textSecondary, textTransform: 'uppercase', letterSpacing: '1px', display: 'block', marginBottom: '16px' }}>The Essentials</label>
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '12px' }}>
                            <GridInput icon={FaBriefcase} label="Work" value={form.lifestyle.job} onChange={(val) => setForm(p => ({ ...p, lifestyle: { ...p.lifestyle, job: val } }))} />
                            <GridInput icon={FaGraduationCap} label="Education" value={form.lifestyle.education} onChange={(val) => setForm(p => ({ ...p, lifestyle: { ...p.lifestyle, education: val } }))} />
                            <GridInput icon={FaStar} label="Zodiac" value={form.lifestyle.zodiac} onChange={(val) => setForm(p => ({ ...p, lifestyle: { ...p.lifestyle, zodiac: val } }))} />
                            <GridInput icon={FaWineGlassAlt} label="Drinking" value={form.lifestyle.drinking} onChange={(val) => setForm(p => ({ ...p, lifestyle: { ...p.lifestyle, drinking: val } }))} />
                            <GridInput icon={FaSmoking} label="Smoking" value={form.lifestyle.smoking} onChange={(val) => setForm(p => ({ ...p, lifestyle: { ...p.lifestyle, smoking: val } }))} />
                            <GridInput icon={FaChild} label="Kids" value={form.lifestyle.kids} onChange={(val) => setForm(p => ({ ...p, lifestyle: { ...p.lifestyle, kids: val } }))} />
                            <GridInput icon={FaPaw} label="Pets" value={form.lifestyle.pets} onChange={(val) => setForm(p => ({ ...p, lifestyle: { ...p.lifestyle, pets: val } }))} />
                        </div>
                    </section>
                </div>
            </main>
        </div>
    );
};

const GridInput = ({ icon: Icon, label, value, onChange }) => (
    <div style={{
        display: 'flex', alignItems: 'center', gap: '12px',
        padding: '12px 16px', borderRadius: '16px', background: '#FFFFFF',
        border: '1px solid #E5E7EB'
    }}>
        <Icon color={AppTheme.colors.textSecondary} size={16} />
        <div style={{ flex: 1 }}>
            <span style={{ fontSize: '11px', fontWeight: '800', color: AppTheme.colors.textTertiary, display: 'block' }}>{label}</span>
            <input
                type="text"
                value={value}
                onChange={(e) => onChange(e.target.value)}
                style={{
                    width: '100%', border: 'none', background: 'transparent',
                    fontSize: '15px', fontWeight: '600', color: AppTheme.colors.textPrimary,
                    outline: 'none', padding: '2px 0'
                }}
            />
        </div>
    </div>
);

export default ProfileEdit;
