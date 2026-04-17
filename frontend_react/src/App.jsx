import React, { lazy, Suspense } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { motion, AnimatePresence } from 'framer-motion';

// Pages (lazy loaded for faster initial load)
const LandingPage = lazy(() => import('./pages/LandingPage'));
const Login = lazy(() => import('./pages/Login'));
const Register = lazy(() => import('./pages/Register'));
const Home = lazy(() => import('./pages/Home'));
const Wallet = lazy(() => import('./pages/Wallet'));
const Gifts = lazy(() => import('./pages/Gifts'));
const Chat = lazy(() => import('./pages/Chat'));
const Matches = lazy(() => import('./pages/Matches'));
const Profile = lazy(() => import('./pages/Profile'));
const KYC = lazy(() => import('./pages/KYC'));
const Subscription = lazy(() => import('./pages/Subscription'));
const Personality = lazy(() => import('./pages/Personality'));
const Onboarding = lazy(() => import('./pages/Onboarding'));
const Settings = lazy(() => import('./pages/Settings'));
const MatchRequests = lazy(() => import('./pages/MatchRequests'));
const BlindDate = lazy(() => import('./pages/BlindDate'));
const VideoCall = lazy(() => import('./pages/VideoCall'));
const ProfileEdit = lazy(() => import('./pages/ProfileEdit'));
const VerifyEmail = lazy(() => import('./pages/VerifyEmail'));

// Components
import BottomNav from './components/layout/BottomNav';
import AIAssistantOverlay from './components/common/AIAssistantOverlay';
import { AppTheme } from './theme/AppTheme';

const PageTransition = ({ children }) => (
  <motion.div
    initial={{ opacity: 0, scale: 0.99, y: 10 }}
    animate={{ opacity: 1, scale: 1, y: 0 }}
    exit={{ opacity: 0, scale: 1.01, y: -10 }}
    transition={{ duration: 0.3, ease: "easeOut" }}
    style={{ width: '100%', minHeight: '100vh', background: AppTheme.colors.lightBackground }}
  >
    {children}
  </motion.div>
);

const RouteFallback = () => (
  <div style={{ height: '100vh', background: AppTheme.colors.lightBackground, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
    <div style={{ textAlign: 'center' }}>
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ duration: 1.5, repeat: Infinity, ease: 'linear' }}
        style={{ width: '64px', height: '64px', border: `4px solid ${AppTheme.colors.primaryPink}20`, borderTopColor: AppTheme.colors.primaryPink, borderRadius: '50%', margin: '0 auto 24px' }}
      />
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: [0.5, 1, 0.5] }}
        transition={{ duration: 2, repeat: Infinity }}
        style={{ fontWeight: '800', fontSize: '15px', color: AppTheme.colors.textPrimary }}>
        Loading...
      </motion.p>
    </div>
  </div>
);

const ErrorFallback = ({ error }) => (
  <div style={{ padding: '40px', background: AppTheme.colors.lightBackground, color: AppTheme.colors.textPrimary, height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', textAlign: 'center' }}>
    <div style={{ width: '80px', height: '80px', borderRadius: '50%', background: '#FEF2F2', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '24px' }}>
      <span style={{ fontSize: '40px' }}>Oops</span>
    </div>
    <h1 style={{ fontSize: '32px', color: AppTheme.colors.textPrimary, fontWeight: '900', marginBottom: '16px', letterSpacing: '-1px' }}>Something went wrong.</h1>
    <p style={{ fontSize: '16px', color: AppTheme.colors.textSecondary, maxWidth: '400px', lineHeight: '1.6' }}>We've encountered an unexpected error while loading this page.</p>
    <div style={{ background: '#F9FAFB', padding: '16px', borderRadius: '16px', border: '1px solid #E5E7EB', marginTop: '24px', fontSize: '12px', color: '#EF4444', textAlign: 'left', width: '100%', maxWidth: '400px', overflowX: 'auto' }}>
      {error.toString()}
    </div>
    <button
      onClick={() => window.location.reload()}
      style={{ marginTop: '32px', padding: '16px 32px', background: AppTheme.gradients.primary, color: 'white', border: 'none', borderRadius: '20px', fontWeight: '800', cursor: 'pointer', boxShadow: '0 10px 25px rgba(253, 41, 123, 0.3)', fontSize: '15px' }}
    >
      Refresh Application
    </button>
  </div>
);

class AppErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }
  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }
  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}

const AppRoutes = () => {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div style={{ height: '100vh', background: AppTheme.colors.lightBackground, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <div style={{ textAlign: 'center' }}>
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 1.5, repeat: Infinity, ease: 'linear' }}
            style={{ width: '64px', height: '64px', border: `4px solid ${AppTheme.colors.primaryPink}20`, borderTopColor: AppTheme.colors.primaryPink, borderRadius: '50%', margin: '0 auto 24px' }}
          />
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: [0.5, 1, 0.5] }}
            transition={{ duration: 2, repeat: Infinity }}
            style={{ fontWeight: '800', fontSize: '15px', color: AppTheme.colors.textPrimary }}>
            Finding matches...
          </motion.p>
        </div>
      </div>
    );
  }

  const isAuthPage = ['/login', '/register', '/', '/onboarding', '/verify-email'].includes(location.pathname);

  // Determine AI Context
  let aiContext = 'general';
  if (location.pathname.includes('/home')) aiContext = 'home';
  if (location.pathname.includes('/chat')) aiContext = 'chat';
  if (location.pathname.includes('/profile')) aiContext = 'profile';

  return (
    <div style={{ minHeight: '100vh', background: AppTheme.colors.lightBackground, position: 'relative' }}>
      <AppErrorBoundary>
        <AnimatePresence mode="wait">
          <Suspense fallback={<RouteFallback />}>
            <Routes location={location} key={location.pathname}>
              <Route path="/" element={<PageTransition><LandingPage /></PageTransition>} />
              <Route path="/onboarding" element={<PageTransition><Onboarding /></PageTransition>} />
              <Route path="/login" element={<PageTransition><Login /></PageTransition>} />
              <Route path="/register" element={<PageTransition><Register /></PageTransition>} />
              <Route path="/verify-email" element={<PageTransition><VerifyEmail /></PageTransition>} />

              {/* Protected */}
              <Route path="/home" element={user ? <PageTransition><Home /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/matches" element={user ? <PageTransition><Matches /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/wallet" element={user ? <PageTransition><Wallet /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/gifts" element={user ? <PageTransition><Gifts /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/profile" element={user ? <PageTransition><Profile /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/settings" element={user ? <PageTransition><Settings /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/chat" element={<Navigate to="/matches" replace />} />
              <Route path="/chat/:matchId" element={user ? <PageTransition><Chat /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/kyc" element={user ? <PageTransition><KYC /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/subscription" element={user ? <PageTransition><Subscription /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/personality" element={user ? <PageTransition><Personality /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/requests" element={user ? <PageTransition><MatchRequests /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/blind-date" element={user ? <PageTransition><BlindDate /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/video-call" element={user ? <PageTransition><VideoCall /></PageTransition> : <Navigate to="/login" replace />} />
              <Route path="/profile/edit" element={user ? <PageTransition><ProfileEdit /></PageTransition> : <Navigate to="/login" replace />} />

              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </Suspense>
        </AnimatePresence>
      </AppErrorBoundary>

      {user && !isAuthPage && <BottomNav />}
      {user && !isAuthPage && <AIAssistantOverlay context={aiContext} />}
    </div>
  );
};

import { ToastProvider } from './context/ToastContext';

function App() {
  return (
    <ToastProvider>
      <AuthProvider>
        <Router>
          <AppRoutes />
        </Router>
      </AuthProvider>
    </ToastProvider>
  );
}

export default App;
