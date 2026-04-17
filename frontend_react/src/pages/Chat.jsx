import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { FaPaperPlane, FaArrowLeft, FaEllipsisV, FaCheckDouble, FaRobot, FaShieldAlt, FaLightbulb, FaExclamationTriangle, FaLock, FaUnlock, FaGift, FaVideo } from 'react-icons/fa';
import { AppTheme } from '../theme/AppTheme';
import { useNavigate, useParams } from 'react-router-dom';
import { messageService } from '../services/message.service';
import { aiService } from '../services/ai.service';
import { giftService } from '../services/gift.service';
import { matchService } from '../services/match.service';
import { websocketService } from '../services/websocket.service';
import { useToast } from '../context/ToastContext';
import { useAuth } from '../context/AuthContext';

const Chat = () => {
    const navigate = useNavigate();
    const { matchId } = useParams();
    const parsedMatchId = matchId ? Number(matchId) : NaN;
    const activeMatchId = Number.isFinite(parsedMatchId) ? parsedMatchId : null;
    const { user: authUser } = useAuth();
    const { showToast } = useToast();
    const [messages, setMessages] = useState([]);
    const [newMessage, setNewMessage] = useState('');
    const [isTyping, setIsTyping] = useState(false);
    const [loading, setLoading] = useState(true);
    const [aiSuggestions, setAiSuggestions] = useState(["How was your weekend?", "Tell me more about your bio!", "Coffee this week?"]);
    const [showAiPanel, setShowAiPanel] = useState(false);
    const [securityAnalysis, setSecurityAnalysis] = useState(null);
    const [decryptedMessages, setDecryptedMessages] = useState(new Set());
    const [match, setMatch] = useState(null);
    const [revealProgress, setRevealProgress] = useState(0);
    const [particlesActive, setParticlesActive] = useState(false);
    const messagesEndRef = useRef(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    };

    useEffect(() => {
        if (activeMatchId == null) {
            setMatch(null);
            setMessages([]);
            setLoading(false);
            return undefined;
        }

        const fetchMatchDetails = async () => {
            try {
                const data = await matchService.getMatchDetails(activeMatchId);
                setMatch(data);
                if (data?.isBlindMatch) {
                    setRevealProgress(data.revealProgress ?? 0);
                }
            } catch (err) {
                console.error("Failed to fetch match details:", err);
            }
        };
        fetchMatchDetails();

        const fetchMessages = async () => {
            try {
                setLoading(true);
                const rawData = await messageService.getMessages(activeMatchId);
                const data = Array.isArray(rawData) ? rawData : [];

                const messagesWithSafety = await Promise.all(data.map(async (msg) => {
                    if (!msg.isMe) {
                        try {
                            const safety = await aiService.checkMessageSafety(msg.text);
                            return { ...msg, safety };
                        } catch (e) {
                            return { ...msg, safety: { is_safe: true } };
                        }
                    }
                    return { ...msg, safety: { is_safe: true } };
                }));

                setMessages(messagesWithSafety);

                try {
                    const analysis = await aiService.analyzeConversationSecurity(`conv_${activeMatchId}`, messagesWithSafety, String(authUser?.id ?? ''), String(activeMatchId));
                    setSecurityAnalysis(analysis);
                } catch (_e) {
                    setSecurityAnalysis(null);
                }

            } catch (error) {
                console.error("Failed to fetch messages:", error);
                setMessages([]);
            } finally {
                setLoading(false);
            }
        };

        fetchMessages();

        // Connect WebSocket
        websocketService.connect(async (msg) => {
            try {
                const incomingMatchId = msg?.matchId ?? msg?.match?.id;
                if (incomingMatchId != null && String(incomingMatchId) !== String(activeMatchId)) return;

                const text = msg?.content ?? msg?.text ?? '';
                const senderId = msg?.senderId ?? msg?.sender?.id;
                const recipientId = msg?.recipientId ?? msg?.receiverId ?? msg?.receiver?.id ?? null;
                const isMe = authUser?.id != null && senderId != null
                    ? String(senderId) === String(authUser.id)
                    : !!msg?.isMe;

                const sentAt = msg?.sentAt ?? msg?.timestamp ?? null;
                const time = sentAt
                    ? new Date(sentAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
                    : new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

                const status = msg?.isRead ? 'read' : 'sent';
                const messageType = msg?.messageType ?? 'TEXT';
                const referenceId = msg?.referenceId ?? null;

                let safety = { is_safe: true, reasons: [] };
                if (!isMe && text) {
                    safety = await aiService.checkMessageSafety(text);
                }

                const formattedMsg = {
                    id: msg?.id ?? Math.random(),
                    text,
                    matchId: incomingMatchId ?? activeMatchId,
                    senderId,
                    recipientId,
                    isMe,
                    time,
                    status,
                    sentAt,
                    safety,
                    messageType,
                    referenceId,
                };

                setMessages((prev) => {
                    if (prev.some((m) => String(m.id) === String(formattedMsg.id))) return prev;
                    return [...prev, formattedMsg];
                });
            } catch (e) {
                console.warn('Failed to handle incoming WebSocket message', e);
            }
        });

        return () => {
            websocketService.disconnect();
        };
    }, [activeMatchId, authUser?.id]);

    useEffect(() => {
        scrollToBottom();
    }, [messages, isTyping]);

    const handleSend = async (textOverride) => {
        const textToSend = typeof textOverride === 'string' ? textOverride : newMessage;
        if (!textToSend.trim()) return;

        const originalText = textToSend;
        setNewMessage('');

        if (activeMatchId == null) {
            showToast('Invalid chat link. Please open a match again.', 'error');
            return;
        }

        const recipientId = match?.opponent?.id;
        if (!recipientId || !authUser?.id) {
            showToast('Could not send message. Please try again.', 'error');
            return;
        }

        // WebSocket send
        const success = websocketService.sendMessage({
            matchId: activeMatchId,
            content: originalText,
            senderId: authUser.id,
            recipientId,
        });

        if (!success) {
            try {
                const sent = await messageService.sendMessage(activeMatchId, originalText);
                const sentMsg = sent ?? {
                    id: Math.random(),
                    text: originalText,
                    senderId: authUser.id,
                    isMe: true,
                    time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                    status: 'sent',
                };
                setMessages((prev) => [...prev, { ...sentMsg, safety: { is_safe: true, reasons: [] } }]);
            } catch (error) {
                console.error('Send message failed:', error);
                showToast('Failed to send message. Please try again.', 'error');
            }
        }

        // Logic for Blind Date Reveal Increment
        if (match?.isBlindMatch && revealProgress < 100) {
            const nextReveal = Math.min(100, revealProgress + 5);
            setRevealProgress(nextReveal);

            // Sync with backend
            matchService.updateRevealProgress(match.id, nextReveal);

            // Special effect for milestones
            if (nextReveal % 25 === 0) {
                setParticlesActive(true);
                setTimeout(() => setParticlesActive(false), 3000);
            }

            // Special toast for clarity milestones
            if (nextReveal === 50) showToast("Neural Clarity increased to 50%! 🌫️✨", "success");
            if (nextReveal === 100) showToast("Total Reveal! You can now see each other clearly. 😍", "success");
        }
    };

    const handleDecrypt = (id) => {
        setDecryptedMessages(prev => new Set([...prev, id]));
    };

    const handleReport = async (msgId) => {
        await messageService.reportMessage(msgId, "AI detected potential scam/harassment");
        showToast("Message reported. Our safety team will review it.", "info");
    };

    const handleAcceptGift = async (transactionId) => {
        try {
            await giftService.acceptGift(transactionId);
            showToast("Gift accepted! 🎁✨", "success");
            // Optionally refresh messages here or wait for WS
        } catch (err) {
            showToast("Failed to accept gift.", "error");
        }
    };

    return (
        <div style={{
            height: '100vh',
            background: AppTheme.colors.lightBackground,
            display: 'flex',
            flexDirection: 'column',
            color: AppTheme.colors.textPrimary,
            overflow: 'hidden'
        }}>
            {/* Header */}
            <div style={{
                padding: '16px',
                background: '#FFFFFF',
                backdropFilter: 'blur(10px)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                borderBottom: '1px solid #E5E7EB',
                zIndex: 10,
                boxShadow: '0 2px 10px rgba(0,0,0,0.02)'
            }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <motion.button
                        whileTap={{ scale: 0.9 }}
                        onClick={() => navigate(-1)}
                        style={{ background: 'none', border: 'none', color: AppTheme.colors.textPrimary, cursor: 'pointer', padding: '4px' }}
                    >
                        <FaArrowLeft size={20} />
                    </motion.button>

                    <div style={{ position: 'relative' }}>
                        <div style={{
                            width: '40px', height: '40px', borderRadius: '50%',
                            background: '#ccc', overflow: 'hidden',
                            boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
                        }}>
                            <img
                                src={match?.avatar || "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100"}
                                alt="Avatar"
                                style={{
                                    width: '100%', height: '100%', objectFit: 'cover',
                                    filter: match?.isBlindMatch ? `blur(${(100 - revealProgress) / 10}px)` : 'none',
                                    transition: 'filter 1s ease'
                                }}
                            />
                        </div>
                        {match?.online && (
                            <span style={{
                                position: 'absolute', bottom: 0, right: 0,
                                width: '12px', height: '12px',
                                borderRadius: '50%', background: AppTheme.colors.successGreen,
                                border: '2px solid #FFFFFF'
                            }} />
                        )}
                    </div>

                    <div>
                        <h3 style={{ fontSize: '16px', fontWeight: '700', margin: 0, display: 'flex', alignItems: 'center', gap: '6px' }}>
                            {match?.isBlindMatch && revealProgress < 100 ? "Mystery Match" : (match?.name || "Sarah")}
                            {match?.isBlindMatch && (
                                <span style={{ fontSize: '10px', background: '#1e1b4b', color: '#fff', padding: '1px 6px', borderRadius: '8px', fontWeight: '800' }}>BLIND</span>
                            )}
                        </h3>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                            {match?.isBlindMatch ? (
                                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                                    <div style={{ width: '60px', height: '4px', background: '#E5E7EB', borderRadius: '2px', overflow: 'hidden' }}>
                                        <motion.div
                                            initial={{ width: 0 }}
                                            animate={{ width: `${revealProgress}%` }}
                                            style={{ height: '100%', background: AppTheme.gradients.primary }}
                                        />
                                    </div>
                                    <span style={{ fontSize: '10px', color: AppTheme.colors.primaryPink, fontWeight: '800' }}>{revealProgress}% Clarified</span>
                                </div>
                            ) : (
                                <>
                                    <FaShieldAlt size={12} color={securityAnalysis?.is_safe ? AppTheme.colors.successGreen : AppTheme.colors.primaryPink} />
                                    <span style={{ fontSize: '12px', color: AppTheme.colors.textTertiary, fontWeight: '500' }}>
                                        {securityAnalysis ? `Safety Score: ${securityAnalysis.overall_safety_score}%` : "Analyzing Safety..."}
                                    </span>
                                </>
                            )}
                        </div>
                    </div>
                </div>

                <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                    <motion.div
                        whileTap={{ scale: 0.9 }}
                        onClick={() => navigate('/gifts')}
                        style={{ color: AppTheme.colors.primaryPink, cursor: 'pointer' }}
                    >
                        <FaGift size={22} title="Send a Gift" />
                    </motion.div>
                    <motion.div
                        whileTap={{ scale: 0.9 }}
                        onClick={() => navigate('/video-call', { state: { matchName: "Sarah", matchImage: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600" } })}
                        style={{ color: AppTheme.colors.brandBlue, cursor: 'pointer' }}
                    >
                        <FaVideo size={22} title="Video Call" />
                    </motion.div>
                    <motion.div
                        whileTap={{ scale: 0.9 }}
                        onClick={() => setShowAiPanel(!showAiPanel)}
                        style={{ color: showAiPanel ? AppTheme.colors.primaryPink : AppTheme.colors.textSecondary, cursor: 'pointer' }}
                    >
                        <FaRobot size={22} title="AI Security Center" />
                    </motion.div>
                    <FaEllipsisV style={{ color: AppTheme.colors.textTertiary, cursor: 'pointer' }} />
                </div>
            </div>

            {/* AI Security Panel */}
            <AnimatePresence>
                {showAiPanel && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        style={{ background: '#FFFFFF', borderBottom: '1px solid #E5E7EB', overflow: 'hidden', boxShadow: '0 4px 12px rgba(0,0,0,0.05)' }}
                    >
                        <div style={{ padding: '20px' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '15px' }}>
                                <FaShieldAlt color={AppTheme.colors.primaryPink} size={20} />
                                <h4 style={{ margin: 0, fontSize: '16px', fontWeight: '700', color: AppTheme.colors.textPrimary }}>Neural Security Audit</h4>
                            </div>

                            {securityAnalysis?.warnings?.length > 0 ? (
                                <div style={{ background: 'rgba(255, 68, 68, 0.05)', border: '1px solid rgba(255, 68, 68, 0.2)', borderRadius: '12px', padding: '12px', marginBottom: '15px' }}>
                                    {securityAnalysis.warnings.map((w, idx) => (
                                        <p key={idx} style={{ color: '#E02424', fontSize: '14px', margin: '4px 0', display: 'flex', alignItems: 'center', gap: '8px', fontWeight: '500' }}>
                                            <FaExclamationTriangle size={14} /> {w}
                                        </p>
                                    ))}
                                </div>
                            ) : (
                                <p style={{ fontSize: '14px', color: AppTheme.colors.successGreen, marginBottom: '15px', fontWeight: '500' }}>
                                    ✔ No immediate threats detected in this conversation.
                                </p>
                            )}

                            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                                <h5 style={{ margin: 0, fontSize: '12px', color: AppTheme.colors.textSecondary, textTransform: 'uppercase', fontWeight: '700' }}>AI Recommendations</h5>
                                {securityAnalysis?.recommendations?.map((rec, i) => (
                                    <div key={i} style={{ fontSize: '14px', display: 'flex', alignItems: 'center', gap: '8px', color: AppTheme.colors.textPrimary }}>
                                        <FaLightbulb size={14} color="#FBBF24" /> {rec}
                                    </div>
                                ))}
                            </div>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Messages */}
            <div style={{ flex: 1, padding: '16px', overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {messages.map((msg) => {
                    const isUnsafe = msg.safety && !msg.safety.is_safe;
                    const isDecrypted = decryptedMessages.has(msg.id);

                    return (
                        <motion.div
                            key={msg.id}
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            style={{
                                alignSelf: msg.isMe ? 'flex-end' : 'flex-start',
                                maxWidth: '75%',
                                display: 'flex',
                                flexDirection: 'column',
                                alignItems: msg.isMe ? 'flex-end' : 'flex-start'
                            }}
                        >
                            <div style={{
                                padding: '12px 16px',
                                borderRadius: '20px',
                                borderBottomRightRadius: msg.isMe ? '4px' : '20px',
                                borderBottomLeftRadius: msg.isMe ? '20px' : '4px',
                                background: msg.isMe ? AppTheme.gradients.primary : '#FFFFFF',
                                border: isUnsafe && !isDecrypted ? '1px solid #EF4444' : (msg.isMe ? 'none' : '1px solid #E5E7EB'),
                                boxShadow: msg.isMe ? '0 4px 10px rgba(253, 41, 123, 0.2)' : '0 2px 5px rgba(0,0,0,0.02)',
                                color: msg.isMe ? '#FFFFFF' : AppTheme.colors.textPrimary,
                                position: 'relative'
                            }}>
                                {msg.messageType === 'GIFT' ? (
                                    <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                            <div style={{ width: '40px', height: '40px', background: 'rgba(255,255,255,0.2)', borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '20px' }}>
                                                🎁
                                            </div>
                                            <div>
                                                <span style={{ fontWeight: '800', fontSize: '14px', display: 'block' }}>New Gift Received!</span>
                                                <p style={{ fontSize: '15px', margin: 0, opacity: 0.9 }}>{msg.text}</p>
                                            </div>
                                        </div>
                                        {!msg.isMe && (
                                            <button
                                                onClick={() => handleAcceptGift(msg.referenceId)}
                                                style={{
                                                    background: '#fff', color: AppTheme.colors.primaryPink,
                                                    border: 'none', padding: '8px 16px', borderRadius: '12px',
                                                    fontSize: '13px', fontWeight: '800', cursor: 'pointer',
                                                    boxShadow: '0 4px 10px rgba(0,0,0,0.1)'
                                                }}
                                            >
                                                Accept Gift
                                            </button>
                                        )}
                                    </div>
                                ) : msg.messageType === 'SYSTEM' ? (
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', opacity: 0.8 }}>
                                        <FaCheckDouble size={14} />
                                        <p style={{ fontSize: '14px', fontStyle: 'italic', margin: 0 }}>{msg.text}</p>
                                    </div>
                                ) : isUnsafe && !isDecrypted ? (
                                    <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#EF4444' }}>
                                            <FaLock size={14} />
                                            <span style={{ fontSize: '14px', fontWeight: '700' }}>Potentially Unsafe Content</span>
                                        </div>
                                        <p style={{ fontSize: '15px', margin: 0, filter: 'blur(5px)', userSelect: 'none' }}>
                                            {msg.text}
                                        </p>
                                        <div style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                                            <button
                                                onClick={() => handleDecrypt(msg.id)}
                                                style={{ background: '#F3F4F6', border: 'none', color: AppTheme.colors.textPrimary, padding: '8px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '600', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px', transition: 'background 0.2s' }}
                                            >
                                                <FaUnlock size={10} /> Reveal
                                            </button>
                                            <button
                                                onClick={() => handleReport(msg.id)}
                                                style={{ background: '#FEF2F2', border: '1px solid #FECACA', color: '#EF4444', padding: '8px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '600', cursor: 'pointer', transition: 'background 0.2s' }}
                                            >
                                                Report
                                            </button>
                                        </div>
                                    </div>
                                ) : (
                                    <>
                                        <p style={{ fontSize: '15px', lineHeight: '1.5', margin: 0 }}>{msg.text}</p>
                                        {isUnsafe && isDecrypted && (
                                            <div style={{ marginTop: '8px', padding: '6px 10px', background: '#FEF2F2', border: '1px solid #FECACA', borderRadius: '8px', fontSize: '11px', color: '#EF4444', display: 'flex', alignItems: 'center', gap: '6px', fontWeight: '500' }}>
                                                <FaExclamationTriangle size={10} /> AI Warning: {msg.safety.reasons?.join(', ')}
                                            </div>
                                        )}
                                    </>
                                )}
                            </div>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '6px', paddingRight: '4px' }}>
                                <span style={{ fontSize: '11px', color: AppTheme.colors.textTertiary, fontWeight: '500' }}>{msg.time}</span>
                                {msg.isMe && (
                                    <FaCheckDouble size={12} color={msg.status === 'read' ? AppTheme.colors.brandBlue : AppTheme.colors.textTertiary} />
                                )}
                            </div>
                        </motion.div>
                    );
                })}

                {isTyping && (
                    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} style={{ alignSelf: 'flex-start', marginLeft: '8px' }}>
                        <div style={{
                            background: '#FFFFFF', padding: '14px 16px',
                            borderRadius: '20px', borderBottomLeftRadius: '4px',
                            border: '1px solid #E5E7EB',
                            display: 'flex', gap: '6px',
                            boxShadow: '0 2px 5px rgba(0,0,0,0.02)'
                        }}>
                            <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6 }} style={{ width: 8, height: 8, background: AppTheme.colors.textTertiary, borderRadius: '50%' }} />
                            <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6, delay: 0.2 }} style={{ width: 8, height: 8, background: AppTheme.colors.textTertiary, borderRadius: '50%' }} />
                            <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6, delay: 0.4 }} style={{ width: 8, height: 8, background: AppTheme.colors.textTertiary, borderRadius: '50%' }} />
                        </div>
                    </motion.div>
                )}
                <div ref={messagesEndRef} />
            </div>

            {/* Smart Suggestions Chips */}
            <div style={{ padding: '0 16px', display: 'flex', gap: '8px', overflowX: 'auto', paddingBottom: '12px', scrollbarWidth: 'none' }}>
                {aiSuggestions.map((text, i) => (
                    <motion.button
                        key={i}
                        whileTap={{ scale: 0.95 }}
                        onClick={() => handleSend(text)}
                        style={{
                            background: '#FFFFFF',
                            border: '1px solid #E5E7EB',
                            color: AppTheme.colors.textPrimary,
                            padding: '10px 16px',
                            borderRadius: '20px',
                            fontSize: '14px',
                            fontWeight: '500',
                            whiteSpace: 'nowrap',
                            cursor: 'pointer',
                            boxShadow: '0 2px 5px rgba(0,0,0,0.02)',
                            transition: 'background 0.2s'
                        }}
                    >
                        {text}
                    </motion.button>
                ))}
            </div>

            {/* Input Area */}
            <div style={{ padding: '16px', paddingBottom: '32px', background: '#FFFFFF', borderTop: '1px solid #E5E7EB' }}>
                <form
                    onSubmit={(e) => { e.preventDefault(); handleSend(); }}
                    style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '12px',
                        background: '#F9FAFB',
                        padding: '12px 16px',
                        borderRadius: '24px',
                        border: `1px solid #E5E7EB`
                    }}
                >
                    <input
                        value={newMessage}
                        onChange={(e) => setNewMessage(e.target.value)}
                        placeholder="Type a message..."
                        style={{
                            background: 'transparent',
                            border: 'none',
                            color: AppTheme.colors.textPrimary,
                            flex: 1,
                            outline: 'none',
                            fontSize: '15px'
                        }}
                    />
                    <motion.button
                        whileTap={{ scale: 0.9 }}
                        type="submit"
                        disabled={!newMessage.trim()}
                        style={{
                            background: 'transparent',
                            border: 'none',
                            color: newMessage.trim() ? AppTheme.colors.primaryPink : AppTheme.colors.textTertiary,
                            cursor: 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            opacity: newMessage.trim() ? 1 : 0.5,
                            transition: 'color 0.2s'
                        }}
                    >
                        <FaPaperPlane size={22} />
                    </motion.button>
                </form>
            </div>
            {particlesActive && <FloatingParticles count={20} />}
        </div>
    );
};

const seededRandom = (seed) => {
    const x = Math.sin(seed) * 10000;
    return x - Math.floor(x);
};

const FloatingParticles = ({ count }) => (
    <div style={{ position: 'fixed', inset: 0, pointerEvents: 'none', zIndex: 9999 }}>
        {[...Array(count)].map((_, i) => (
            <motion.div
                key={i}
                initial={{
                    opacity: 0,
                    x: seededRandom(i + 1) * window.innerWidth,
                    y: window.innerHeight + 100,
                    scale: seededRandom(i + 2) * 0.5 + 0.5
                }}
                animate={{
                    opacity: [0, 1, 0.5, 0],
                    y: -100,
                    x: seededRandom(i + 3) * window.innerWidth,
                    rotate: seededRandom(i + 4) * 360
                }}
                transition={{
                    duration: seededRandom(i + 5) * 3 + 2,
                    ease: "easeOut",
                    repeat: Infinity,
                    delay: seededRandom(i + 6) * 2
                }}
                style={{
                    position: 'absolute',
                    fontSize: `${seededRandom(i + 7) * 30 + 10}px`,
                    filter: 'drop-shadow(0 0 10px rgba(253, 41, 123, 0.5))'
                }}
            >
                {['💖', '✨', '💎', '🌸', '🎁', '🔥'][Math.floor(seededRandom(i + 8) * 6)]}
            </motion.div>
        ))}
    </div>
);

export default Chat;
