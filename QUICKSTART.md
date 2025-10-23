# ⚡ Quick Start Guide

Get your Thank You Notes system running in **under 1 hour**.

---

## 🎯 30-Second Overview

You're building a system where:
1. Guests write thank you notes on iPads with Apple Pencil
2. Notes appear **instantly** on a main display (laptop/projector)
3. You control everything from a host dashboard

---

## 📋 What You Need

- [ ] Mac computer with Xcode installed
- [ ] 3-4 iPads (iOS 15+)
- [ ] Laptop for main display
- [ ] Firebase account (free)
- [ ] USB cables for iPads
- [ ] Same WiFi network for all devices

---

## 🚀 Setup (Follow in Order)

### Part 1: Firebase (15 minutes)

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com/
   - Click "Add project"
   - Name it "ThankYouNotes"
   - Skip Google Analytics
   - Click "Create"

2. **Enable Realtime Database**
   - Click "Build" → "Realtime Database"
   - Click "Create Database"
   - Choose location closest to you
   - Start in "test mode"

3. **Set Security Rules**
   - Click "Rules" tab
   - Copy/paste from `firebase-rules.json` in this repo
   - Click "Publish"

4. **Get iOS Config**
   - Click gear icon → Project Settings
   - Scroll to "Your apps"
   - Click iOS button
   - Bundle ID: `com.thankyou.notes`
   - Download `GoogleService-Info.plist`
   - Save it (you'll need it in Part 2)

5. **Get Web Config**
   - Same settings page
   - Click Web button (</> icon)
   - Copy the config object
   - Save it in a text file (you'll need it in Part 3)

---

### Part 2: iPad App (30 minutes first time, 2 min per iPad after)

1. **Install Xcode** (if needed)
   ```
   Open Mac App Store → Search "Xcode" → Get (free)
   Wait 20-30 minutes for download
   ```

2. **Install CocoaPods** (if needed)
   ```bash
   sudo gem install cocoapods
   ```

3. **Setup Project**
   ```bash
   cd iPad-App
   pod install
   open ThankYouNotesApp.xcworkspace
   ```

4. **Add Firebase Config**
   - Drag `GoogleService-Info.plist` (from Part 1) into Xcode
   - Drop it in the `ThankYouNotesApp` folder
   - Check "Copy items if needed"

5. **Configure Signing**
   - Select project in Xcode (left sidebar)
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team (sign in with Apple ID)
   - Xcode auto-generates free certificate

6. **Deploy to First iPad**
   - Connect iPad via USB
   - Unlock iPad → Tap "Trust This Computer"
   - In Xcode: Select iPad from dropdown (top left)
   - Click Run button (▶️) or press ⌘R
   - Wait ~30 seconds

7. **Enable on iPad** (first time only)
   - iPad shows "Untrusted Developer" alert
   - Go to: Settings → General → VPN & Device Management
   - Tap your Apple ID → Trust

8. **Deploy to Other iPads**
   - Repeat steps 6-7 for each iPad (~2 minutes each)

9. **Certificate Renewal**
   - Certificates expire every 7 days
   - To renew: Just run app from Xcode again (30 seconds)

---

### Part 3: Web Display (10 minutes)

1. **Install Dependencies**
   ```bash
   cd web-display
   npm install
   ```

2. **Configure Environment**
   ```bash
   cp .env.template .env
   nano .env  # or use any text editor
   ```

   Paste your Firebase config from Part 1:
   ```env
   VITE_FIREBASE_API_KEY=your_api_key
   VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
   VITE_FIREBASE_DATABASE_URL=https://your_project.firebaseio.com
   VITE_FIREBASE_PROJECT_ID=your_project_id
   VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
   VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   VITE_FIREBASE_APP_ID=your_app_id
   ```

3. **Run Display**
   ```bash
   npm run dev
   ```
   Opens at: http://localhost:3000

4. **Make it Fullscreen**
   - Press F11 (or Cmd+Shift+F on Mac)
   - Connect to projector if needed

---

### Part 4: Host Panel (10 minutes)

1. **Install Dependencies**
   ```bash
   cd host-panel
   npm install
   ```

2. **Configure Environment**
   ```bash
   cp .env.template .env
   nano .env
   ```

   Same Firebase config as Part 3, plus:
   ```env
   VITE_DISPLAY_URL=http://localhost:3000
   ```

3. **Run Host Panel**
   ```bash
   npm run dev
   ```
   Opens at: http://localhost:3001

---

## ✅ Test Everything (5 minutes)

1. **iPad Test**
   - Open app on iPad
   - Tap "Start New Note"
   - Enter recipient and sender
   - Select a template
   - Draw something with Apple Pencil
   - Preview and submit

2. **Host Panel Test**
   - Should see new note in "Pending" queue
   - Click "Preview Drawing"
   - Click "Approve"

3. **Display Test**
   - Note should appear on main display within 1 second
   - Should show for 12 seconds (default)
   - Should fade out smoothly

4. **Full Flow Test**
   - iPad shows "Thank You!" screen
   - After 5 seconds, returns to welcome screen
   - Ready for next user

---

## 🎉 You're Done!

**What works now:**
- ✅ iPads accept thank you notes with Apple Pencil
- ✅ Notes sync to Firebase in real-time
- ✅ Display shows notes with animations
- ✅ Host panel lets you moderate and control display

**Next steps:**
- Adjust display duration in host panel
- Try landscape vs portrait modes
- Test with multiple iPads simultaneously
- Read full README.md for deployment options

---

## 🔧 Common Issues

**iPad: "Developer Mode Required"**
```
Settings → Privacy & Security → Developer Mode → Enable → Restart
```

**Display: Notes not showing**
```
Check Firebase rules are published
Verify .env file has correct credentials
Open browser console (F12) for errors
```

**Host Panel: Can't control display**
```
Make sure display window is open (click "Open Display")
Check VITE_DISPLAY_URL in .env
```

**General: Connection issues**
```
All devices must be on same WiFi
Check Firebase Database URL is correct
Try restarting devices
```

---

## 📞 Need Help?

1. Check full README.md for detailed troubleshooting
2. Open browser console (F12) for error messages
3. Check Firebase Console → Realtime Database → Data tab
4. Verify all .env files have correct values

---

## 🎯 Event Day Checklist

**30 minutes before event:**
- [ ] Open display in fullscreen on laptop
- [ ] Open host panel on separate device
- [ ] Unlock all iPads
- [ ] Test one complete note end-to-end
- [ ] Set display mode (landscape/portrait)
- [ ] Adjust display duration if needed

**During event:**
- [ ] Monitor host panel for pending notes
- [ ] Approve notes as they come in
- [ ] Keep iPads charged (or plugged in)

---

**Total Setup Time:** Under 1 hour
**Time per Note:** 1-2 minutes
**System Latency:** ~1 second (iPad submit → Display show)

Enjoy! 🚀✨
