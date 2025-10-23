import React, { useState } from 'react';

const ModQueue = ({ pendingNotes, onApprove, onReject }) => {
  const [previewNote, setPreviewNote] = useState(null);

  return (
    <div className="bg-gray-800 rounded-xl p-6">
      <h2 className="text-2xl font-bold mb-4">Moderation Queue</h2>

      {pendingNotes.length === 0 ? (
        <div className="text-center py-12">
          <div className="text-6xl mb-4">✅</div>
          <p className="text-gray-400">All clear! No pending notes.</p>
        </div>
      ) : (
        <div className="space-y-4">
          {pendingNotes.map((note) => (
            <div
              key={note.id}
              className="bg-gray-700 rounded-lg p-4 hover:bg-gray-600 transition-colors"
            >
              {/* Note info */}
              <div className="mb-3">
                <p className="font-semibold text-lg">
                  To: {note.iPad_input?.recipient || 'Unknown'}
                </p>
                <p className="text-sm text-gray-400">
                  From: {note.iPad_input?.sender || 'Unknown'}
                </p>
                <p className="text-xs text-gray-500 mt-1">
                  {new Date(note.createdAt).toLocaleString()}
                </p>
              </div>

              {/* Preview button */}
              <button
                onClick={() => setPreviewNote(note)}
                className="w-full mb-3 px-3 py-2 bg-gray-600 hover:bg-gray-500 rounded text-sm font-medium transition-colors"
              >
                👁️ Preview Drawing
              </button>

              {/* Action buttons */}
              <div className="flex gap-2">
                <button
                  onClick={() => onApprove(note.id)}
                  className="flex-1 px-4 py-2 bg-green-600 hover:bg-green-700 rounded-lg font-medium transition-colors"
                >
                  ✅ Approve
                </button>
                <button
                  onClick={() => onReject(note.id)}
                  className="flex-1 px-4 py-2 bg-red-600 hover:bg-red-700 rounded-lg font-medium transition-colors"
                >
                  ❌ Reject
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Preview Modal */}
      {previewNote && (
        <div
          className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-50 p-8"
          onClick={() => setPreviewNote(null)}
        >
          <div
            className="bg-white rounded-2xl overflow-hidden max-w-2xl w-full shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="bg-gradient-to-r from-indigo-500 to-purple-500 px-6 py-4">
              <div className="flex items-center justify-between">
                <p className="text-white text-xl font-semibold">
                  To: {previewNote.iPad_input?.recipient}
                </p>
                <button
                  onClick={() => setPreviewNote(null)}
                  className="text-white hover:text-gray-200 text-2xl"
                >
                  ×
                </button>
              </div>
            </div>

            {/* Drawing */}
            <div className="p-6">
              <img
                src={`data:image/png;base64,${previewNote.iPad_input?.drawingImage}`}
                alt="Note preview"
                className="w-full h-auto rounded-lg"
              />
            </div>

            {/* Footer */}
            <div className="bg-gray-50 px-6 py-4 border-t border-gray-200">
              <p className="text-gray-600 text-lg italic">
                From: {previewNote.iPad_input?.sender}
              </p>
            </div>

            {/* Action buttons */}
            <div className="flex gap-3 p-6 bg-gray-100">
              <button
                onClick={() => {
                  onApprove(previewNote.id);
                  setPreviewNote(null);
                }}
                className="flex-1 px-6 py-3 bg-green-600 hover:bg-green-700 text-white rounded-lg font-medium transition-colors"
              >
                ✅ Approve & Display
              </button>
              <button
                onClick={() => {
                  onReject(previewNote.id);
                  setPreviewNote(null);
                }}
                className="flex-1 px-6 py-3 bg-red-600 hover:bg-red-700 text-white rounded-lg font-medium transition-colors"
              >
                ❌ Reject & Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ModQueue;
