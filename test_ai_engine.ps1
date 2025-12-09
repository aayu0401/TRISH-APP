# Test TRISH AI Matching Engine

Write-Host "🚀 Testing TRISH AI Matching Engine" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "Test 1: Health Check" -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8000/health" -Method Get
    Write-Host "✅ AI Engine is running!" -ForegroundColor Green
    Write-Host "   Status: $($health.status)" -ForegroundColor Green
    Write-Host "   Service: $($health.service)" -ForegroundColor Green
} catch {
    Write-Host "❌ AI Engine is not running!" -ForegroundColor Red
    Write-Host "   Please start it with: uvicorn app:app --reload" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Test 2: AI Matching Algorithm
Write-Host "Test 2: AI Matching Algorithm" -ForegroundColor Yellow
Write-Host ""

$matchRequest = @{
    user = @{
        id = "1"
        name = "John Doe"
        age = 28
        interests = @("Travel", "Music", "Food", "Photography")
        latitude = 28.6139
        longitude = 77.2090
    }
    candidates = @(
        @{
            id = "2"
            name = "Sarah Smith"
            age = 26
            interests = @("Travel", "Food", "Movies", "Photography")
            latitude = 28.7041
            longitude = 77.1025
        },
        @{
            id = "3"
            name = "Emma Johnson"
            age = 30
            interests = @("Music", "Art", "Reading", "Yoga")
            latitude = 28.5355
            longitude = 77.3910
        },
        @{
            id = "4"
            name = "Lisa Anderson"
            age = 27
            interests = @("Travel", "Music", "Food", "Fitness")
            latitude = 28.6289
            longitude = 77.2065
        },
        @{
            id = "5"
            name = "Amy Wilson"
            age = 32
            interests = @("Cooking", "Gardening", "Books")
            latitude = 28.4595
            longitude = 77.0266
        }
    )
    max_distance = 50
} | ConvertTo-Json -Depth 10

Write-Host "👤 User Profile:" -ForegroundColor Cyan
Write-Host "   Name: John Doe" -ForegroundColor White
Write-Host "   Age: 28" -ForegroundColor White
Write-Host "   Interests: Travel, Music, Food, Photography" -ForegroundColor White
Write-Host "   Location: Delhi (28.6139, 77.2090)" -ForegroundColor White
Write-Host ""

Write-Host "🔍 Finding matches from 4 candidates..." -ForegroundColor Cyan
Write-Host ""

try {
    $result = Invoke-RestMethod -Uri "http://localhost:8000/match" -Method Post -Body $matchRequest -ContentType "application/json"
    
    Write-Host "✅ Match Results:" -ForegroundColor Green
    Write-Host "   Total Matches Found: $($result.count)" -ForegroundColor Green
    Write-Host ""
    
    $rank = 1
    foreach ($match in $result.matches) {
        Write-Host "   Rank #$rank: $($match.name)" -ForegroundColor Yellow
        Write-Host "      Overall Score: $($match.score * 100)%" -ForegroundColor White
        Write-Host "      Interest Match: $($match.interest_score * 100)%" -ForegroundColor White
        if ($match.distance) {
            Write-Host "      Distance: $($match.distance) km" -ForegroundColor White
        }
        Write-Host ""
        $rank++
    }
    
    Write-Host "🎯 AI Matching Algorithm Breakdown:" -ForegroundColor Cyan
    Write-Host "   • Interest Similarity: 40% weight" -ForegroundColor White
    Write-Host "   • Age Compatibility: 30% weight" -ForegroundColor White
    Write-Host "   • Location Proximity: 30% weight" -ForegroundColor White
    Write-Host ""
    
    Write-Host "✨ The AI ranked candidates based on compatibility!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error calling match API:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🌐 Visit http://localhost:8000/docs for interactive API testing!" -ForegroundColor Cyan
Write-Host ""
