import { useEffect, useState, useRef } from 'react';

const LandscapeMode = ({ notes, displayDuration = 12000 }) => {
  const MAX_VISIBLE_NOTES = 12; // Maximum notes visible at once
  const [visibleNotes, setVisibleNotes] = useState([]);
  const [nextNoteIndex, setNextNoteIndex] = useState(0);
  const [removingIds, setRemovingIds] = useState(new Set());

  // Initialize with first batch of notes
  useEffect(() => {
    if (notes.length > 0 && visibleNotes.length === 0) {
      const initial = notes.slice(0, Math.min(MAX_VISIBLE_NOTES, notes.length));
      setVisibleNotes(initial.map(note => ({ ...note, position: getRandomPosition() })));
      setNextNoteIndex(Math.min(MAX_VISIBLE_NOTES, notes.length));
    }
  }, [notes]);

  // FIFO: Add new note, remove oldest
  useEffect(() => {
    if (notes.length === 0 || nextNoteIndex >= notes.length) return;

    const interval = setInterval(() => {
      if (visibleNotes.length >= MAX_VISIBLE_NOTES) {
        // Remove oldest note (first in array) with animation
        const oldestId = visibleNotes[0].id;
        setRemovingIds(prev => new Set([...prev, oldestId]));

        setTimeout(() => {
          setVisibleNotes(prev => {
            const remaining = prev.slice(1);
            // Add new note
            const newNote = {
              ...notes[nextNoteIndex % notes.length],
              position: getRandomPosition()
            };
            return [...remaining, newNote];
          });
          setRemovingIds(prev => {
            const newSet = new Set(prev);
            newSet.delete(oldestId);
            return newSet;
          });
          setNextNoteIndex(prev => (prev + 1) % notes.length);
        }, 600); // Match exit animation duration
      } else {
        // Still filling up - just add notes
        setVisibleNotes(prev => [
          ...prev,
          { ...notes[nextNoteIndex % notes.length], position: getRandomPosition() }
        ]);
        setNextNoteIndex(prev => (prev + 1) % notes.length);
      }
    }, displayDuration);

    return () => clearInterval(interval);
  }, [notes, nextNoteIndex, visibleNotes.length, displayDuration]);

  // Generate random position and rotation for sticky note effect
  function getRandomPosition() {
    return {
      top: `${Math.random() * 60 + 10}%`,
      left: `${Math.random() * 70 + 10}%`,
      rotation: Math.random() * 20 - 10, // -10 to 10 degrees
      scale: Math.random() * 0.15 + 0.9, // 0.9 to 1.05
    };
  }

  if (notes.length === 0) return null;

  return (
    <div className="relative w-full h-full overflow-hidden bg-gradient-to-br from-amber-50 via-yellow-50 to-orange-50">
      {/* Cork board texture background */}
      <div className="absolute inset-0 opacity-10"
        style={{
          backgroundImage: 'radial-gradient(circle, #8b4513 1px, transparent 1px)',
          backgroundSize: '20px 20px'
        }}
      />

      {/* Sticky Notes */}
      {visibleNotes.map((note, index) => {
        const isRemoving = removingIds.has(note.id);
        const colors = [
          'bg-yellow-200',
          'bg-pink-200',
          'bg-blue-200',
          'bg-green-200',
          'bg-purple-200',
          'bg-orange-200'
        ];
        const color = colors[index % colors.length];

        return (
          <div
            key={note.id}
            className={`absolute transition-all duration-600 ${
              isRemoving ? 'animate-sticky-exit' : 'animate-sticky-enter'
            }`}
            style={{
              top: note.position.top,
              left: note.position.left,
              transform: `rotate(${note.position.rotation}deg) scale(${note.position.scale})`,
              width: '280px',
              zIndex: index,
            }}
          >
            {/* Sticky Note Card */}
            <div className={`${color} rounded-lg shadow-2xl p-4 relative`}
              style={{
                boxShadow: '0 10px 30px rgba(0,0,0,0.3), 0 5px 10px rgba(0,0,0,0.2)'
              }}
            >
              {/* Tape effect at top */}
              <div className="absolute -top-3 left-1/2 transform -translate-x-1/2 w-20 h-6 bg-white/40 rounded-sm"
                style={{
                  boxShadow: 'inset 0 1px 2px rgba(0,0,0,0.1)'
                }}
              />

              {/* Header */}
              <div className="mb-2 border-b-2 border-gray-400/30 pb-2">
                <p className="font-bold text-sm text-gray-800 truncate">
                  To: {note.iPad_input?.recipient || 'Unknown'}
                </p>
                <p className="text-xs text-gray-600 truncate">
                  From: {note.iPad_input?.sender || 'Unknown'}
                </p>
              </div>

              {/* Note Image */}
              <div className="aspect-[3/4] rounded overflow-hidden bg-white">
                <img
                  src={`data:image/png;base64,${note.iPad_input?.drawingImage}`}
                  alt="Thank you note"
                  className="w-full h-full object-cover"
                />
              </div>
            </div>
          </div>
        );
      })}

      {/* Note Counter */}
      <div className="absolute top-6 right-6 bg-white/90 backdrop-blur-sm px-5 py-3 rounded-full shadow-xl border-2 border-amber-200">
        <p className="text-lg font-bold text-amber-800">
          {notes.length} Thank You Notes
        </p>
      </div>

      {/* CSS Animations */}
      <style jsx>{`
        @keyframes sticky-enter {
          0% {
            opacity: 0;
            transform: translateY(100px) rotate(15deg) scale(0);
          }
          50% {
            transform: translateY(-20px) rotate(-5deg) scale(1.1);
          }
          100% {
            opacity: 1;
            transform: translateY(0) rotate(var(--rotation)) scale(var(--scale));
          }
        }
        @keyframes sticky-exit {
          0% {
            opacity: 1;
            transform: rotate(var(--rotation)) scale(var(--scale));
          }
          100% {
            opacity: 0;
            transform: translateY(-200px) rotate(25deg) scale(0.5);
          }
        }
        .animate-sticky-enter {
          animation: sticky-enter 0.8s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
        }
        .animate-sticky-exit {
          animation: sticky-exit 0.6s ease-in forwards;
        }
      `}</style>
    </div>
  );
};

export default LandscapeMode;
