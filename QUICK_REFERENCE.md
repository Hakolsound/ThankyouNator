# ⚡ Quick Reference Card

## 🔥 Firebase Project
- **Project:** scrabble-6b9ff
- **Database:** https://scrabble-6b9ff-default-rtdb.firebaseio.com
- **Console:** https://console.firebase.google.com/project/scrabble-6b9ff

---

## 🚀 Launch Commands

### Web Display
```bash
cd /Users/ronpeer/Code/ThankYou/ThankYouNotesApp/web-display
npm run dev
```
**URL:** http://localhost:3000

### Host Panel
```bash
cd /Users/ronpeer/Code/ThankYou/ThankYouNotesApp/host-panel
npm run dev
```
**URL:** http://localhost:3001

### iPad App
```bash
cd /Users/ronpeer/Code/ThankYou/ThankYouNotesApp/iPad-App
open ThankYouNotesApp.xcworkspace
```
Then: Select iPad → Click Run (▶️)

---

## 📁 Configuration Files

### Web Display Config
**File:** `web-display/.env`
```
VITE_FIREBASE_DATABASE_URL=https://scrabble-6b9ff-default-rtdb.firebaseio.com
```

### Host Panel Config
**File:** `host-panel/.env`
```
VITE_FIREBASE_DATABASE_URL=https://scrabble-6b9ff-default-rtdb.firebaseio.com
VITE_DISPLAY_URL=http://localhost:3000
```

### iPad App Config
**File:** `iPad-App/ThankYouNotesApp/GoogleService-Info.plist`
- Already configured with your Firebase project

---

## 🎯 Quick Setup (First Time)

1. **Set Firebase Rules** (5 min)
   - Go to Firebase Console → Realtime Database → Rules
   - Copy rules from `firebase-rules.json`
   - Click Publish

2. **Install Web Dependencies** (2 min)
   ```bash
   cd web-display && npm install
   cd ../host-panel && npm install
   ```

3. **Install iPad Dependencies** (2 min)
   ```bash
   cd iPad-App && pod install
   ```

4. **Test!** (5 min)
   - Run web display + host panel
   - Deploy iPad app
   - Create test note

---

## 🔧 Common Tasks

### Refresh iPad Certificate (Every 7 Days)
```bash
# Connect iPad, open Xcode
open iPad-App/ThankYouNotesApp.xcworkspace
# Select iPad → Click Run (30 seconds)
```

### Clear All Notes
- Open host panel: http://localhost:3001
- Click "Clear All Notes" button

### Check Firebase Data
- Firebase Console → Realtime Database → Data tab
- Look for `sessions/` node

### Restart Web Apps
```bash
# Ctrl+C to stop, then:
npm run dev
```

---

## 📊 Display Settings

### Landscape Mode
- 5 notes per page
- Auto-cycles every 15 seconds
- Best for: Wide screens, projectors

### Portrait Mode
- 1 note at a time
- Auto-cycles every 12 seconds
- Best for: Vertical displays, tablets

### Adjust in Host Panel
- Toggle mode: Landscape ↔ Portrait button
- Duration: Slider (5-30 seconds)

---

## 🐛 Quick Fixes

### "Offline" on Display
```bash
# Check Firebase rules are published
# Verify .env file exists
# Restart: Ctrl+C, then npm run dev
```

### iPad Won't Deploy
```bash
# Clean build
# In Xcode: Product → Clean Build Folder (⌘⇧K)
# Try again
```

### Notes Not Showing
```bash
# Check Firebase Console → Data tab
# Verify status: ready_for_display
# Refresh display page (F5)
```

---

## 📱 iPad Bundle ID
`com.thankyou.notes`

**Must match exactly in:**
- Xcode → Signing & Capabilities
- Firebase Console → iOS app settings

---

## 🔢 Port Numbers
- Web Display: **3000**
- Host Panel: **3001**

---

## 📚 Documentation
- **Full Guide:** [README.md](README.md)
- **Quick Setup:** [QUICKSTART.md](QUICKSTART.md)
- **Your Setup:** [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
- **Firebase:** [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

---

## ✅ Pre-Event Checklist
- [ ] Firebase rules published
- [ ] Web display running (green dot)
- [ ] Host panel running (green dot)
- [ ] iPad apps deployed (<7 days old)
- [ ] Test note submitted successfully
- [ ] Display mode selected
- [ ] Duration configured

---

**Ready to Go!** 🎉
