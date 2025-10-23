import React from 'react';

const Controls = ({ settings, updateSettings, onClearAll, onResetSlideshow }) => {
  return (
    <div className="bg-gray-800 rounded-xl p-6">
      <h2 className="text-2xl font-bold mb-6">Display Settings</h2>

      <div className="space-y-6">
        {/* Display Mode */}
        <div>
          <label className="block text-sm font-medium mb-3">Display Mode</label>
          <div className="flex gap-3">
            <button
              onClick={() => updateSettings({ displayMode: 'landscape' })}
              className={`flex-1 px-4 py-3 rounded-lg font-medium transition-colors ${
                settings.displayMode === 'landscape'
                  ? 'bg-indigo-600 text-white'
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
            >
              🖼️ Landscape (Sticky Notes)
            </button>
            <button
              onClick={() => updateSettings({ displayMode: 'portrait' })}
              className={`flex-1 px-4 py-3 rounded-lg font-medium transition-colors ${
                settings.displayMode === 'portrait'
                  ? 'bg-indigo-600 text-white'
                  : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
              }`}
            >
              📱 Portrait (Full Screen)
            </button>
          </div>
        </div>

        {/* Display Duration */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <label className="block text-sm font-medium">
              Display Duration (seconds)
            </label>
            <span className="text-2xl font-bold text-indigo-400">
              {settings.displayDuration}s
            </span>
          </div>
          <input
            type="range"
            min="5"
            max="30"
            step="1"
            value={settings.displayDuration}
            onChange={(e) =>
              updateSettings({ displayDuration: parseInt(e.target.value) })
            }
            className="w-full h-2 bg-gray-700 rounded-lg appearance-none cursor-pointer accent-indigo-600"
          />
          <div className="flex justify-between text-xs text-gray-400 mt-1">
            <span>5s</span>
            <span>30s</span>
          </div>
        </div>

        {/* Animation Speed */}
        <div>
          <label className="block text-sm font-medium mb-3">
            Animation Speed
          </label>
          <div className="grid grid-cols-3 gap-3">
            {['slow', 'normal', 'fast'].map((speed) => (
              <button
                key={speed}
                onClick={() => updateSettings({ animationSpeed: speed })}
                className={`px-4 py-2 rounded-lg font-medium capitalize transition-colors ${
                  settings.animationSpeed === speed
                    ? 'bg-indigo-600 text-white'
                    : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
                }`}
              >
                {speed}
              </button>
            ))}
          </div>
        </div>

        {/* Font Size */}
        <div>
          <label className="block text-sm font-medium mb-3">Font Size</label>
          <div className="grid grid-cols-3 gap-3">
            {['small', 'medium', 'large'].map((size) => (
              <button
                key={size}
                onClick={() => updateSettings({ fontSize: size })}
                className={`px-4 py-2 rounded-lg font-medium capitalize transition-colors ${
                  settings.fontSize === size
                    ? 'bg-indigo-600 text-white'
                    : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
                }`}
              >
                {size}
              </button>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="pt-4 border-t border-gray-700">
          <label className="block text-sm font-medium mb-3">
            Quick Actions
          </label>
          <div className="grid grid-cols-3 gap-3">
            <button
              onClick={() => {
                if (confirm('🔄 Reset the slideshow display?\n\nThis will clear the displayed notes and show only currently approved notes.')) {
                  onResetSlideshow();
                }
              }}
              className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg font-medium transition-colors"
            >
              🔄 Reset Slideshow
            </button>
            <button
              onClick={() => {
                if (confirm('⚠️ This will permanently delete ALL notes from Firebase.\n\nAre you sure you want to continue?')) {
                  onClearAll();
                }
              }}
              className="px-4 py-2 bg-red-600 hover:bg-red-700 rounded-lg font-medium transition-colors"
            >
              🗑️ Clear All Notes
            </button>
            <button
              onClick={() => window.location.reload()}
              className="px-4 py-2 bg-yellow-600 hover:bg-yellow-700 rounded-lg font-medium transition-colors"
            >
              🔄 Refresh Panel
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Controls;
