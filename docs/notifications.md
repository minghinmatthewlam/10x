# Notifications

## Scheduling

- Local notifications only; no remote notifications.
- Requests authorization at daily setup completion (and when toggles change).
- Morning reminder uses user-selected hour/minute.
- Midday and evening reminders are optional toggles (fixed times).
- Reminder content includes the next incomplete focus and cancels when all focuses are complete.
- Sound is disabled by spec (`content.sound = nil`).

## Settings

- Status displayed in Settings screen.
- If denied, provide “Open Settings” shortcut.
- Debug-only test notification available.
