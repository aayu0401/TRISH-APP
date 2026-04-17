import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaBrain, FaArrowRight, FaSpinner, FaArrowLeft } from 'react-icons/fa';
import GlassCard from '../components/common/GlassCard';
import PremiumButton from '../components/common/PremiumButton';
import { AppTheme } from '../theme/AppTheme';
import { aiService } from '../services/ai.service';
import { useNavigate } from 'react-router-dom';

const QUESTIONS = [
    {
        id: 1,
        question: "How do you prefer to spend your perfect weekend?",
        options: ["Exploring a new city", "Reading a book at home", "Partying with friends", "Working on a passion project"],
        trait: "E"
    },
    {
        id: 2,
        question: "When making big decisions, you rely mostly on:",
        options: ["Logic & Facts", "Gut Feeling & Intuition", "Advice from others", "Past experiences"],
        trait: "T"
    },
    {
        id: 3,
        question: "In a relationship, what matters most to you?",
        options: ["Deep conversations", "Shared adventures", "Physical affection", "Mutual ambition"],
        trait: "F"
    }
];

const PersonalityAnalysisResult = ({ result, onFindMatches }) => {
    if (!result) return null;

    return (
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} style={{ textAlign: 'center' }}>
            <div style={{
                width: '120px', height: '120px', margin: '0 auto 24px',
                background: AppTheme.gradients.primary,
                borderRadius: '50%',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: '0 10px 30px rgba(253, 41, 123, 0.3)'
            }}>
                <div style={{ width: '110px', height: '110px', background: '#FFFFFF', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <span style={{ fontSize: '32px', fontWeight: '900', color: AppTheme.colors.primaryPink }}>{result.type}</span>
                </div>
            </div>
            <h2 style={{ marginBottom: '12px', fontSize: '28px', fontWeight: '800', color: AppTheme.colors.textPrimary }}>{result.title}</h2>
            <p style={{ color: AppTheme.colors.textSecondary, marginBottom: '24px', fontSize: '16px', lineHeight: '1.6' }}>
                {result.desc}
            </p>
            <div style={{ padding: '20px', background: '#F9FAFB', borderRadius: '16px', marginBottom: '32px', border: '1px solid #E5E7EB' }}>
                <p style={{ fontSize: '14px', color: AppTheme.colors.textPrimary, margin: 0, fontWeight: '700' }}>
                    Best Matches: <span style={{ color: AppTheme.colors.primaryPink }}>{result.matchType}</span>
                </p>
            </div>
            <PremiumButton text="Find Compatible Matches" type="gradient" fullWidth onClick={onFindMatches} />
        </motion.div>
    );
};

const PersonalityLoadingView = () => (
    <div style={{ textAlign: 'center', padding: '60px 0' }}>
        <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 1.5, repeat: Infinity, ease: "linear" }}
            style={{ display: 'inline-block', marginBottom: '32px' }}
        >
            <div style={{ width: '60px', height: '60px', borderRadius: '50%', border: `4px solid ${AppTheme.colors.primaryPink}30`, borderTopColor: AppTheme.colors.primaryPink }} />
        </motion.div>
        <h3 style={{ fontSize: '24px', fontWeight: '800', color: AppTheme.colors.textPrimary, marginBottom: '8px' }}>Analyzing Personality...</h3>
        <p style={{ color: AppTheme.colors.textSecondary, fontSize: '15px' }}>Finding your perfect archetype</p>
    </div>
);

const Personality = () => {
    const navigate = useNavigate();
    const [currentQuestion, setCurrentQuestion] = useState(0);
    const [answers, setAnswers] = useState({});
    const [isCompleted, setIsCompleted] = useState(false);
    const [isAnalyzing, setIsAnalyzing] = useState(false);
    const [result, setResult] = useState(null);

    const handleAnswer = (option) => {
        const newAnswers = { ...answers, [currentQuestion]: option };
        setAnswers(newAnswers);

        if (currentQuestion < QUESTIONS.length - 1) {
            setTimeout(() => {
                setCurrentQuestion(prev => prev + 1);
            }, 300);
        } else {
            analyzePersonality(newAnswers);
        }
    };

    const analyzePersonality = async (finalAnswers) => {
        setIsCompleted(true);
        setIsAnalyzing(true);

        const isOnline = await aiService.checkHealth();

        setTimeout(() => {
            const firstAnswer = finalAnswers[0] || "";
            const isExtrovert = firstAnswer.includes("Exploring") || firstAnswer.includes("Partying");
            const type = isExtrovert ? "ENFP" : "INFJ";

            const resultData = {
                type: type,
                title: type === "INFJ" ? "The Advocate" : "The Campaigner",
                desc: type === "INFJ"
                    ? "You are insightful, creative, and passionate. You seek deep connections and meaningful, authentic relationships."
                    : "You are an enthusiastic, creative and sociable free spirit, who can always find a reason to smile and energize others.",
                matchType: type === "INFJ" ? "ENFP, ENTP" : "INFJ, INTJ"
            };

            setResult(resultData);
            setIsAnalyzing(false);
        }, 2000);
    };

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            padding: '24px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center'
        }}>
            <div style={{
                background: '#FFFFFF',
                padding: '40px 32px',
                maxWidth: '500px',
                width: '100%',
                borderRadius: '32px',
                boxShadow: '0 20px 40px rgba(0,0,0,0.05)',
                border: '1px solid #E5E7EB'
            }}>
                {!isCompleted ? (
                    <AnimatePresence mode="wait">
                        <motion.div
                            key={currentQuestion}
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                            transition={{ duration: 0.2 }}
                        >
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
                                <motion.button
                                    whileTap={{ scale: 0.9 }}
                                    onClick={() => currentQuestion > 0 ? setCurrentQuestion(prev => prev - 1) : navigate(-1)}
                                    style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#F3F4F6', display: 'flex', alignItems: 'center', justifyContent: 'center', color: AppTheme.colors.textPrimary, border: 'none', cursor: 'pointer' }}
                                >
                                    <FaArrowLeft size={14} />
                                </motion.button>
                                <span style={{ color: AppTheme.colors.primaryPink, fontWeight: '700', fontSize: '15px', background: `${AppTheme.colors.primaryPink}15`, padding: '6px 12px', borderRadius: '20px' }}>
                                    {currentQuestion + 1} of {QUESTIONS.length}
                                </span>
                            </div>

                            <div style={{ width: '100%', height: '6px', background: '#F3F4F6', borderRadius: '3px', marginBottom: '40px', overflow: 'hidden' }}>
                                <motion.div
                                    animate={{ width: `${((currentQuestion) / QUESTIONS.length) * 100}%` }}
                                    style={{ height: '100%', background: AppTheme.gradients.primary }}
                                />
                            </div>

                            <h3 style={{ fontSize: '26px', fontWeight: '800', marginBottom: '32px', lineHeight: '1.4', color: AppTheme.colors.textPrimary }}>
                                {QUESTIONS[currentQuestion].question}
                            </h3>

                            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                                {QUESTIONS[currentQuestion].options.map((option, i) => {
                                    const isSelected = answers[currentQuestion] === option;
                                    return (
                                        <motion.button
                                            key={i}
                                            whileHover={{ scale: 1.02, y: -2 }}
                                            whileTap={{ scale: 0.98 }}
                                            onClick={() => handleAnswer(option)}
                                            style={{
                                                padding: '20px 24px',
                                                background: isSelected ? AppTheme.colors.primaryPink : '#FFFFFF',
                                                border: isSelected ? 'none' : '1px solid #E5E7EB',
                                                borderRadius: '20px',
                                                color: isSelected ? '#FFFFFF' : AppTheme.colors.textPrimary,
                                                fontSize: '16px',
                                                fontWeight: '600',
                                                textAlign: 'left',
                                                cursor: 'pointer',
                                                display: 'flex',
                                                justifyContent: 'space-between',
                                                alignItems: 'center',
                                                boxShadow: isSelected ? '0 10px 20px rgba(253, 41, 123, 0.2)' : '0 2px 10px rgba(0,0,0,0.02)',
                                                transition: 'all 0.2s'
                                            }}
                                        >
                                            {option}
                                            {isSelected && <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }}><FaArrowRight size={14} color="#FFFFFF" /></motion.div>}
                                        </motion.button>
                                    );
                                })}
                            </div>
                        </motion.div>
                    </AnimatePresence>
                ) : isAnalyzing ? (
                    <PersonalityLoadingView />
                ) : (
                    <PersonalityAnalysisResult result={result} onFindMatches={() => navigate('/home')} />
                )}
            </div>
        </div>
    );
};

export default Personality;
