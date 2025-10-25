import React, { useState, useRef } from 'react';

const RejectedQueue = ({ rejectedNotes, onRestore, onDeleteForever }) => {
  const [hoveredNote, setHoveredNote] = useState(null);
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const hoverTimeoutRef = useRef(null);
  const hideTimeoutRef = useRef(null);

  const handleMouseEnter = (noteId, event) => {
    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
    }
    if (hideTimeoutRef.current) {
      clearTimeout(hideTimeoutRef.current);
    }

    // Calculate optimal preview position
    const rect = event.currentTarget.getBoundingClientRect();
    const previewWidth = 320;
    const previewHeight = 500;
    const margin = 40;

    // Start with mouse position
    let x = event.clientX;
    let y = event.clientY;

    // Check if there's enough space above the mouse
    const spaceAbove = y - margin;
    const spaceBelow = window.innerHeight - y - margin;

    // Position preview with minimal Y shift, just enough to fit in viewport
    if (spaceAbove >= previewHeight) {
      // Enough space above - align bottom of preview slightly above mouse
      y = y - 20; // Small offset from mouse
    } else if (spaceBelow >= previewHeight) {
      // Not enough space above, but enough below - align top slightly below mouse
      y = y + 20; // Small offset from mouse
    } else {
      // Not enough space on either side - clamp to viewport
      y = Math.max(margin, Math.min(y - previewHeight / 2, window.innerHeight - previewHeight - margin));
    }

    // Clamp Y to ensure preview stays within viewport
    y = Math.max(margin, Math.min(y, window.innerHeight - previewHeight - margin));

    // Adjust horizontal position to center on mouse, but keep in viewport
    x = x - previewWidth / 2;

    // Clamp X to viewport
    if (x < margin) {
      x = margin;
    } else if (x + previewWidth > window.innerWidth - margin) {
      x = window.innerWidth - previewWidth - margin;
    }

    setMousePosition({ x, y });

    hoverTimeoutRef.current = setTimeout(() => {
      setHoveredNote(noteId);
    }, 800);
  };

  const handleMouseLeave = () => {
    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
    }
    hideTimeoutRef.current = setTimeout(() => {
      setHoveredNote(null);
    }, 250);
  };

  const handlePreviewMouseEnter = () => {
    if (hideTimeoutRef.current) {
      clearTimeout(hideTimeoutRef.current);
    }
  };

  const handlePreviewMouseLeave = () => {
    setHoveredNote(null);
  };

  return (
    <div className="bg-gradient-to-br from-slate-800 to-slate-700 rounded-xl p-6 h-full shadow-2xl border border-red-500/30">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-2xl font-bold text-white">Rejected</h2>
        <span className="text-sm text-red-300 bg-red-500/20 px-3 py-1 rounded-full font-medium border border-red-400/30">
          {rejectedNotes.length} notes
        </span>
      </div>

      <div className="overflow-y-auto" style={{ maxHeight: 'calc(100vh - 300px)' }}>
        {rejectedNotes.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">🗑️</div>
            <p className="text-gray-400">No rejected notes.</p>
          </div>
        ) : (
          <div className="grid grid-cols-4 sm:grid-cols-6 gap-2">
            {rejectedNotes.map((note) => (
              <div
                key={note.id}
                className="relative group cursor-pointer"
                onMouseEnter={(e) => handleMouseEnter(note.id, e)}
                onMouseLeave={handleMouseLeave}
              >
                {/* Thumbnail */}
                <div className="relative aspect-[3/4] bg-slate-900 rounded-lg overflow-hidden border-2 border-red-500/40 hover:border-red-400 transition-all shadow-lg">
                  <img
                    src={`data:image/png;base64,${note.iPad_input?.drawingImage}`}
                    alt="Note thumbnail"
                    className="w-full h-full object-cover"
                  />
                  {/* Rejected badge overlay */}
                  <div className="absolute top-1 right-1">
                    <span className="bg-red-500 px-1 py-0.5 rounded-full text-xs font-medium text-white shadow-lg">
                      🚫
                    </span>
                  </div>
                </div>

                {/* Hover Preview with Quick Actions - smart positioned */}
                {hoveredNote === note.id && (
                  <div
                    className="fixed z-50 pointer-events-none"
                    style={{
                      left: `${mousePosition.x}px`,
                      top: `${mousePosition.y}px`
                    }}
                  >
                    <div
                      className="relative pointer-events-auto"
                      onMouseEnter={handlePreviewMouseEnter}
                      onMouseLeave={handlePreviewMouseLeave}
                    >
                      {/* Preview Card with Rejected color (Red) */}
                      <div className="bg-white rounded-2xl shadow-2xl overflow-hidden border-4 border-red-400 w-80">
                        {/* Image */}
                        <img
                          src={`data:image/png;base64,${note.iPad_input?.drawingImage}`}
                          alt="Note preview"
                          className="w-full h-auto"
                        />

                        {/* Info Bar */}
                        <div className="bg-gradient-to-r from-red-500 to-pink-500 px-4 py-3">
                          <div className="flex items-center justify-between">
                            <div>
                              <p className="text-white font-semibold text-sm">
                                To: {note.iPad_input?.recipient || 'Unknown'}
                              </p>
                              <p className="text-white/80 text-xs">
                                From: {note.iPad_input?.sender || 'Unknown'}
                              </p>
                            </div>
                            <span className="bg-white/20 px-2 py-1 rounded-full text-xs font-medium text-white">
                              🚫 Rejected
                            </span>
                          </div>
                        </div>

                        {/* Quick Actions */}
                        <div className="flex gap-2 p-3 bg-gradient-to-r from-red-50 to-pink-50">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onRestore(note.id);
                              setHoveredNote(null);
                            }}
                            className="flex-1 px-4 py-2 bg-gradient-to-r from-blue-400 to-cyan-500 hover:from-blue-500 hover:to-cyan-600 text-white rounded-lg font-medium transition-all text-sm shadow-md"
                          >
                            ↩️ Restore
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onDeleteForever(note.id);
                              setHoveredNote(null);
                            }}
                            className="px-4 py-2 bg-gradient-to-r from-red-500 to-pink-500 hover:from-red-600 hover:to-pink-600 text-white rounded-lg font-medium transition-all text-sm shadow-md"
                          >
                            ❌
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default RejectedQueue;
