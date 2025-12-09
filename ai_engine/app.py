from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import CountVectorizer
import math

app = FastAPI(title='TRISH AI Engine')

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class UserProfile(BaseModel):
    id: str
    name: str
    age: int
    interests: List[str] = []
    latitude: Optional[float] = None
    longitude: Optional[float] = None

class MatchRequest(BaseModel):
    user: UserProfile
    candidates: List[UserProfile]
    max_distance: Optional[int] = 50  # km

class MatchResult(BaseModel):
    id: str
    name: str
    score: float
    interest_score: float
    distance: Optional[float] = None

@app.get('/health')
def health():
    return {'status': 'ok', 'service': 'trish-ai-engine'}

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
    
    set1 = set(interests1)
    set2 = set(interests2)
    
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

@app.post('/match')
def match(request: MatchRequest):
    """
    Calculate match scores for candidates based on:
    - Interest similarity (40%)
    - Age compatibility (30%)
    - Location proximity (30%)
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
        distance_score = 0.5  # Default neutral score
        
        if user.latitude and user.longitude and candidate.latitude and candidate.longitude:
            distance = calculate_distance(
                user.latitude, user.longitude,
                candidate.latitude, candidate.longitude
            )
            
            # Filter by max distance
            if request.max_distance and distance > request.max_distance:
                continue  # Skip this candidate
            
            # Score based on distance (closer = better)
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
        
        # Composite score (weighted average)
        composite_score = (
            interest_score * 0.4 +
            age_score * 0.3 +
            distance_score * 0.3
        )
        
        results.append(MatchResult(
            id=candidate.id,
            name=candidate.name,
            score=round(composite_score, 2),
            interest_score=round(interest_score, 2),
            distance=round(distance, 1) if distance else None
        ))
    
    # Sort by score (highest first)
    results.sort(key=lambda x: x.score, reverse=True)
    
    return {'matches': results, 'for': user.id, 'count': len(results)}

