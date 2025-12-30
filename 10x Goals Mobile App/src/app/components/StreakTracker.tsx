import { Flame } from 'lucide-react';
import { motion } from 'motion/react';

interface StreakTrackerProps {
  currentStreak: number;
  bestStreak: number;
}

export function StreakTracker({ currentStreak, bestStreak }: StreakTrackerProps) {
  return (
    <div className="bg-gradient-to-br from-orange-50 to-red-50 dark:from-orange-950/20 dark:to-red-950/20 rounded-2xl p-5 border border-orange-200/50 dark:border-orange-900/50">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm text-neutral-600 dark:text-neutral-400 mb-1">Current Streak</p>
          <div className="flex items-baseline gap-2">
            <motion.span
              key={currentStreak}
              initial={{ scale: 1.2, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              className="text-4xl tracking-tight text-neutral-900 dark:text-neutral-100"
            >
              {currentStreak}
            </motion.span>
            <span className="text-lg text-neutral-500">days</span>
          </div>
        </div>
        
        <motion.div
          animate={{
            scale: currentStreak > 0 ? [1, 1.1, 1] : 1,
          }}
          transition={{
            duration: 0.6,
            repeat: currentStreak > 0 ? Infinity : 0,
            repeatDelay: 2,
          }}
        >
          <Flame
            className={`w-14 h-14 ${
              currentStreak > 0
                ? 'text-orange-500'
                : 'text-neutral-300 dark:text-neutral-700'
            }`}
            fill={currentStreak > 0 ? 'currentColor' : 'none'}
          />
        </motion.div>
      </div>

      {bestStreak > currentStreak && (
        <div className="mt-4 pt-4 border-t border-orange-200/50 dark:border-orange-900/50">
          <p className="text-sm text-neutral-600 dark:text-neutral-400">
            Personal Best: <span className="text-neutral-900 dark:text-neutral-100">{bestStreak} days</span>
          </p>
        </div>
      )}

      <div className="mt-4 text-xs text-neutral-500">
        Complete 2+ goals daily to maintain streak
      </div>
    </div>
  );
}