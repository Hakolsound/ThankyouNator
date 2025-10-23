import React from 'react';

const Stats = ({ totalSessions, pendingCount, displayedToday }) => {
  const stats = [
    {
      label: 'Total Sessions',
      value: totalSessions,
      icon: '📊',
      color: 'bg-blue-500/20 text-blue-400',
    },
    {
      label: 'Pending Review',
      value: pendingCount,
      icon: '⏳',
      color: 'bg-yellow-500/20 text-yellow-400',
    },
    {
      label: 'Displayed Today',
      value: displayedToday,
      icon: '✅',
      color: 'bg-green-500/20 text-green-400',
    },
    {
      label: 'Current Time',
      value: new Date().toLocaleTimeString(),
      icon: '🕐',
      color: 'bg-purple-500/20 text-purple-400',
    },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((stat, index) => (
        <div
          key={index}
          className={`${stat.color} rounded-xl p-6 backdrop-blur-sm`}
        >
          <div className="flex items-center justify-between mb-2">
            <span className="text-3xl">{stat.icon}</span>
            <span className="text-3xl font-bold">{stat.value}</span>
          </div>
          <p className="text-sm opacity-80">{stat.label}</p>
        </div>
      ))}
    </div>
  );
};

export default Stats;
