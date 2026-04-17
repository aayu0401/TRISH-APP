"""
AI Chat Checker - Security & Content Moderation Module
Analyzes conversations for safety, red flags, inappropriate content, and scams
"""

from typing import List, Dict, Any, Optional
from pydantic import BaseModel
from datetime import datetime
import re
from collections import Counter

# ==================== DATA MODELS ====================

class Message(BaseModel):
    id: str
    sender_id: str
    content: str
    timestamp: Optional[datetime] = None

class ConversationAnalysisRequest(BaseModel):
    conversation_id: str
    messages: List[Message]
    user_id: str
    match_id: str

class RedFlag(BaseModel):
    type: str
    severity: str  # LOW, MEDIUM, HIGH, CRITICAL
    description: str
    matched_pattern: Optional[str] = None
    confidence: float

class SafetyAnalysisResponse(BaseModel):
    conversation_id: str
    overall_safety_score: float  # 0-100
    sentiment_score: float  # -1 to 1
    red_flags: List[RedFlag]
    warnings: List[str]
    recommendations: List[str]
    is_safe: bool
    requires_review: bool

class ContentModerationResponse(BaseModel):
    is_appropriate: bool
    violations: List[str]
    severity: str
    action_required: str  # NONE, WARN, BLOCK, BAN

# ==================== RED FLAG PATTERNS ====================

# Financial scam patterns
FINANCIAL_SCAM_PATTERNS = [
    r'\b(send|wire|transfer)\s+(money|cash|funds)\b',
    r'\b(bitcoin|crypto|cryptocurrency|btc|eth)\s+(wallet|address)\b',
    r'\b(investment|trading)\s+(opportunity|platform|scheme)\b',
    r'\b(urgent|emergency)\s+(money|cash|help)\b',
    r'\b(bank\s+account|credit\s+card)\s+(number|details|info)\b',
    r'\b(paypal|venmo|cashapp|zelle)\b.*\b(send|transfer)\b',
    r'\b(gift\s+card|prepaid\s+card)\b',
    r'\b(western\s+union|moneygram)\b',
    r'\b(inheritance|lottery|prize)\s+(money|won|claim)\b',
    r'\b(nigerian\s+prince|foreign\s+investor)\b',
]

# Personal information requests
PERSONAL_INFO_PATTERNS = [
    r'\b(social\s+security|ssn|tax\s+id)\b',
    r'\b(password|pin|passcode)\b',
    r'\b(home\s+address|residential\s+address)\b',
    r'\b(bank\s+account|routing\s+number)\b',
    r'\b(credit\s+card|debit\s+card)\s+(number|cvv|cvc)\b',
    r'\b(drivers?\s+license|passport)\s+(number|id)\b',
]

# Inappropriate/Sexual content
INAPPROPRIATE_PATTERNS = [
    r'\b(nude|naked|nsfw)\s+(pic|photo|image|video)\b',
    r'\b(sex|sexual|intimate)\s+(video|chat|call)\b',
    r'\b(dick|cock|pussy|tits)\s+(pic|photo)\b',
    r'\b(onlyfans|premium\s+snapchat)\b',
    r'\b(escort|prostitute|sugar\s+baby|sugar\s+daddy)\b',
]

# Harassment/Abuse patterns
HARASSMENT_PATTERNS = [
    r'\b(kill|hurt|harm)\s+(yourself|you)\b',
    r'\b(stupid|idiot|ugly|fat|worthless)\b.*\b(bitch|slut|whore)\b',
    r'\b(stalk|follow|track)\s+you\b',
    r'\b(rape|assault|abuse)\b',
    r'\b(die|death)\s+(threat|wish)\b',
]

# Off-platform communication (potential scam)
OFF_PLATFORM_PATTERNS = [
    r'\b(whatsapp|telegram|kik|snapchat|instagram)\b.*\b(add|contact|message)\b',
    r'\b(email|gmail|yahoo)\s+(address|me)\b',
    r'\b(phone\s+number|cell|mobile)\b',
    r'\b(meet\s+me\s+on|chat\s+on)\s+\w+\b',
]

# Age-related red flags
AGE_CONCERN_PATTERNS = [
    r'\b(underage|minor|teenager|teen)\b',
    r'\b(high\s+school|middle\s+school)\b',
    r'\b(parent|parents|guardian)\s+(don\'t\s+know|permission)\b',
]

# Catfish/Fake profile indicators
CATFISH_PATTERNS = [
    r'\b(not\s+my\s+real|fake|stolen)\s+(photo|pic|picture)\b',
    r'\b(model|celebrity|famous)\s+(photo|picture)\b',
    r'\b(can\'t\s+video|no\s+video)\s+(call|chat)\b',
    r'\b(camera\s+broken|phone\s+broken)\b',
]

# Negative sentiment words
NEGATIVE_WORDS = [
    'hate', 'angry', 'annoyed', 'frustrated', 'upset', 'mad', 'furious',
    'terrible', 'awful', 'horrible', 'disgusting', 'pathetic', 'worthless',
    'stupid', 'dumb', 'idiot', 'moron', 'loser', 'failure'
]

# Positive sentiment words
POSITIVE_WORDS = [
    'love', 'happy', 'excited', 'amazing', 'wonderful', 'great', 'awesome',
    'fantastic', 'excellent', 'beautiful', 'lovely', 'nice', 'good', 'fun',
    'enjoy', 'like', 'appreciate', 'grateful', 'blessed', 'lucky'
]

# Pressure/Urgency indicators
PRESSURE_PATTERNS = [
    r'\b(right\s+now|immediately|urgent|asap)\b',
    r'\b(limited\s+time|offer\s+expires|act\s+fast)\b',
    r'\b(don\'t\s+tell|keep\s+secret|between\s+us)\b',
    r'\b(trust\s+me|believe\s+me)\b.*\b(send|give|share)\b',
]

# ==================== ANALYSIS FUNCTIONS ====================

def detect_red_flags(messages: List[Message]) -> List[RedFlag]:
    """Detect red flags in conversation"""
    red_flags = []
    
    # Combine all message content
    full_conversation = " ".join([msg.content.lower() for msg in messages])
    
    # Check financial scams
    for pattern in FINANCIAL_SCAM_PATTERNS:
        matches = re.findall(pattern, full_conversation, re.IGNORECASE)
        if matches:
            red_flags.append(RedFlag(
                type="FINANCIAL_SCAM",
                severity="CRITICAL",
                description="Potential financial scam or money request detected",
                matched_pattern=str(matches[0]) if matches else None,
                confidence=0.85
            ))
    
    # Check personal information requests
    for pattern in PERSONAL_INFO_PATTERNS:
        matches = re.findall(pattern, full_conversation, re.IGNORECASE)
        if matches:
            red_flags.append(RedFlag(
                type="PERSONAL_INFO_REQUEST",
                severity="HIGH",
                description="Request for sensitive personal information detected",
                matched_pattern=str(matches[0]) if matches else None,
                confidence=0.90
            ))
    
    # Check inappropriate content
    for pattern in INAPPROPRIATE_PATTERNS:
        matches = re.findall(pattern, full_conversation, re.IGNORECASE)
        if matches:
            red_flags.append(RedFlag(
                type="INAPPROPRIATE_CONTENT",
                severity="HIGH",
                description="Inappropriate or sexual content detected",
                matched_pattern=str(matches[0]) if matches else None,
                confidence=0.80
            ))
    
    # Check harassment
    for pattern in HARASSMENT_PATTERNS:
        matches = re.findall(pattern, full_conversation, re.IGNORECASE)
        if matches:
            red_flags.append(RedFlag(
                type="HARASSMENT",
                severity="CRITICAL",
                description="Harassment or abusive language detected",
                matched_pattern=str(matches[0]) if matches else None,
                confidence=0.95
            ))
    
    # Check off-platform requests
    for pattern in OFF_PLATFORM_PATTERNS:
        matches = re.findall(pattern, full_conversation, re.IGNORECASE)
        if matches:
            red_flags.append(RedFlag(
                type="OFF_PLATFORM_REQUEST",
                severity="MEDIUM",
                description="Request to move conversation off-platform (potential scam indicator)",
                matched_pattern=str(matches[0]) if matches else None,
                confidence=0.70
            ))
    
    # Check age concerns
    for pattern in AGE_CONCERN_PATTERNS:
        matches = re.findall(pattern, full_conversation, re.IGNORECASE)
        if matches:
            red_flags.append(RedFlag(
                type="AGE_CONCERN",
                severity="CRITICAL",
                description="Potential underage user or age-related concern",
                matched_pattern=str(matches[0]) if matches else None,
                confidence=0.75
            ))
    
    # Check catfish indicators
    for pattern in CATFISH_PATTERNS:
        matches = re.findall(pattern, full_conversation, re.IGNORECASE)
        if matches:
            red_flags.append(RedFlag(
                type="CATFISH_INDICATOR",
                severity="MEDIUM",
                description="Potential fake profile or catfish behavior",
                matched_pattern=str(matches[0]) if matches else None,
                confidence=0.65
            ))
    
    # Check pressure tactics
    for pattern in PRESSURE_PATTERNS:
        matches = re.findall(pattern, full_conversation, re.IGNORECASE)
        if matches:
            red_flags.append(RedFlag(
                type="PRESSURE_TACTICS",
                severity="MEDIUM",
                description="Pressure or urgency tactics detected",
                matched_pattern=str(matches[0]) if matches else None,
                confidence=0.70
            ))
    
    return red_flags

def analyze_sentiment(messages: List[Message]) -> float:
    """
    Analyze conversation sentiment
    Returns: -1 (very negative) to 1 (very positive)
    """
    if not messages:
        return 0.0
    
    positive_count = 0
    negative_count = 0
    
    for message in messages:
        content_lower = message.content.lower()
        
        # Count positive words
        for word in POSITIVE_WORDS:
            positive_count += content_lower.count(word)
        
        # Count negative words
        for word in NEGATIVE_WORDS:
            negative_count += content_lower.count(word)
    
    total_sentiment_words = positive_count + negative_count
    
    if total_sentiment_words == 0:
        return 0.0  # Neutral
    
    # Calculate sentiment score
    sentiment = (positive_count - negative_count) / total_sentiment_words
    
    # Normalize to -1 to 1 range
    return max(-1.0, min(1.0, sentiment))

def calculate_safety_score(red_flags: List[RedFlag], sentiment: float) -> float:
    """
    Calculate overall safety score (0-100)
    Higher score = safer conversation
    """
    base_score = 100.0
    
    # Deduct points based on red flags
    severity_penalties = {
        'LOW': 5,
        'MEDIUM': 15,
        'HIGH': 30,
        'CRITICAL': 50
    }
    
    for flag in red_flags:
        penalty = severity_penalties.get(flag.severity, 10)
        base_score -= penalty * flag.confidence
    
    # Adjust based on sentiment (very negative sentiment reduces score)
    if sentiment < -0.5:
        base_score -= 10
    elif sentiment < -0.3:
        base_score -= 5
    
    # Ensure score is between 0 and 100
    return max(0.0, min(100.0, base_score))

def generate_warnings(red_flags: List[RedFlag]) -> List[str]:
    """Generate user-friendly warnings based on red flags"""
    warnings = []
    
    flag_types = set([flag.type for flag in red_flags])
    
    if 'FINANCIAL_SCAM' in flag_types:
        warnings.append("⚠️ Warning: This conversation contains requests for money or financial information. Never send money to someone you haven't met in person.")
    
    if 'PERSONAL_INFO_REQUEST' in flag_types:
        warnings.append("⚠️ Warning: Someone is asking for sensitive personal information. Never share passwords, SSN, or financial details.")
    
    if 'INAPPROPRIATE_CONTENT' in flag_types:
        warnings.append("⚠️ Warning: Inappropriate or sexual content detected. You can report this user if you feel uncomfortable.")
    
    if 'HARASSMENT' in flag_types:
        warnings.append("🚨 Critical: Harassment or abusive language detected. Please report this user immediately and consider blocking them.")
    
    if 'OFF_PLATFORM_REQUEST' in flag_types:
        warnings.append("⚠️ Caution: Request to move conversation off-platform. This is a common scam tactic. Stay on TRISH for your safety.")
    
    if 'AGE_CONCERN' in flag_types:
        warnings.append("🚨 Critical: Potential underage user detected. This conversation will be reviewed by our safety team.")
    
    if 'CATFISH_INDICATOR' in flag_types:
        warnings.append("⚠️ Caution: Potential fake profile indicators detected. Request a video call to verify identity.")
    
    if 'PRESSURE_TACTICS' in flag_types:
        warnings.append("⚠️ Warning: Pressure or urgency tactics detected. Legitimate connections don't rush you. Take your time.")
    
    return warnings

def generate_recommendations(red_flags: List[RedFlag], sentiment: float, safety_score: float) -> List[str]:
    """Generate safety recommendations"""
    recommendations = []
    
    if safety_score < 50:
        recommendations.append("Consider ending this conversation and reporting the user")
        recommendations.append("Block this user to prevent further contact")
    elif safety_score < 70:
        recommendations.append("Proceed with extreme caution")
        recommendations.append("Do not share personal information")
        recommendations.append("Request video verification before meeting")
    elif safety_score < 85:
        recommendations.append("Stay alert and trust your instincts")
        recommendations.append("Keep conversations on the platform")
    
    if sentiment < -0.3:
        recommendations.append("This conversation has negative sentiment - consider if this match is right for you")
    
    if not red_flags and safety_score >= 85:
        recommendations.append("This conversation appears safe so far")
        recommendations.append("Continue getting to know each other naturally")
    
    return recommendations

def moderate_content(message_content: str) -> ContentModerationResponse:
    """Moderate individual message content"""
    violations = []
    severity = "NONE"
    action = "NONE"
    
    content_lower = message_content.lower()
    
    # Check for explicit sexual content
    explicit_words = ['fuck', 'shit', 'ass', 'dick', 'cock', 'pussy', 'bitch', 'cunt']
    if any(word in content_lower for word in explicit_words):
        violations.append("Explicit language")
        severity = "MEDIUM"
        action = "WARN"
    
    # Check for hate speech
    hate_words = ['nigger', 'faggot', 'retard', 'chink', 'spic']
    if any(word in content_lower for word in hate_words):
        violations.append("Hate speech")
        severity = "CRITICAL"
        action = "BAN"
    
    # Check for threats
    threat_patterns = [r'\b(kill|murder|hurt|harm)\s+you\b', r'\b(death\s+threat)\b']
    for pattern in threat_patterns:
        if re.search(pattern, content_lower):
            violations.append("Threats of violence")
            severity = "CRITICAL"
            action = "BAN"
            break
    
    # Check for spam
    if len(message_content) > 500 and message_content.count('http') > 3:
        violations.append("Potential spam")
        severity = "LOW"
        action = "WARN"
    
    is_appropriate = len(violations) == 0
    
    return ContentModerationResponse(
        is_appropriate=is_appropriate,
        violations=violations,
        severity=severity,
        action_required=action
    )

def analyze_conversation_patterns(messages: List[Message], user_id: str) -> Dict[str, Any]:
    """Analyze conversation patterns for suspicious behavior"""
    if not messages:
        return {}
    
    user_messages = [msg for msg in messages if msg.sender_id == user_id]
    match_messages = [msg for msg in messages if msg.sender_id != user_id]
    
    # Calculate message ratio
    total_messages = len(messages)
    user_ratio = len(user_messages) / total_messages if total_messages > 0 else 0
    
    # Check for one-sided conversation
    is_one_sided = user_ratio > 0.8 or user_ratio < 0.2
    
    # Check for rapid messaging (potential spam)
    if len(match_messages) >= 5:
        # Check if match sent 5+ messages in quick succession
        is_spam_like = True  # Simplified check
    else:
        is_spam_like = False
    
    # Check message length patterns
    avg_user_length = sum(len(msg.content) for msg in user_messages) / len(user_messages) if user_messages else 0
    avg_match_length = sum(len(msg.content) for msg in match_messages) / len(match_messages) if match_messages else 0
    
    return {
        'total_messages': total_messages,
        'user_message_count': len(user_messages),
        'match_message_count': len(match_messages),
        'user_message_ratio': round(user_ratio, 2),
        'is_one_sided': is_one_sided,
        'is_spam_like': is_spam_like,
        'avg_user_message_length': round(avg_user_length, 1),
        'avg_match_message_length': round(avg_match_length, 1),
        'engagement_level': 'high' if total_messages > 20 else 'medium' if total_messages > 10 else 'low'
    }

# ==================== MAIN ANALYSIS FUNCTION ====================

def analyze_conversation_safety(request: ConversationAnalysisRequest) -> SafetyAnalysisResponse:
    """
    Main function to analyze conversation safety
    Returns comprehensive safety analysis
    """
    # Detect red flags
    red_flags = detect_red_flags(request.messages)
    
    # Analyze sentiment
    sentiment = analyze_sentiment(request.messages)
    
    # Calculate safety score
    safety_score = calculate_safety_score(red_flags, sentiment)
    
    # Generate warnings
    warnings = generate_warnings(red_flags)
    
    # Generate recommendations
    recommendations = generate_recommendations(red_flags, sentiment, safety_score)
    
    # Determine if conversation is safe
    is_safe = safety_score >= 70 and not any(flag.severity == 'CRITICAL' for flag in red_flags)
    
    # Determine if requires manual review
    requires_review = (
        safety_score < 50 or
        any(flag.severity == 'CRITICAL' for flag in red_flags) or
        any(flag.type in ['AGE_CONCERN', 'HARASSMENT'] for flag in red_flags)
    )
    
    return SafetyAnalysisResponse(
        conversation_id=request.conversation_id,
        overall_safety_score=round(safety_score, 2),
        sentiment_score=round(sentiment, 2),
        red_flags=red_flags,
        warnings=warnings,
        recommendations=recommendations,
        is_safe=is_safe,
        requires_review=requires_review
    )

# ==================== EXPORT ====================

__all__ = [
    'Message',
    'ConversationAnalysisRequest',
    'RedFlag',
    'SafetyAnalysisResponse',
    'ContentModerationResponse',
    'analyze_conversation_safety',
    'moderate_content',
    'analyze_conversation_patterns',
    'detect_red_flags',
    'analyze_sentiment',
]
