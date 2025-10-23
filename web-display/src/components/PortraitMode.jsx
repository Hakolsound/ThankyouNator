import React, { useEffect, useState } from 'react';
import NoteCard from './NoteCard';

const PortraitMode = ({ notes }) => {
  const [currentIndex, setCurrentIndex] = useState(0);

  // Auto-advance through notes
  useEffect(() => {
    if (notes.length <= 1) return; // No need to cycle with one note

    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % notes.length);
    }, 12000); // Change note every 12 seconds

    return () => clearInterval(interval);
  }, [notes.length]);

  if (notes.length === 0) return null;

  const currentNote = notes[currentIndex];

  return (
    <div className="w-full h-full flex flex-col items-center justify-center p-12">
      <div className="animate-fade-in" key={currentNote.id}>
        <NoteCard note={currentNote} large />
      </div>

      {/* Page indicator dots (bottom) */}
      {notes.length > 1 && (
        <div className="fixed bottom-8">
          <div className="flex gap-3">
            {notes.slice(0, Math.min(10, notes.length)).map((_, i) => (
              <div
                key={i}
                className={`h-3 rounded-full transition-all duration-300 ${
                  i === currentIndex
                    ? 'bg-orange-500 w-12'
                    : 'bg-gray-300 w-3'
                }`}
              />
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default PortraitMode;
