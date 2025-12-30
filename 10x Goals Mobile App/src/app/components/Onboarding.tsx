import { useState } from 'react';
import { Button } from './ui/button';
import { ChevronRight, Target, Zap, TrendingUp, Bell } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface OnboardingProps {
  onComplete: () => void;
}

export function Onboarding({ onComplete }: OnboardingProps) {
  const [step, setStep] = useState(0);

  const screens = [
    {
      id: 'welcome',
      title: '10x Goals',
      subtitle: 'Transform Your Potential',
      description: 'Stop settling for incremental progress. When you aim for 10x growth, you unlock a different mindset - one that is clearer, more focused, and less crowded.',
      icon: <Target className="w-16 h-16 text-neutral-900 dark:text-neutral-100" />,
    },
    {
      id: 'philosophy',
      title: '10x is Easier Than 2x',
      subtitle: 'Focus on What Truly Matters',
      description: '2x thinking keeps you competing with everyone else. 10x thinking forces you to eliminate the noise and focus only on what will exponentially transform your life.',
      icon: <Zap className="w-16 h-16 text-neutral-900 dark:text-neutral-100" />,
    },
    {
      id: 'features',
      title: 'Your Daily Practice',
      subtitle: 'Simple. Focused. Powerful.',
      description: 'Set 1-3 transformational goals each day. Complete 2 to maintain your streak. Track your progress weekly and watch your life transform.',
      icon: <TrendingUp className="w-16 h-16 text-neutral-900 dark:text-neutral-100" />,
    },
    {
      id: 'notifications',
      title: 'Stay On Track',
      subtitle: 'Daily Reminders',
      description: 'Receive gentle reminders throughout your day - morning, midday, and evening - to keep you focused on what matters most.',
      icon: <Bell className="w-16 h-16 text-neutral-900 dark:text-neutral-100" />,
    },
  ];

  const currentScreen = screens[step];

  const handleNext = () => {
    if (step < screens.length - 1) {
      setStep(step + 1);
    } else {
      onComplete();
    }
  };

  const handleSkip = () => {
    onComplete();
  };

  return (
    <div className="fixed inset-0 bg-white dark:bg-neutral-950 z-50 flex flex-col">
      {/* Skip button */}
      <div className="absolute top-6 right-6 z-10">
        <Button variant="ghost" onClick={handleSkip} className="text-neutral-500 hover:text-neutral-900 dark:hover:text-neutral-100">
          Skip
        </Button>
      </div>

      {/* Progress dots */}
      <div className="absolute top-8 left-0 right-0 flex justify-center gap-2 z-10">
        {screens.map((_, index) => (
          <div
            key={index}
            className={`h-1 rounded-full transition-all duration-300 ${
              index === step ? 'w-8 bg-neutral-900 dark:bg-neutral-100' : 'w-1 bg-neutral-300 dark:bg-neutral-700'
            }`}
          />
        ))}
      </div>

      {/* Main content */}
      <div className="flex-1 flex items-center justify-center p-8">
        <AnimatePresence mode="wait">
          <motion.div
            key={step}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
            className="max-w-md w-full text-center"
          >
            {/* Icon with subtle background */}
            <div className="mb-12 flex justify-center">
              <div className="p-6">
                {currentScreen.icon}
              </div>
            </div>

            {/* Text content */}
            <h1 className="mb-2 tracking-tight text-neutral-900 dark:text-neutral-100">
              {currentScreen.title}
            </h1>
            <h2 className="mb-6 text-neutral-500 dark:text-neutral-400">
              {currentScreen.subtitle}
            </h2>
            <p className="text-neutral-600 dark:text-neutral-400 leading-relaxed max-w-sm mx-auto">
              {currentScreen.description}
            </p>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom button */}
      <div className="p-8 pb-12">
        <Button
          onClick={handleNext}
          className="w-full h-12 bg-neutral-900 hover:bg-neutral-800 dark:bg-neutral-100 dark:hover:bg-neutral-200 text-white dark:text-neutral-900 rounded-xl transition-colors"
        >
          {step < screens.length - 1 ? (
            <>
              Continue
              <ChevronRight className="ml-2 w-5 h-5" />
            </>
          ) : (
            'Get Started'
          )}
        </Button>
      </div>
    </div>
  );
}