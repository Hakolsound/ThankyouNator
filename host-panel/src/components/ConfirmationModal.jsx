import React, { useState } from 'react';

const ConfirmationModal = ({ isOpen, onClose, onConfirm, title, message, confirmText = 'RESET' }) => {
  const [inputValue, setInputValue] = useState('');

  if (!isOpen) return null;

  const handleConfirm = () => {
    if (inputValue === confirmText) {
      onConfirm();
      setInputValue('');
      onClose();
    }
  };

  const handleCancel = () => {
    setInputValue('');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full mx-4 overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-red-600 to-orange-600 px-6 py-4">
          <h3 className="text-xl font-bold text-white">{title}</h3>
        </div>

        {/* Content */}
        <div className="p-6 space-y-4">
          <p className="text-gray-700">{message}</p>

          <div className="space-y-2">
            <label className="block text-sm font-medium text-gray-700">
              Type <span className="font-mono bg-gray-100 px-2 py-1 rounded text-red-600">{confirmText}</span> to confirm:
            </label>
            <input
              type="text"
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              className="w-full px-4 py-3 border-2 border-gray-300 rounded-lg focus:border-red-500 focus:outline-none text-lg font-mono"
              placeholder={`Type ${confirmText}`}
              autoFocus
            />
          </div>

          {inputValue && inputValue !== confirmText && (
            <p className="text-sm text-red-600">
              ❌ Text doesn't match. Please type exactly: <span className="font-mono">{confirmText}</span>
            </p>
          )}
        </div>

        {/* Actions */}
        <div className="flex gap-3 p-6 bg-gray-50 border-t border-gray-200">
          <button
            onClick={handleCancel}
            className="flex-1 px-6 py-3 bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-lg font-medium transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleConfirm}
            disabled={inputValue !== confirmText}
            className={`flex-1 px-6 py-3 rounded-lg font-medium transition-colors ${
              inputValue === confirmText
                ? 'bg-red-600 hover:bg-red-700 text-white'
                : 'bg-gray-300 text-gray-500 cursor-not-allowed'
            }`}
          >
            Confirm Reset
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmationModal;
