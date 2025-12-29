# UX Flows

## Onboarding

- Triggered if onboarding flag is false or no active goals exist.
- Two screens: Welcome → Goal setup.
- Goals are created through `TenXStore`.

## Daily setup

- If no entry for today, present setup.
- If yesterday had unfinished focuses, show Continue/Fresh prompt.
- Must create exactly 3 focuses, each linked to an active goal.

## Home

- Shows current day focuses with completion state.
- Tapping a focus toggles completion (with confirmation for un-complete).
- Context menu allows editing focus title + goal.

## Goals

- List of active goals with swipe-to-archive.
- Archived goals list supports unarchive.

## Settings

- Notification time picker + permission status.
- Appearance mode selector.
