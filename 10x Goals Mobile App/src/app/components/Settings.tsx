import { useState } from 'react';
import { Button } from './ui/button';
import { Label } from './ui/label';
import { Switch } from './ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from './ui/sheet';
import { Settings as SettingsIcon, Moon, Sun, Bell, Palette } from 'lucide-react';

interface SettingsProps {
  theme: 'light' | 'dark' | 'system';
  onThemeChange: (theme: 'light' | 'dark' | 'system') => void;
  colorScheme: string;
  onColorSchemeChange: (color: string) => void;
  morningTime: string;
  onMorningTimeChange: (time: string) => void;
}

const COLOR_SCHEMES = [
  { name: 'Ocean', primary: 'blue', gradient: 'from-blue-500 to-cyan-500' },
  { name: 'Sunset', primary: 'orange', gradient: 'from-orange-500 to-pink-500' },
  { name: 'Forest', primary: 'green', gradient: 'from-green-500 to-emerald-500' },
  { name: 'Lavender', primary: 'purple', gradient: 'from-purple-500 to-violet-500' },
  { name: 'Monochrome', primary: 'neutral', gradient: 'from-neutral-700 to-neutral-900' },
];

export function Settings({
  theme,
  onThemeChange,
  colorScheme,
  onColorSchemeChange,
  morningTime,
  onMorningTimeChange,
}: SettingsProps) {
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon" className="rounded-full hover:bg-neutral-100 dark:hover:bg-neutral-800">
          <SettingsIcon className="w-5 h-5 text-neutral-600 dark:text-neutral-400" />
        </Button>
      </SheetTrigger>
      <SheetContent side="bottom" className="h-[85vh] rounded-t-2xl border-neutral-200 dark:border-neutral-800">
        <SheetHeader className="border-b border-neutral-200 dark:border-neutral-800 pb-4">
          <SheetTitle className="text-neutral-900 dark:text-neutral-100">Settings</SheetTitle>
        </SheetHeader>

        <div className="space-y-8 mt-6 overflow-y-auto max-h-[calc(85vh-100px)] pb-6">
          {/* Appearance */}
          <div className="space-y-4">
            <div className="flex items-center gap-2.5">
              <Sun className="w-4 h-4 text-neutral-500" />
              <h4 className="text-neutral-900 dark:text-neutral-100">Appearance</h4>
            </div>

            <div className="space-y-2 pl-6">
              <Label htmlFor="theme-select" className="text-sm text-neutral-600 dark:text-neutral-400">Theme</Label>
              <Select value={theme} onValueChange={onThemeChange}>
                <SelectTrigger id="theme-select" className="h-11 bg-neutral-50 dark:bg-neutral-900 border-neutral-200 dark:border-neutral-800">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="light">
                    <div className="flex items-center gap-2">
                      <Sun className="w-4 h-4" />
                      Light
                    </div>
                  </SelectItem>
                  <SelectItem value="dark">
                    <div className="flex items-center gap-2">
                      <Moon className="w-4 h-4" />
                      Dark
                    </div>
                  </SelectItem>
                  <SelectItem value="system">System</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Color Scheme */}
          <div className="space-y-4">
            <div className="flex items-center gap-2.5">
              <Palette className="w-4 h-4 text-neutral-500" />
              <h4 className="text-neutral-900 dark:text-neutral-100">Accent Color</h4>
            </div>

            <div className="grid grid-cols-5 gap-2.5 pl-6">
              {COLOR_SCHEMES.map((scheme) => (
                <button
                  key={scheme.name}
                  onClick={() => onColorSchemeChange(scheme.primary)}
                  className={`aspect-square rounded-lg bg-gradient-to-br ${scheme.gradient} transition-all ${
                    colorScheme === scheme.primary
                      ? 'ring-2 ring-offset-2 ring-neutral-900 dark:ring-neutral-100 scale-105'
                      : 'opacity-50 hover:opacity-100'
                  }`}
                  title={scheme.name}
                />
              ))}
            </div>
          </div>

          {/* Notifications */}
          <div className="space-y-4">
            <div className="flex items-center gap-2.5">
              <Bell className="w-4 h-4 text-neutral-500" />
              <h4 className="text-neutral-900 dark:text-neutral-100">Notifications</h4>
            </div>

            <div className="space-y-4 pl-6">
              <div className="flex items-center justify-between">
                <Label htmlFor="notifications" className="text-sm text-neutral-600 dark:text-neutral-400">Daily Reminders</Label>
                <Switch
                  id="notifications"
                  checked={notificationsEnabled}
                  onCheckedChange={setNotificationsEnabled}
                />
              </div>

              {notificationsEnabled && (
                <div className="space-y-2">
                  <Label htmlFor="morning-time" className="text-sm text-neutral-600 dark:text-neutral-400">Morning Reminder</Label>
                  <input
                    id="morning-time"
                    type="time"
                    value={morningTime}
                    onChange={(e) => onMorningTimeChange(e.target.value)}
                    className="w-full px-3 py-2.5 border border-neutral-300 dark:border-neutral-700 rounded-lg bg-white dark:bg-neutral-950 text-neutral-900 dark:text-neutral-100"
                  />
                  <p className="text-xs text-neutral-500">
                    Midday and evening reminders are automatic
                  </p>
                </div>
              )}
            </div>
          </div>

          {/* About */}
          <div className="space-y-1 pt-4 border-t border-neutral-200 dark:border-neutral-800">
            <p className="text-sm text-neutral-600 dark:text-neutral-400">
              10x Goals v1.0
            </p>
            <p className="text-xs text-neutral-500">
              Inspired by "10x is Easier Than 2x"
            </p>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  );
}