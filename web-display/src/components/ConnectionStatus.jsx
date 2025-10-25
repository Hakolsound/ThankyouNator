import React from 'react';

const ConnectionStatus = ({ isConnected }) => {
  return (
    <div className="fixed top-2 right-2 z-50">
      <div
        className={`w-2 h-2 rounded-full ${
          isConnected ? 'bg-green-500' : 'bg-red-500'
        } shadow-lg`}
        title={isConnected ? 'Connected' : 'Offline'}
      />
    </div>
  );
};

export default ConnectionStatus;
