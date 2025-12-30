import { Goal } from './GoalInput';
import { Check, X } from 'lucide-react';
import { motion } from 'motion/react';

interface WeeklyProgressProps {
  weekData: {
    date: string;
    goals: Goal[];
    completed: number;
    total: number;
  }[];
}

export function WeeklyProgress({ weekData }: WeeklyProgressProps) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  const getStatusColor = (completed: number, total: number) => {
    if (total === 0) return 'bg-neutral-100 dark:bg-neutral-800';
    if (completed >= 2) return 'bg-emerald-500';
    if (completed >= 1) return 'bg-amber-400';
    return 'bg-neutral-200 dark:bg-neutral-700';
  };

  const getCompletionRate = () => {
    const daysWithGoals = weekData.filter(d => d.total > 0);
    if (daysWithGoals.length === 0) return 0;
    const successfulDays = daysWithGoals.filter(d => d.completed >= 2).length;
    return Math.round((successfulDays / daysWithGoals.length) * 100);
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <h3 className="text-neutral-900 dark:text-neutral-100">This Week</h3>
        <div className="text-sm">
          <span className="text-neutral-500">Success: </span>
          <span className="text-neutral-900 dark:text-neutral-100">{getCompletionRate()}%</span>
        </div>
      </div>

      {/* Week visualization */}
      <div className="grid grid-cols-7 gap-2">
        {weekData.map((day, index) => {
          const isSuccess = day.completed >= 2 && day.total > 0;
          const isPartial = day.completed >= 1 && day.completed < 2 && day.total > 0;
          const hasGoals = day.total > 0;

          return (
            <motion.div
              key={day.date}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
              className="text-center"
            >
              <div className="text-xs text-neutral-500 mb-2">
                {days[index]}
              </div>
              <div
                className={`aspect-square rounded-xl flex items-center justify-center ${getStatusColor(
                  day.completed,
                  day.total
                )} transition-colors relative overflow-hidden`}
              >
                {hasGoals && (
                  <div className="absolute inset-0 flex items-center justify-center">
                    {isSuccess ? (
                      <Check className="w-4 h-4 text-white" strokeWidth={2.5} />
                    ) : isPartial ? (
                      <span className="text-white text-xs">
                        {day.completed}/{day.total}
                      </span>
                    ) : (
                      <X className="w-4 h-4 text-white opacity-60" strokeWidth={2.5} />
                    )}
                  </div>
                )}
              </div>
            </motion.div>
          );
        })}
      </div>

      {/* Legend */}
      <div className="flex justify-center gap-4 text-xs pt-2">
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-emerald-500"></div>
          <span className="text-neutral-600 dark:text-neutral-400">Success</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-amber-400"></div>
          <span className="text-neutral-600 dark:text-neutral-400">Partial</span>
        </div>
        <div className="flex items-center gap-1.5">
          <div className="w-2.5 h-2.5 rounded-full bg-neutral-200 dark:bg-neutral-700"></div>
          <span className="text-neutral-600 dark:text-neutral-400">Missed</span>
        </div>
      </div>
    </div>
  );
}