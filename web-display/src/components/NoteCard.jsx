import React from 'react';

const NoteCard = ({ note, large = false }) => {
  const { iPad_input } = note;
  const { recipient, sender, drawingImage, templateTheme } = iPad_input;

  // Canvas aspect ratio is 3:4 (1200x1600)
  const scale = large ? 2 : 1;
  const canvasWidth = 300 * scale;
  const canvasHeight = 400 * scale;

  return (
    <div
      style={{ width: `${canvasWidth}px` }}
      className="bg-white rounded-2xl shadow-2xl overflow-hidden transform transition-all duration-300 hover:scale-105 hover:shadow-3xl flex flex-col"
    >
      {/* Recipient header - overlay on top of image */}
      <div className="bg-gradient-to-r from-purple-600 via-pink-600 to-blue-600 px-4 py-2 flex-shrink-0 relative z-10">
        <p className="text-white text-base font-semibold">To: {recipient}</p>
      </div>

      {/* Drawing content - exact 3:4 aspect ratio, no padding */}
      <div className="relative" style={{ width: `${canvasWidth}px`, height: `${canvasHeight}px` }}>
        <img
          src={`data:image/png;base64,${drawingImage}`}
          alt="Thank you note"
          className="w-full h-full object-cover"
        />
      </div>

      {/* Sender footer - overlay on bottom of image */}
      <div className="bg-gray-50 bg-opacity-95 px-4 py-2 border-t border-gray-200 flex-shrink-0 relative z-10">
        <p className="text-gray-600 text-sm italic">From: {sender}</p>
      </div>
    </div>
  );
};

export default NoteCard;
