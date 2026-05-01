# Feature: Me / Owner Account

## Overview

The Me tab is the owner's personal space — separate from their dogs' profiles. It shows the owner's profile (name, city, photo), notification preferences, and app settings. It also houses sign out and account deletion. The owner's profile photo and name appear alongside their dog in conversations and events, giving other owners a sense of who they're talking to. There is no subscription or premium tier in v1 — everything is free.

---

## Screens

1. **Me (main screen)** — profile summary + settings sections
2. **Edit Profile** — edit name, city, and profile photo
3. **Notification Settings** — control which push notifications are received
4. **App Settings** — units, appearance

---

## Me (Main Screen)

### Purpose
Single-screen hub for the owner's account. All sections accessible from here.

### UI elements

**Profile header**
- Owner's profile photo (circular, large) — tap to open Edit Profile
- Owner's first name
- City
- "Edit Profile" link / button

**Sections (grouped list)**

1. **Preferences**
   - Notification Settings → navigates to Notification Settings screen
   - App Settings → navigates to App Settings screen

2. **Account**
   - Sign Out → confirmation alert → signs out
   - Delete Account → navigates to account deletion confirmation flow

**App version** shown at the very bottom in small grey text (e.g. "FurBabies v1.0.0")

### States
- **Loading**: skeleton for profile header while owner doc loads from Firestore
- **Populated**: full screen as described
- **No profile photo set**: placeholder avatar with a camera icon overlay prompting the owner to add one

---

## Edit Profile

### Purpose
Let the owner update their display name, city, and profile photo.

### UI elements
- **Profile photo** at the top — large circular; tap to open system image picker (camera or library); shows current photo or placeholder
- **First name field** — required, max 50 characters
- **City field** — optional, max 100 characters, free text
- **Save button** — disabled until at least the name field is non-empty
- **Remove photo option** — shown only when a photo exists; removes the profile photo (reverts to placeholder)

### Business rules
- Profile photo is stored in Firebase Storage at `users/{userId}/profile.jpg`; the download URL is stored on the user Firestore doc
- Photo is compressed before upload (max 1 MB)
- Name and city changes are written to `users/{userId}` immediately on Save
- Changes to the owner's name appear in conversations and events — these are read live from Firestore so existing conversation messages are not retroactively updated (the sender name is not stored on each message)

### States
- **Idle**: pre-filled with current values
- **Uploading photo**: progress indicator on the photo circle
- **Saving**: Save button spinner; fields disabled
- **Success**: navigates back to Me screen with updated values
- **Error**: toast for network failure; values preserved

---

## Notification Settings

### Purpose
Let the owner control which categories of push notifications they receive.

### Notification categories and toggles

| Category | Default | Description |
|---|---|---|
| Health reminders | On | Gentle / standard / urgent reminders for upcoming health events |
| Overdue health alerts | On | Alerts when a health event becomes overdue |
| AI friend nudges | On | Proactive messages from the virtual AI friend |
| Match alerts | On | Notification when a mutual match occurs |
| New messages | On | Notification when a matched owner sends a message |
| Event updates | On | RSVP confirmations and reminders for saved events |
| Exhibition reminders | On | Reminders for watchlisted exhibitions |
| Badge earned | On | Notification when a new badge is unlocked |
| Walk streak | Off | Daily reminder to go for a walk (opt-in) |

### UI elements
- Grouped list of toggle rows, one per category
- Each row: category name, short description in grey, toggle on the right
- A banner at the top if the owner has denied push notification permission at the iOS system level: "Notifications are disabled. Enable them in Settings to receive alerts." with a "Go to Settings" button (opens iOS Settings deep link)

### Business rules
- Preferences are stored in `users/{userId}/notificationSettings` as a map of `category: boolean`
- If a category is toggled off, the Cloud Function responsible for that category checks this flag before sending
- The iOS system-level permission is separate — if the owner denied it at the OS level, all notifications are blocked regardless of these settings. The app detects this via `UNUserNotificationCenter.current().notificationSettings` and shows the banner.
- The walk streak daily reminder is opt-in (off by default) to avoid being annoying

### States
- **Loading**: skeleton toggles
- **Populated**: all toggles with current values
- **Permission denied banner**: shown at top when OS-level permission is denied

---

## App Settings

### Purpose
Control general app preferences.

### Settings

| Setting | Options | Default |
|---|---|---|
| Weight unit | kg / lbs | kg |
| Distance unit | km / miles | km |
| App appearance | System / Light / Dark | System |

### UI elements
- Grouped list: each setting as a row with a disclosure indicator leading to a picker or inline segment control
- Weight and distance units affect all displays of weight (dog profile, weight log) and distance (walk stats, map) throughout the app

### Business rules
- Preferences stored locally (UserDefaults) — not synced to Firestore
- Weight unit affects display only; all values are stored in kg internally. Conversion is applied at the display layer.
- Distance unit affects display only; all values are stored in km internally.

---

## Sign Out

Accessible from the Me main screen under the Account section.

### Flow
1. Owner taps "Sign Out"
2. Alert: "Sign out of FurBabies? You'll need to sign in again to access your account." with Cancel / Sign Out
3. On confirm:
   - `AuthServiceProtocol.signOut()` called
   - Local SwiftData cache cleared
   - UserDefaults notification settings cleared
   - App navigates to Onboarding → Auth screen

---

## Account Deletion

Accessible from the Me main screen under the Account section.

### Flow
1. Owner taps "Delete Account"
2. Warning screen with clear explanation: "This will permanently delete your account and all data for all your dogs — health records, matches, conversations, walk history, photos, and documents. This cannot be undone."
3. Owner must type **"DELETE"** in a text field to confirm (friction for an irreversible action)
4. Taps "Permanently Delete" button (only enabled when "DELETE" is typed exactly)
5. Cloud Function executes cascading delete:
   - All `users/{userId}/dogs/` subcollections
   - All `matches/` documents where the user's dogs are involved
   - All Firebase Storage files under `users/{userId}/`
   - `users/{userId}` document
   - Firebase Auth account deleted last
6. App navigates back to Onboarding → Auth screen
7. If Cloud Function fails: error shown, nothing deleted — owner can try again

---

## User Flows

### Flow 1: Edit profile photo
1. Owner opens Me tab
2. Taps profile photo (or "Edit Profile")
3. Edit Profile screen opens
4. Taps the photo circle → system image picker opens
5. Selects a photo → photo compresses and uploads to Firebase Storage
6. Progress indicator shown during upload
7. Taps Save → name/city saved to Firestore
8. Returns to Me screen with updated photo and name

### Flow 2: Turn off match alerts
1. Owner opens Me tab → Notification Settings
2. Finds "Match alerts" toggle → taps to turn off
3. Toggle animates off; preference saved to Firestore immediately
4. Owner will no longer receive match push notifications

### Flow 3: Switch to imperial units
1. Owner opens Me tab → App Settings
2. Taps "Weight unit" → selects "lbs"
3. Taps "Distance unit" → selects "miles"
4. Returns to app — all weight and distance values now display in imperial

### Flow 4: Sign out
1. Owner taps "Sign Out" on the Me screen
2. Confirmation alert
3. Confirms → signed out, returned to Onboarding

### Flow 5: Delete account
1. Owner taps "Delete Account"
2. Warning screen explains what will be deleted
3. Types "DELETE" in the confirmation field
4. "Permanently Delete" button becomes active
5. Taps it → loading state while Cloud Function runs
6. Complete → app resets to Onboarding

---

## Business Rules

- **Owner profile photo is optional** — the placeholder avatar is used everywhere (conversations, event attendee strip) if no photo is set
- **Name is required** — the owner cannot save an empty name; it was collected at sign-up (Owner Profile Setup) so it should always exist
- **Unit preferences are local only** — switching devices resets to defaults (kg / km / System). No sync in v1.
- **Notification settings are per-account** (stored in Firestore) — they follow the owner across devices
- **The owner's name in conversations** is read live from `users/{userId}.name` — it is not stored on each message. If the owner renames themselves, all future reads will show the new name.

---

## Data (Firestore)

```
users/{userId}
  name: string
  city: string
  email: string
  profilePhotoUrl: string | null
  createdAt: timestamp
  updatedAt: timestamp

users/{userId}/notificationSettings    // stored as a single doc
  healthReminders: boolean
  overdueAlerts: boolean
  aiFriendNudges: boolean
  matchAlerts: boolean
  newMessages: boolean
  eventUpdates: boolean
  exhibitionReminders: boolean
  badgeEarned: boolean
  walkStreak: boolean
```

**Local (UserDefaults)**
```
weightUnit: "kg" | "lbs"
distanceUnit: "km" | "miles"
appearance: "system" | "light" | "dark"
```

**Firebase Storage**
```
users/{userId}/profile.jpg    // owner profile photo
```

**Reads:** Me screen (user doc + notification settings), Edit Profile (user doc), all features that display owner name/photo
**Writes:** Edit Profile (user doc + Storage upload), Notification Settings (notificationSettings doc), sign-up (creates user doc via Owner Profile Setup)
**Deletes:** Account deletion (all user data via Cloud Function)

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Owner removes profile photo | `profilePhotoUrl` set to null in Firestore; placeholder shown everywhere |
| Owner uploads a very large photo | Compressed client-side to max 1 MB before upload |
| Owner's city is blank | City line hidden on the Me screen and in public-facing contexts; not required |
| OS-level notifications denied | Settings banner shown; toggles still visible but greyed out with explanatory text |
| Owner types "delete" (lowercase) in account deletion | "Permanently Delete" button stays disabled — must be uppercase "DELETE" exactly |
| Cloud Function fails during account deletion | Error shown; retry button; no partial deletion (function is transactional) |
| Owner signs out on one device while signed in on another | Both devices sign out when the auth token expires or on next refresh |

---

## Out of Scope

- Subscription or in-app purchases — not in v1
- Privacy settings (dog visibility controls) — managed per dog in the Dog Profile feature
- Language / localisation settings — not in v1
- Owner social links or bio — not in v1
- Blocking other owners (separate from blocking dogs) — blocking is dog-to-dog in the Matching feature
