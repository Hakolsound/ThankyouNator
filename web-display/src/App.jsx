import { useState, useEffect } from 'react';
import { useFirebaseListener } from './hooks/useFirebaseListener';
import { database, ref, onValue } from './firebase';
import LandscapeMode from './components/LandscapeMode';
import PortraitMode from './components/PortraitMode';
import IdleScreen from './components/IdleScreen';
import ConnectionStatus from './components/ConnectionStatus';

function App() {
  const { notes, isConnected, lastUpdate, markAsDisplaying } = useFirebaseListener();
  const [displayMode, setDisplayMode] = useState('landscape'); // 'landscape' or 'portrait'
  const [displayDuration, setDisplayDuration] = useState(12000); // 12 seconds
  const [scrollSpeed, setScrollSpeed] = useState('medium'); // For portrait mode
  const [zoomDuration, setZoomDuration] = useState(8000); // For portrait mode
  const [cardsPerRow, setCardsPerRow] = useState(3); // For portrait mode grid
  const [focusFrequency, setFocusFrequency] = useState('normal'); // For portrait mode
  const [branding, setBranding] = useState({
    backgroundType: 'gradient',
    backgroundColor: '#f0f0f0',
    gradientStart: '#faf5ff',
    gradientEnd: '#fce7f3',
    backgroundImage: '',
    headerColorStart: '#a855f7',
    headerColorEnd: '#ec4899',
    headerFont: 'system-ui',
    headerPadding: 'normal'
  });
  const [allNotes, setAllNotes] = useState([]); // Accumulated notes throughout event
  const [processedIds, setProcessedIds] = useState(new Set()); // Track which notes we've shown

  // Listen for display settings from Firebase
  useEffect(() => {
    const settingsRef = ref(database, 'displaySettings');
    const unsub = onValue(settingsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        if (data.displayMode) setDisplayMode(data.displayMode);
        if (data.displayDuration) setDisplayDuration(data.displayDuration * 1000);
        if (data.scrollSpeed) setScrollSpeed(data.scrollSpeed);
        if (data.zoomDuration) setZoomDuration(data.zoomDuration * 1000);
        if (data.cardsPerRow) setCardsPerRow(data.cardsPerRow);
        if (data.focusFrequency) setFocusFrequency(data.focusFrequency);
        if (data.branding) setBranding(data.branding);
      }
    });
    return () => unsub();
  }, []);

  // Listen for display mode changes from host panel
  useEffect(() => {
    const handleMessage = (event) => {
      if (event.data.type === 'DISPLAY_MODE') {
        setDisplayMode(event.data.mode);
      }
      if (event.data.type === 'DISPLAY_DURATION') {
        setDisplayDuration(event.data.duration * 1000);
      }
      if (event.data.type === 'CLEAR_NOTES') {
        // Host panel can send this to clear all notes
        setAllNotes([]);
        setProcessedIds(new Set());
      }
      if (event.data.type === 'RESET_SLIDESHOW') {
        // Reset to show only current approved notes
        setAllNotes([]);
        setProcessedIds(new Set());
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  // Process new notes - accumulate instead of replacing
  useEffect(() => {
    if (notes.length > 0) {
      processNotes();
    }
  }, [notes]);

  const processNotes = async () => {
    // Find new notes we haven't processed yet
    const newNotes = notes.filter(note => !processedIds.has(note.id));

    if (newNotes.length === 0) return;

    // Mark new notes as displaying and add to processedIds
    const newIds = new Set(processedIds);
    for (const note of newNotes) {
      await markAsDisplaying(note.id);
      newIds.add(note.id);
    }
    setProcessedIds(newIds);

    // Add new notes to accumulated list (newest first), ensuring uniqueness
    setAllNotes(prev => {
      const existingIds = new Set(prev.map(n => n.id));
      const uniqueNewNotes = newNotes.filter(n => !existingIds.has(n.id));
      return [...uniqueNewNotes, ...prev];
    });
  };

  return (
    <div className="w-screen h-screen overflow-hidden bg-gradient-to-br from-blue-50 to-purple-50">
      {/* Connection Status */}
      <ConnectionStatus isConnected={isConnected} lastUpdate={lastUpdate} />

      {/* Display Content */}
      {allNotes.length === 0 ? (
        <IdleScreen />
      ) : (
        <>
          {displayMode === 'landscape' ? (
            <LandscapeMode notes={allNotes} displayDuration={displayDuration} />
          ) : (
            <PortraitMode
              notes={allNotes}
              displayDuration={displayDuration}
              scrollSpeed={scrollSpeed}
              zoomDuration={zoomDuration}
              cardsPerRow={cardsPerRow}
              focusFrequency={focusFrequency}
              branding={branding}
            />
          )}
        </>
      )}
    </div>
  );
}

export default App;
