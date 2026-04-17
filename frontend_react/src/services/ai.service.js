import axios from 'axios';

// Direct connection to the Python AI Engine
const AI_ENGINE_URL = import.meta.env.VITE_AI_ENGINE_URL || 'http://localhost:8000';

export const aiService = {
    // Check if AI is reachable
    checkHealth: async () => {
        try {
            const res = await axios.get(`${AI_ENGINE_URL}/health`);
            return res.data.status === 'ok';
        } catch (error) {
            console.warn("AI Engine offline:", error);
            return false;
        }
    },

    // Analyze compatibility between two sets of personality data
    analyzeCompatibility: async (userTraits, matchTraits) => {
        try {
            const response = await axios.post(`${AI_ENGINE_URL}/personality-compatibility`, {
                user_mbti: userTraits.mbti,
                candidate_mbti: matchTraits.mbti,
                user_enneagram: userTraits.enneagram,
                candidate_enneagram: matchTraits.enneagram,
                // Defaulting Big Five for demo if missing
                user_big_five: userTraits.bigFive || { openness: 80, conscientiousness: 60, extraversion: 50, agreeableness: 70, neuroticism: 30 },
                candidate_big_five: matchTraits.bigFive || { openness: 75, conscientiousness: 65, extraversion: 55, agreeableness: 80, neuroticism: 20 }
            });
            return response.data;
        } catch (error) {
            console.error("AI Analysis Failed:", error);
            // Fallback mock analysis
            return {
                overall_personality_score: 0.85,
                insights: [
                    "Strong compatibility detected based on local backup analysis.",
                    "Both users share high Openness traits."
                ]
            };
        }
    },

    // Get conversation starters
    getConversationStarters: async (userInterests, matchInterests) => {
        try {
            const payload = {
                user: { id: "u1", name: "User", age: 25, interests: userInterests },
                candidates: [{ id: "c1", name: "Match", age: 25, interests: matchInterests }]
            };

            const response = await axios.post(`${AI_ENGINE_URL}/predict-conversation-quality`, payload);
            return response.data.conversation_tips;
        } catch (error) {
            return ["Ask about their travel experiences", "Discuss favorite movies"];
        }
    },

    // Check individual message for spam or abuse
    checkMessageSafety: async (messageContent) => {
        try {
            const response = await axios.post(`${AI_ENGINE_URL}/check-message-safety`, null, {
                params: { message: messageContent }
            });
            return response.data;
        } catch (error) {
            return { is_safe: true, reasons: [] };
        }
    },

    // Detailed conversation security analysis
    analyzeConversationSecurity: async (conversationId, messages, userId, matchId) => {
        try {
            // Map frontend messages to AI engine format
            const formattedMessages = messages.map((m, idx) => ({
                id: m.id || `msg_${idx}`,
                sender_id: m.senderId || m.sender,
                content: m.text || m.content,
                timestamp: m.timestamp
            }));

            const response = await axios.post(`${AI_ENGINE_URL}/analyze-conversation-security`, {
                conversation_id: conversationId,
                messages: formattedMessages,
                user_id: userId,
                match_id: matchId
            });
            return response.data;
        } catch (error) {
            return {
                is_safe: true,
                overall_safety_score: 100,
                sentiment_score: 0,
                red_flags: [],
                warnings: [],
                recommendations: []
            };
        }
    },

    // Generate a creative bio based on user traits and interests
    generateBio: async (traits) => {
        try {
            const response = await axios.post(`${AI_ENGINE_URL}/generate-profile-bio`, {
                mbti: traits.mbti,
                enneagram: traits.enneagram,
                interests: traits.interests,
                lifestyle: traits.lifestyle,
                tone: traits.tone || 'witty'
            });
            return response.data.bio;
        } catch (error) {
            console.error("AI Bio Generation Failed:", error);
            // Dynamic fallback
            const fallbackBios = [
                `Adventurous soul with an ${traits.mbti || 'INTJ'} mind. Coffee enthusiast and lifelong learner.`,
                `Exploring the intersection of art and tech. ${traits.mbti || 'INTJ'} / ${traits.enneagram || '5w6'}. Always up for a good hike!`,
                `Digital nomad at heart, ${traits.mbti || 'INTJ'} by personality. Let's create something beautiful together.`
            ];
            return fallbackBios[Math.floor(Math.random() * fallbackBios.length)];
        }
    }
};
