import React from 'react';

const IdleScreen = () => {
  return (
    <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-amber-50 via-rose-50 to-orange-50 relative overflow-hidden">
      {/* Soft background decorations */}
      <div className="absolute inset-0 opacity-20">
        {/* Floating hearts */}
        {[...Array(8)].map((_, i) => (
          <div
            key={i}
            className="absolute text-rose-400 animate-float"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              fontSize: `${Math.random() * 30 + 20}px`,
              animationDelay: `${i * 0.5}s`,
              animationDuration: `${3 + Math.random() * 2}s`,
            }}
          >
            ❤️
          </div>
        ))}
      </div>

      <div className="text-center space-y-12 animate-fade-in px-12 max-w-4xl relative z-10">
        {/* Warm, inviting icon */}
        <div className="flex justify-center">
          <div className="relative">
            <div className="w-40 h-40 bg-gradient-to-br from-rose-400 to-orange-400 rounded-full flex items-center justify-center animate-float shadow-2xl">
              <span className="text-7xl">✍️</span>
            </div>
            {/* Sparkle effects */}
            <div className="absolute -top-4 -right-4 text-4xl animate-pulse">✨</div>
            <div className="absolute -bottom-2 -left-4 text-3xl animate-pulse" style={{ animationDelay: '0.5s' }}>💫</div>
          </div>
        </div>

        {/* Personal, warm messaging */}
        <div className="space-y-6">
          <h1 className="text-7xl font-bold bg-gradient-to-r from-rose-600 via-orange-500 to-amber-500 bg-clip-text text-transparent leading-tight">
            Share Your Gratitude
          </h1>

          <div className="space-y-4">
            <p className="text-3xl text-gray-700 font-medium leading-relaxed">
              Got someone to thank? ❤️
            </p>
            <p className="text-2xl text-gray-600 leading-relaxed max-w-2xl mx-auto">
              Grab an iPad nearby and create a beautiful handwritten note.
              Your message will appear right here for everyone to see!
            </p>
          </div>
        </div>

        {/* Call to action with hand-drawn style */}
        <div className="inline-block">
          <div className="bg-white/80 backdrop-blur-sm rounded-3xl px-12 py-6 shadow-xl border-4 border-dashed border-rose-300">
            <p className="text-3xl font-bold text-rose-600 mb-2">
              👉 Look for the iPads 👈
            </p>
            <p className="text-xl text-gray-600">
              Write your thank you note with Apple Pencil
            </p>
          </div>
        </div>

        {/* Friendly animated dots */}
        <div className="flex justify-center gap-3 mt-8">
          {[...Array(5)].map((_, i) => (
            <div
              key={i}
              className="w-4 h-4 rounded-full bg-gradient-to-r from-rose-400 to-orange-400 animate-pulse"
              style={{
                animationDelay: `${i * 0.15}s`,
              }}
            />
          ))}
        </div>
      </div>
    </div>
  );
};

export default IdleScreen;
