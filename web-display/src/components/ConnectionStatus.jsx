import React from 'react';

const ConnectionStatus = ({ isConnected }) => {
  return (
    <div className="fixed top-6 right-6 z-50">
      <div
        className={`w-3 h-3 rounded-full ${
          isConnected ? 'bg-green-500' : 'bg-red-500'
        } shadow-lg`}
        title={isConnected ? 'Connected' : 'Offline'}
      />
    </div>
  );
};

export default ConnectionStatus;
