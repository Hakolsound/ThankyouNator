import { useState, useEffect } from 'react';
import { database, ref, onValue, update, remove } from './firebase';
import Dashboard from './components/Dashboard';
import Controls from './components/Controls';
import ModQueue from './components/ModQueue';
import RejectedQueue from './components/RejectedQueue';
import ConfirmationModal from './components/ConfirmationModal';
import Stats from './components/Stats';

function App() {
  const [sessions, setSessions] = useState([]);
  const [isConnected, setIsConnected] = useState(false);
  const [activeTab, setActiveTab] = useState('pending');
  const [showResetModal, setShowResetModal] = useState(false);
  const [settings, setSettings] = useState({
    displayMode: 'landscape',
    displayDuration: 12,
    scrollSpeed: 'medium', // For portrait mode social wall
    zoomDuration: 8, // For portrait mode zoom focus (seconds)
    cardsPerRow: 3, // For portrait mode grid (2-4)
    focusFrequency: 'normal', // For portrait mode focus frequency
    // Branding settings
    branding: {
      backgroundType: 'gradient', // 'solid', 'gradient', 'image'
      backgroundColor: '#f0f0f0',
      gradientStart: '#faf5ff',
      gradientEnd: '#fce7f3',
      gradientAngle: 135, // 0-360 degrees
      backgroundImage: '',
      headerColorStart: '#a855f7',
      headerColorEnd: '#ec4899',
      headerGradientAngle: 90, // 0-360 degrees (90 = left to right)
      headerFont: 'system-ui',
      headerPadding: 'normal', // 'compact', 'normal', 'spacious'
      headerFontSize: 'native' // 'small', 'native', 'big'
    }
  });

  // Listen for display settings from Firebase
  useEffect(() => {
    const settingsRef = ref(database, 'displaySettings');
    const unsub = onValue(settingsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        setSettings(prev => ({
          ...prev,
          ...data,
          branding: {
            ...prev.branding,
            ...(data.branding || {})
          }
        }));
      }
    });
    return () => unsub();
  }, []);

  // Listen for connection status
  useEffect(() => {
    const connectedRef = ref(database, '.info/connected');
    const unsub = onValue(connectedRef, (snapshot) => {
      setIsConnected(snapshot.val() === true);
    });
    return () => unsub();
  }, []);

  // Listen for all sessions
  useEffect(() => {
    const sessionsRef = ref(database, 'sessions');
    const unsub = onValue(sessionsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        const sessionsArray = Object.entries(data).map(([id, session]) => ({
          id,
          ...session,
        }));
        sessionsArray.sort((a, b) => b.createdAt - a.createdAt);
        setSessions(sessionsArray);
      } else {
        setSessions([]);
      }
    });
    return () => unsub();
  }, []);

  // Approve note (change status to ready_for_display)
  const approveNote = async (sessionId) => {
    const sessionRef = ref(database, `sessions/${sessionId}`);
    await update(sessionRef, { status: 'ready_for_display' });
  };

  // Reject note (change status to rejected)
  const rejectNote = async (sessionId) => {
    const sessionRef = ref(database, `sessions/${sessionId}`);
    await update(sessionRef, { status: 'rejected' });
  };

  // Restore note (change from rejected back to pending)
  const restoreNote = async (sessionId) => {
    const sessionRef = ref(database, `sessions/${sessionId}`);
    await update(sessionRef, { status: 'pending' });
  };

  // Delete forever with easy confirmation
  const deleteForever = async (sessionId) => {
    if (confirm('Delete this note forever? This cannot be undone.')) {
      const sessionRef = ref(database, `sessions/${sessionId}`);
      await remove(sessionRef);
    }
  };

  // Clear all notes from Firebase
  const clearAllNotes = async () => {
    const sessionsRef = ref(database, 'sessions');
    await remove(sessionsRef);
  };

  // Reset slideshow with strict confirmation
  const resetSlideshow = () => {
    const displayWindow = window.open('', 'display');
    if (displayWindow) {
      displayWindow.postMessage({ type: 'RESET_SLIDESHOW' }, '*');
    }
    // Also try posting to localhost:3000 directly
    window.postMessage({ type: 'RESET_SLIDESHOW' }, 'http://localhost:3000');
    setShowResetModal(false);
  };

  // Update settings in Firebase
  const updateSettings = async (newSettings) => {
    const updatedSettings = { ...settings, ...newSettings };
    const settingsRef = ref(database, 'displaySettings');
    await update(settingsRef, updatedSettings);
  };

  // Open display window
  const openDisplay = () => {
    const displayUrl = import.meta.env.VITE_DISPLAY_URL || 'http://localhost:3000';
    window.open(displayUrl, 'display', 'width=1920,height=1080,fullscreen=yes');
  };

  // Create test notes for demo
  const createTestNotes = async () => {
    const testImage = "iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAFUlEQVR42mP8z8BQz0AEYBxVSF+FABJADveWkH6oAAAAAElFTkSuQmCC";

    const testNotes = [
      { recipient: "Sarah Johnson", sender: "Mike Chen", theme: "watercolor" },
      { recipient: "The Team", sender: "Emily Rodriguez", theme: "heartBorder" },
      { recipient: "Dr. Smith", sender: "John Williams", theme: "confetti" },
    ];

    for (let i = 0; i < testNotes.length; i++) {
      const note = testNotes[i];
      const sessionId = `test-${Date.now()}-${i}`;
      const timestamp = Date.now() - (i * 60000);

      const sessionRef = ref(database, `sessions/${sessionId}`);
      await update(sessionRef, {
        sessionId,
        status: 'pending',
        createdAt: timestamp,
        expiresAt: timestamp + 3600000,
        iPad_input: {
          recipient: note.recipient,
          sender: note.sender,
          drawingImage: testImage,
          templateTheme: note.theme,
        }
      });
    }

    alert('✅ Created 3 test notes!');
  };

  const pendingNotes = sessions.filter((s) => s.status === 'pending');
  const liveNotes = sessions.filter((s) => s.status === 'ready_for_display' || s.status === 'displaying');
  const rejectedNotes = sessions.filter((s) => s.status === 'rejected');
  const displayedToday = sessions.filter(
    (s) =>
      s.status === 'complete' &&
      new Date(s.createdAt).toDateString() === new Date().toDateString()
  ).length;

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-gray-900 to-slate-800">
      <div className="container mx-auto px-6 py-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <h1 className="text-4xl font-bold bg-gradient-to-r from-blue-400 to-purple-400 bg-clip-text text-transparent">Thank You Notes - Host Panel</h1>
          <div className="flex items-center gap-4">
            <div
              className={`w-3 h-3 rounded-full ${
                isConnected ? 'bg-green-500' : 'bg-red-500'
              } shadow-lg`}
              title={isConnected ? 'Connected' : 'Offline'}
            />
            <button
              onClick={createTestNotes}
              className="px-6 py-2 bg-gradient-to-r from-green-400 to-emerald-500 hover:from-green-500 hover:to-emerald-600 text-white rounded-lg font-medium transition-all shadow-md"
            >
              ✨ Create Test Notes
            </button>
            <button
              onClick={openDisplay}
              className="px-6 py-2 bg-gradient-to-r from-indigo-500 to-purple-600 hover:from-indigo-600 hover:to-purple-700 text-white rounded-lg font-medium transition-all shadow-md"
            >
              Open Display
            </button>
          </div>
        </div>

        {/* Stats */}
        <Stats
          totalSessions={sessions.length}
          displayedToday={displayedToday}
        />

        {/* Main content - Tab layout */}
        <div className="space-y-6 mt-8">
          {/* Tab Navigation */}
          <div className="flex gap-3 bg-gradient-to-r from-slate-800 to-slate-700 p-2 rounded-xl shadow-2xl border border-slate-600">
            <button
              onClick={() => setActiveTab('pending')}
              className={`flex-1 px-6 py-4 rounded-lg font-semibold transition-all shadow-md ${
                activeTab === 'pending'
                  ? 'bg-gradient-to-r from-blue-500 to-cyan-500 text-white border-2 border-blue-400'
                  : 'bg-slate-700/50 text-gray-300 hover:bg-slate-600 border-2 border-transparent'
              }`}
            >
              <div className="flex items-center justify-center gap-2">
                <span className="text-xl">⏳</span>
                <span>Pending ({pendingNotes.length})</span>
              </div>
            </button>
            <button
              onClick={() => setActiveTab('live')}
              className={`flex-1 px-6 py-4 rounded-lg font-semibold transition-all shadow-md ${
                activeTab === 'live'
                  ? 'bg-gradient-to-r from-green-500 to-emerald-500 text-white border-2 border-green-400'
                  : 'bg-slate-700/50 text-gray-300 hover:bg-slate-600 border-2 border-transparent'
              }`}
            >
              <div className="flex items-center justify-center gap-2">
                <span className="text-xl">📺</span>
                <span>Live ({liveNotes.length})</span>
              </div>
            </button>
            <button
              onClick={() => setActiveTab('rejected')}
              className={`flex-1 px-6 py-4 rounded-lg font-semibold transition-all shadow-md ${
                activeTab === 'rejected'
                  ? 'bg-gradient-to-r from-red-500 to-pink-500 text-white border-2 border-red-400'
                  : 'bg-slate-700/50 text-gray-300 hover:bg-slate-600 border-2 border-transparent'
              }`}
            >
              <div className="flex items-center justify-center gap-2">
                <span className="text-xl">🚫</span>
                <span>Rejected ({rejectedNotes.length})</span>
              </div>
            </button>
          </div>

          {/* Tab Content and Controls Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Tab Content - 2 columns */}
            <div className="lg:col-span-2">
              {activeTab === 'pending' && (
                <Dashboard
                  sessions={sessions}
                  onApprove={approveNote}
                  onReject={rejectNote}
                  onDeleteForever={deleteForever}
                />
              )}
              {activeTab === 'live' && (
                <ModQueue
                  liveNotes={liveNotes}
                  onReject={rejectNote}
                  onDeleteForever={deleteForever}
                />
              )}
              {activeTab === 'rejected' && (
                <RejectedQueue
                  rejectedNotes={rejectedNotes}
                  onRestore={restoreNote}
                  onDeleteForever={deleteForever}
                />
              )}
            </div>

            {/* Controls - 1 column */}
            <div className="lg:col-span-1">
              <Controls
                settings={settings}
                updateSettings={updateSettings}
                onClearAll={clearAllNotes}
                onResetSlideshow={() => setShowResetModal(true)}
              />
            </div>
          </div>
        </div>

        {/* Reset Confirmation Modal */}
        <ConfirmationModal
          isOpen={showResetModal}
          onClose={() => setShowResetModal(false)}
          onConfirm={resetSlideshow}
          title="⚠️ Reset Slideshow"
          message="This will reset the entire slideshow and restart from the beginning. This action cannot be undone."
          confirmText="RESET"
        />
      </div>
    </div>
  );
}

export default App;
