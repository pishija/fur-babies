# Feature: Exhibitions

## Overview

Exhibitions is a directory of professional dog shows and kennel club competitions — conformation shows, agility competitions, obedience trials, and breed speciality shows. The directory is manually curated and maintained by the FurBabies team. It lives inside the Social tab alongside Events, Matches, and Discover. Owners can browse, filter, save exhibitions to a personal watchlist, and set a reminder a chosen number of days before the event. A deep link to the official registration page is provided for each exhibition.

---

## Screens

1. **Exhibitions Feed** — scrollable list of upcoming exhibitions (within the Social tab)
2. **Exhibition Detail** — full information, save to watchlist, set reminder, and link to registration
3. **My Watchlist** — saved exhibitions for the current user

All screens live within the **Social tab**, accessible via its top segmented/tab navigation: **Discover | Matches | Events | Exhibitions**.

---

## Exhibitions Feed

### Purpose
Let owners browse upcoming dog shows and competitions relevant to their dog.

### UI elements
- **Vertical list** of exhibition cards, each showing:
  - Show name
  - Show type badge (Conformation, Agility, Obedience, Breed Speciality)
  - Date (e.g. "14–15 June 2026")
  - Location (city + country)
  - Organiser (e.g. "FCI", "AKC", national kennel club name)
  - Breed eligibility note if breed-specific (e.g. "Golden Retrievers only")
  - Bookmark icon — tap to save/unsave to watchlist without opening the detail
- **Filter bar** above the list: horizontal chip scroll — All, Conformation, Agility, Obedience, Breed Speciality, Nearby, This Month
- **Breed filter shortcut**: a chip showing the active dog's breed (e.g. "Labrador events") — filters to shows open to that breed
- **"My Watchlist" button** — top right of the screen

### States
- **Loading**: skeleton cards
- **Empty** (no exhibitions match filters): "No exhibitions found. Try adjusting your filters."
- **Populated**: list sorted by nearest date first
- **Saved**: bookmark icon filled/highlighted for saved exhibitions

---

## Exhibition Detail

### Purpose
Show the full details of an exhibition and let the owner save it or set a reminder.

### UI elements
- **Show name** (large title)
- **Show type badge**
- **Organiser**
- **Date(s)**: single day or multi-day range
- **Location**: venue name, city, country + small map snippet with "Open in Maps" button
- **Breed eligibility**: "Open to all breeds" or specific breed(s) listed
- **Description**: additional info provided by the team (e.g. registration notes, what to expect)
- **Save to Watchlist button**: filled bookmark = saved; outlined = not saved; toggle on tap
- **Set Reminder**: visible only when saved to watchlist
  - Number input: "Remind me _ days before" (default: 14)
  - Options: 7, 14, 30, 60 days (or free number entry)
- **Register / Official Page button**: opens the external registration URL in Safari (deep link to official site)

### States
- **Loading**: skeleton
- **Populated**: full detail
- **Saved**: bookmark filled; Reminder section visible
- **Past exhibition**: date label shows "This exhibition has passed"; Register button hidden; Save/Reminder still accessible (for historical reference)

---

## My Watchlist

### Purpose
Give the owner a quick view of exhibitions they've saved across all filter states.

### UI elements
- List of saved exhibitions, sorted by nearest date first
- Each row: show name, type, date, location, days until event (e.g. "in 23 days")
- Past exhibitions shown at the bottom with a "Passed" label
- Tap a row → opens Exhibition Detail
- Swipe to remove from watchlist

### States
- **Empty**: "No saved exhibitions yet. Browse the directory to save shows you're interested in."
- **Populated**: upcoming first, past at the bottom

---

## User Flows

### Flow 1: Browse and save an exhibition
1. Owner opens Social tab → taps "Exhibitions" segment
2. Feed loads with upcoming shows sorted by date
3. Owner taps the breed chip for their dog → list filters to breed-eligible shows
4. Taps an exhibition card → Exhibition Detail opens
5. Taps "Save to Watchlist" → bookmark fills
6. Sets reminder to 30 days before
7. Taps back → card in feed now shows filled bookmark

### Flow 2: Quick-save from the feed
1. Owner sees an exhibition card in the feed
2. Taps the bookmark icon directly on the card
3. Exhibition saved to watchlist; reminder defaults to 14 days before

### Flow 3: Open the registration page
1. Owner opens Exhibition Detail
2. Taps "Register / Official Page"
3. Safari opens with the official external URL

### Flow 4: View and manage watchlist
1. Owner taps "My Watchlist"
2. Sees all saved exhibitions
3. Swipes a row left → "Remove" button appears → taps Remove → exhibition removed from watchlist; reminder cancelled

### Flow 5: Change reminder days
1. Owner opens Exhibition Detail for a saved exhibition
2. Taps the current reminder setting
3. Changes from 14 to 7 days
4. Saves → reminder rescheduled

---

## Business Rules

- **Exhibition data is team-managed**: only the FurBabies team can add, edit, or remove exhibitions from the directory
- **No user submissions**: users cannot suggest exhibitions in v1 (unlike Places)
- **Watchlist is per user account** (not per dog) — a saved exhibition is saved for the owner, not tied to a specific dog
- **Reminders are per saved exhibition**: each saved exhibition can have one reminder. Setting a new day count replaces the previous reminder.
- **Reminder delivery**: a push notification is sent the chosen number of days before the event date. If the owner removes the exhibition from their watchlist, the reminder is cancelled.
- **Past exhibitions**: remain visible in the feed and detail for reference; shown after upcoming ones in the feed; reminder is cancelled automatically once the date passes
- **Breed filter**: shows exhibitions where `breedEligibility` is null (open to all) OR contains the active dog's breed string. Matching is case-insensitive.

---

## Data (Firestore)

```
exhibitions/{exhibitionId}
  title: string
  type: "conformation" | "agility" | "obedience" | "breed_speciality"
  organiser: string
  startDate: timestamp
  endDate: timestamp | null       // null for single-day events
  venueName: string
  city: string
  country: string
  lat: number
  lng: number
  breedEligibility: string[] | null   // null = open to all breeds
  description: string
  registrationUrl: string
  createdAt: timestamp

users/{userId}/watchlist/{exhibitionId}
  savedAt: timestamp
  remindDaysBefore: number         // default 14
  remindAt: timestamp              // calculated: startDate minus remindDaysBefore days
  reminderSentAt: timestamp | null
```

**Reads:** Exhibitions feed (all approved exhibitions, date-filtered, optionally breed-filtered), Exhibition Detail (exhibition doc), My Watchlist (watchlist subcollection for the user)
**Writes:** Save to watchlist (watchlist doc created + reminder scheduled), Update reminder (watchlist doc updated + reminder rescheduled), Remove from watchlist (watchlist doc deleted + reminder cancelled)
**Deletes:** Remove from watchlist, reminder cancellation on event date passing

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Exhibition has no registration URL | Register button is hidden; a note reads "Registration details TBC" |
| Exhibition spans multiple days | Date shown as a range (e.g. "14–16 June"); reminder fires based on the start date |
| Owner saves an exhibition that has already passed | Allowed — appears in watchlist under "Past"; reminder is not set |
| Owner changes their active dog while viewing Exhibitions | Breed filter chip updates to the new dog's breed; watchlist is not affected (it's per-user) |
| Team updates an exhibition's date after the owner has saved it | The watchlist reminder is not automatically rescheduled — reminder remains at the original calculated time. Owner must re-save to update. (v1 limitation) |
| No exhibitions match the breed filter | Empty state: "No upcoming shows for [breed] found. Check back later." |

---

## Out of Scope

- User-submitted exhibitions — not in v1
- Community notes from previous attendees — v2.0
- Live API integration with FCI / AKC / UKC — not in v1; team curates manually
- In-app registration form — always external (opens Safari)
- Map view of exhibition venues — not in v1 (list only)
