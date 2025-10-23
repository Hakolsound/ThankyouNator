# 🔥 Firebase Setup Guide

Complete step-by-step guide to set up Firebase for the Thank You Notes system.

---

## 📋 What You'll Get

After completing this guide, you'll have:
- ✅ Firebase project created
- ✅ Realtime Database enabled
- ✅ Security rules configured
- ✅ API keys and credentials for iOS
- ✅ API keys and credentials for Web
- ✅ All configuration files ready

**Time Required:** 15 minutes

---

## 🚀 Step 1: Create Firebase Project

### 1.1 Go to Firebase Console

Open your browser and navigate to:
```
https://console.firebase.google.com/
```

Sign in with your Google account.

### 1.2 Create New Project

1. Click **"Add project"** or **"Create a project"**
2. Enter project name: `ThankYouNotes` (or any name you prefer)
3. Click **Continue**

### 1.3 Disable Google Analytics (Optional)

1. Toggle **"Enable Google Analytics for this project"** to **OFF**
   - Not needed for this project
   - Simplifies setup
2. Click **Create project**
3. Wait 30-60 seconds for project creation
4. Click **Continue**

---

## 🗄️ Step 2: Enable Realtime Database

### 2.1 Navigate to Database

1. In the left sidebar, click **"Build"**
2. Click **"Realtime Database"**
3. Click **"Create Database"** button

### 2.2 Choose Location

1. Select region closest to your event location:
   - `us-central1` (United States)
   - `europe-west1` (Europe)
   - `asia-southeast1` (Asia)
2. Click **Next**

### 2.3 Security Rules

1. Select **"Start in test mode"**
   - We'll configure proper rules in next step
2. Click **Enable**
3. Wait 10-20 seconds for database creation

### 2.4 Note Your Database URL

You'll see a URL like:
```
https://thankyounotes-12345.firebaseio.com
```

**Copy this URL** - you'll need it later!

---

## 🔒 Step 3: Configure Security Rules

### 3.1 Go to Rules Tab

1. In Realtime Database view, click **"Rules"** tab
2. You'll see default test rules

### 3.2 Replace with Production Rules

**Delete everything** in the editor and paste this:

```json
{
  "rules": {
    "sessions": {
      "$sessionId": {
        ".read": true,
        ".write": true,
        ".validate": "newData.hasChildren(['iPad_input', 'status', 'createdAt'])",
        "iPad_input": {
          ".validate": "newData.hasChildren(['recipient', 'sender', 'drawingImage', 'templateTheme'])"
        },
        "status": {
          ".validate": "newData.isString() && (newData.val() === 'pending' || newData.val() === 'ready_for_display' || newData.val() === 'displaying' || newData.val() === 'complete')"
        },
        "createdAt": {
          ".validate": "newData.isNumber()"
        },
        "displayedAt": {
          ".validate": "newData.isNumber()"
        },
        "expiresAt": {
          ".validate": "newData.isNumber()"
        }
      }
    },
    "settings": {
      ".read": true,
      ".write": true
    }
  }
}
```

### 3.3 Publish Rules

1. Click **"Publish"** button
2. You should see: "Rules published successfully"

**Important:** These rules allow read/write for internal use. For public-facing apps, add Firebase Authentication.

---

## 📱 Step 4: Get iOS Configuration

### 4.1 Register iOS App

1. Go to **Project Overview** (click gear icon → Project settings)
2. Scroll to **"Your apps"** section
3. Click **iOS** button (Apple icon)

### 4.2 Fill in iOS App Details

1. **iOS bundle ID:** `com.thankyou.notes`
   - Must match exactly!
2. **App nickname:** `ThankYouNotesApp` (optional)
3. **App Store ID:** Leave blank
4. Click **Register app**

### 4.3 Download Configuration File

1. Click **Download GoogleService-Info.plist**
2. Save it to your computer (remember where!)
3. Click **Next**
4. Click **Next** again (skip SDK steps, we use CocoaPods)
5. Click **Continue to console**

### 4.4 Copy File to Project

```bash
# Copy GoogleService-Info.plist to your iPad app folder
cp ~/Downloads/GoogleService-Info.plist /Users/ronpeer/Code/ThankYou/ThankYouNotesApp/iPad-App/ThankYouNotesApp/
```

**Or** manually:
1. Open Xcode project
2. Drag `GoogleService-Info.plist` into `ThankYouNotesApp` folder
3. Check **"Copy items if needed"**

---

## 🌐 Step 5: Get Web Configuration

### 5.1 Register Web App

1. Go back to **Project settings**
2. Scroll to **"Your apps"** section
3. Click **Web** button (`</>` icon)

### 5.2 Fill in Web App Details

1. **App nickname:** `ThankYouNotesWeb`
2. **Do NOT check** "Also set up Firebase Hosting"
3. Click **Register app**

### 5.3 Copy Configuration

You'll see a code snippet like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyC1234567890abcdefghijklmnopqrst",
  authDomain: "thankyounotes-12345.firebaseapp.com",
  databaseURL: "https://thankyounotes-12345.firebaseio.com",
  projectId: "thankyounotes-12345",
  storageBucket: "thankyounotes-12345.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef1234567890"
};
```

**Copy all these values!**

### 5.4 Create Web Display .env File

```bash
cd /Users/ronpeer/Code/ThankYou/ThankYouNotesApp/web-display
cp .env.template .env
nano .env  # or use your favorite editor
```

Paste your values:

```env
VITE_FIREBASE_API_KEY=AIzaSyC1234567890abcdefghijklmnopqrst
VITE_FIREBASE_AUTH_DOMAIN=thankyounotes-12345.firebaseapp.com
VITE_FIREBASE_DATABASE_URL=https://thankyounotes-12345.firebaseio.com
VITE_FIREBASE_PROJECT_ID=thankyounotes-12345
VITE_FIREBASE_STORAGE_BUCKET=thankyounotes-12345.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=123456789012
VITE_FIREBASE_APP_ID=1:123456789012:web:abcdef1234567890
```

Save and close.

### 5.5 Create Host Panel .env File

```bash
cd /Users/ronpeer/Code/ThankYou/ThankYouNotesApp/host-panel
cp .env.template .env
nano .env
```

Paste the **same values** as web display, plus:

```env
VITE_FIREBASE_API_KEY=AIzaSyC1234567890abcdefghijklmnopqrst
VITE_FIREBASE_AUTH_DOMAIN=thankyounotes-12345.firebaseapp.com
VITE_FIREBASE_DATABASE_URL=https://thankyounotes-12345.firebaseio.com
VITE_FIREBASE_PROJECT_ID=thankyounotes-12345
VITE_FIREBASE_STORAGE_BUCKET=thankyounotes-12345.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=123456789012
VITE_FIREBASE_APP_ID=1:123456789012:web:abcdef1234567890
VITE_DISPLAY_URL=http://localhost:3000
```

Save and close.

---

## ✅ Step 6: Verify Setup

### 6.1 Test Firebase Connection

1. Go to Firebase Console → Realtime Database
2. Click **"Data"** tab
3. You should see your database root (empty is fine)

### 6.2 Test Web Display

```bash
cd /Users/ronpeer/Code/ThankYou/ThankYouNotesApp/web-display
npm install
npm run dev
```

Open http://localhost:3000

You should see:
- ✅ "Waiting for the next message..." screen
- ✅ Green "Connected" indicator (top right)

If connected = Firebase works!

### 6.3 Test Host Panel

```bash
cd /Users/ronpeer/Code/ThankYou/ThankYouNotesApp/host-panel
npm install
npm run dev
```

Open http://localhost:3001

You should see:
- ✅ Dark dashboard
- ✅ Green "Connected" indicator
- ✅ Stats showing 0 sessions
- ✅ Empty dashboard

If connected = Firebase works!

---

## 🔍 Troubleshooting

### Problem: "Permission denied" errors

**Fix:**
1. Go to Firebase Console → Realtime Database → Rules
2. Make sure rules are published (see Step 3.2)
3. Click "Publish" again

### Problem: Web app shows "Offline" (red dot)

**Possible causes:**
1. **Wrong database URL**
   - Check `.env` file matches Firebase Console
2. **Typo in credentials**
   - Copy/paste again from Firebase
3. **Database not enabled**
   - Go to Realtime Database, make sure it's created

**Fix:**
```bash
# Check .env file
cat .env

# Should have VITE_FIREBASE_DATABASE_URL with correct URL
# If wrong, edit and restart dev server
```

### Problem: iPad app won't connect

**Possible causes:**
1. **Wrong GoogleService-Info.plist**
   - Make sure it's from YOUR Firebase project
2. **Bundle ID mismatch**
   - Must be exactly `com.thankyou.notes`
3. **File not in Xcode project**
   - Drag into Xcode, check "Copy items"

**Fix:**
1. Open Xcode
2. Verify `GoogleService-Info.plist` is in project
3. Check Bundle ID in Signing & Capabilities
4. Clean build folder: Product → Clean Build Folder (⌘⇧K)
5. Run again

### Problem: "Invalid API key" error

**Fix:**
1. Go to Firebase Console → Project settings
2. Under "Web apps", click your app
3. Copy the config again (might have changed)
4. Update `.env` files
5. Restart dev servers

### Problem: Can't see data in Firebase Console

**Expected during setup!**

Data only appears after:
1. iPad app submits a note, OR
2. You manually add test data

**To add test data:**
1. Firebase Console → Realtime Database → Data tab
2. Hover over root, click **+**
3. Add:
   - Name: `sessions`
   - Click **+** under `sessions`
   - Add a test session (see schema below)

---

## 📋 Quick Reference

### Database URL Format

```
https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com
```

If your region is NOT `us-central1`:
```
https://YOUR_PROJECT_ID-default-rtdb.REGION.firebasedatabase.app
```

### iOS Config Location

```
ThankYouNotesApp/
└── iPad-App/
    └── ThankYouNotesApp/
        └── GoogleService-Info.plist  ← HERE
```

### Web Config Locations

```
ThankYouNotesApp/
├── web-display/
│   └── .env  ← HERE
└── host-panel/
    └── .env  ← HERE
```

---

## 🔐 Security Best Practices

### For Development/Testing
- ✅ Current rules (read/write open)
- ✅ Internal network only
- ✅ Not exposed to public internet

### For Production (Public Events)
Add Firebase Authentication:

```json
{
  "rules": {
    "sessions": {
      "$sessionId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

Then require sign-in for iPad app and host panel.

### For Small Private Events
Current rules are fine if:
- ✅ Only internal network access
- ✅ No sensitive data in notes
- ✅ Moderation queue enabled (host approves all)

---

## 💰 Firebase Pricing

### Free Tier (Spark Plan)
- ✅ 10GB/month downloaded
- ✅ 100k simultaneous connections
- ✅ 1GB database storage

**Enough for:**
- 100-200 notes/event
- 4-10 iPads
- Multiple displays
- Most small-medium events

### Paid Tier (Blaze Plan)
- Pay-as-you-go
- $0.10/GB downloaded
- $5/GB stored
- $0.018/100k reads

**Cost for typical event:**
- 300 notes @ 500KB each = 150MB
- Cost: ~$0.50-1.00 per event

**Set spending limit:**
1. Firebase Console → Upgrade to Blaze
2. Set budget alerts
3. Set max spending (e.g., $10/month)

---

## 📊 Monitor Usage

### Check Data Usage

1. Firebase Console → Usage & Billing
2. See current month usage
3. Graphs show downloads, storage, connections

### Set Budget Alerts

1. Google Cloud Console (link in Firebase)
2. Billing → Budgets & alerts
3. Set alert at $5, $10, etc.
4. Get email when approaching limit

### Optimize for Cost

- ✅ Use auto-expire (sessions delete after 1 hour)
- ✅ Compress images (<500KB each)
- ✅ Clean up old data monthly
- ✅ Only fetch what you need (queries with filters)

---

## ✅ Setup Complete!

You now have:
- ✅ Firebase project created
- ✅ Realtime Database enabled and configured
- ✅ iOS credentials (GoogleService-Info.plist)
- ✅ Web credentials (.env files)
- ✅ Security rules published
- ✅ Connection verified

**Next Steps:**
1. Deploy iPad app to devices (see README.md)
2. Test complete flow (iPad → Firebase → Display)
3. Configure host panel settings
4. Go live! 🚀

---

## 📞 Need Help?

**Firebase won't connect?**
- Check credentials match exactly
- Verify database URL format
- Make sure database is enabled

**See errors in console?**
- Open browser dev tools (F12)
- Check Network tab for failed requests
- Look for error messages

**Still stuck?**
- Check full README.md for troubleshooting
- Verify all steps completed
- Try creating a new Firebase project

---

**Firebase Setup Complete!** 🎉

Time to build something awesome! ✨
