import React from 'react';

const Stats = ({ totalSessions, displayedToday }) => {
  const stats = [
    {
      label: 'Total Sessions',
      value: totalSessions,
      icon: '📊',
      gradient: 'from-blue-500 to-cyan-500',
      border: 'border-blue-500/30',
    },
    {
      label: 'Displayed Today',
      value: displayedToday,
      icon: '✅',
      gradient: 'from-green-500 to-emerald-500',
      border: 'border-green-500/30',
    },
    {
      label: 'Current Time',
      value: new Date().toLocaleTimeString(),
      icon: '🕐',
      gradient: 'from-purple-500 to-pink-500',
      border: 'border-purple-500/30',
    },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      {stats.map((stat, index) => (
        <div
          key={index}
          className={`bg-gradient-to-br from-slate-800 to-slate-700 rounded-xl p-6 shadow-2xl border ${stat.border}`}
        >
          <div className="flex items-center justify-between mb-3">
            <span className="text-4xl">{stat.icon}</span>
            <span className={`text-4xl font-bold bg-gradient-to-r ${stat.gradient} bg-clip-text text-transparent`}>
              {stat.value}
            </span>
          </div>
          <p className="text-sm font-medium text-gray-300">{stat.label}</p>
        </div>
      ))}
    </div>
  );
};

export default Stats;
