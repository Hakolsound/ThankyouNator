import React from 'react';

const Dashboard = ({ sessions, onApprove, onReject, onRemove }) => {
  const getStatusColor = (status) => {
    switch (status) {
      case 'pending':
        return 'bg-yellow-500';
      case 'ready_for_display':
        return 'bg-blue-500';
      case 'displaying':
        return 'bg-green-500';
      case 'complete':
        return 'bg-gray-500';
      default:
        return 'bg-gray-500';
    }
  };

  const getStatusLabel = (status) => {
    return status.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase());
  };

  return (
    <div className="bg-gray-800 rounded-xl p-6">
      <h2 className="text-2xl font-bold mb-4">All Sessions</h2>
      <div className="space-y-3 max-h-[500px] overflow-y-auto">
        {sessions.length === 0 ? (
          <p className="text-gray-400 text-center py-8">No sessions yet</p>
        ) : (
          sessions.map((session) => (
            <div
              key={session.id}
              className="bg-gray-700 rounded-lg p-4 hover:bg-gray-600 transition-colors"
            >
              <div className="flex items-center justify-between mb-3">
                <div className="flex-1">
                  <p className="font-semibold text-lg">
                    To: {session.iPad_input?.recipient || 'Unknown'}
                  </p>
                  <p className="text-sm text-gray-400">
                    From: {session.iPad_input?.sender || 'Unknown'}
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <span
                    className={`${getStatusColor(
                      session.status
                    )} px-3 py-1 rounded-full text-xs font-medium whitespace-nowrap`}
                  >
                    {getStatusLabel(session.status)}
                  </span>
                </div>
              </div>

              {/* Action buttons */}
              <div className="flex gap-2 mt-3 pt-3 border-t border-gray-600">
                {session.status === 'pending' && (
                  <>
                    <button
                      onClick={() => onApprove(session.id)}
                      className="flex-1 px-3 py-2 bg-green-600 hover:bg-green-700 rounded-lg text-sm font-medium transition-colors"
                    >
                      ✅ Approve
                    </button>
                    <button
                      onClick={() => onReject(session.id)}
                      className="flex-1 px-3 py-2 bg-red-600 hover:bg-red-700 rounded-lg text-sm font-medium transition-colors"
                    >
                      ❌ Reject
                    </button>
                  </>
                )}

                {(session.status === 'ready_for_display' || session.status === 'displaying') && (
                  <>
                    <button
                      onClick={() => onRemove(session.id)}
                      className="flex-1 px-3 py-2 bg-red-600 hover:bg-red-700 rounded-lg text-sm font-medium transition-colors"
                    >
                      🗑️ Remove from Display
                    </button>
                  </>
                )}

                {session.status === 'complete' && (
                  <button
                    onClick={() => onRemove(session.id)}
                    className="flex-1 px-3 py-2 bg-gray-600 hover:bg-gray-500 rounded-lg text-sm font-medium transition-colors"
                  >
                    🗑️ Delete
                  </button>
                )}
              </div>

              <div className="flex items-center justify-between text-xs text-gray-400 mt-2">
                <span>
                  {new Date(session.createdAt).toLocaleString()}
                </span>
                <span className="font-mono">{session.id.slice(0, 8)}</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default Dashboard;
