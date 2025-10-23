# 🏛️ System Architecture

Visual diagrams and technical architecture documentation.

---

## 🎯 High-Level System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        EVENT SPACE                               │
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  iPad 1  │  │  iPad 2  │  │  iPad 3  │  │  iPad 4  │       │
│  │          │  │          │  │          │  │          │       │
│  │  Guest   │  │  Guest   │  │  Guest   │  │  Guest   │       │
│  │ Drawing  │  │ Drawing  │  │ Drawing  │  │ Drawing  │       │
│  │  Notes   │  │  Notes   │  │  Notes   │  │  Notes   │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│       │             │             │             │               │
│       └─────────────┴─────────────┴─────────────┘               │
│                          │                                      │
│                          │ WiFi / Cellular                      │
│                          ↓                                      │
│              ┌───────────────────────┐                          │
│              │  Firebase Realtime    │                          │
│              │      Database         │                          │
│              │   (Cloud Backend)     │                          │
│              └───────────┬───────────┘                          │
│                          │                                      │
│                    ┌─────┴─────┐                                │
│                    │           │                                │
│                    ↓           ↓                                │
│         ┌──────────────┐  ┌──────────────┐                     │
│         │ Web Display  │  │ Host Admin   │                     │
│         │  (Laptop)    │  │    Panel     │                     │
│         │              │  │  (Laptop)    │                     │
│         │   16:9       │  │              │                     │
│         │  Projector   │  │  Moderation  │                     │
│         └──────────────┘  └──────────────┘                     │
│                                                                  │
│         AUDIENCE SEES NOTES    HOST CONTROLS DISPLAY            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 iPad App Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        IPAD APP LAYERS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐      │
│  │                   SwiftUI Views                       │      │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐    │      │
│  │  │Welcome │→ │ Input  │→ │Template│→ │Drawing │    │      │
│  │  │ View   │  │ View   │  │  View  │  │  View  │    │      │
│  │  └────────┘  └────────┘  └────────┘  └───┬────┘    │      │
│  │                                            │          │      │
│  │                                            ↓          │      │
│  │                                      ┌────────┐      │      │
│  │                                      │Preview │      │      │
│  │                                      │ View   │      │      │
│  │                                      └───┬────┘      │      │
│  └──────────────────────────────────────────┼──────────┘      │
│                                              │                  │
│  ┌──────────────────────────────────────────┼──────────────┐  │
│  │             SessionManager               │              │  │
│  │  ┌──────────────────────────────────────┐│              │  │
│  │  │ • AppState (state machine)           ││              │  │
│  │  │ • DrawingState (current note)        ││              │  │
│  │  │ • Navigation logic                   ││              │  │
│  │  │ • Idle timer (5 min)                 ││              │  │
│  │  │ • Haptic feedback                    ││              │  │
│  │  └──────────────────────────────────────┘│              │  │
│  └───────────────────────────────────────────┼──────────────┘  │
│                                              │                  │
│  ┌──────────────────────────────────────────┼──────────────┐  │
│  │            FirebaseService               │              │  │
│  │  ┌──────────────────────────────────────┐│              │  │
│  │  │ • Connection monitoring              ││              │  │
│  │  │ • PKDrawing → PNG conversion         ││              │  │
│  │  │ • Template rendering                 ││              │  │
│  │  │ • Base64 encoding                    ││              │  │
│  │  │ • Session upload                     ││              │  │
│  │  │ • Offline queue                      ││              │  │
│  │  └──────────────────────────────────────┘│              │  │
│  └───────────────────────────────────────────┼──────────────┘  │
│                                              │                  │
│  ┌──────────────────────────────────────────┼──────────────┐  │
│  │               PencilKit                  │              │  │
│  │  ┌──────────────────────────────────────┐│              │  │
│  │  │ • PKCanvasView (drawing surface)     ││              │  │
│  │  │ • Pressure sensitivity               ││              │  │
│  │  │ • Palm rejection                     ││              │  │
│  │  │ • 120fps rendering                   ││              │  │
│  │  │ • Undo/redo stack                    ││              │  │
│  │  └──────────────────────────────────────┘│              │  │
│  └───────────────────────────────────────────┼──────────────┘  │
│                                              │                  │
│                                              ↓                  │
│                         ┌──────────────────────────┐           │
│                         │  Firebase Realtime DB    │           │
│                         └──────────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🖥️ Web Display Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     WEB DISPLAY LAYERS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐      │
│  │                  React App.jsx                        │      │
│  │  ┌────────────────────────────────────────────────┐  │      │
│  │  │ State Management                                │  │      │
│  │  │ • Display mode (landscape/portrait)            │  │      │
│  │  │ • Note queue                                    │  │      │
│  │  │ • Display duration                              │  │      │
│  │  │ • Idle detection (30s)                          │  │      │
│  │  └────────────────────────────────────────────────┘  │      │
│  └────────────────────────┬─────────────────────────────┘      │
│                            │                                     │
│  ┌─────────────────────────┼────────────────────────────────┐  │
│  │    useFirebaseListener  │                                │  │
│  │  ┌──────────────────────▼──────────────────────────┐    │  │
│  │  │ • Real-time listener (ready_for_display)       │    │  │
│  │  │ • Connection monitoring (.info/connected)      │    │  │
│  │  │ • markAsDisplaying()                           │    │  │
│  │  │ • markAsComplete()                             │    │  │
│  │  │ • Auto-refresh on changes                      │    │  │
│  │  └───────────────────────────────────────────────┘    │  │
│  └────────────────────────┬────────────────────────────────┘  │
│                            │                                     │
│  ┌─────────────────────────┴────────────────────────────────┐  │
│  │              Display Components                           │  │
│  │                                                            │  │
│  │  ┌────────────────┐            ┌────────────────┐        │  │
│  │  │ LandscapeMode  │            │ PortraitMode   │        │  │
│  │  │                │            │                │        │  │
│  │  │ • 5 notes max  │            │ • 1 note       │        │  │
│  │  │ • Sticky grid  │            │ • Full screen  │        │  │
│  │  │ • Rotation     │            │ • Centered     │        │  │
│  │  │ • Z-layering   │            │ • Large text   │        │  │
│  │  └───────┬────────┘            └───────┬────────┘        │  │
│  │          │                              │                 │  │
│  │          └──────────┬───────────────────┘                 │  │
│  │                     │                                      │  │
│  │             ┌───────▼───────┐                             │  │
│  │             │   NoteCard    │                             │  │
│  │             │               │                             │  │
│  │             │ • Base64 img  │                             │  │
│  │             │ • Recipient   │                             │  │
│  │             │ • Sender      │                             │  │
│  │             │ • Animations  │                             │  │
│  │             └───────────────┘                             │  │
│  │                                                            │  │
│  │  ┌────────────────┐            ┌────────────────┐        │  │
│  │  │  IdleScreen    │            │ConnectionStatus│        │  │
│  │  │  (no notes)    │            │  (indicator)   │        │  │
│  │  └────────────────┘            └────────────────┘        │  │
│  └────────────────────────────────────────────────────────┘  │
│                            │                                     │
│                            ↓                                     │
│                ┌──────────────────────┐                         │
│                │   Tailwind CSS       │                         │
│                │   • Animations       │                         │
│                │   • Responsive       │                         │
│                │   • Utilities        │                         │
│                └──────────────────────┘                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎛️ Host Panel Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      HOST PANEL LAYERS                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐      │
│  │                  React App.jsx                        │      │
│  │  ┌────────────────────────────────────────────────┐  │      │
│  │  │ State Management                                │  │      │
│  │  │ • All sessions                                  │  │      │
│  │  │ • Display settings                              │  │      │
│  │  │ • Connection status                             │  │      │
│  │  │ • PostMessage to display                        │  │      │
│  │  └────────────────────────────────────────────────┘  │      │
│  └────────────────────────┬─────────────────────────────┘      │
│                            │                                     │
│  ┌─────────────────────────┼────────────────────────────────┐  │
│  │     Firebase Service    │                                │  │
│  │  ┌──────────────────────▼──────────────────────────┐    │  │
│  │  │ • Listen to all sessions                       │    │  │
│  │  │ • Connection monitoring                        │    │  │
│  │  │ • update() - Approve/modify sessions           │    │  │
│  │  │ • remove() - Reject sessions                   │    │  │
│  │  └───────────────────────────────────────────────┘    │  │
│  └────────────────────────┬────────────────────────────────┘  │
│                            │                                     │
│  ┌─────────────────────────┴────────────────────────────────┐  │
│  │              UI Components (4 Main)                       │  │
│  │                                                            │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Stats.jsx                                         │  │  │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐          │  │  │
│  │  │  │  Total   │ │ Pending  │ │Displayed │          │  │  │
│  │  │  │Sessions  │ │  Count   │ │  Today   │          │  │  │
│  │  │  └──────────┘ └──────────┘ └──────────┘          │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                            │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Dashboard.jsx                                     │  │  │
│  │  │  • Scrollable session list                        │  │  │
│  │  │  • Status badges (pending/displaying/complete)    │  │  │
│  │  │  • Timestamps                                      │  │  │
│  │  │  • Real-time updates                               │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                            │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Controls.jsx                                      │  │  │
│  │  │  • Display mode toggle (landscape/portrait)       │  │  │
│  │  │  • Duration slider (5-30s)                         │  │  │
│  │  │  • Animation speed (slow/normal/fast)             │  │  │
│  │  │  • Font size (small/medium/large)                 │  │  │
│  │  │  • Quick actions (reset/clear)                    │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                            │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  ModQueue.jsx                                      │  │  │
│  │  │  • Pending notes list                              │  │  │
│  │  │  • Preview modal (full-screen)                     │  │  │
│  │  │  • Approve button → status: ready_for_display     │  │  │
│  │  │  • Reject button → delete session                 │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────┘  │
│                            │                                     │
│                            ↓                                     │
│                ┌──────────────────────┐                         │
│                │   Dark Theme         │                         │
│                │   • Gray-900 bg      │                         │
│                │   • Card-based       │                         │
│                │   • Indigo accents   │                         │
│                └──────────────────────┘                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow: Complete Session Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    SESSION LIFECYCLE                             │
└─────────────────────────────────────────────────────────────────┘

1. INITIATION (iPad)
   ┌──────────┐
   │  Guest   │
   │  taps    │
   │ "Start"  │
   └────┬─────┘
        │
        ↓
   ┌──────────────────┐
   │ SessionManager   │
   │ creates new      │
   │ DrawingState     │
   └────┬─────────────┘
        │
        ↓

2. INPUT (iPad)
   ┌──────────────────┐
   │ User enters:     │
   │ • Recipient      │
   │ • Sender         │
   │ • Template       │
   │ • Drawing        │
   └────┬─────────────┘
        │
        ↓

3. SUBMISSION (iPad)
   ┌──────────────────┐
   │ User previews    │
   │ & clicks Submit  │
   └────┬─────────────┘
        │
        ↓
   ┌──────────────────┐
   │ FirebaseService  │
   │ • PKDrawing → PNG│
   │ • Base64 encode  │
   │ • Create session │
   └────┬─────────────┘
        │
        ↓
   ┌────────────────────────────┐
   │ Firebase Realtime Database │
   │                            │
   │ sessions/{sessionId}       │
   │ ├─ status: ready_for_display│
   │ ├─ createdAt: timestamp    │
   │ └─ iPad_input:             │
   │    ├─ recipient            │
   │    ├─ sender               │
   │    └─ drawingImage (base64)│
   └────┬───────────┬───────────┘
        │           │
        ↓           ↓

4a. DISPLAY PATH (Auto)      4b. MODERATION PATH (Optional)
   ┌──────────────────┐          ┌──────────────────┐
   │ Web Display      │          │ Host Panel       │
   │ Listener detects │          │ Shows in queue   │
   └────┬─────────────┘          └────┬─────────────┘
        │                              │
        ↓                              ↓
   ┌──────────────────┐          ┌──────────────────┐
   │ Status:          │          │ Host previews    │
   │ displaying       │          │ & approves       │
   └────┬─────────────┘          └────┬─────────────┘
        │                              │
        ↓                              ↓
   ┌──────────────────┐          ┌──────────────────┐
   │ Animate on       │          │ Status:          │
   │ screen (12s)     │          │ ready_for_display│
   └────┬─────────────┘          └────┬─────────────┘
        │                              │
        ↓                              └─────→ (back to 4a)
   ┌──────────────────┐
   │ Status:          │
   │ complete         │
   └────┬─────────────┘
        │
        ↓

5. CLEANUP
   ┌──────────────────┐
   │ Firebase         │
   │ Auto-delete      │
   │ after 1 hour     │
   │ (expiresAt TTL)  │
   └──────────────────┘

6. RESET (iPad)
   ┌──────────────────┐
   │ "Thank You!"     │
   │ screen (5s)      │
   └────┬─────────────┘
        │
        ↓
   ┌──────────────────┐
   │ Return to        │
   │ Welcome screen   │
   │ (Ready for next) │
   └──────────────────┘

TOTAL TIME: ~90 seconds (input + display + reset)
```

---

## 🔥 Firebase Database Schema

```
firebase-realtime-database/
│
├── sessions/
│   │
│   ├── {session-uuid-1}/
│   │   ├── status: "ready_for_display"  ← State machine
│   │   ├── createdAt: 1698765432000     ← Timestamp (ms)
│   │   ├── displayedAt: 1698765445000   ← When shown
│   │   ├── expiresAt: 1698769032000     ← Auto-delete at
│   │   └── iPad_input/
│   │       ├── recipient: "Sarah"
│   │       ├── sender: "John"
│   │       ├── drawingImage: "iVBORw0KG..." ← Base64 PNG
│   │       ├── templateTheme: "watercolor"
│   │       └── rawDrawingData: "YnBsaXN0..." ← Base64 PKDrawing
│   │
│   ├── {session-uuid-2}/
│   │   ├── status: "displaying"
│   │   ├── ...
│   │
│   └── {session-uuid-3}/
│       ├── status: "complete"
│       └── ...
│
├── settings/ (optional)
│   ├── displayMode: "landscape"
│   ├── displayDuration: 12
│   ├── animationSpeed: "normal"
│   └── fontSize: "medium"
│
└── .info/ (Firebase system)
    └── connected: true/false  ← Connection status
```

### Status State Machine

```
pending
  ↓
ready_for_display  ← Submitted from iPad or approved by host
  ↓
displaying         ← Web display picks it up
  ↓
complete           ← Display duration finished
  ↓
[auto-deleted after 1 hour]
```

---

## 🌐 Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       NETWORK TOPOLOGY                           │
└─────────────────────────────────────────────────────────────────┘

Option 1: LOCAL NETWORK (Development/Small Events)
────────────────────────────────────────────────────

                     ┌──────────────┐
                     │   WiFi AP    │
                     │ 192.168.1.1  │
                     └──────┬───────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐         ┌────▼────┐        ┌────▼────┐
   │ iPad 1  │         │ iPad 2  │        │ Laptop  │
   │ .10     │         │ .11     │        │ .20     │
   └─────────┘         └─────────┘        └─────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                            ↓
                    ┌───────────────┐
                    │   Firebase    │
                    │  (Internet)   │
                    └───────────────┘

• All devices on same WiFi
• Access web apps via local IP (192.168.1.20:3000)
• Firebase accessed via internet


Option 2: INTERNET (Production/Large Events)
────────────────────────────────────────────

   ┌──────────┐     ┌──────────┐     ┌──────────┐
   │  iPad 1  │     │  iPad 2  │     │  Laptop  │
   │ Cellular │     │   WiFi   │     │   WiFi   │
   └────┬─────┘     └────┬─────┘     └────┬─────┘
        │                │                 │
        └────────────────┼─────────────────┘
                         │
                    INTERNET
                         │
        ┌────────────────┼─────────────────┐
        │                │                 │
   ┌────▼─────┐     ┌────▼─────┐     ┌────▼─────┐
   │ Firebase │     │  Vercel  │     │  Vercel  │
   │ Realtime │     │  Display │     │   Host   │
   │    DB    │     │   App    │     │   Panel  │
   └──────────┘     └──────────┘     └──────────┘

• iPads connect via WiFi or cellular
• Web apps deployed to Vercel (display.yourdomain.com)
• All communicate through Firebase
• No local network required
```

---

## ⚡ Performance Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     PERFORMANCE LAYERS                           │
└─────────────────────────────────────────────────────────────────┘

LAYER 1: INPUT (iPad)
─────────────────────
┌──────────────────┐
│   Apple Pencil   │  ← Hardware accelerated
│   < 9ms latency  │     Direct to display chip
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│   PencilKit      │  ← Metal rendering
│   120fps @ 50ms  │     GPU acceleration
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ PKDrawing cache  │  ← In-memory
│   < 10ms         │     Instant undo/redo
└────┬─────────────┘
     │
     ↓

LAYER 2: SUBMISSION (iPad → Firebase)
─────────────────────────────────────
┌──────────────────┐
│ Image conversion │  ← UIGraphicsRenderer
│   PNG @ 1200px   │     ~200ms
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Base64 encoding  │  ← Native Swift
│   ~50ms          │     CPU optimized
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Firebase upload  │  ← WebSocket
│   ~200-300ms     │     Persistent connection
└────┬─────────────┘
     │
TOTAL: ~500ms

LAYER 3: SYNC (Firebase → Display)
──────────────────────────────────
┌──────────────────┐
│ Firebase push    │  ← Real-time listener
│   ~50-100ms      │     No polling
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ React state      │  ← useState hook
│   < 10ms         │     Immediate render
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Base64 decode    │  ← Browser native
│   ~50ms          │     Async decode
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ CSS animation    │  ← GPU accelerated
│   60fps          │     requestAnimationFrame
└────┬─────────────┘
     │
TOTAL: ~200-300ms

OVERALL: iPad submit → Display shown = ~1 second
```

---

## 🔒 Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     SECURITY LAYERS                              │
└─────────────────────────────────────────────────────────────────┘

LAYER 1: CLIENT VALIDATION (iPad)
─────────────────────────────────
┌──────────────────┐
│ Input validation │  • Recipient not empty
│                  │  • Sender optional
│                  │  • Drawing exists
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Image sanitize   │  • PNG format only
│                  │  • Size limit (500KB)
│                  │  • No metadata
└────┬─────────────┘
     │
     ↓

LAYER 2: FIREBASE RULES (Database)
──────────────────────────────────
┌──────────────────┐
│ Read rules       │  • Public read (internal network)
│                  │  • No authentication required
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Write validation │  • Must have required fields
│                  │  • Status enum only
│                  │  • Timestamp format check
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Auto-expiration  │  • expiresAt TTL (1 hour)
│                  │  • Auto-cleanup
└────┬─────────────┘
     │
     ↓

LAYER 3: APPLICATION LOGIC (Host Panel)
───────────────────────────────────────
┌──────────────────┐
│ Moderation queue │  • Human review
│                  │  • Approve/reject
│                  │  • Preview before display
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Content filter   │  • Visual inspection
│                  │  • Manual moderation
└────┬─────────────┘
     │
     ↓

LAYER 4: NETWORK (Transport)
────────────────────────────
┌──────────────────┐
│ HTTPS/WSS only   │  • Firebase enforced
│                  │  • TLS 1.3
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ No public API    │  • Internal network only
│                  │  • Firebase auth optional
└──────────────────┘
```

---

## 📊 Scalability Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SCALING STRATEGY                              │
└─────────────────────────────────────────────────────────────────┘

CURRENT (Out of the Box)
────────────────────────
┌──────────────────┐
│ 4 iPads          │  Simultaneous users
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ 60 notes/hour    │  1 note per minute per iPad
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ 1 display        │  16:9 laptop/projector
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Firebase Free    │  10GB/month, 100k connections
└──────────────────┘


SCALE UP: MORE IPADS
────────────────────
┌──────────────────┐
│ 10+ iPads        │  Just deploy app to more devices
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ 150 notes/hour   │  Linear scaling
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Same display     │  Queue handles all
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Firebase Free    │  Still within limits
└──────────────────┘


SCALE UP: MORE DISPLAYS
───────────────────────
┌──────────────────┐
│ 4 iPads          │  Same input devices
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Firebase         │  Single source of truth
└────┬─────────────┘
     │
     ├──────────┬──────────┬──────────┐
     │          │          │          │
     ↓          ↓          ↓          ↓
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│Display 1│ │Display 2│ │Display 3│ │Display 4│
│Room A   │ │Room B   │ │Room C   │ │ Online  │
└─────────┘ └─────────┘ └─────────┘ └─────────┘

• All displays show same notes
• Or filter by tags/categories (future)


SCALE UP: HIGH VOLUME EVENT
────────────────────────────
┌──────────────────┐
│ 20 iPads         │
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ 300 notes/hour   │  Sustained rate
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Multiple displays│  Rooms + online
└────┬─────────────┘
     │
     ↓
┌──────────────────┐
│ Firebase Blaze   │  $0.10/GB (pay as you go)
│ ~$5-10/event     │  300 notes = ~150MB
└──────────────────┘


BOTTLENECKS & SOLUTIONS
───────────────────────
Bottleneck: Display duration (12s per note)
Solution: Reduce to 8s or use multiple displays

Bottleneck: Firebase free tier (10GB/month)
Solution: Upgrade to Blaze (~$5/month for most events)

Bottleneck: Note queue backup
Solution: Add more displays or increase display speed

Bottleneck: iPad battery life
Solution: Keep plugged in or use 6+ hour events max
```

---

**Last Updated:** October 22, 2025
