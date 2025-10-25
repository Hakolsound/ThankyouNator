import React, { useState } from 'react';

const Controls = ({ settings, updateSettings, onClearAll, onResetSlideshow }) => {
  const [activeTab, setActiveTab] = useState('display');

  const updateBranding = (brandingUpdate) => {
    updateSettings({
      branding: {
        ...settings.branding,
        ...brandingUpdate
      }
    });
  };

  const headerPaddingValues = {
    compact: { py: '0.5rem', label: 'Compact' },
    normal: { py: '0.75rem', label: 'Normal' },
    spacious: { py: '1.5rem', label: 'Spacious' }
  };

  const fontOptions = [
    { value: 'system-ui', label: 'System' },
    { value: 'Arial', label: 'Arial' },
    { value: 'Helvetica', label: 'Helvetica' },
    { value: 'Georgia', label: 'Georgia' },
    { value: 'Times New Roman', label: 'Times' },
    { value: 'Courier New', label: 'Courier' },
    { value: 'Verdana', label: 'Verdana' },
    { value: 'Impact', label: 'Impact' },
    { value: 'Comic Sans MS', label: 'Comic Sans' },
  ];

  return (
    <div className="bg-gradient-to-br from-slate-800 to-slate-700 rounded-xl p-6 shadow-2xl border border-purple-500/30">
      <h2 className="text-2xl font-bold mb-6 text-white flex items-center gap-2">
        <span>⚙️</span> Display Settings
      </h2>

      {/* Tab Navigation */}
      <div className="flex gap-2 mb-6 bg-slate-900/50 p-1 rounded-lg">
        <button
          onClick={() => setActiveTab('display')}
          className={`flex-1 px-4 py-2 rounded-md font-medium transition-all ${
            activeTab === 'display'
              ? 'bg-gradient-to-r from-indigo-500 to-purple-600 text-white'
              : 'text-gray-400 hover:text-white'
          }`}
        >
          Display
        </button>
        <button
          onClick={() => setActiveTab('branding')}
          className={`flex-1 px-4 py-2 rounded-md font-medium transition-all ${
            activeTab === 'branding'
              ? 'bg-gradient-to-r from-indigo-500 to-purple-600 text-white'
              : 'text-gray-400 hover:text-white'
          }`}
        >
          Branding
        </button>
      </div>

      <div className="space-y-6">
        {activeTab === 'display' && (
          <>
            {/* Display Mode */}
            <div>
              <label className="block text-sm font-semibold mb-3 text-gray-300">Display Mode</label>
              <div className="grid grid-cols-1 gap-3">
                <button
                  onClick={() => updateSettings({ displayMode: 'landscape' })}
                  className={`px-6 py-4 rounded-lg font-medium transition-all shadow-md ${
                    settings.displayMode === 'landscape'
                      ? 'bg-gradient-to-r from-indigo-500 to-purple-600 text-white border-2 border-purple-400'
                      : 'bg-slate-700 text-gray-300 hover:bg-slate-600 border-2 border-slate-600'
                  }`}
                >
                  <div className="flex items-center justify-center gap-2">
                    <span className="text-2xl">🖼️</span>
                    <span>Landscape (Sticky Notes)</span>
                  </div>
                </button>
                <button
                  onClick={() => updateSettings({ displayMode: 'portrait' })}
                  className={`px-6 py-4 rounded-lg font-medium transition-all shadow-md ${
                    settings.displayMode === 'portrait'
                      ? 'bg-gradient-to-r from-indigo-500 to-purple-600 text-white border-2 border-purple-400'
                      : 'bg-slate-700 text-gray-300 hover:bg-slate-600 border-2 border-slate-600'
                  }`}
                >
                  <div className="flex items-center justify-center gap-2">
                    <span className="text-2xl">📱</span>
                    <span>Portrait (Full Screen)</span>
                  </div>
                </button>
              </div>
            </div>

            {/* Display Duration */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <label className="block text-sm font-semibold text-gray-300">
                  Display Duration
                </label>
                <span className="text-3xl font-bold bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">
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
                className="w-full h-3 bg-slate-600 rounded-lg appearance-none cursor-pointer"
                style={{
                  background: `linear-gradient(to right, rgb(99 102 241) 0%, rgb(168 85 247) ${((settings.displayDuration - 5) / 25) * 100}%, rgb(71 85 105) ${((settings.displayDuration - 5) / 25) * 100}%, rgb(71 85 105) 100%)`
                }}
              />
              <div className="flex justify-between text-xs text-gray-400 mt-2">
                <span className="font-medium">5s</span>
                <span className="font-medium">30s</span>
              </div>
            </div>

            {/* Scroll Speed (Portrait Mode) */}
            <div>
              <label className="block text-sm font-semibold mb-3 text-gray-300">
                Scroll Speed (Portrait)
              </label>
              <div className="grid grid-cols-3 gap-3">
                {['slow', 'medium', 'fast'].map((speed) => (
                  <button
                    key={speed}
                    onClick={() => updateSettings({ scrollSpeed: speed })}
                    className={`px-4 py-3 rounded-lg font-medium capitalize transition-all shadow-md ${
                      settings.scrollSpeed === speed
                        ? 'bg-gradient-to-r from-indigo-500 to-purple-600 text-white border-2 border-purple-400'
                        : 'bg-slate-700 text-gray-300 hover:bg-slate-600 border-2 border-slate-600'
                    }`}
                  >
                    {speed}
                  </button>
                ))}
              </div>
            </div>

            {/* Zoom Duration (Portrait Mode) */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <label className="block text-sm font-semibold text-gray-300">
                  Zoom Duration (Portrait)
                </label>
                <span className="text-3xl font-bold bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">
                  {settings.zoomDuration}s
                </span>
              </div>
              <input
                type="range"
                min="5"
                max="20"
                step="1"
                value={settings.zoomDuration}
                onChange={(e) =>
                  updateSettings({ zoomDuration: parseInt(e.target.value) })
                }
                className="w-full h-3 bg-slate-600 rounded-lg appearance-none cursor-pointer"
                style={{
                  background: `linear-gradient(to right, rgb(99 102 241) 0%, rgb(168 85 247) ${((settings.zoomDuration - 5) / 15) * 100}%, rgb(71 85 105) ${((settings.zoomDuration - 5) / 15) * 100}%, rgb(71 85 105) 100%)`
                }}
              />
              <div className="flex justify-between text-xs text-gray-400 mt-2">
                <span className="font-medium">5s</span>
                <span className="font-medium">20s</span>
              </div>
            </div>

            {/* Cards Per Row (Portrait Mode) */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <label className="block text-sm font-semibold text-gray-300">
                  Cards Per Row (Portrait)
                </label>
                <span className="text-3xl font-bold bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">
                  {settings.cardsPerRow}
                </span>
              </div>
              <input
                type="range"
                min="2"
                max="4"
                step="1"
                value={settings.cardsPerRow}
                onChange={(e) =>
                  updateSettings({ cardsPerRow: parseInt(e.target.value) })
                }
                className="w-full h-3 bg-slate-600 rounded-lg appearance-none cursor-pointer"
                style={{
                  background: `linear-gradient(to right, rgb(99 102 241) 0%, rgb(168 85 247) ${((settings.cardsPerRow - 2) / 2) * 100}%, rgb(71 85 105) ${((settings.cardsPerRow - 2) / 2) * 100}%, rgb(71 85 105) 100%)`
                }}
              />
              <div className="flex justify-between text-xs text-gray-400 mt-2">
                <span className="font-medium">2</span>
                <span className="font-medium">4</span>
              </div>
            </div>

            {/* Focus Frequency (Portrait Mode) */}
            <div>
              <label className="block text-sm font-semibold mb-3 text-gray-300">
                Focus Frequency (Portrait)
              </label>
              <div className="grid grid-cols-4 gap-2">
                {['never', 'rare', 'normal', 'frequent'].map((freq) => (
                  <button
                    key={freq}
                    onClick={() => updateSettings({ focusFrequency: freq })}
                    className={`px-3 py-2 rounded-lg font-medium capitalize transition-all shadow-md text-xs ${
                      settings.focusFrequency === freq
                        ? 'bg-gradient-to-r from-indigo-500 to-purple-600 text-white border-2 border-purple-400'
                        : 'bg-slate-700 text-gray-300 hover:bg-slate-600 border-2 border-slate-600'
                    }`}
                  >
                    {freq}
                  </button>
                ))}
              </div>
            </div>

            {/* Quick Actions */}
            <div className="pt-4 border-t border-slate-600">
              <label className="block text-sm font-semibold mb-3 text-gray-300">
                Quick Actions
              </label>
              <div className="space-y-3">
                <button
                  onClick={onResetSlideshow}
                  className="w-full px-6 py-3 bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 rounded-lg font-medium transition-all shadow-lg text-white border-2 border-blue-400"
                >
                  <div className="flex items-center justify-center gap-2">
                    <span className="text-xl">🔄</span>
                    <span>Reset Slideshow</span>
                  </div>
                </button>
                <button
                  onClick={() => window.location.reload()}
                  className="w-full px-6 py-3 bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 rounded-lg font-medium transition-all shadow-lg text-white border-2 border-yellow-400"
                >
                  <div className="flex items-center justify-center gap-2">
                    <span className="text-xl">🔄</span>
                    <span>Refresh Panel</span>
                  </div>
                </button>
                <button
                  onClick={() => {
                    if (confirm('⚠️ This will permanently delete ALL notes from Firebase.\n\nAre you sure you want to continue?')) {
                      onClearAll();
                    }
                  }}
                  className="w-full px-6 py-3 bg-gradient-to-r from-red-500 to-pink-500 hover:from-red-600 hover:to-pink-600 rounded-lg font-medium transition-all shadow-lg text-white border-2 border-red-400"
                >
                  <div className="flex items-center justify-center gap-2">
                    <span className="text-xl">🗑️</span>
                    <span>Clear All Notes</span>
                  </div>
                </button>
              </div>
            </div>
          </>
        )}

        {activeTab === 'branding' && (
          <>
            {/* Background Type */}
            <div>
              <label className="block text-sm font-semibold mb-3 text-gray-300">Background Type</label>
              <div className="grid grid-cols-3 gap-3">
                {['solid', 'gradient', 'image'].map((type) => (
                  <button
                    key={type}
                    onClick={() => updateBranding({ backgroundType: type })}
                    className={`px-4 py-3 rounded-lg font-medium capitalize transition-all shadow-md ${
                      settings.branding?.backgroundType === type
                        ? 'bg-gradient-to-r from-indigo-500 to-purple-600 text-white border-2 border-purple-400'
                        : 'bg-slate-700 text-gray-300 hover:bg-slate-600 border-2 border-slate-600'
                    }`}
                  >
                    {type}
                  </button>
                ))}
              </div>
            </div>

            {/* Background Color (Solid) */}
            {settings.branding?.backgroundType === 'solid' && (
              <div>
                <label className="block text-sm font-semibold mb-3 text-gray-300">Background Color</label>
                <div className="flex gap-3">
                  <input
                    type="color"
                    value={settings.branding?.backgroundColor || '#f0f0f0'}
                    onChange={(e) => updateBranding({ backgroundColor: e.target.value })}
                    className="h-12 w-20 rounded-lg cursor-pointer border-2 border-slate-600"
                  />
                  <input
                    type="text"
                    value={settings.branding?.backgroundColor || '#f0f0f0'}
                    onChange={(e) => updateBranding({ backgroundColor: e.target.value })}
                    className="flex-1 px-4 py-2 bg-slate-700 text-white rounded-lg border-2 border-slate-600 font-mono"
                  />
                </div>
              </div>
            )}

            {/* Background Gradient */}
            {settings.branding?.backgroundType === 'gradient' && (
              <>
                <div>
                  <label className="block text-sm font-semibold mb-3 text-gray-300">Gradient Start</label>
                  <div className="flex gap-3">
                    <input
                      type="color"
                      value={settings.branding?.gradientStart || '#faf5ff'}
                      onChange={(e) => updateBranding({ gradientStart: e.target.value })}
                      className="h-12 w-20 rounded-lg cursor-pointer border-2 border-slate-600"
                    />
                    <input
                      type="text"
                      value={settings.branding?.gradientStart || '#faf5ff'}
                      onChange={(e) => updateBranding({ gradientStart: e.target.value })}
                      className="flex-1 px-4 py-2 bg-slate-700 text-white rounded-lg border-2 border-slate-600 font-mono"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-semibold mb-3 text-gray-300">Gradient End</label>
                  <div className="flex gap-3">
                    <input
                      type="color"
                      value={settings.branding?.gradientEnd || '#fce7f3'}
                      onChange={(e) => updateBranding({ gradientEnd: e.target.value })}
                      className="h-12 w-20 rounded-lg cursor-pointer border-2 border-slate-600"
                    />
                    <input
                      type="text"
                      value={settings.branding?.gradientEnd || '#fce7f3'}
                      onChange={(e) => updateBranding({ gradientEnd: e.target.value })}
                      className="flex-1 px-4 py-2 bg-slate-700 text-white rounded-lg border-2 border-slate-600 font-mono"
                    />
                  </div>
                </div>
                {/* Preview */}
                <div>
                  <label className="block text-sm font-semibold mb-3 text-gray-300">Preview</label>
                  <div
                    className="h-20 rounded-lg border-2 border-slate-600"
                    style={{
                      background: `linear-gradient(to br, ${settings.branding?.gradientStart || '#faf5ff'}, ${settings.branding?.gradientEnd || '#fce7f3'})`
                    }}
                  />
                </div>
              </>
            )}

            {/* Background Image URL */}
            {settings.branding?.backgroundType === 'image' && (
              <div>
                <label className="block text-sm font-semibold mb-3 text-gray-300">Background Image URL</label>
                <input
                  type="text"
                  value={settings.branding?.backgroundImage || ''}
                  onChange={(e) => updateBranding({ backgroundImage: e.target.value })}
                  placeholder="https://example.com/image.jpg"
                  className="w-full px-4 py-2 bg-slate-700 text-white rounded-lg border-2 border-slate-600"
                />
              </div>
            )}

            {/* Header Color Gradient */}
            <div className="pt-4 border-t border-slate-600">
              <label className="block text-sm font-semibold mb-3 text-gray-300">Header Gradient</label>
              <div className="space-y-3">
                <div>
                  <label className="block text-xs font-medium mb-2 text-gray-400">Start Color</label>
                  <div className="flex gap-3">
                    <input
                      type="color"
                      value={settings.branding?.headerColorStart || '#a855f7'}
                      onChange={(e) => updateBranding({ headerColorStart: e.target.value })}
                      className="h-12 w-20 rounded-lg cursor-pointer border-2 border-slate-600"
                    />
                    <input
                      type="text"
                      value={settings.branding?.headerColorStart || '#a855f7'}
                      onChange={(e) => updateBranding({ headerColorStart: e.target.value })}
                      className="flex-1 px-4 py-2 bg-slate-700 text-white rounded-lg border-2 border-slate-600 font-mono"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-medium mb-2 text-gray-400">End Color</label>
                  <div className="flex gap-3">
                    <input
                      type="color"
                      value={settings.branding?.headerColorEnd || '#ec4899'}
                      onChange={(e) => updateBranding({ headerColorEnd: e.target.value })}
                      className="h-12 w-20 rounded-lg cursor-pointer border-2 border-slate-600"
                    />
                    <input
                      type="text"
                      value={settings.branding?.headerColorEnd || '#ec4899'}
                      onChange={(e) => updateBranding({ headerColorEnd: e.target.value })}
                      className="flex-1 px-4 py-2 bg-slate-700 text-white rounded-lg border-2 border-slate-600 font-mono"
                    />
                  </div>
                </div>
                {/* Preview */}
                <div>
                  <label className="block text-xs font-medium mb-2 text-gray-400">Preview</label>
                  <div
                    className="h-16 rounded-lg border-2 border-slate-600 flex items-center justify-center"
                    style={{
                      background: `linear-gradient(to right, ${settings.branding?.headerColorStart || '#a855f7'}, ${settings.branding?.headerColorEnd || '#ec4899'})`
                    }}
                  >
                    <span className="text-white font-bold text-lg">Sample Header</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Header Font */}
            <div>
              <label className="block text-sm font-semibold mb-3 text-gray-300">Header Font</label>
              <select
                value={settings.branding?.headerFont || 'system-ui'}
                onChange={(e) => updateBranding({ headerFont: e.target.value })}
                className="w-full px-4 py-3 bg-slate-700 text-white rounded-lg border-2 border-slate-600 font-medium cursor-pointer"
              >
                {fontOptions.map((font) => (
                  <option key={font.value} value={font.value} style={{ fontFamily: font.value }}>
                    {font.label}
                  </option>
                ))}
              </select>
            </div>

            {/* Header Padding */}
            <div>
              <label className="block text-sm font-semibold mb-3 text-gray-300">Header Padding</label>
              <div className="grid grid-cols-3 gap-3">
                {Object.entries(headerPaddingValues).map(([key, { label }]) => (
                  <button
                    key={key}
                    onClick={() => updateBranding({ headerPadding: key })}
                    className={`px-4 py-3 rounded-lg font-medium transition-all shadow-md ${
                      settings.branding?.headerPadding === key
                        ? 'bg-gradient-to-r from-indigo-500 to-purple-600 text-white border-2 border-purple-400'
                        : 'bg-slate-700 text-gray-300 hover:bg-slate-600 border-2 border-slate-600'
                    }`}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default Controls;
