# Feature: Health Calendars

## Overview

The health calendar is the engine behind smart reminders for each dog. It tracks all recurring and one-off health events — vaccinations, deworming, flea prevention, vet checkups, medications, and custom events — for the dog's lifetime. Events trigger escalating push notifications as due dates approach and overdue alerts if missed. Completing a recurring event automatically schedules the next occurrence. The calendar also includes weight history logging and heat cycle tracking for intact female dogs.

---

## Screens

1. **Health Calendar** — main timeline list view for the active dog
2. **Add / Edit Health Event** — form to create or modify a health event
3. **Weight Log** — log a new weight entry and view history chart

---

## Health Calendar (Main Screen)

### Purpose
Give the owner a clear picture of what's coming up, what's overdue, and what's been done for their dog's health.

### UI elements
- **Screen title**: "Health" or "[Dog name]'s Health"
- **Overdue section** (shown only when events are overdue): red-highlighted list at the top; each row shows event name, how many days overdue
- **Upcoming section**: events sorted by nearest due date first; each row shows event type icon, event name, due date (e.g. "in 3 weeks"), status chip
- **Past section**: collapsible section of completed events, sorted most recent first; collapsed by default
- **Add event button**: prominent "+" button (top right or floating action button)
- **Weight history card**: a tappable card at the top or bottom of the screen showing the most recent logged weight and a mini trend sparkline; tapping opens the Weight Log screen

### Row design (each event)
- Icon on the left (based on event type)
- Event name
- Due date (human-readable: "Tomorrow", "In 3 weeks", "12 Apr 2026")
- Status chip: **Upcoming** (grey) / **Due soon** (orange, within 7 days) / **Overdue** (red) / **Completed** (green)
- Tap row → opens Edit Health Event sheet pre-filled with this event's data + a "Mark as Complete" button

### States
- **Loading**: skeleton rows
- **Empty**: "No health events yet" illustration + "Add your first event" button
- **Populated**: overdue (if any) + upcoming + past
- **All caught up**: no overdue events, upcoming section only — show a small "All up to date ✓" banner

---

## Add / Edit Health Event

### Purpose
Create a new health event or edit an existing one. Also the screen where the owner marks an event as complete.

### Form fields

| Field | Type | Required | Notes |
|---|---|---|---|
| Event type | Picker or "Custom" | Yes | See preset types below |
| Custom name | Text | Only if type = Custom | Free text, max 100 chars |
| Due date | Date picker | Yes | Can be today or future for new events; past dates allowed when logging historical events |
| Repeat | Toggle | No | Defaults based on type (see business rules) |
| Repeat interval | Picker | Only if Repeat = on | Options depend on event type |
| Notes | Text area | No | Free text, max 500 chars |

### Preset event types
- Vaccination — DHPP
- Vaccination — Rabies
- Vaccination — Leptospirosis
- Vaccination — Bordetella (Kennel Cough)
- Vaccination — Canine Influenza
- Vaccination — Lyme Disease
- Deworming
- Flea & tick prevention
- Heartworm prevention
- Heat cycle (only shown if dog is female + not neutered)
- Annual vet checkup
- Dental cleaning
- Grooming
- Nail trim
- Medication (prompts for medication name in the custom name field)
- Custom

### "Mark as Complete" button
- Shown on the Edit sheet (not on Add, since a new event hasn't been done yet)
- On tap: event is marked completed with today's date
- If the event is recurring: the next occurrence is auto-scheduled (see Business Rules)
- A brief confirmation toast: "Marked as complete. Next [event name] scheduled for [date]."
- If the event is not recurring: event simply moves to the Past section

### States
- **Add mode**: empty form with type defaulted to first option
- **Edit mode**: form pre-filled with existing event data; "Mark as Complete" and "Delete Event" options visible
- **Saving**: save button shows spinner; form inputs disabled
- **Error**: inline errors for invalid fields; toast for network errors

### User actions
- Select event type → repeat and interval fields auto-populate with defaults for that type
- Toggle repeat on/off
- Tap Save → event written to Firestore, reminders scheduled
- Tap "Mark as Complete" (edit mode only)
- Tap "Delete Event" (edit mode only) → confirmation alert → event and all its pending reminders deleted

---

## Weight Log

### Purpose
Track the dog's weight over time to monitor health trends. The AI flags unusual gain or loss.

### UI elements
- **Current weight** displayed prominently at the top
- **Line chart**: weight over time with a shaded ideal range band for the dog's breed and sex
- **Log entry list**: recent weight entries below the chart (date + weight)
- **Log Weight button**: opens a simple form (weight input + date, defaults to today)

### Business rules
- Weight entries cannot be deleted individually (the log is permanent)
- If a new entry's weight differs from the previous by more than 20% in less than 30 days, a warning is shown: "That's a significant change — double-check the value or speak to your vet."
- The AI friend monitors the weight log and may send proactive messages about unusual trends (AI Friend feature handles this)

### States
- **Empty**: "No weight entries yet" + Log Weight button
- **Loading**: skeleton chart
- **Populated**: chart + list

---

## Heat Cycle Tracking

Heat cycle tracking is only visible and available when the active dog is **female and not neutered** (`sex = "female"` and `isNeutered = false`).

### How it works
- A "Heat cycle" event type is available in the Add Event form for eligible dogs
- Owner logs the cycle start date and end date (end date added after the cycle ends)
- The app predicts the next cycle approximately 6 months after the last cycle start date
- A predicted upcoming event is shown in the calendar as "Heat cycle (predicted)" in a different style from confirmed events
- When the cycle starts again, owner logs the actual start date, which replaces the prediction

### Symptoms tracking
- On the Heat cycle event detail: a list of trackable symptoms (restlessness, swelling, discharge, nesting behaviour, reduced appetite)
- Owner can check off symptoms during an active cycle
- Symptoms are stored as an array on the cycle event document

### Alerts
- Fertile window alert: shown in the app 9–14 days into the cycle ("Luna may be in her fertile window")
- False pregnancy warning: shown 6–8 weeks after cycle ends if no pregnancy has been logged ("Watch for signs of false pregnancy: nesting, milk production, lethargy")

---

## User Flows

### Flow 1: Add a health event
1. Owner opens Health Calendar tab
2. Taps "+" button
3. Selects event type from the picker
4. Sets the due date
5. Repeat toggle is pre-set based on event type; owner can adjust
6. Optionally adds notes
7. Taps Save → event appears in Upcoming list; reminders are scheduled

### Flow 2: Mark an event complete (recurring)
1. Owner taps a health event row
2. Edit sheet opens
3. Owner taps "Mark as Complete"
4. Event moves to Past section as completed
5. A new event of the same type is auto-created with the next due date
6. Toast confirms: "Marked as complete. Next DHPP scheduled for 1 May 2027."

### Flow 3: Mark an event complete (non-recurring)
1. Same as above but no next event is created
2. Event moves to Past; no toast about next date

### Flow 4: Edit an event
1. Owner taps an event row
2. Edit sheet opens pre-filled
3. Owner changes the date or notes
4. Taps Save → event updated; reminders rescheduled

### Flow 5: Delete an event
1. Owner taps an event row → Edit sheet
2. Taps "Delete Event"
3. Confirmation: "Delete this health event? Any scheduled reminders will be cancelled."
4. Confirms → event deleted, pending reminders cancelled

### Flow 6: Log weight
1. Owner taps the weight card on the Health Calendar screen
2. Weight Log screen opens
3. Owner taps "Log Weight"
4. Enters weight (kg) and confirms date (today by default)
5. Taps Save → entry appears in chart and list

### Flow 7: Log heat cycle
1. Owner taps "+" on Health Calendar
2. Selects "Heat cycle" (only visible for intact female dogs)
3. Sets start date
4. Saves → event created; app shows fertile window estimate in the event detail
5. When cycle ends, owner taps the event → Edit sheet → adds end date → Saves
6. Predicted next cycle event appears ~6 months later

---

## Business Rules

### Default repeat intervals by event type

| Event type | Repeat | Default interval | Owner-configurable? |
|---|---|---|---|
| Vaccination — DHPP | Yes | 12 months | No |
| Vaccination — Rabies | Yes | 12 months | Yes: 12, 24, or 36 months |
| Vaccination — Leptospirosis | Yes | 12 months | No |
| Vaccination — Bordetella | Yes | 12 months | No |
| Vaccination — Canine Influenza | Yes | 12 months | No |
| Vaccination — Lyme Disease | Yes | 12 months | No |
| Deworming | Yes | 3 months | Yes: 3, 4, or 6 months |
| Flea & tick prevention | Yes | 1 month | No |
| Heartworm prevention | Yes | 1 month | No |
| Annual vet checkup | Yes | 12 months | No |
| Dental cleaning | Yes | 6 months | Yes: 6 or 12 months |
| Grooming | Yes | Owner sets | Yes: 1–12 months |
| Nail trim | Yes | 1 month | No |
| Medication | Yes | Owner sets | Yes: 1–12 months |
| Heat cycle | No | N/A — predicted, not recurring | N/A |
| Custom | Owner's choice | Owner sets | Yes |

### Next occurrence scheduling (on mark complete)
- The next due date is calculated from the **completion date** (today), not the original due date
- Exception: if the original due date was in the future (owner marked it early), calculate from the original due date instead
- The next occurrence is created as a new Firestore document with the same type, name, interval, and notes

### Reminder scheduling (on event create or update)
When a health event is saved, three reminders are scheduled:
- **4 weeks before** due date → gentle push notification
- **1 week before** due date → standard push notification
- **1 day before** due date → urgent push notification
- **On due date + 1 day** if not completed → overdue alert push notification

If the event is updated or deleted, all pending reminders for that event are cancelled and (if updated) rescheduled.

### Overdue definition
An event is overdue if its due date has passed and `completedAt` is null.

---

## Data (Firestore)

```
users/{userId}/dogs/{dogId}/healthEvents/{eventId}
  type: string                  // preset type key or "custom"
  name: string                  // display name (auto-set for presets, user-entered for custom)
  dueDate: timestamp
  completedAt: timestamp | null
  isRecurring: boolean
  intervalMonths: number | null
  notes: string
  createdAt: timestamp

users/{userId}/dogs/{dogId}/healthReminders/{reminderId}
  eventId: string
  remindAt: timestamp
  level: "gentle" | "standard" | "urgent" | "overdue"
  sentAt: timestamp | null

users/{userId}/dogs/{dogId}/weightLogs/{logId}
  weightKg: number
  loggedAt: timestamp

users/{userId}/dogs/{dogId}/heatCycles/{cycleId}
  startDate: timestamp
  endDate: timestamp | null
  symptoms: string[]
  predictedNextStart: timestamp
```

**Reads:** Health Calendar list, Weight Log chart, AI Friend context injection, health summary shown on Dog Profile View
**Writes:** Add/Edit Event form, Mark Complete action, Weight Log form, Heat Cycle logging
**Deletes:** Delete Event (event doc + reminders), Dog deletion (all subcollections)

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Owner marks a future-dated event as complete early | Next occurrence calculated from the original due date, not today |
| Owner adds a past due date on a new event | Shown immediately as overdue; overdue reminder fires on next app open or background check |
| Owner deletes a recurring event | Only that specific occurrence is deleted; no future occurrences were pre-created (they're created on mark complete), so nothing else to delete |
| Dog becomes neutered (owner updates profile) | Heat cycle events are not deleted automatically; owner should delete them manually. Heat cycle type is no longer shown in the Add Event picker |
| Repeat interval changed on edit | Reminders rescheduled from the updated due date with the new interval; next occurrence will use the new interval |
| Owner adds a DHPP and also a custom vaccine event | Both coexist independently; no deduplication |
| Dog has no health events | Calendar shows empty state; AI friend has no health context to use |
| Weight entry is clearly wrong (e.g. 0.01 kg for a Labrador) | Warning shown but entry is still accepted — the app does not reject it |
| Network drops while marking complete | Optimistic UI: event shown as complete immediately; if sync fails, it reverts with an error toast |

---

## Out of Scope

- Sharing health records with a vet (Vet-share PDF — v2.0)
- Importing vaccination records from a photo or document (not in this version)
- Push notification delivery — handled in Notifications feature
- AI friend proactive nudges based on health events — handled in AI Friend feature
- Weight trend ideal range data — sourced from a static breed database (implementation detail for the agent building this screen)
