from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import numpy as np
from scipy.spatial.distance import cosine
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import CountVectorizer
import math
from datetime import datetime
from collections import defaultdict

app = FastAPI(title='TRISH AI Engine - Advanced Matching')

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== DATA MODELS ====================

class BigFiveTraits(BaseModel):
    openness: int = Field(ge=0, le=100)
    conscientiousness: int = Field(ge=0, le=100)
    extraversion: int = Field(ge=0, le=100)
    agreeableness: int = Field(ge=0, le=100)
    neuroticism: int = Field(ge=0, le=100)

class BehavioralMetrics(BaseModel):
    avg_response_time_minutes: Optional[float] = None
    avg_message_length: Optional[int] = None
    active_hours: Optional[List[int]] = None  # Hours of day (0-23)
    swipe_selectivity: Optional[float] = None  # Ratio of likes to total swipes
    conversation_initiation_rate: Optional[float] = None

class UserProfile(BaseModel):
    id: str
    name: str
    age: int
    interests: List[str] = []
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    mbti_type: Optional[str] = None
    enneagram_type: Optional[str] = None
    big_five: Optional[BigFiveTraits] = None
    values: Optional[List[str]] = []
    behavioral_metrics: Optional[BehavioralMetrics] = None

class MatchRequest(BaseModel):
    user: UserProfile
    candidates: List[UserProfile]
    max_distance: Optional[int] = 50
    custom_weights: Optional[Dict[str, float]] = None

class CompatibilityBreakdown(BaseModel):
    interest_score: float
    personality_score: float
    age_score: float
    location_score: float
    value_score: float
    communication_score: float
    activity_score: float

class MatchInsights(BaseModel):
    strengths: List[str]
    growth_areas: List[str]
    conversation_starters: List[str]
    compatibility_summary: str

class AdvancedMatchResult(BaseModel):
    id: str
    name: str
    overall_score: float
    breakdown: CompatibilityBreakdown
    insights: MatchInsights
    distance: Optional[float] = None
    predicted_conversation_quality: Optional[float] = None

class PersonalityCompatibilityRequest(BaseModel):
    user_mbti: Optional[str] = None
    candidate_mbti: Optional[str] = None
    user_enneagram: Optional[str] = None
    candidate_enneagram: Optional[str] = None
    user_big_five: Optional[BigFiveTraits] = None
    candidate_big_five: Optional[BigFiveTraits] = None

class PersonalityCompatibilityResponse(BaseModel):
    mbti_score: Optional[float] = None
    enneagram_score: Optional[float] = None
    big_five_score: Optional[float] = None
    overall_personality_score: float
    insights: List[str]

class WingmanRequest(BaseModel):
    user_id: str
    message: str
    context: Optional[str] = None  # e.g., "chatting with Sarah, she likes hiking"
    tone: Optional[str] = "supportive"  # supportive, distinct, funny, direct

class WingmanResponse(BaseModel):
    response: str
    suggested_actions: List[str]


# ==================== PERSONALITY COMPATIBILITY MATRICES ====================

# MBTI Compatibility Matrix (16x16) - Based on cognitive function theory
MBTI_COMPATIBILITY = {
    'INTJ': {'ENFP': 0.95, 'ENTP': 0.90, 'INFJ': 0.85, 'ENTJ': 0.80, 'INTP': 0.75, 'INFP': 0.70, 'ISTJ': 0.65, 'ESTJ': 0.60},
    'INTP': {'ENTJ': 0.95, 'ENFJ': 0.90, 'INTJ': 0.85, 'ENTP': 0.80, 'INFJ': 0.75, 'INFP': 0.70, 'ISTP': 0.65, 'ESTP': 0.60},
    'ENTJ': {'INTP': 0.95, 'INFP': 0.90, 'INTJ': 0.85, 'ENTP': 0.80, 'ENFP': 0.75, 'INFJ': 0.70, 'ESTJ': 0.65, 'ISTJ': 0.60},
    'ENTP': {'INFJ': 0.95, 'INTJ': 0.90, 'ENFP': 0.85, 'INTP': 0.80, 'ENTJ': 0.75, 'INFP': 0.70, 'ESTP': 0.65, 'ISTP': 0.60},
    'INFJ': {'ENTP': 0.95, 'ENFP': 0.90, 'INTJ': 0.85, 'INFP': 0.80, 'ENFJ': 0.75, 'INTP': 0.70, 'ISFJ': 0.65, 'ESFJ': 0.60},
    'INFP': {'ENFJ': 0.95, 'ENTJ': 0.90, 'INFJ': 0.85, 'ENFP': 0.80, 'INTP': 0.75, 'INTJ': 0.70, 'ISFP': 0.65, 'ESFP': 0.60},
    'ENFJ': {'INFP': 0.95, 'ISFP': 0.90, 'INTP': 0.85, 'ENFP': 0.80, 'INFJ': 0.75, 'INTJ': 0.70, 'ESFJ': 0.65, 'ISFJ': 0.60},
    'ENFP': {'INTJ': 0.95, 'INFJ': 0.90, 'ENTP': 0.85, 'INFP': 0.80, 'ENFJ': 0.75, 'ENTJ': 0.70, 'ESFP': 0.65, 'ISFP': 0.60},
    'ISTJ': {'ESTP': 0.90, 'ESFP': 0.85, 'ESTJ': 0.80, 'ISFJ': 0.75, 'INTJ': 0.70, 'ISTP': 0.65, 'ENTJ': 0.60, 'ENTP': 0.55},
    'ISFJ': {'ESFP': 0.90, 'ESTP': 0.85, 'ESTJ': 0.80, 'ISTJ': 0.75, 'INFJ': 0.70, 'ISFP': 0.65, 'ENFJ': 0.60, 'ENFP': 0.55},
    'ESTJ': {'ISTP': 0.90, 'ISFP': 0.85, 'ISTJ': 0.80, 'ESFJ': 0.75, 'ENTJ': 0.70, 'ESTP': 0.65, 'INTJ': 0.60, 'INTP': 0.55},
    'ESFJ': {'ISFP': 0.90, 'ISTP': 0.85, 'ISTJ': 0.80, 'ESTJ': 0.75, 'ENFJ': 0.70, 'ESFP': 0.65, 'INFJ': 0.60, 'INFP': 0.55},
    'ISTP': {'ESTJ': 0.90, 'ESFJ': 0.85, 'ESTP': 0.80, 'ISTJ': 0.75, 'INTP': 0.70, 'ISTP': 0.65, 'ENTP': 0.60, 'ENTJ': 0.55},
    'ISFP': {'ENFJ': 0.90, 'ESFJ': 0.85, 'ESTJ': 0.80, 'ESFP': 0.75, 'INFP': 0.70, 'ISFJ': 0.65, 'ENFP': 0.60, 'INFJ': 0.55},
    'ESTP': {'ISFJ': 0.90, 'ISTJ': 0.85, 'ISTP': 0.80, 'ESFP': 0.75, 'ENTP': 0.70, 'ESTP': 0.65, 'INTP': 0.60, 'INTJ': 0.55},
    'ESFP': {'ISTJ': 0.90, 'ISFJ': 0.85, 'ISTP': 0.80, 'ESTP': 0.75, 'ENFP': 0.70, 'ESFP': 0.65, 'INFP': 0.60, 'INFJ': 0.55},
}

# Enneagram Compatibility Matrix (9x9) - Based on complementary dynamics
ENNEAGRAM_COMPATIBILITY = {
    '1': {'2': 0.90, '7': 0.85, '9': 0.80, '5': 0.75, '6': 0.70, '3': 0.65, '4': 0.60, '8': 0.55, '1': 0.50},
    '2': {'8': 0.90, '4': 0.85, '1': 0.80, '3': 0.75, '9': 0.70, '7': 0.65, '5': 0.60, '6': 0.55, '2': 0.50},
    '3': {'9': 0.90, '6': 0.85, '1': 0.80, '2': 0.75, '7': 0.70, '5': 0.65, '4': 0.60, '8': 0.55, '3': 0.50},
    '4': {'1': 0.90, '9': 0.85, '2': 0.80, '5': 0.75, '7': 0.70, '6': 0.65, '3': 0.60, '8': 0.55, '4': 0.50},
    '5': {'8': 0.90, '7': 0.85, '1': 0.80, '4': 0.75, '9': 0.70, '2': 0.65, '6': 0.60, '3': 0.55, '5': 0.50},
    '6': {'9': 0.90, '2': 0.85, '3': 0.80, '1': 0.75, '7': 0.70, '8': 0.65, '4': 0.60, '5': 0.55, '6': 0.50},
    '7': {'5': 0.90, '1': 0.85, '9': 0.80, '2': 0.75, '3': 0.70, '6': 0.65, '8': 0.60, '4': 0.55, '7': 0.50},
    '8': {'2': 0.90, '9': 0.85, '5': 0.80, '6': 0.75, '1': 0.70, '7': 0.65, '3': 0.60, '4': 0.55, '8': 0.50},
    '9': {'4': 0.90, '3': 0.85, '1': 0.80, '6': 0.75, '8': 0.70, '5': 0.65, '2': 0.60, '7': 0.55, '9': 0.50},
}

# ==================== CORE ALGORITHMS ====================

def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance between two points using Haversine formula (in km)"""
    R = 6371  # Earth's radius in km
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    a = math.sin(delta_lat / 2) ** 2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c

def calculate_interest_similarity(interests1: List[str], interests2: List[str]) -> float:
    """Calculate similarity between two interest lists using Jaccard similarity"""
    if not interests1 or not interests2:
        return 0.0
    
    set1 = set([i.lower() for i in interests1])
    set2 = set([i.lower() for i in interests2])
    
    intersection = len(set1.intersection(set2))
    union = len(set1.union(set2))
    
    return intersection / union if union > 0 else 0.0

def calculate_value_alignment(values1: List[str], values2: List[str]) -> float:
    """Calculate alignment of core values using Jaccard similarity"""
    if not values1 or not values2:
        return 0.5  # Neutral score if no values provided
    
    set1 = set([v.lower() for v in values1])
    set2 = set([v.lower() for v in values2])
    
    intersection = len(set1.intersection(set2))
    union = len(set1.union(set2))
    
    return intersection / union if union > 0 else 0.0

def calculate_age_compatibility(age1: int, age2: int) -> float:
    """Calculate age compatibility score (closer ages = higher score)"""
    age_diff = abs(age1 - age2)
    
    if age_diff <= 2:
        return 1.0
    elif age_diff <= 5:
        return 0.9
    elif age_diff <= 10:
        return 0.7
    elif age_diff <= 15:
        return 0.5
    else:
        return 0.3

def calculate_mbti_compatibility(mbti1: str, mbti2: str) -> float:
    """Calculate MBTI compatibility using predefined matrix"""
    if not mbti1 or not mbti2:
        return 0.5  # Neutral score
    
    mbti1 = mbti1.upper()
    mbti2 = mbti2.upper()
    
    # Check direct compatibility
    if mbti1 in MBTI_COMPATIBILITY and mbti2 in MBTI_COMPATIBILITY[mbti1]:
        return MBTI_COMPATIBILITY[mbti1][mbti2]
    
    # Check reverse compatibility
    if mbti2 in MBTI_COMPATIBILITY and mbti1 in MBTI_COMPATIBILITY[mbti2]:
        return MBTI_COMPATIBILITY[mbti2][mbti1]
    
    # Calculate based on shared preferences
    shared_traits = sum(1 for i in range(4) if mbti1[i] == mbti2[i])
    return 0.4 + (shared_traits * 0.15)  # 0.4 to 1.0 range

def calculate_enneagram_compatibility(enne1: str, enne2: str) -> float:
    """Calculate Enneagram compatibility using predefined matrix"""
    if not enne1 or not enne2:
        return 0.5  # Neutral score
    
    # Extract number from enneagram type (e.g., "1w2" -> "1")
    enne1_num = enne1[0] if enne1 else None
    enne2_num = enne2[0] if enne2 else None
    
    if not enne1_num or not enne2_num:
        return 0.5
    
    # Check compatibility matrix
    if enne1_num in ENNEAGRAM_COMPATIBILITY and enne2_num in ENNEAGRAM_COMPATIBILITY[enne1_num]:
        return ENNEAGRAM_COMPATIBILITY[enne1_num][enne2_num]
    
    # Check reverse
    if enne2_num in ENNEAGRAM_COMPATIBILITY and enne1_num in ENNEAGRAM_COMPATIBILITY[enne2_num]:
        return ENNEAGRAM_COMPATIBILITY[enne2_num][enne1_num]
    
    return 0.5

def calculate_big_five_compatibility(traits1: BigFiveTraits, traits2: BigFiveTraits) -> float:
    """
    Calculate Big Five compatibility using weighted cosine similarity
    Research shows: Agreeableness (30%), Emotional Stability (25%), 
    Conscientiousness (20%), Openness (15%), Extraversion (10%)
    """
    if not traits1 or not traits2:
        return 0.5
    
    # Convert to vectors
    vec1 = np.array([
        traits1.openness,
        traits1.conscientiousness,
        traits1.extraversion,
        traits1.agreeableness,
        100 - traits1.neuroticism  # Emotional stability (inverse of neuroticism)
    ])
    
    vec2 = np.array([
        traits2.openness,
        traits2.conscientiousness,
        traits2.extraversion,
        traits2.agreeableness,
        100 - traits2.neuroticism
    ])
    
    # Weights based on relationship research
    weights = np.array([0.15, 0.20, 0.10, 0.30, 0.25])
    
    # Calculate weighted similarity
    # For personality, moderate similarity is optimal (not too similar, not too different)
    differences = np.abs(vec1 - vec2)
    
    # Score based on differences (sweet spot is 10-30 point difference)
    scores = []
    for diff in differences:
        if diff <= 10:
            scores.append(0.95)  # Very similar
        elif diff <= 20:
            scores.append(1.0)   # Optimal similarity
        elif diff <= 30:
            scores.append(0.90)  # Good similarity
        elif diff <= 40:
            scores.append(0.75)  # Moderate difference
        else:
            scores.append(0.60)  # Significant difference
    
    weighted_score = np.average(scores, weights=weights)
    return float(weighted_score)

def calculate_personality_compatibility(user: UserProfile, candidate: UserProfile) -> tuple:
    """Calculate overall personality compatibility and return score + insights"""
    scores = {}
    insights = []
    
    # MBTI Compatibility
    if user.mbti_type and candidate.mbti_type:
        mbti_score = calculate_mbti_compatibility(user.mbti_type, candidate.mbti_type)
        scores['mbti'] = mbti_score
        if mbti_score >= 0.85:
            insights.append(f"Excellent MBTI compatibility ({user.mbti_type} + {candidate.mbti_type})")
        elif mbti_score >= 0.70:
            insights.append(f"Good MBTI match with complementary strengths")
    
    # Enneagram Compatibility
    if user.enneagram_type and candidate.enneagram_type:
        enne_score = calculate_enneagram_compatibility(user.enneagram_type, candidate.enneagram_type)
        scores['enneagram'] = enne_score
        if enne_score >= 0.80:
            insights.append(f"Strong Enneagram pairing (Type {user.enneagram_type[0]} + {candidate.enneagram_type[0]})")
    
    # Big Five Compatibility
    if user.big_five and candidate.big_five:
        big_five_score = calculate_big_five_compatibility(user.big_five, candidate.big_five)
        scores['big_five'] = big_five_score
        if big_five_score >= 0.85:
            insights.append("Highly compatible personality traits")
    
    # Calculate weighted average
    if scores:
        overall_score = np.mean(list(scores.values()))
    else:
        overall_score = 0.5  # Neutral if no personality data
    
    return overall_score, insights

def calculate_behavioral_compatibility(user: UserProfile, candidate: UserProfile) -> float:
    """Calculate behavioral pattern compatibility"""
    if not user.behavioral_metrics or not candidate.behavioral_metrics:
        return 0.5  # Neutral score
    
    scores = []
    
    # Response time compatibility (similar response patterns)
    if user.behavioral_metrics.avg_response_time_minutes and candidate.behavioral_metrics.avg_response_time_minutes:
        time_diff = abs(user.behavioral_metrics.avg_response_time_minutes - candidate.behavioral_metrics.avg_response_time_minutes)
        if time_diff <= 30:
            scores.append(1.0)
        elif time_diff <= 60:
            scores.append(0.8)
        else:
            scores.append(0.6)
    
    # Active hours overlap
    if user.behavioral_metrics.active_hours and candidate.behavioral_metrics.active_hours:
        user_hours = set(user.behavioral_metrics.active_hours)
        cand_hours = set(candidate.behavioral_metrics.active_hours)
        overlap = len(user_hours.intersection(cand_hours))
        scores.append(min(overlap / 8, 1.0))  # Normalize to 0-1
    
    # Message length compatibility
    if user.behavioral_metrics.avg_message_length and candidate.behavioral_metrics.avg_message_length:
        length_ratio = min(user.behavioral_metrics.avg_message_length, candidate.behavioral_metrics.avg_message_length) / \
                      max(user.behavioral_metrics.avg_message_length, candidate.behavioral_metrics.avg_message_length)
        scores.append(length_ratio)
    
    return np.mean(scores) if scores else 0.5

def calculate_location_score(user: UserProfile, candidate: UserProfile, max_distance: int) -> tuple:
    """Calculate location compatibility score and distance"""
    if not all([user.latitude, user.longitude, candidate.latitude, candidate.longitude]):
        return 0.5, None
    
    distance = calculate_distance(
        user.latitude, user.longitude,
        candidate.latitude, candidate.longitude
    )
    
    # Filter by max distance
    if max_distance and distance > max_distance:
        return 0.0, distance
    
    # Score based on distance
    if distance <= 5:
        score = 1.0
    elif distance <= 10:
        score = 0.9
    elif distance <= 25:
        score = 0.7
    elif distance <= 50:
        score = 0.5
    else:
        score = 0.3
    
    return score, distance

def generate_match_insights(user: UserProfile, candidate: UserProfile, breakdown: CompatibilityBreakdown) -> MatchInsights:
    """Generate personalized match insights"""
    strengths = []
    growth_areas = []
    conversation_starters = []
    
    # Analyze strengths
    if breakdown.personality_score >= 0.80:
        strengths.append("Highly compatible personalities")
    if breakdown.interest_score >= 0.60:
        strengths.append(f"Share {int(breakdown.interest_score * 100)}% common interests")
    if breakdown.value_score >= 0.70:
        strengths.append("Strong alignment on core values")
    if breakdown.location_score >= 0.80:
        strengths.append("Live nearby - easy to meet up")
    
    # Identify growth areas
    if breakdown.communication_score < 0.60:
        growth_areas.append("Different communication styles - be patient")
    if breakdown.activity_score < 0.60:
        growth_areas.append("Different activity patterns - find common times")
    
    # Generate conversation starters based on shared interests
    shared_interests = set([i.lower() for i in user.interests]).intersection(
        set([i.lower() for i in candidate.interests])
    )
    
    for interest in list(shared_interests)[:3]:
        conversation_starters.append(f"Ask about their favorite {interest} experience")
    
    if user.mbti_type and candidate.mbti_type:
        conversation_starters.append(f"Discuss your personality types ({user.mbti_type} & {candidate.mbti_type})")
    
    # Generate summary
    if breakdown.personality_score + breakdown.interest_score + breakdown.value_score >= 2.1:
        summary = "Excellent match with strong compatibility across multiple dimensions!"
    elif breakdown.personality_score + breakdown.interest_score >= 1.4:
        summary = "Great potential match with good personality and interest alignment."
    else:
        summary = "Interesting match with unique complementary qualities."
    
    return MatchInsights(
        strengths=strengths or ["Unique pairing with growth potential"],
        growth_areas=growth_areas or ["Explore each other's differences"],
        conversation_starters=conversation_starters or ["Ask about their day", "Share a fun fact about yourself"],
        compatibility_summary=summary
    )

def predict_conversation_quality(user: UserProfile, candidate: UserProfile, overall_score: float) -> float:
    """Predict conversation quality based on compatibility factors"""
    # Base prediction on overall compatibility
    base_score = overall_score
    
    # Boost for shared interests (good conversation topics)
    if user.interests and candidate.interests:
        interest_boost = calculate_interest_similarity(user.interests, candidate.interests) * 0.2
        base_score = min(base_score + interest_boost, 1.0)
    
    # Boost for complementary personalities (interesting dynamics)
    if user.mbti_type and candidate.mbti_type:
        # Opposite E/I can create interesting conversations
        if user.mbti_type[0] != candidate.mbti_type[0]:
            base_score = min(base_score + 0.05, 1.0)
    
    return round(base_score, 2)

# ==================== API ENDPOINTS ====================

@app.get('/health')
def health():
    return {'status': 'ok', 'service': 'trish-ai-engine-advanced', 'version': '2.0'}

@app.post('/match')
def basic_match(request: MatchRequest):
    """
    Basic matching endpoint (backward compatible)
    Calculate match scores based on interests, age, and location
    """
    user = request.user
    candidates = request.candidates
    results = []
    
    for candidate in candidates:
        # Calculate interest similarity
        interest_score = calculate_interest_similarity(user.interests, candidate.interests)
        
        # Calculate age compatibility
        age_score = calculate_age_compatibility(user.age, candidate.age)
        
        # Calculate distance score
        distance = None
        distance_score = 0.5
        
        if user.latitude and user.longitude and candidate.latitude and candidate.longitude:
            distance = calculate_distance(
                user.latitude, user.longitude,
                candidate.latitude, candidate.longitude
            )
            
            if request.max_distance and distance > request.max_distance:
                continue
            
            if distance <= 5:
                distance_score = 1.0
            elif distance <= 10:
                distance_score = 0.9
            elif distance <= 25:
                distance_score = 0.7
            elif distance <= 50:
                distance_score = 0.5
            else:
                distance_score = 0.3
        
        # Composite score
        composite_score = (
            interest_score * 0.4 +
            age_score * 0.3 +
            distance_score * 0.3
        )
        
        results.append({
            'id': candidate.id,
            'name': candidate.name,
            'score': round(composite_score, 2),
            'interest_score': round(interest_score, 2),
            'distance': round(distance, 1) if distance else None
        })
    
    results.sort(key=lambda x: x['score'], reverse=True)
    return {'matches': results, 'for': user.id, 'count': len(results)}

@app.post('/advanced-match', response_model=Dict[str, Any])
def advanced_match(request: MatchRequest):
    """
    Advanced matching with 7-dimensional scoring:
    1. Interest Similarity (20%)
    2. Personality Compatibility (25%)
    3. Age Compatibility (10%)
    4. Location Proximity (15%)
    5. Value Alignment (15%)
    6. Communication Style (10%)
    7. Activity Pattern (5%)
    """
    user = request.user
    candidates = request.candidates
    results = []
    
    # Default weights
    default_weights = {
        'interest': 0.20,
        'personality': 0.25,
        'age': 0.10,
        'location': 0.15,
        'value': 0.15,
        'communication': 0.10,
        'activity': 0.05
    }
    
    # Use custom weights if provided
    weights = request.custom_weights or default_weights
    
    for candidate in candidates:
        # 1. Interest Similarity
        interest_score = calculate_interest_similarity(user.interests, candidate.interests)
        
        # 2. Personality Compatibility
        personality_score, personality_insights = calculate_personality_compatibility(user, candidate)
        
        # 3. Age Compatibility
        age_score = calculate_age_compatibility(user.age, candidate.age)
        
        # 4. Location Proximity
        location_score, distance = calculate_location_score(user, candidate, request.max_distance)
        
        # Skip if outside max distance
        if location_score == 0.0 and distance and request.max_distance:
            continue
        
        # 5. Value Alignment
        value_score = calculate_value_alignment(user.values or [], candidate.values or [])
        
        # 6. Communication Style (behavioral)
        communication_score = calculate_behavioral_compatibility(user, candidate)
        
        # 7. Activity Pattern
        activity_score = communication_score  # Use same behavioral metrics for now
        
        # Create breakdown
        breakdown = CompatibilityBreakdown(
            interest_score=round(interest_score, 2),
            personality_score=round(personality_score, 2),
            age_score=round(age_score, 2),
            location_score=round(location_score, 2),
            value_score=round(value_score, 2),
            communication_score=round(communication_score, 2),
            activity_score=round(activity_score, 2)
        )
        
        # Calculate overall score
        overall_score = (
            interest_score * weights['interest'] +
            personality_score * weights['personality'] +
            age_score * weights['age'] +
            location_score * weights['location'] +
            value_score * weights['value'] +
            communication_score * weights['communication'] +
            activity_score * weights['activity']
        )
        
        # Generate insights
        insights = generate_match_insights(user, candidate, breakdown)
        
        # Predict conversation quality
        conversation_quality = predict_conversation_quality(user, candidate, overall_score)
        
        results.append(AdvancedMatchResult(
            id=candidate.id,
            name=candidate.name,
            overall_score=round(overall_score, 2),
            breakdown=breakdown,
            insights=insights,
            distance=round(distance, 1) if distance else None,
            predicted_conversation_quality=conversation_quality
        ))
    
    # Sort by overall score
    results.sort(key=lambda x: x.overall_score, reverse=True)
    
    return {
        'matches': [r.dict() for r in results],
        'for': user.id,
        'count': len(results),
        'algorithm_version': '2.0',
        'weights_used': weights
    }

@app.post('/personality-compatibility', response_model=PersonalityCompatibilityResponse)
def personality_compatibility(request: PersonalityCompatibilityRequest):
    """Get detailed personality compatibility analysis"""
    scores = {}
    insights = []
    
    # MBTI Analysis
    if request.user_mbti and request.candidate_mbti:
        mbti_score = calculate_mbti_compatibility(request.user_mbti, request.candidate_mbti)
        scores['mbti'] = mbti_score
        
        if mbti_score >= 0.85:
            insights.append(f"Excellent MBTI pairing: {request.user_mbti} and {request.candidate_mbti} complement each other beautifully")
        elif mbti_score >= 0.70:
            insights.append(f"Good MBTI compatibility with balanced dynamics")
        else:
            insights.append(f"Different MBTI types can bring fresh perspectives")
    
    # Enneagram Analysis
    if request.user_enneagram and request.candidate_enneagram:
        enne_score = calculate_enneagram_compatibility(request.user_enneagram, request.candidate_enneagram)
        scores['enneagram'] = enne_score
        
        if enne_score >= 0.80:
            insights.append(f"Strong Enneagram compatibility - Type {request.user_enneagram[0]} and {request.candidate_enneagram[0]} work well together")
    
    # Big Five Analysis
    if request.user_big_five and request.candidate_big_five:
        big_five_score = calculate_big_five_compatibility(request.user_big_five, request.candidate_big_five)
        scores['big_five'] = big_five_score
        
        if big_five_score >= 0.85:
            insights.append("Personality traits are highly compatible for a lasting relationship")
        
        # Specific trait insights
        agreeableness_diff = abs(request.user_big_five.agreeableness - request.candidate_big_five.agreeableness)
        if agreeableness_diff <= 15:
            insights.append("Similar levels of agreeableness suggest smooth conflict resolution")
    
    # Calculate overall score
    overall_score = np.mean(list(scores.values())) if scores else 0.5
    
    return PersonalityCompatibilityResponse(
        mbti_score=scores.get('mbti'),
        enneagram_score=scores.get('enneagram'),
        big_five_score=scores.get('big_five'),
        overall_personality_score=round(overall_score, 2),
        insights=insights or ["Complete personality tests for detailed compatibility analysis"]
    )

@app.post('/predict-conversation-quality')
def predict_quality(request: MatchRequest):
    """Predict conversation quality for a specific match"""
    if not request.candidates:
        raise HTTPException(status_code=400, detail="No candidate provided")
    
    candidate = request.candidates[0]
    
    # Calculate overall compatibility
    personality_score, _ = calculate_personality_compatibility(request.user, candidate)
    interest_score = calculate_interest_similarity(request.user.interests, candidate.interests)
    
    overall_score = (personality_score + interest_score) / 2
    
    # Predict conversation quality
    quality_score = predict_conversation_quality(request.user, candidate, overall_score)
    
    # Generate prediction insights
    if quality_score >= 0.80:
        prediction = "Excellent - High likelihood of engaging conversations"
        tips = ["Be yourself", "Ask open-ended questions", "Share personal stories"]
    elif quality_score >= 0.60:
        prediction = "Good - Solid foundation for meaningful dialogue"
        tips = ["Focus on shared interests", "Be curious about differences", "Listen actively"]
    else:
        prediction = "Moderate - May require effort to find common ground"
        tips = ["Ask about their passions", "Share unique experiences", "Be patient and open-minded"]
    
    return {
        'quality_score': quality_score,
        'prediction': prediction,
        'conversation_tips': tips,
        'shared_interests': list(set([i.lower() for i in request.user.interests]).intersection(
            set([i.lower() for i in candidate.interests])
        ))
    }

@app.post('/behavioral-analysis')
def behavioral_analysis(request: MatchRequest):
    """Analyze behavioral compatibility between users"""
    if not request.candidates:
        raise HTTPException(status_code=400, detail="No candidate provided")
    
    candidate = request.candidates[0]
    
    if not request.user.behavioral_metrics or not candidate.behavioral_metrics:
        return {
            'compatibility_score': 0.5,
            'analysis': "Insufficient behavioral data for detailed analysis",
            'recommendations': ["Continue chatting to gather more data"]
        }
    
    compatibility_score = calculate_behavioral_compatibility(request.user, candidate)
    
    analysis = []
    recommendations = []
    
    # Response time analysis
    if request.user.behavioral_metrics.avg_response_time_minutes and candidate.behavioral_metrics.avg_response_time_minutes:
        user_time = request.user.behavioral_metrics.avg_response_time_minutes
        cand_time = candidate.behavioral_metrics.avg_response_time_minutes
        
        if abs(user_time - cand_time) <= 30:
            analysis.append("Similar response times - good communication rhythm")
        else:
            analysis.append("Different response patterns - be patient with reply times")
            recommendations.append("Don't expect immediate responses")
    
    # Activity overlap
    if request.user.behavioral_metrics.active_hours and candidate.behavioral_metrics.active_hours:
        overlap = len(set(request.user.behavioral_metrics.active_hours).intersection(
            set(candidate.behavioral_metrics.active_hours)
        ))
        
        if overlap >= 6:
            analysis.append(f"Great activity overlap - {overlap} hours of common active time")
        else:
            analysis.append("Different schedules - plan conversations accordingly")
            recommendations.append("Schedule calls during overlapping active hours")
    
    return {
        'compatibility_score': round(compatibility_score, 2),
        'analysis': analysis or ["Behavioral patterns are being analyzed"],
        'recommendations': recommendations or ["Continue interacting naturally"]
    }

# ==================== CHAT SECURITY ENDPOINTS ====================

# Import chat security module
from chat_security import (
    Message,
    ConversationAnalysisRequest,
    SafetyAnalysisResponse,
    ContentModerationResponse,
    analyze_conversation_safety,
    moderate_content,
    analyze_conversation_patterns
)

@app.post('/analyze-conversation-security', response_model=SafetyAnalysisResponse)
def analyze_security(request: ConversationAnalysisRequest):
    """
    Analyze conversation for security threats, red flags, and safety concerns
    Returns comprehensive safety analysis with warnings and recommendations
    """
    return analyze_conversation_safety(request)

@app.post('/moderate-message')
def moderate_message(message: str):
    """
    Moderate individual message for inappropriate content
    Returns moderation decision and required action
    """
    result = moderate_content(message)
    return result.dict()

@app.post('/check-message-safety')
def check_message_safety(message: str):
    """
    Quick safety check for a single message
    Returns simple safe/unsafe boolean with reason
    """
    moderation = moderate_content(message)
    
    # Create a simple message object for red flag detection
    from chat_security import detect_red_flags, Message as ChatMessage
    msg = ChatMessage(id="temp", sender_id="temp", content=message)
    red_flags = detect_red_flags([msg])
    
    critical_flags = [f for f in red_flags if f.severity in ['CRITICAL', 'HIGH']]
    
    is_safe = moderation.is_appropriate and len(critical_flags) == 0
    
    reasons = []
    if not moderation.is_appropriate:
        reasons.extend(moderation.violations)
    if critical_flags:
        is_safe = False
        reasons.extend([f.reason for f in critical_flags])
    
    return {
        "is_safe": is_safe,
        "reason": "; ".join(reasons) if reasons else "Message appears safe"
    }

@app.post('/wingman/chat', response_model=WingmanResponse)
def wingman_chat(request: WingmanRequest):
    """
    AI Dating Coach (Wingman) Chat
    Returns advice, conversation starters, or emotional support.
    """
    # In a real implementation, this would call OpenAI/Gemini/Anthropic API
    # with a system prompt like: "You are Trish, a world-class dating coach..."
    
    user_msg = request.message.lower()
    tone = request.tone
    
    response_text = ""
    educational_tidbit = ""
    suggested_actions = []

    # Simple rule-based logic for demo (replace with LLM call)
    if "ghosted" in user_msg or "no reply" in user_msg:
        response_text = "I know it hurts to be left on read. Remember, their silence is often about their own capacity, not your worth. Give it 48 hours before sending a playful 'check-in' meme, then let it go."
        suggested_actions = ["Send a funny GIF", "Focus on other matches", "Archive conversation"]
        
    elif "nervous" in user_msg or "anxious" in user_msg:
        response_text = "It's totally normal to feel butterflies! That just means you care. Try to reframe that anxiety as excitement. What's the worst that could happen? You have a funny story for later."
        suggested_actions = ["Do a breathing exercise", "Review their profile", "Listen to hype music"]
        
    elif "opener" in user_msg or "start" in user_msg or "say" in user_msg:
        if request.context:
            response_text = f"Since you mentioned '{request.context}', try connecting on that! Shared interests are the best bridge."
            suggested_actions = [f"Ask about {request.context}", "Share a related photo", "Send a voice note"]
        else:
            response_text = "Without specific context, questions are your best friend. People love talking about themselves! Try asking about their 'perfect Sunday' or a travel memory."
            suggested_actions = ["Ask: 'What's the highlight of your week?'", "Ask: 'Top 3 travel destinations?'"]
            
    elif "date" in user_msg and "idea" in user_msg:
         response_text = "For a great date, aim for activity + conversation. 'Active' dates (bowling, walking, arcade) reduce awkward silences compared to just dinner."
         suggested_actions = ["Arcade Bar night", "Sunset walk", "Coffee + Bookstore"]
         
    else:
        # Generic supportive response
        response_text = "I'm here to help! Whether you need a confidence boost, a clever reply, or just to vent, I've got your back. What's on your mind regarding your matches?"
        suggested_actions = ["Ask for profile advice", "Practice conversation", "Discuss safety"]

    return WingmanResponse(
        response=response_text,
        suggested_actions=suggested_actions
    )


@app.post('/analyze-conversation-patterns')
def analyze_patterns(request: ConversationAnalysisRequest):
    """
    Analyze conversation patterns for suspicious behavior
    Returns engagement metrics and pattern analysis
    """
    patterns = analyze_conversation_patterns(request.messages, request.user_id)
    
    # Add red flag detection
    from chat_security import detect_red_flags
    red_flags = detect_red_flags(request.messages)
    
    patterns['red_flags_count'] = len(red_flags)
    patterns['has_critical_flags'] = any(f.severity == 'CRITICAL' for f in red_flags)
    
    return patterns

@app.post('/real-time-safety-check')
def real_time_safety_check(
    conversation_id: str,
    new_message: str,
    sender_id: str,
    conversation_history: List[Dict[str, str]]
):
    """
    Real-time safety check for incoming messages
    Analyzes new message in context of conversation history
    """
    from chat_security import Message as ChatMessage, detect_red_flags, moderate_content, analyze_sentiment
    
    # Convert history to Message objects
    messages = []
    for msg in conversation_history:
        messages.append(ChatMessage(
            id=msg.get('id', 'temp'),
            sender_id=msg.get('sender_id', 'unknown'),
            content=msg.get('content', '')
        ))
    
    # Add new message
    new_msg = ChatMessage(id='new', sender_id=sender_id, content=new_message)
    messages.append(new_msg)
    
    # Moderate the new message
    moderation = moderate_content(new_message)
    
    # Detect red flags in full conversation
    red_flags = detect_red_flags(messages)
    
    # Analyze sentiment
    sentiment = analyze_sentiment(messages)
    
    # Check if message should be blocked
    should_block = (
        moderation.action_required == 'BAN' or
        any(f.severity == 'CRITICAL' for f in red_flags)
    )
    
    # Check if warning should be shown
    should_warn = (
        moderation.action_required == 'WARN' or
        any(f.severity in ['HIGH', 'MEDIUM'] for f in red_flags)
    )
    
    warnings = []
    if should_warn:
        if not moderation.is_appropriate:
            warnings.append(f"This message contains: {', '.join(moderation.violations)}")
        for flag in red_flags:
            if flag.severity in ['CRITICAL', 'HIGH']:
                warnings.append(flag.description)
    
    return {
        'conversation_id': conversation_id,
        'should_block': should_block,
        'should_warn': should_warn,
        'warnings': warnings,
        'moderation_result': moderation.dict(),
        'red_flags': [f.dict() for f in red_flags],
        'sentiment_score': round(sentiment, 2),
        'sentiment_label': 'positive' if sentiment > 0.3 else 'negative' if sentiment < -0.3 else 'neutral'
    }

@app.get('/safety-statistics')
def safety_statistics():
    """
    Get statistics about safety patterns and common red flags
    Useful for admin dashboard
    """
    return {
        'total_red_flag_categories': 8,
        'categories': [
            {'name': 'Financial Scam', 'severity': 'CRITICAL', 'patterns': len(FINANCIAL_SCAM_PATTERNS)},
            {'name': 'Personal Info Request', 'severity': 'HIGH', 'patterns': len(PERSONAL_INFO_PATTERNS)},
            {'name': 'Inappropriate Content', 'severity': 'HIGH', 'patterns': len(INAPPROPRIATE_PATTERNS)},
            {'name': 'Harassment', 'severity': 'CRITICAL', 'patterns': len(HARASSMENT_PATTERNS)},
            {'name': 'Off-Platform Request', 'severity': 'MEDIUM', 'patterns': len(OFF_PLATFORM_PATTERNS)},
            {'name': 'Age Concern', 'severity': 'CRITICAL', 'patterns': len(AGE_CONCERN_PATTERNS)},
            {'name': 'Catfish Indicator', 'severity': 'MEDIUM', 'patterns': len(CATFISH_PATTERNS)},
            {'name': 'Pressure Tactics', 'severity': 'MEDIUM', 'patterns': len(PRESSURE_PATTERNS)}
        ],
        'sentiment_analysis': {
            'positive_words_tracked': len(POSITIVE_WORDS),
            'negative_words_tracked': len(NEGATIVE_WORDS)
        },
        'content_moderation': {
            'actions': ['NONE', 'WARN', 'BLOCK', 'BAN'],
            'severity_levels': ['NONE', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
        }
    }

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=8000)

