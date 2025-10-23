import { useState, useEffect } from 'react';
import { database, ref, onValue, update, remove } from './firebase';
import Dashboard from './components/Dashboard';
import Controls from './components/Controls';
import ModQueue from './components/ModQueue';
import Stats from './components/Stats';

function App() {
  const [sessions, setSessions] = useState([]);
  const [isConnected, setIsConnected] = useState(false);
  const [settings, setSettings] = useState({
    displayMode: 'landscape',
    displayDuration: 12,
    animationSpeed: 'normal',
    fontSize: 'medium',
  });

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

  // Reject/Delete note
  const rejectNote = async (sessionId) => {
    const sessionRef = ref(database, `sessions/${sessionId}`);
    await remove(sessionRef);
  };

  // Remove note from display (delete from Firebase)
  const removeNote = async (sessionId) => {
    if (confirm('Are you sure you want to remove this note?')) {
      const sessionRef = ref(database, `sessions/${sessionId}`);
      await remove(sessionRef);
    }
  };

  // Clear all notes from Firebase
  const clearAllNotes = async () => {
    const sessionsRef = ref(database, 'sessions');
    await remove(sessionsRef);
  };

  // Reset slideshow - send message to display to clear its array
  const resetSlideshow = () => {
    const displayWindow = window.open('', 'display');
    if (displayWindow) {
      displayWindow.postMessage({ type: 'RESET_SLIDESHOW' }, '*');
    }
    // Also try posting to localhost:3000 directly
    window.postMessage({ type: 'RESET_SLIDESHOW' }, 'http://localhost:3000');
  };

  // Update settings and notify display
  const updateSettings = (newSettings) => {
    setSettings((prev) => ({ ...prev, ...newSettings }));

    // Send message to display window
    const displayWindow = window.open('', 'display');
    if (displayWindow) {
      if (newSettings.displayMode) {
        displayWindow.postMessage(
          { type: 'DISPLAY_MODE', mode: newSettings.displayMode },
          '*'
        );
      }
      if (newSettings.displayDuration) {
        displayWindow.postMessage(
          { type: 'DISPLAY_DURATION', duration: newSettings.displayDuration },
          '*'
        );
      }
    }
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
  const displayedToday = sessions.filter(
    (s) =>
      s.status === 'complete' &&
      new Date(s.createdAt).toDateString() === new Date().toDateString()
  ).length;

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="container mx-auto px-6 py-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <h1 className="text-4xl font-bold">Thank You Notes - Host Panel</h1>
          <div className="flex items-center gap-4">
            <div
              className={`w-3 h-3 rounded-full ${
                isConnected ? 'bg-green-500' : 'bg-red-500'
              } shadow-lg`}
              title={isConnected ? 'Connected' : 'Offline'}
            />
            <button
              onClick={createTestNotes}
              className="px-6 py-2 bg-green-600 hover:bg-green-700 rounded-lg font-medium transition-colors"
            >
              ✨ Create Test Notes
            </button>
            <button
              onClick={openDisplay}
              className="px-6 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg font-medium transition-colors"
            >
              Open Display
            </button>
          </div>
        </div>

        {/* Stats */}
        <Stats
          totalSessions={sessions.length}
          pendingCount={pendingNotes.length}
          displayedToday={displayedToday}
        />

        {/* Main content grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-8">
          {/* Left column - Dashboard & Controls */}
          <div className="lg:col-span-2 space-y-6">
            <Dashboard
              sessions={sessions}
              onApprove={approveNote}
              onReject={rejectNote}
              onRemove={removeNote}
            />
            <Controls settings={settings} updateSettings={updateSettings} onClearAll={clearAllNotes} onResetSlideshow={resetSlideshow} />
          </div>

          {/* Right column - Moderation Queue */}
          <div className="lg:col-span-1">
            <ModQueue
              pendingNotes={pendingNotes}
              onApprove={approveNote}
              onReject={rejectNote}
            />
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
