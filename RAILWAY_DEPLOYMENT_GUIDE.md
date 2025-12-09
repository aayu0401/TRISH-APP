# 🚂 Railway Deployment Guide for TRISH Dating App

## 📋 **Overview**

This guide will help you deploy the TRISH Dating App to Railway.app with all services running.

---

## 🎯 **Services to Deploy**

1. **PostgreSQL Database** (Railway Plugin)
2. **AI Engine** (FastAPI - Python)
3. **Backend API** (Spring Boot - Java)

---

## 🚀 **Step-by-Step Deployment**

### **Step 1: Create Railway Account**

1. Go to https://railway.app
2. Click "Login" → Sign in with GitHub
3. Authorize Railway to access your repositories

---

### **Step 2: Create New Project**

1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose: `aayu0401/TRISH-APP`
4. Railway will detect your repository

---

### **Step 3: Deploy PostgreSQL Database**

1. In your Railway project, click "+ New"
2. Select "Database" → "PostgreSQL"
3. Railway will provision a PostgreSQL database
4. **Copy the connection details** (you'll need these later)

**Environment Variables (Auto-generated):**
- `DATABASE_URL`
- `PGHOST`
- `PGPORT`
- `PGUSER`
- `PGPASSWORD`
- `PGDATABASE`

---

### **Step 4: Deploy AI Engine (FastAPI)**

1. Click "+ New" → "GitHub Repo"
2. Select your repository
3. **Root Directory**: Set to `ai_engine`
4. Railway will auto-detect Python

**Environment Variables to Add:**
```
PORT=8000
```

**Build Settings:**
- Build Command: `pip install -r requirements.txt`
- Start Command: `uvicorn app:app --host 0.0.0.0 --port $PORT`

**Health Check:**
- Path: `/health`
- Timeout: 100 seconds

---

### **Step 5: Deploy Backend (Spring Boot)**

1. Click "+ New" → "GitHub Repo"
2. Select your repository
3. **Root Directory**: Set to `backend`
4. Railway will auto-detect Java/Maven

**Environment Variables to Add:**
```
PORT=8080
SPRING_DATASOURCE_URL=jdbc:postgresql://${PGHOST}:${PGPORT}/${PGDATABASE}
SPRING_DATASOURCE_USERNAME=${PGUSER}
SPRING_DATASOURCE_PASSWORD=${PGPASSWORD}
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION=86400000
```

**Build Settings:**
- Build Command: `mvn clean package -DskipTests`
- Start Command: `java -Dserver.port=$PORT -jar target/*.jar`

**Health Check:**
- Path: `/api/health`
- Timeout: 300 seconds

---

## 🔗 **Service Configuration**

### **AI Engine Configuration**

**Files Created:**
- ✅ `ai_engine/railway.toml`
- ✅ `ai_engine/Procfile`
- ✅ `ai_engine/runtime.txt`

**Public URL:** Railway will generate (e.g., `https://trish-ai-production.up.railway.app`)

---

### **Backend Configuration**

**Files Created:**
- ✅ `backend/railway.toml`
- ✅ `backend/Procfile`

**Public URL:** Railway will generate (e.g., `https://trish-backend-production.up.railway.app`)

---

## 🔧 **Environment Variables Reference**

### **Backend Service**

| Variable | Value | Description |
|----------|-------|-------------|
| `PORT` | `8080` | Server port (Railway auto-assigns) |
| `SPRING_DATASOURCE_URL` | From Railway DB | PostgreSQL connection URL |
| `SPRING_DATASOURCE_USERNAME` | From Railway DB | Database username |
| `SPRING_DATASOURCE_PASSWORD` | From Railway DB | Database password |
| `JWT_SECRET` | Your secret key | JWT signing key |
| `JWT_EXPIRATION` | `86400000` | Token expiration (24 hours) |

### **AI Engine Service**

| Variable | Value | Description |
|----------|-------|-------------|
| `PORT` | `8000` | Server port (Railway auto-assigns) |

---

## 📱 **Update Flutter App Configuration**

After deployment, update your Flutter app to use the Railway URLs:

**Edit: `frontend/lib/config.dart`**

```dart
// Replace with your Railway URLs
const String API_URL = 'https://trish-backend-production.up.railway.app';
const String AI_URL = 'https://trish-ai-production.up.railway.app';
const String WS_URL = 'wss://trish-backend-production.up.railway.app/ws/chat';
```

---

## ✅ **Verify Deployment**

### **1. Check AI Engine**
```bash
curl https://your-ai-engine-url.up.railway.app/health
```

**Expected Response:**
```json
{
  "status": "ok",
  "service": "trish-ai-engine"
}
```

### **2. Check Backend**
```bash
curl https://your-backend-url.up.railway.app/api/health
```

**Expected Response:**
```json
{
  "status": "UP"
}
```

### **3. Test Registration**
```bash
curl -X POST https://your-backend-url.up.railway.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "age": 25,
    "gender": "MALE"
  }'
```

---

## 🎯 **Railway Dashboard Features**

### **Monitoring**
- View logs in real-time
- Monitor CPU/Memory usage
- Track deployment history

### **Scaling**
- Upgrade to Pro for autoscaling
- Increase resources as needed

### **Custom Domains**
- Add your own domain
- Automatic SSL certificates

---

## 💰 **Pricing**

### **Free Tier (Hobby Plan)**
- $5 free credit per month
- Enough for development/testing
- All services included

### **Pro Plan**
- $20/month
- More resources
- Priority support
- Custom domains

---

## 🔄 **Continuous Deployment**

Railway automatically deploys when you push to GitHub:

```bash
# Make changes to your code
git add .
git commit -m "Update feature"
git push origin main

# Railway will automatically:
# 1. Detect the push
# 2. Build the services
# 3. Deploy updates
# 4. Run health checks
```

---

## 🐛 **Troubleshooting**

### **Build Fails**

**Check Logs:**
1. Go to Railway dashboard
2. Click on the failing service
3. View "Deployments" tab
4. Check build logs

**Common Issues:**
- Missing dependencies in `pom.xml` or `requirements.txt`
- Incorrect build commands
- Out of memory (upgrade plan)

### **Service Won't Start**

**Check:**
- Environment variables are set correctly
- Database connection is working
- Port is set to `$PORT` (Railway assigns dynamically)

### **Database Connection Issues**

**Verify:**
```bash
# In Railway dashboard, check PostgreSQL service
# Copy connection string and test locally
```

---

## 📊 **Deployment Checklist**

- ✅ PostgreSQL database created
- ✅ AI Engine deployed with health check
- ✅ Backend deployed with health check
- ✅ Environment variables configured
- ✅ Services can communicate
- ✅ Health endpoints responding
- ✅ Flutter app updated with URLs
- ✅ Test registration/login working

---

## 🌐 **Alternative: Deploy Each Service Separately**

If Railway doesn't work, try these alternatives:

### **Option 1: Render.com**
- Free tier available
- Similar to Railway
- Good for Spring Boot apps

### **Option 2: Heroku**
- Classic PaaS
- Good documentation
- PostgreSQL add-on available

### **Option 3: Google Cloud Run**
- Pay per use
- Scales to zero
- Good for containers

---

## 📞 **Support**

- **Railway Docs**: https://docs.railway.app
- **Railway Discord**: https://discord.gg/railway
- **GitHub Issues**: https://github.com/aayu0401/TRISH-APP/issues

---

## 🎉 **Next Steps After Deployment**

1. **Test all endpoints** using Postman or curl
2. **Update Flutter app** with production URLs
3. **Set up monitoring** and alerts
4. **Configure custom domain** (optional)
5. **Enable HTTPS** (automatic on Railway)
6. **Set up CI/CD** (automatic with GitHub)
7. **Monitor logs** and performance
8. **Scale as needed** based on usage

---

**Your TRISH Dating App will be live on the internet!** 🚀

**Example URLs:**
- Backend: `https://trish-backend-production.up.railway.app`
- AI Engine: `https://trish-ai-production.up.railway.app`
- API Docs: `https://trish-ai-production.up.railway.app/docs`
