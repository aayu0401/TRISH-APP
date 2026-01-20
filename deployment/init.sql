-- Initialize Trish Database

-- Users table is created by JPA/Hibernate automatically
-- This file can be used for initial data seeding if needed

-- Example: Insert sample interests
-- INSERT INTO user_interests (user_id, interest) VALUES (1, 'Travel');

-- Create indexes for better performance

-- Core feature indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_location ON users(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_swipes_swiper ON swipes(swiper_id);
CREATE INDEX IF NOT EXISTS idx_swipes_swiped ON swipes(swiped_id);
CREATE INDEX IF NOT EXISTS idx_matches_user1 ON matches(user1_id);
CREATE INDEX IF NOT EXISTS idx_matches_user2 ON matches(user2_id);
CREATE INDEX IF NOT EXISTS idx_messages_match ON messages(match_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON messages(receiver_id);

-- Gift/E-commerce indexes
CREATE INDEX IF NOT EXISTS idx_gifts_category ON gifts(category);
CREATE INDEX IF NOT EXISTS idx_gifts_type ON gifts(type);
CREATE INDEX IF NOT EXISTS idx_gifts_available ON gifts(is_available);
CREATE INDEX IF NOT EXISTS idx_gift_transactions_sender ON gift_transactions(sender_id);
CREATE INDEX IF NOT EXISTS idx_gift_transactions_receiver ON gift_transactions(receiver_id);
CREATE INDEX IF NOT EXISTS idx_gift_transactions_status ON gift_transactions(status);

-- Wallet indexes
CREATE INDEX IF NOT EXISTS idx_wallets_user ON wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_wallet ON wallet_transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_status ON wallet_transactions(status);

-- KYC indexes
CREATE INDEX IF NOT EXISTS idx_kyc_user ON kyc_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_kyc_status ON kyc_verifications(status);

-- Subscription indexes
CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_plan ON subscriptions(plan);

-- Personality indexes
CREATE INDEX IF NOT EXISTS idx_personality_user ON personality_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_personality_mbti ON personality_profiles(mbti_type);
CREATE INDEX IF NOT EXISTS idx_personality_enneagram ON personality_profiles(enneagram_type);

-- Block/Report indexes (Phase 1)
CREATE INDEX IF NOT EXISTS idx_blocks_blocker ON blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocks_blocked ON blocks(blocked_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_reports_reported ON reports(reported_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);

-- Video Call indexes (Phase 2)
CREATE INDEX IF NOT EXISTS idx_video_calls_caller ON video_calls(caller_id);
CREATE INDEX IF NOT EXISTS idx_video_calls_receiver ON video_calls(receiver_id);
CREATE INDEX IF NOT EXISTS idx_video_calls_status ON video_calls(status);

-- Story indexes (Phase 3)
CREATE INDEX IF NOT EXISTS idx_stories_user ON stories(user_id);
CREATE INDEX IF NOT EXISTS idx_stories_expires ON stories(expires_at);
CREATE INDEX IF NOT EXISTS idx_story_views_story ON story_views(story_id);
CREATE INDEX IF NOT EXISTS idx_story_views_viewer ON story_views(viewer_id);

-- Post/Feed indexes (Phase 3)
CREATE INDEX IF NOT EXISTS idx_posts_user ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at);
CREATE INDEX IF NOT EXISTS idx_post_likes_post ON post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user ON post_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_post ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user ON comments(user_id);

-- Profile View indexes (Phase 4)
CREATE INDEX IF NOT EXISTS idx_profile_views_viewed ON profile_views(viewed_user_id);
CREATE INDEX IF NOT EXISTS idx_profile_views_viewer ON profile_views(viewer_id);

-- Notification indexes (Phase 5)
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user ON fcm_tokens(user_id);
