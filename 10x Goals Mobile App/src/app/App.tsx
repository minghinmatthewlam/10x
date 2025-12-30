import { useState, useEffect } from 'react';
import { Onboarding } from './components/Onboarding';
import { GoalInput, Goal } from './components/GoalInput';
import { StreakTracker } from './components/StreakTracker';
import { WeeklyProgress } from './components/WeeklyProgress';
import { Settings } from './components/Settings';
import { Calendar } from 'lucide-react';
import { format, startOfWeek, addDays, isSameDay, parseISO } from 'date-fns';

interface DayData {
  date: string;
  goals: Goal[];
}

function App() {
  const [showOnboarding, setShowOnboarding] = useState(true);
  const [goals, setGoals] = useState<Goal[]>([]);
  const [streak, setStreak] = useState(0);
  const [bestStreak, setBestStreak] = useState(0);
  const [theme, setTheme] = useState<'light' | 'dark' | 'system'>('system');
  const [colorScheme, setColorScheme] = useState('blue');
  const [morningTime, setMorningTime] = useState('07:00');
  const [historicalData, setHistoricalData] = useState<DayData[]>([]);

  // Load data from localStorage on mount
  useEffect(() => {
    const hasCompletedOnboarding = localStorage.getItem('hasCompletedOnboarding');
    if (hasCompletedOnboarding === 'true') {
      setShowOnboarding(false);
    }

    const savedGoals = localStorage.getItem('todayGoals');
    const savedDate = localStorage.getItem('todayGoalsDate');
    const today = format(new Date(), 'yyyy-MM-dd');

    // Reset goals if it's a new day
    if (savedDate === today && savedGoals) {
      setGoals(JSON.parse(savedGoals));
    } else {
      // Save yesterday's goals to history before resetting
      if (savedDate && savedGoals) {
        saveToHistory(savedDate, JSON.parse(savedGoals));
      }
      setGoals([]);
      localStorage.setItem('todayGoalsDate', today);
    }

    const savedStreak = localStorage.getItem('streak');
    if (savedStreak) setStreak(parseInt(savedStreak));

    const savedBestStreak = localStorage.getItem('bestStreak');
    if (savedBestStreak) setBestStreak(parseInt(savedBestStreak));

    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) setTheme(savedTheme as 'light' | 'dark' | 'system');

    const savedColorScheme = localStorage.getItem('colorScheme');
    if (savedColorScheme) setColorScheme(savedColorScheme);

    const savedMorningTime = localStorage.getItem('morningTime');
    if (savedMorningTime) setMorningTime(savedMorningTime);

    const savedHistory = localStorage.getItem('historicalData');
    if (savedHistory) setHistoricalData(JSON.parse(savedHistory));
  }, []);

  // Apply theme
  useEffect(() => {
    const root = document.documentElement;
    if (theme === 'dark') {
      root.classList.add('dark');
    } else if (theme === 'light') {
      root.classList.remove('dark');
    } else {
      // System preference
      if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        root.classList.add('dark');
      } else {
        root.classList.remove('dark');
      }
    }
  }, [theme]);

  // Save goals to localStorage whenever they change
  useEffect(() => {
    if (!showOnboarding) {
      localStorage.setItem('todayGoals', JSON.stringify(goals));
      updateStreak();
    }
  }, [goals, showOnboarding]);

  const saveToHistory = (date: string, goalsData: Goal[]) => {
    const newHistoricalData = [...historicalData];
    const existingIndex = newHistoricalData.findIndex(d => d.date === date);
    
    if (existingIndex >= 0) {
      newHistoricalData[existingIndex] = { date, goals: goalsData };
    } else {
      newHistoricalData.push({ date, goals: goalsData });
    }
    
    setHistoricalData(newHistoricalData);
    localStorage.setItem('historicalData', JSON.stringify(newHistoricalData));
  };

  const updateStreak = () => {
    const completedGoals = goals.filter(g => g.completed).length;
    
    // Only update streak at end of day or when goals are completed
    if (completedGoals >= 2) {
      const today = format(new Date(), 'yyyy-MM-dd');
      const lastStreakDate = localStorage.getItem('lastStreakDate');
      
      if (lastStreakDate !== today) {
        const newStreak = streak + 1;
        setStreak(newStreak);
        localStorage.setItem('streak', newStreak.toString());
        localStorage.setItem('lastStreakDate', today);
        
        if (newStreak > bestStreak) {
          setBestStreak(newStreak);
          localStorage.setItem('bestStreak', newStreak.toString());
        }
      }
    }
  };

  const handleCompleteOnboarding = () => {
    setShowOnboarding(false);
    localStorage.setItem('hasCompletedOnboarding', 'true');
  };

  const handleAddGoal = (goal: Omit<Goal, 'id' | 'createdAt'>) => {
    const newGoal: Goal = {
      ...goal,
      id: Date.now().toString(),
      createdAt: new Date().toISOString(),
    };
    setGoals([...goals, newGoal]);
  };

  const handleRemoveGoal = (id: string) => {
    setGoals(goals.filter(g => g.id !== id));
  };

  const handleToggleGoal = (id: string) => {
    setGoals(
      goals.map(g => (g.id === id ? { ...g, completed: !g.completed } : g))
    );
  };

  // Generate weekly progress data
  const getWeeklyProgressData = () => {
    const today = new Date();
    const weekStart = startOfWeek(today, { weekStartsOn: 1 }); // Start on Monday
    
    return Array.from({ length: 7 }).map((_, index) => {
      const date = addDays(weekStart, index);
      const dateStr = format(date, 'yyyy-MM-dd');
      
      // Check if it's today
      if (isSameDay(date, today)) {
        return {
          date: dateStr,
          goals: goals,
          completed: goals.filter(g => g.completed).length,
          total: goals.length,
        };
      }
      
      // Check historical data
      const historicalDay = historicalData.find(d => d.date === dateStr);
      if (historicalDay) {
        return {
          date: dateStr,
          goals: historicalDay.goals,
          completed: historicalDay.goals.filter(g => g.completed).length,
          total: historicalDay.goals.length,
        };
      }
      
      // Future or no data
      return {
        date: dateStr,
        goals: [],
        completed: 0,
        total: 0,
      };
    });
  };

  if (showOnboarding) {
    return <Onboarding onComplete={handleCompleteOnboarding} />;
  }

  const completedCount = goals.filter(g => g.completed).length;
  const today = format(new Date(), 'EEEE, MMMM d');

  return (
    <div className="min-h-screen bg-neutral-50 dark:bg-neutral-950 pb-20">
      {/* Header */}
      <div className="bg-white/80 dark:bg-neutral-900/80 backdrop-blur-xl border-b border-neutral-200/50 dark:border-neutral-800/50 sticky top-0 z-10">
        <div className="max-w-md mx-auto px-5 py-5 flex items-center justify-between">
          <div>
            <h1 className="text-xl tracking-tight">10x Goals</h1>
            <p className="text-sm text-neutral-500 dark:text-neutral-400 mt-0.5">{today}</p>
          </div>
          <Settings
            theme={theme}
            onThemeChange={(t) => {
              setTheme(t);
              localStorage.setItem('theme', t);
            }}
            colorScheme={colorScheme}
            onColorSchemeChange={(c) => {
              setColorScheme(c);
              localStorage.setItem('colorScheme', c);
            }}
            morningTime={morningTime}
            onMorningTimeChange={(t) => {
              setMorningTime(t);
              localStorage.setItem('morningTime', t);
            }}
          />
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-md mx-auto px-5 py-8 space-y-5">
        {/* Streak Tracker */}
        <StreakTracker currentStreak={streak} bestStreak={bestStreak} />

        {/* Progress Summary */}
        {goals.length > 0 && (
          <div className="bg-white dark:bg-neutral-900 rounded-2xl p-5 shadow-sm border border-neutral-200/50 dark:border-neutral-800/50">
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-neutral-900 dark:text-neutral-100">Today's Progress</h3>
              <span className="text-sm text-neutral-500">
                {completedCount}/{goals.length}
              </span>
            </div>
            <div className="w-full bg-neutral-100 dark:bg-neutral-800 rounded-full h-2 overflow-hidden">
              <div
                className="bg-neutral-900 dark:bg-neutral-100 h-full transition-all duration-700 ease-out"
                style={{ width: `${(completedCount / goals.length) * 100}%` }}
              />
            </div>
            {completedCount >= 2 ? (
              <p className="text-sm text-neutral-600 dark:text-neutral-400 mt-3">
                ✓ Streak active
              </p>
            ) : (
              <p className="text-sm text-neutral-500 mt-3">
                {2 - completedCount} more needed for streak
              </p>
            )}
          </div>
        )}

        {/* Goal Input */}
        <div className="bg-white dark:bg-neutral-900 rounded-2xl p-5 shadow-sm border border-neutral-200/50 dark:border-neutral-800/50">
          <div className="flex items-center gap-2 mb-5">
            <Calendar className="w-5 h-5 text-neutral-400" />
            <h2 className="text-neutral-900 dark:text-neutral-100">Today's Goals</h2>
          </div>
          <GoalInput
            goals={goals}
            onAddGoal={handleAddGoal}
            onRemoveGoal={handleRemoveGoal}
            onToggleGoal={handleToggleGoal}
          />
        </div>

        {/* Weekly Progress */}
        <div className="bg-white dark:bg-neutral-900 rounded-2xl p-5 shadow-sm border border-neutral-200/50 dark:border-neutral-800/50">
          <WeeklyProgress weekData={getWeeklyProgressData()} />
        </div>

        {/* Motivational Quote */}
        <div className="bg-neutral-100 dark:bg-neutral-900 rounded-2xl p-6 border border-neutral-200/50 dark:border-neutral-800/50 text-center">
          <p className="text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed">
            "10x is easier than 2x because it forces you to focus only on what truly matters."
          </p>
          <p className="text-xs text-neutral-500 mt-3">— Dan Sullivan</p>
        </div>
      </div>
    </div>
  );
}

export default App;