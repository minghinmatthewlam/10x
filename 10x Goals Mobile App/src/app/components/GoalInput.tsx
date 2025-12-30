import { useState } from 'react';
import { Input } from './ui/input';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Plus, X, Target } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

export interface Goal {
  id: string;
  text: string;
  tag: string;
  completed: boolean;
  createdAt: string;
}

interface GoalInputProps {
  goals: Goal[];
  onAddGoal: (goal: Omit<Goal, 'id' | 'createdAt'>) => void;
  onRemoveGoal: (id: string) => void;
  onToggleGoal: (id: string) => void;
}

const TAGS = [
  { label: 'Health', color: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-400 border-emerald-200 dark:border-emerald-900' },
  { label: 'Work', color: 'bg-blue-50 text-blue-700 dark:bg-blue-950/50 dark:text-blue-400 border-blue-200 dark:border-blue-900' },
  { label: 'Relationships', color: 'bg-pink-50 text-pink-700 dark:bg-pink-950/50 dark:text-pink-400 border-pink-200 dark:border-pink-900' },
  { label: 'Learning', color: 'bg-violet-50 text-violet-700 dark:bg-violet-950/50 dark:text-violet-400 border-violet-200 dark:border-violet-900' },
  { label: 'Finance', color: 'bg-amber-50 text-amber-700 dark:bg-amber-950/50 dark:text-amber-400 border-amber-200 dark:border-amber-900' },
  { label: 'Creative', color: 'bg-orange-50 text-orange-700 dark:bg-orange-950/50 dark:text-orange-400 border-orange-200 dark:border-orange-900' },
];

export function GoalInput({ goals, onAddGoal, onRemoveGoal, onToggleGoal }: GoalInputProps) {
  const [inputValue, setInputValue] = useState('');
  const [selectedTag, setSelectedTag] = useState('Health');
  const [showTagSelector, setShowTagSelector] = useState(false);

  const canAddMore = goals.length < 3;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (inputValue.trim() && canAddMore) {
      onAddGoal({
        text: inputValue.trim(),
        tag: selectedTag,
        completed: false,
      });
      setInputValue('');
      setShowTagSelector(false);
    }
  };

  const getTagColor = (tagLabel: string) => {
    return TAGS.find(t => t.label === tagLabel)?.color || TAGS[0].color;
  };

  return (
    <div className="space-y-4">
      {/* Goal input form */}
      {canAddMore && (
        <form onSubmit={handleSubmit} className="space-y-3">
          <Input
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="What's your 10x goal today?"
            className="h-11 text-base bg-neutral-50 dark:bg-neutral-900 border-neutral-200 dark:border-neutral-800"
            onFocus={() => setShowTagSelector(true)}
          />
          
          <AnimatePresence>
            {showTagSelector && (
              <motion.div
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="space-y-3"
              >
                <p className="text-sm text-neutral-600 dark:text-neutral-400">Category</p>
                <div className="flex flex-wrap gap-2">
                  {TAGS.map((tag) => (
                    <button
                      key={tag.label}
                      type="button"
                      onClick={() => setSelectedTag(tag.label)}
                      className={`px-3 py-1.5 rounded-lg text-xs border transition-all ${
                        selectedTag === tag.label
                          ? tag.color
                          : tag.color + ' opacity-40 hover:opacity-100'
                      }`}
                    >
                      {tag.label}
                    </button>
                  ))}
                </div>
                
                <Button
                  type="submit"
                  disabled={!inputValue.trim()}
                  className="w-full h-11 bg-neutral-900 hover:bg-neutral-800 dark:bg-neutral-100 dark:hover:bg-neutral-200 text-white dark:text-neutral-900 rounded-xl"
                >
                  <Plus className="w-4 h-4 mr-2" />
                  Add Goal ({goals.length}/3)
                </Button>
              </motion.div>
            )}
          </AnimatePresence>
        </form>
      )}

      {/* Goals list */}
      <div className="space-y-3">
        <AnimatePresence>
          {goals.map((goal) => (
            <motion.div
              key={goal.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className={`p-4 rounded-xl border transition-all ${
                goal.completed
                  ? 'bg-neutral-50 dark:bg-neutral-900/50 border-neutral-200 dark:border-neutral-800'
                  : 'bg-white dark:bg-neutral-900 border-neutral-200 dark:border-neutral-800'
              }`}
            >
              <div className="flex items-start gap-3">
                <button
                  onClick={() => onToggleGoal(goal.id)}
                  className={`mt-0.5 w-5 h-5 rounded-full border-2 flex items-center justify-center transition-all ${
                    goal.completed
                      ? 'bg-neutral-900 dark:bg-neutral-100 border-neutral-900 dark:border-neutral-100'
                      : 'border-neutral-300 dark:border-neutral-700 hover:border-neutral-900 dark:hover:border-neutral-100'
                  }`}
                >
                  {goal.completed && (
                    <motion.svg
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="w-3 h-3 text-white dark:text-neutral-900"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                      strokeWidth={3}
                    >
                      <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                    </motion.svg>
                  )}
                </button>
                
                <div className="flex-1 min-w-0">
                  <p className={`text-sm ${goal.completed ? 'line-through text-neutral-400' : 'text-neutral-900 dark:text-neutral-100'}`}>
                    {goal.text}
                  </p>
                  <span className={`inline-block mt-2 px-2 py-0.5 rounded-md text-xs border ${getTagColor(goal.tag)}`}>
                    {goal.tag}
                  </span>
                </div>

                <button
                  onClick={() => onRemoveGoal(goal.id)}
                  className="text-neutral-400 hover:text-neutral-600 dark:hover:text-neutral-300 transition-colors"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
      </div>

      {goals.length === 0 && (
        <div className="text-center py-16 text-neutral-400">
          <Target className="w-10 h-10 mx-auto mb-3 opacity-20" />
          <p className="text-sm">No goals set yet</p>
        </div>
      )}

      {goals.length === 3 && (
        <p className="text-sm text-center text-neutral-500 pt-2">
          Complete at least 2 to maintain your streak
        </p>
      )}
    </div>
  );
}