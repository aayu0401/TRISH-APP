# 🚀 TRISH App - Quick Railway Deployment

## ⚡ **Fast Track Deployment (5 Minutes)**

### **Step 1: Go to Railway**
👉 https://railway.app

### **Step 2: Create Services**

#### **Service 1: PostgreSQL Database**
1. Click "+ New" → "Database" → "PostgreSQL"
2. Done! Railway auto-configures it.

#### **Service 2: AI Engine**
1. Click "+ New" → "GitHub Repo" → Select `aayu0401/TRISH-APP`
2. **Root Directory**: `ai_engine`
3. **Environment Variables**: 
   - (None needed - Railway auto-detects)
4. Deploy!

#### **Service 3: Backend**
1. Click "+ New" → "GitHub Repo" → Select `aayu0401/TRISH-APP`
2. **Root Directory**: `backend`
3. **Environment Variables**:
   ```
   SPRING_DATASOURCE_URL=jdbc:postgresql://${PGHOST}:${PGPORT}/${PGDATABASE}
   SPRING_DATASOURCE_USERNAME=${PGUSER}
   SPRING_DATASOURCE_PASSWORD=${PGPASSWORD}
   JWT_SECRET=your-secret-key-here
   ```
4. Deploy!

### **Step 3: Get Your URLs**
Railway will give you URLs like:
- AI Engine: `https://trish-ai-xxx.up.railway.app`
- Backend: `https://trish-backend-xxx.up.railway.app`

### **Step 4: Test**
```bash
curl https://your-ai-url.up.railway.app/health
curl https://your-backend-url.up.railway.app/api/health
```

## ✅ **Done!**

Your app is now LIVE on the internet! 🎉

---

## 📱 **Update Flutter App**

Edit `frontend/lib/config.dart`:
```dart
const String API_URL = 'https://your-backend-url.up.railway.app';
```

---

## 🆘 **Having Issues?**

### **Railway says "Script start.sh not found"**
✅ **FIXED!** We added:
- `railway.toml` files
- `Procfile` files  
- `runtime.txt` for Python

Just push to GitHub and redeploy!

### **Build fails**
- Check logs in Railway dashboard
- Verify environment variables
- See `RAILWAY_DEPLOYMENT_GUIDE.md` for details

---

## 📚 **Full Documentation**
- **Complete Guide**: `RAILWAY_DEPLOYMENT_GUIDE.md`
- **Setup Guide**: `SETUP_AND_DEMO_GUIDE.md`
- **Features**: `IMPLEMENTATION_SUMMARY.md`

---

**Repository**: https://github.com/aayu0401/TRISH-APP

**All configuration files are ready - just deploy!** 🚂
