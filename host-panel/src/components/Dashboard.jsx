import React, { useState, useRef } from 'react';

const Dashboard = ({ sessions, onApprove, onReject, onRemove, onDeleteForever }) => {
  const [hoveredNote, setHoveredNote] = useState(null);
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const hoverTimeoutRef = useRef(null);
  const hideTimeoutRef = useRef(null);

  // Filter only pending notes
  const pendingNotes = sessions.filter(s => s.status === 'pending');

  const handleMouseEnter = (sessionId, event) => {
    // Clear any existing timeouts
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

    // Set timeout for 0.8 seconds before showing preview
    hoverTimeoutRef.current = setTimeout(() => {
      setHoveredNote(sessionId);
    }, 800);
  };

  const handleMouseLeave = () => {
    // Clear hover timeout if mouse leaves before preview appears
    if (hoverTimeoutRef.current) {
      clearTimeout(hoverTimeoutRef.current);
    }
    // Add 250ms delay before hiding popup
    hideTimeoutRef.current = setTimeout(() => {
      setHoveredNote(null);
    }, 250);
  };

  const handlePreviewMouseEnter = () => {
    // Cancel hide timeout when mouse enters preview
    if (hideTimeoutRef.current) {
      clearTimeout(hideTimeoutRef.current);
    }
  };

  const handlePreviewMouseLeave = () => {
    // Hide immediately when leaving preview
    setHoveredNote(null);
  };

  return (
    <div className="bg-gradient-to-br from-slate-800 to-slate-700 rounded-xl p-6 h-full shadow-2xl border border-blue-500/30">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-2xl font-bold text-white">Pending</h2>
        <span className="text-sm text-blue-300 bg-blue-500/20 px-3 py-1 rounded-full font-medium border border-blue-400/30">
          {pendingNotes.length} notes
        </span>
      </div>

      <div>
        {pendingNotes.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">✅</div>
            <p className="text-gray-400">All clear! No pending notes.</p>
          </div>
        ) : (
          <div className="grid grid-cols-4 sm:grid-cols-6 gap-2">
            {pendingNotes.map((session) => (
              <div
                key={session.id}
                className="relative group cursor-pointer"
                onMouseEnter={(e) => handleMouseEnter(session.id, e)}
                onMouseLeave={handleMouseLeave}
              >
                {/* Thumbnail */}
                <div className="aspect-[3/4] bg-slate-900 rounded-lg overflow-hidden border-2 border-blue-500/40 hover:border-blue-400 transition-all shadow-lg">
                  <img
                    src={`data:image/png;base64,${session.iPad_input?.drawingImage}`}
                    alt="Note thumbnail"
                    className="w-full h-full object-cover"
                  />
                </div>

                {/* Hover Preview with Quick Actions - smart positioned */}
                {hoveredNote === session.id && (
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
                      {/* Preview Card with Pending color (Blue) */}
                      <div className="bg-white rounded-2xl shadow-2xl overflow-hidden border-4 border-blue-400 w-80">
                        {/* Image */}
                        <img
                          src={`data:image/png;base64,${session.iPad_input?.drawingImage}`}
                          alt="Note preview"
                          className="w-full h-auto"
                        />

                        {/* Info Bar */}
                        <div className="bg-gradient-to-r from-blue-500 to-cyan-500 px-4 py-3">
                          <p className="text-white font-semibold text-sm">
                            To: {session.iPad_input?.recipient || 'Unknown'}
                          </p>
                          <p className="text-white/80 text-xs">
                            From: {session.iPad_input?.sender || 'Unknown'}
                          </p>
                        </div>

                        {/* Quick Actions */}
                        <div className="flex gap-2 p-3 bg-gradient-to-r from-blue-50 to-cyan-50">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onApprove(session.id);
                              setHoveredNote(null);
                            }}
                            className="flex-1 px-4 py-2 bg-gradient-to-r from-green-400 to-emerald-500 hover:from-green-500 hover:to-emerald-600 text-white rounded-lg font-medium transition-all text-sm shadow-md"
                          >
                            ✅ Approve
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onReject(session.id);
                              setHoveredNote(null);
                            }}
                            className="flex-1 px-4 py-2 bg-gradient-to-r from-orange-400 to-red-400 hover:from-orange-500 hover:to-red-500 text-white rounded-lg font-medium transition-all text-sm shadow-md"
                          >
                            🚫 Reject
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onDeleteForever(session.id);
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

export default Dashboard;
