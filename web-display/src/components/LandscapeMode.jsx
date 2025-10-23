import { useEffect, useState } from 'react';
import NoteCard from './NoteCard';

const LandscapeMode = ({ notes }) => {
  const NOTES_PER_PAGE = 6; // Show 6 notes at a time (2 rows x 3 columns)
  const CYCLE_DURATION = 15000; // 15 seconds per page

  const [displayedNotes, setDisplayedNotes] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [animatingOut, setAnimatingOut] = useState(false);

  // Update displayed notes when notes change or index changes
  useEffect(() => {
    if (notes.length > 0) {
      const start = currentIndex;
      const end = Math.min(start + NOTES_PER_PAGE, notes.length);
      setDisplayedNotes(notes.slice(start, end));
    } else {
      setDisplayedNotes([]);
    }
  }, [notes, currentIndex]);

  // Auto-cycle through notes with FIFO
  useEffect(() => {
    if (notes.length <= NOTES_PER_PAGE) {
      // If we have fewer notes than one page, don't cycle
      return;
    }

    const interval = setInterval(() => {
      // Trigger exit animation
      setAnimatingOut(true);

      // After animation, change the page
      setTimeout(() => {
        setCurrentIndex(prev => {
          const next = prev + NOTES_PER_PAGE;
          // Loop back to the beginning when we reach the end
          return next >= notes.length ? 0 : next;
        });
        setAnimatingOut(false);
      }, 500); // Duration of exit animation
    }, CYCLE_DURATION);

    return () => clearInterval(interval);
  }, [notes.length]);

  const totalPages = Math.ceil(notes.length / NOTES_PER_PAGE);

  return (
    <div className="h-screen w-screen flex flex-col items-center justify-center p-12 bg-gradient-to-br from-rose-50 via-amber-50 to-orange-50">
      {/* Notes Grid - 2 rows x 3 columns */}
      <div className={`grid grid-cols-3 gap-8 max-w-[90%] transition-all duration-500 ${
        animatingOut ? 'opacity-0 scale-95' : 'opacity-100 scale-100'
      }`}>
        {displayedNotes.map((note, index) => (
          <div
            key={note.id}
            className="transform transition-all duration-700 ease-out"
            style={{
              animation: animatingOut
                ? `slideOut 0.5s ease-in-out forwards`
                : `slideIn 0.7s ease-out ${index * 100}ms both`,
            }}
          >
            <NoteCard note={note} />
          </div>
        ))}
      </div>

      {/* Page indicator */}
      {totalPages > 1 && (
        <div className="absolute bottom-12 left-1/2 transform -translate-x-1/2">
          <div className="flex gap-3">
            {Array.from({ length: totalPages }).map((_, i) => (
              <div
                key={i}
                className={`h-3 rounded-full transition-all duration-300 ${
                  i === Math.floor(currentIndex / NOTES_PER_PAGE)
                    ? 'bg-orange-500 w-12'
                    : 'bg-gray-300 w-3'
                }`}
              />
            ))}
          </div>
        </div>
      )}

      {/* CSS Animations */}
      <style jsx>{`
        @keyframes slideIn {
          from {
            opacity: 0;
            transform: translateY(50px) scale(0.9);
          }
          to {
            opacity: 1;
            transform: translateY(0) scale(1);
          }
        }
        @keyframes slideOut {
          from {
            opacity: 1;
            transform: translateY(0) scale(1);
          }
          to {
            opacity: 0;
            transform: translateY(-50px) scale(0.9);
          }
        }
      `}</style>
    </div>
  );
};

export default LandscapeMode;
