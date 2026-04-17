import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaShieldAlt, FaCamera, FaCheckCircle, FaExclamationTriangle, FaArrowLeft, FaIdCard, FaUserCheck, FaFileAlt } from 'react-icons/fa';
import { AppTheme } from '../theme/AppTheme';
import { useNavigate } from 'react-router-dom';
import PremiumButton from '../components/common/PremiumButton';
import { useToast } from '../context/ToastContext';

const KYC_STEPS = [
    {
        id: 'start',
        title: 'Get Verified',
        desc: 'Join the circle of trust. Verified profiles get 3x more matches and priority placement.',
        icon: FaShieldAlt,
        color: AppTheme.colors.brandBlue
    },
    {
        id: 'document',
        title: 'Upload ID',
        desc: 'Take a clear photo of your ID card or Passport for identity confirmation.',
        icon: FaIdCard,
        color: '#6366F1'
    },
    {
        id: 'selfie',
        title: 'Liveness Check',
        desc: 'Take a selfie to prove this is your account. We use AI to match it with your ID.',
        icon: FaCamera,
        color: AppTheme.colors.primaryPink
    },
    {
        id: 'processing',
        title: 'Verifying...',
        desc: 'Our AI engine is currently validating your identity documents.',
        icon: FaUserCheck,
        color: '#FBBF24'
    },
    {
        id: 'success',
        title: 'Verified!',
        desc: 'Congratulations! Your profile now bears the blue checkmark of trust.',
        icon: FaCheckCircle,
        color: AppTheme.colors.successGreen
    }
];

const KYCVerification = () => {
    const [currentStep, setCurrentStep] = useState(0);
    const [capturedSelfie, setCapturedSelfie] = useState(null);
    const [capturedDoc, setCapturedDoc] = useState(null);
    const [isScanning, setIsScanning] = useState(false);
    const videoRef = useRef(null);
    const navigate = useNavigate();
    const { showToast } = useToast();

    const nextStep = () => setCurrentStep(prev => prev + 1);

    const startCamera = async () => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ video: true });
            if (videoRef.current) {
                videoRef.current.srcObject = stream;
            }
        } catch (err) {
            console.error("Camera access denied:", err);
            showToast("Camera access is required for verification.", "error");
        }
    };

    const takePhoto = () => {
        setIsScanning(true);
        setTimeout(() => {
            setCapturedSelfie("https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600");
            setIsScanning(false);
            nextStep();
        }, 3000);
    };

    const handleFileUpload = (e) => {
        const file = e.target.files[0];
        if (file) {
            setCapturedDoc(URL.createObjectURL(file));
            nextStep();
        }
    };

    const simulateProcessing = () => {
        setTimeout(() => {
            nextStep();
        }, 5000);
    };

    useEffect(() => {
        if (KYC_STEPS[currentStep].id === 'selfie' && !capturedSelfie) {
            startCamera();
        }
        if (KYC_STEPS[currentStep].id === 'processing') {
            simulateProcessing();
        }
    }, [currentStep, capturedSelfie]);

    const currentStepData = KYC_STEPS[currentStep];

    return (
        <div style={{
            minHeight: '100vh',
            background: AppTheme.colors.lightBackground,
            color: AppTheme.colors.textPrimary,
            padding: '24px',
            display: 'flex',
            flexDirection: 'column',
            position: 'relative',
            overflow: 'hidden'
        }}>
            {/* Header */}
            <header style={{ marginBottom: '40px', display: 'flex', alignItems: 'center', gap: '16px' }}>
                <motion.button
                    whileTap={{ scale: 0.9 }}
                    onClick={() => currentStep === 0 ? navigate(-1) : setCurrentStep(prev => prev - 1)}
                    style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#FFF', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 10px rgba(0,0,0,0.05)', cursor: 'pointer' }}
                >
                    <FaArrowLeft size={16} />
                </motion.button>
                <h1 style={{ fontSize: '20px', fontWeight: '800', margin: 0 }}>Identity Verification</h1>
            </header>

            <AnimatePresence mode="wait">
                <motion.div
                    key={currentStep}
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: -20 }}
                    style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
                >
                    <div style={{ textAlign: 'center', marginBottom: '48px' }}>
                        <div style={{
                            width: '80px', height: '80px', borderRadius: '50%',
                            background: `${currentStepData.color}20`,
                            color: currentStepData.color,
                            display: 'flex', alignItems: 'center', justifyContent: 'center',
                            margin: '0 auto 24px'
                        }}>
                            <currentStepData.icon size={36} />
                        </div>
                        <h2 style={{ fontSize: '28px', fontWeight: '800', marginBottom: '12px' }}>{currentStepData.title}</h2>
                        <p style={{ color: AppTheme.colors.textSecondary, fontSize: '16px', lineHeight: '1.6', maxWidth: '300px', margin: '0 auto' }}>
                            {currentStepData.desc}
                        </p>
                    </div>

                    {/* Step Specific Content */}
                    <div style={{ flex: 1 }}>
                        {currentStepData.id === 'start' && (
                            <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                                <FeatureItem icon={FaShieldAlt} text="Verified Badge on Profile" />
                                <FeatureItem icon={FaUserCheck} text="Trust with Potential Matches" />
                                <FeatureItem icon={FaCheckCircle} text="Priority in Search Feed" />
                            </div>
                        )}

                        {currentStepData.id === 'document' && (
                            <div style={{ textAlign: 'center' }}>
                                <input
                                    type="file"
                                    id="doc-upload"
                                    hidden
                                    accept="image/*"
                                    onChange={handleFileUpload}
                                />
                                <label htmlFor="doc-upload" style={{ cursor: 'pointer' }}>
                                    <div style={{
                                        width: '100%', height: '200px', borderRadius: '24px',
                                        border: '2px dashed #E5E7EB', display: 'flex',
                                        flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                                        background: '#FFF'
                                    }}>
                                        <FaFileAlt size={40} color="#E5E7EB" style={{ marginBottom: '12px' }} />
                                        <span style={{ fontWeight: '700', color: AppTheme.colors.textSecondary }}>Tap to upload or take photo</span>
                                    </div>
                                </label>
                            </div>
                        )}

                        {currentStepData.id === 'selfie' && (
                            <div style={{ position: 'relative', width: '100%', height: '350px', borderRadius: '32px', overflow: 'hidden', background: '#000' }}>
                                <video
                                    ref={videoRef}
                                    autoPlay
                                    playsInline
                                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                                />
                                {/* Face Overlay Guide */}
                                <div style={{
                                    position: 'absolute', inset: 0,
                                    border: '40px solid rgba(0,0,0,0.5)',
                                    display: 'flex', alignItems: 'center', justifyContent: 'center'
                                }}>
                                    <div style={{
                                        width: '240px', height: '300px', borderRadius: '150px / 180px',
                                        border: `2px solid ${isScanning ? AppTheme.colors.primaryPink : '#FFF'}`,
                                        boxShadow: '0 0 0 1000px rgba(0,0,0,0.3)'
                                    }} />
                                </div>

                                {isScanning && (
                                    <motion.div
                                        animate={{ top: ['10%', '90%', '10%'] }}
                                        transition={{ duration: 2, repeat: Infinity }}
                                        style={{
                                            position: 'absolute', left: '15%', right: '15%',
                                            height: '2px', background: AppTheme.colors.primaryPink,
                                            boxShadow: `0 0 20px ${AppTheme.colors.primaryPink}`,
                                            zIndex: 10
                                        }}
                                    />
                                )}
                            </div>
                        )}

                        {currentStepData.id === 'processing' && (
                            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%' }}>
                                <div style={{ position: 'relative', width: '200px', height: '200px' }}>
                                    <motion.div
                                        animate={{ rotate: 360 }}
                                        transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                                        style={{
                                            position: 'absolute', inset: 0, borderRadius: '50%',
                                            border: '4px solid transparent',
                                            borderTopColor: AppTheme.colors.primaryPink,
                                            borderRightColor: AppTheme.colors.brandBlue
                                        }}
                                    />
                                    <div style={{
                                        position: 'absolute', inset: '10px', borderRadius: '50%',
                                        overflow: 'hidden', border: '1px solid #E5E7EB'
                                    }}>
                                        <img src={capturedSelfie} alt="Processing" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                    </div>
                                    <motion.div
                                        animate={{ scale: [1, 1.1, 1], opacity: [0.5, 1, 0.5] }}
                                        transition={{ duration: 2, repeat: Infinity }}
                                        style={{
                                            position: 'absolute', top: '-10px', right: '-10px',
                                            background: '#FBBF24', color: '#FFF', padding: '10px',
                                            borderRadius: '50%', boxShadow: '0 4px 10px rgba(0,0,0,0.1)'
                                        }}
                                    >
                                        <FaUserCheck size={16} />
                                    </motion.div>
                                </div>
                                <div style={{ marginTop: '40px', textAlign: 'center' }}>
                                    <div style={{ fontSize: '14px', fontWeight: '800', color: AppTheme.colors.textTertiary, letterSpacing: '2px', marginBottom: '8px' }}>NEURAL ENGINE ACTIVE</div>
                                    <div style={{ width: '200px', height: '4px', background: '#E5E7EB', borderRadius: '2px', overflow: 'hidden' }}>
                                        <motion.div
                                            animate={{ width: '100%' }}
                                            transition={{ duration: 5 }}
                                            style={{ height: '100%', background: AppTheme.gradients.primary }}
                                        />
                                    </div>
                                </div>
                            </div>
                        )}

                        {currentStepData.id === 'success' && (
                            <div style={{ textAlign: 'center' }}>
                                <motion.div
                                    initial={{ scale: 0 }}
                                    animate={{ scale: 1 }}
                                    transition={{ type: 'spring', damping: 10 }}
                                    style={{
                                        width: '120px', height: '120px', borderRadius: '50%',
                                        background: AppTheme.colors.successGreen, color: '#FFF',
                                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                                        margin: '0 auto 32px', boxShadow: '0 10px 30px rgba(16, 185, 129, 0.3)'
                                    }}
                                >
                                    <FaCheckCircle size={60} />
                                </motion.div>
                                <p style={{ fontSize: '16px', color: AppTheme.colors.textSecondary, marginBottom: '32px' }}>
                                    Your identity has been confirmed. The verification badge will appear on your profile immediately.
                                </p>
                            </div>
                        )}
                    </div>

                    {/* Footer Actions */}
                    <div style={{ marginTop: '32px' }}>
                        {currentStepData.id === 'start' && (
                            <PremiumButton text="Start Verification" type="gradient" fullWidth onClick={nextStep} />
                        )}
                        {currentStepData.id === 'selfie' && (
                            <PremiumButton
                                text={isScanning ? "Capturing..." : "Capture Selfie"}
                                type="gradient"
                                fullWidth
                                onClick={takePhoto}
                                isLoading={isScanning}
                            />
                        )}
                        {currentStepData.id === 'success' && (
                            <PremiumButton text="Back to Profile" type="gradient" fullWidth onClick={() => navigate('/profile')} />
                        )}
                    </div>
                </motion.div>
            </AnimatePresence>
        </div>
    );
};

const FeatureItem = ({ icon: Icon, text }) => (
    <div style={{ display: 'flex', alignItems: 'center', gap: '16px', padding: '16px', borderRadius: '20px', background: '#FFF', border: '1px solid #E5E7EB' }}>
        <div style={{ color: AppTheme.colors.primaryPink }}>
            <Icon size={20} />
        </div>
        <span style={{ fontWeight: '600', color: AppTheme.colors.textPrimary }}>{text}</span>
    </div>
);

export default KYCVerification;
