# 🚀 TRISH Dating App - Complete Setup & Demo Guide

## ✅ **Current Status**

### **Running Services:**
- ✅ **Backend (Spring Boot)**: http://localhost:8080
  - Health Check: http://localhost:8080/api/health
- ✅ **React Frontend (Vite)**: http://localhost:5173
- ✅ **AI Engine**: http://localhost:8000
  - Health Check: http://localhost:8000/health
  - API Docs: http://localhost:8000/docs

### **Not Running (Requires Installation):**
- ❌ Frontend (Flutter) - Requires Flutter SDK
- ❌ Database (PostgreSQL) - Requires Docker (recommended for production)

---

## 🎯 **Quick Demo - AI Matching Engine**

The AI matching engine is currently running! You can test it right now.

### **Test the AI Matching API**

Open your browser and visit:
- **API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health

### **Example API Call**

You can test the matching algorithm with this PowerShell command:

```powershell
$body = @{
    user = @{
        id = "1"
        name = "John"
        age = 28
        interests = @("Travel", "Music", "Food")
        latitude = 28.6139
        longitude = 77.2090
    }
    candidates = @(
        @{
            id = "2"
            name = "Sarah"
            age = 26
            interests = @("Travel", "Food", "Movies")
            latitude = 28.7041
            longitude = 77.1025
        },
        @{
            id = "3"
            name = "Emma"
            age = 30
            interests = @("Music", "Art", "Reading")
            latitude = 28.5355
            longitude = 77.3910
        }
    )
    max_distance = 50
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "http://localhost:8000/match" -Method Post -Body $body -ContentType "application/json"
```

---

## 📋 **Complete Setup Instructions**

To run the **FULL APP**, you need to install the following:

### **1. Install Docker Desktop** 🐳
- Download: https://www.docker.com/products/docker-desktop
- Install Docker Desktop for Windows
- Restart your computer after installation

### **2. Install Java Development Kit (JDK 17+)** ☕
- Download: https://www.oracle.com/java/technologies/downloads/#java17
- Or use OpenJDK: https://adoptium.net/
- Add to PATH environment variable

### **3. Install Flutter SDK** 📱
- Download: https://docs.flutter.dev/get-started/install/windows
- Extract to C:\flutter
- Add C:\flutter\bin to PATH
- Run: `flutter doctor` to verify installation

### **4. Install Maven (Optional - for backend development)** 📦
- Download: https://maven.apache.org/download.cgi
- Extract and add to PATH

---

## 🚀 **Running the Full Stack (After Installation)**

### **Step 1: Start Backend Services with Docker**

```powershell
cd "c:\Users\44743\Downloads\TRISH_bundle (1)\deployment"
docker compose up --build -d
```

This will start:
- PostgreSQL Database (Port 5432)
- Spring Boot Backend (Port 8080)
- FastAPI AI Engine (Port 8000)

### **Step 2: Verify Services**

```powershell
# Check if containers are running
docker compose ps

# Check backend health
Invoke-RestMethod -Uri "http://localhost:8080/api/health"

# Check AI engine health
Invoke-RestMethod -Uri "http://localhost:8000/health"
```

### **Step 3: Run React App (Recommended)**

```powershell
cd "c:\Users\44743\Downloads\TRISH_bundle (1)\frontend_react"
npm install
npm run dev
```

Open: http://localhost:5173

### **Step 4: Run Flutter App (Optional)**

```powershell
cd "c:\Users\44743\Downloads\TRISH_bundle (1)\frontend"

# Get dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Android emulator needs 10.0.2.2 to reach your host machine
flutter run --dart-define=ENV=dev --dart-define=API_URL=http://10.0.2.2:8080 --dart-define=AI_ENGINE_URL=http://10.0.2.2:8000
```

---

## 🌐 **Alternative: Deploy to Cloud**

If you want to see the app without installing everything locally, you can deploy to cloud:

### **Option 1: Deploy to Railway.app** 🚂
1. Go to https://railway.app
2. Connect your GitHub repository
3. Deploy backend and AI engine
4. Get public URLs

### **Option 2: Deploy to Render.com** 🎨
1. Go to https://render.com
2. Connect GitHub repository
3. Create services for:
   - PostgreSQL Database
   - Spring Boot Backend
   - FastAPI AI Engine

### **Option 3: Deploy to Heroku** 💜
1. Install Heroku CLI
2. Deploy each service separately

---

## 📱 **App Flow Overview**

### **1. User Registration & Login**
```
Register Screen → Enter Details → Create Account → Login
```

### **2. Profile Setup**
```
Onboarding → Upload Photos → Set Preferences → Complete Personality Test
```

### **3. Matching & Swiping**
```
Home Screen → View Profiles → Swipe Right (Like) / Left (Pass) → Match!
```

### **4. Messaging**
```
Matches Screen → Select Match → Chat Screen → Send Messages
```

### **5. Gifts & E-commerce**
```
Gifts Screen → Browse Catalog → Select Gift → Add to Cart → Purchase with Wallet
```

### **6. Wallet Management**
```
Wallet Screen → Add Money → View Balance → Transaction History
```

### **7. KYC Verification**
```
Profile → Verify Identity → Upload Documents → Get Verified Badge
```

### **8. Premium Subscription**
```
Profile → Upgrade → Select Plan → Pay → Unlock Premium Features
```

---

## 🧪 **Testing the AI Engine (Currently Running)**

### **Test 1: Health Check**
```powershell
Invoke-RestMethod -Uri "http://localhost:8000/health"
```

**Expected Response:**
```json
{
  "status": "ok",
  "service": "trish-ai-engine"
}
```

### **Test 2: Match Recommendations**
Visit: http://localhost:8000/docs

Try the `/match` endpoint with sample data.

---

## 📊 **API Endpoints Overview**

### **Backend APIs (Port 8080)**
```
Authentication:
POST   /api/auth/register
POST   /api/auth/login

Users:
GET    /api/users/profile
PUT    /api/users/profile
POST   /api/users/photos

Matching:
POST   /api/swipes
GET    /api/matches
GET    /api/recommendations

Messaging:
POST   /api/messages
GET    /api/messages/match/{matchId}

Gifts:
GET    /api/gifts
POST   /api/gifts/send
GET    /api/gifts/sent
GET    /api/gifts/received

Wallet:
GET    /api/wallet
POST   /api/wallet/add-money
POST   /api/wallet/withdraw
GET    /api/wallet/transactions

KYC:
GET    /api/kyc/status
POST   /api/kyc/submit
POST   /api/kyc/verify-aadhar
POST   /api/kyc/verify-pan

Subscriptions:
GET    /api/subscription/current
POST   /api/subscription/subscribe
GET    /api/subscription/plans

Personality:
GET    /api/personality/profile
POST   /api/personality/test
GET    /api/personality/compatibility/{userId}

AI Assistant:
POST   /api/ai/chat-suggestions
GET    /api/ai/icebreakers
GET    /api/ai/analyze-conversation/{matchId}
```

### **AI Engine APIs (Port 8000)**
```
GET    /health
POST   /match
```

---

## 🎬 **Demo Scenarios**

### **Scenario 1: User Registration Flow**
1. Open app → Register screen
2. Enter: Name, Email, Password, Age, Gender
3. Upload 3-6 photos
4. Set preferences (age range, distance, gender)
5. Add interests
6. Complete!

### **Scenario 2: Matching Flow**
1. Home screen shows potential matches
2. AI ranks profiles based on:
   - Interest similarity (40%)
   - Age compatibility (30%)
   - Location proximity (30%)
3. Swipe right to like, left to pass
4. If both like → It's a match!

### **Scenario 3: Gift Flow**
1. Match with someone
2. Go to Gifts screen
3. Browse categories (Flowers, Chocolates, etc.)
4. Select gift
5. Add personal message
6. Pay with wallet
7. Track delivery

### **Scenario 4: Premium Upgrade**
1. Profile → Upgrade
2. View plans (Basic ₹299, Premium ₹599, VIP ₹1299)
3. Select plan
4. Apply promo code (optional)
5. Pay with wallet
6. Unlock features:
   - Unlimited swipes
   - See who liked you
   - Rewind
   - Boost
   - Ad-free

---

## 🔧 **Troubleshooting**

### **AI Engine Not Starting**
```powershell
# Check if port 8000 is in use
netstat -ano | findstr :8000

# Kill process if needed
taskkill /PID <process_id> /F

# Restart AI engine
cd "c:\Users\44743\Downloads\TRISH_bundle (1)\ai_engine"
uvicorn app:app --reload
```

### **Backend Not Starting**
- Ensure Java 17+ is installed
- Check if port 8080 is available
- Verify PostgreSQL is running

### **Flutter App Issues**
```powershell
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 📞 **Support & Resources**

- **GitHub Repository**: https://github.com/aayu0401/TRISH-APP
- **API Documentation**: http://localhost:8000/docs (when running)
- **Implementation Summary**: See IMPLEMENTATION_SUMMARY.md

---

## 🎉 **Next Steps**

1. **Install Docker** to run the full stack
2. **Test the AI Engine** (currently running at http://localhost:8000)
3. **Deploy to cloud** for public access
4. **Integrate payment gateway** (Razorpay/Stripe)
5. **Submit to app stores** (Google Play, App Store)

---

**The AI matching engine is running NOW! Visit http://localhost:8000/docs to try it!** 🚀
