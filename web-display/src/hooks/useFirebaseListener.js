import { useState, useEffect } from 'react';
import { database, ref, onValue, query, orderByChild, equalTo } from '../firebase';
import { ref as dbRef, update } from 'firebase/database';

export const useFirebaseListener = () => {
  const [notes, setNotes] = useState([]);
  const [isConnected, setIsConnected] = useState(false);
  const [lastUpdate, setLastUpdate] = useState(null);

  useEffect(() => {
    // Listen for connection status
    const connectedRef = ref(database, '.info/connected');
    const connectionUnsub = onValue(connectedRef, (snapshot) => {
      setIsConnected(snapshot.val() === true);
    });

    // Listen for ALL sessions and filter in memory
    const sessionsRef = ref(database, 'sessions');

    const notesUnsub = onValue(sessionsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        const notesArray = Object.entries(data)
          .map(([id, note]) => ({
            id,
            ...note,
          }))
          // Filter for ready_for_display OR displaying status
          .filter(note => note.status === 'ready_for_display' || note.status === 'displaying');

        // Sort by createdAt (newest first)
        notesArray.sort((a, b) => b.createdAt - a.createdAt);

        setNotes(notesArray);
        setLastUpdate(Date.now());
      } else {
        setNotes([]);
      }
    });

    return () => {
      connectionUnsub();
      notesUnsub();
    };
  }, []);

  // Mark note as displaying
  const markAsDisplaying = async (sessionId) => {
    const sessionRef = dbRef(database, `sessions/${sessionId}`);
    await update(sessionRef, {
      status: 'displaying',
      displayedAt: Date.now(),
    });
  };

  // Mark note as complete
  const markAsComplete = async (sessionId) => {
    const sessionRef = dbRef(database, `sessions/${sessionId}`);
    await update(sessionRef, {
      status: 'complete',
    });
  };

  return {
    notes,
    isConnected,
    lastUpdate,
    markAsDisplaying,
    markAsComplete,
  };
};
