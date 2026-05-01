# Feature: Live Walk Map

## Overview

The Map tab is the app's spatial hub. It has two modes — **Browse** and **Walk** — and two always-available map layers: **Live Dogs** (dogs currently on walks nearby) and **Places** (pet-friendly venues like vets, cafes, parks, and grooming salons). Both layers are visible at the same time by default; the owner can toggle individual place categories on/off. In Browse mode the owner discovers nearby dogs and places. In Walk mode the app actively tracks the walk — recording distance, duration, and route — while sharing the dog's fuzzed location on the live map. Walk mode is triggered by motion detection with explicit owner confirmation. Location is never shared passively. The Map is a dedicated tab in the tab bar.

---

## Screens

1. **Map (Browse mode)** — the default map view showing nearby walking dogs and pet-friendly places
2. **Walk Session (Walk mode)** — full-screen map with live stats overlay, active during a walk
3. **Walk Summary** — shown when a walk ends, with distance, duration, and route
4. **Nearby Breed Stats Panel** — a slide-up panel with breed distribution in the area
5. **Layer Controls** — a compact panel for toggling map layers and place categories

---

## Map — Browse Mode

### Purpose
Let the owner discover nearby dogs currently on walks without sharing their own location.

### UI elements
- **Full-screen map** (MapKit) centred on the user's last known location or current location
- **Dog pins** (Live Dogs layer): custom map pins showing each walking dog's profile photo thumbnail; tapping a pin shows a popup with the dog's name, breed, and distance
- **Place pins** (Places layer): category-coloured pins for pet-friendly venues; tapping a pin shows a popup with the place name, category, star rating, and distance; tapping the popup opens the Place Detail screen (see Pet-Friendly Places feature)
- **Layer controls button**: bottom left corner → opens Layer Controls panel to toggle Live Dogs on/off and toggle individual place categories
- **Breed stats button**: bottom right corner → slides up the Nearby Breed Stats Panel
- **My location button**: standard map button to re-centre on user
- **No active location sharing** while in browse mode

### Layer Controls panel
A compact bottom sheet with two sections:
- **Live Dogs toggle**: on/off switch to show/hide walking dog pins
- **Places categories**: individual toggles for each category — Vets, Cafes & Restaurants, Parks & Green Spaces, Dog Beaches, Off-Leash Zones, Pet Shops, Grooming Salons, Dog-Friendly Hotels, Hiking Trails
- Layer preferences are saved locally on the device (persisted across app launches)

### States
- **Location permission not granted**: banner prompting the owner to allow location access in Settings; map is still shown but centred on a default location
- **No dogs nearby**: map shows but no pins visible; a subtle label "No dogs walking nearby right now"
- **Dogs nearby**: pins rendered on map

---

## Walk Detection

### How it works
The app uses CoreMotion (activity detection) to identify when the user begins walking or running. When walking activity is detected:

1. A **banner notification appears at the top of the screen** (regardless of which tab the user is on): *"Looks like you're walking [Dog name]! Start tracking?"* with "Start" and "Dismiss" buttons
2. If the owner taps **"Start"**: a walk session begins immediately (Walk mode activates, Map tab opens)
3. If the owner taps **"Dismiss"**: the prompt goes away and does not reappear for at least 30 minutes
4. If the owner ignores it: the banner disappears after 10 seconds; same 30-minute cooldown

### Active dog context
The walk session is always tied to the **currently active dog** (as set by the dog switcher). If the owner has multiple dogs, they switch to the right dog before (or during) starting a walk.

### Permission requirements
- **CoreMotion / Motion & Fitness** permission required for auto-detection
- **Location (While Using)** permission required to show on the live map
- If either permission is missing, a prompt explains why it is needed; the owner can also start a walk manually from the Map tab if auto-detection is unavailable

### Manual start fallback
A **"Start Walk" button** is visible on the Map tab browse screen for owners who denied motion permission or prefer to start manually.

---

## Walk Session — Walk Mode

### Purpose
Track the active walk in real time — recording distance, route, and duration — while sharing the dog's presence (not exact location) on the live map.

### UI elements
- **Full-screen map** showing:
  - The dog's current route as a coloured polyline drawn as they walk
  - Nearby dog pins (other dogs also in walk mode) on the same map — **their coordinates are fuzzed by ~50 metres**
  - The owner's current position as a dog-avatar pin (their exact position is only on their own device; what others see is fuzzed)
- **Stats bar at the bottom** (semi-transparent overlay):
  - Distance walked (e.g. "1.42 km")
  - Duration (e.g. "18:34")
  - Current pace (e.g. "13:02 / km")
- **"End Walk" button** — prominent, in the stats bar or as a floating button
- **Dog switcher** remains accessible at the top (switching dogs during a walk ends the current walk session first with a warning)

### What other users see
- The active dog appears as a pin on the live map for nearby users
- The pin shows the dog's profile photo, name, breed, and approximate distance
- The dog's coordinates are fuzzed by **~50 metres** before being shared — exact location is never exposed to other users
- The pin disappears automatically after **15 minutes of inactivity** (if the walk session is not properly ended — acts as a safety fallback)

### States
- **Acquiring GPS**: spinner on the map while GPS signal is being obtained; stats bar shows "–" for distance and pace
- **Active walk**: polyline growing, stats updating every second (duration) and every ~10 metres (distance + pace)
- **GPS lost mid-walk**: a banner warns "GPS signal lost — walk is paused". Stats stop updating; route pauses. Resumes automatically when signal returns.
- **Ending walk**: brief loading while the session is saved and location is removed from the live map

---

## Walk Summary Screen

### Purpose
Show the completed walk stats and give the owner a moment to appreciate their effort before returning to the app.

### UI elements
- Static map showing the completed route as a polyline
- **Distance**: total distance in km
- **Duration**: total time
- **Average pace**
- **Badges earned** (if any were unlocked by this walk — e.g. "First Steps", "10km Club")
- "Done" button → returns to Map browse mode

### States
- **Loading**: brief while summary data is saved to Firestore
- **Populated**: full summary shown

---

## Nearby Breed Stats Panel

### Purpose
Show which breeds are most active nearby — a fun discovery for dog owners.

### UI elements
- Slides up as a bottom sheet
- **Bar chart** of breeds active within the selected radius in the last 30 minutes
- **Radius selector**: 1 km / 5 km / 10 km
- **Small vs large dog split**: percentage shown below the chart
- "Close" button or drag down to dismiss

---

## User Flows

### Flow 1: Auto-detect → start walk
1. Owner leaves home with their dog
2. Motion activity detected: walking started
3. Banner appears on-screen: "Looks like you're walking [Dog name]! Start tracking?"
4. Owner taps "Start"
5. Map tab activates; Walk mode begins immediately
6. Polyline starts drawing from current position; stats begin at 0

### Flow 2: Manual start
1. Owner opens Map tab (browse mode)
2. Taps "Start Walk" button
3. Walk mode begins

### Flow 3: End a walk
1. Owner taps "End Walk" button
2. Brief confirmation (optional, to avoid accidental taps): "End your walk?"
3. On confirm:
   - Walk session saved to Firestore (distance, duration, route polyline)
   - Dog's pin removed from the live map
   - Walk Summary screen shown

### Flow 4: Browse the map without walking
1. Owner opens Map tab
2. Sees nearby dog pins (dogs currently on walks)
3. Taps a pin → popup with dog's name, breed, distance
4. Taps popup → read-only dog profile (same as in Matching)

### Flow 5: View breed stats
1. Owner opens Map tab
2. Taps breed stats button
3. Panel slides up showing bar chart of active breeds nearby
4. Owner adjusts radius → chart updates
5. Drags panel down to dismiss

### Flow 6: Switch dogs during a walk
1. Owner is in Walk mode with Dog A
2. Taps Dog B in the dog switcher
3. Alert: "Switching dogs will end Dog A's current walk. Continue?"
4. Confirms → current walk saved and summarised; Dog B becomes active; walk mode ends (owner would start a new walk for Dog B if needed)

---

## Business Rules

- **Location sharing is always explicit**: the owner must confirm the auto-detect prompt or manually tap "Start Walk". No background location sharing ever occurs.
- **Fuzzing**: the dog's live location shared to other users is offset by a random amount in the range of 30–70 metres (centred around ~50 m) in a random direction. This offset changes with each location update, so it cannot be triangulated over time.
- **15-minute expiry**: if a walk session is started but the owner closes the app without ending it, the dog's pin is automatically removed from the live map after 15 minutes. The walk data (distance + route) up to that point is still saved when the app is next opened.
- **Walk tracking precision**: GPS location is recorded every ~10 seconds while walking. Route is stored as a GeoJSON polyline written to Firestore only when the walk is explicitly ended.
- **Walk stats feed gamification**: on walk end, the Gamification system checks if any walking badges have been unlocked (async, does not block the summary screen).
- **Streak**: a walk must be logged within 36 hours of the previous walk to maintain the streak. Checked asynchronously after walk end.
- **Walk-together invite** (v1.0 — not in Day 1): a matched friend taps a pin on the map and sends an invite; if accepted, both owners see each other's live (fuzzed) position in a shared session.
- **AI compatibility hint on map pins** (v1.0 — not in Day 1): if a nearby dog is a strong match for the active dog's breed and size, a subtle indicator appears on their pin.
- **Popular routes heatmap** (v2.0): not in this version.

---

## Data (Firestore + Firebase Storage)

```
users/{userId}/dogs/{dogId}/walkSessions/{sessionId}
  startedAt: timestamp
  endedAt: timestamp | null
  distanceKm: number
  durationSeconds: number
  routeGeoJSON: string      // GeoJSON LineString, written only on walk end
  badgesEarned: string[]    // badge slugs awarded from this walk
```

**Live location** (not Firestore — stored in memory on-device and shared via Firebase Realtime Database or a dedicated presence system):
```
liveWalks/{dogId}
  lat: number               // fuzzed ~50m before writing
  lng: number               // fuzzed ~50m before writing
  dogName: string
  breed: string
  primaryPhotoUrl: string
  expiresAt: timestamp      // now + 15 minutes, refreshed every location update
```

**Reads:** Browse map (live walk pins for nearby dogs), breed stats panel, walk summary
**Writes:** Walk start (live location record created), location updates (live record updated), walk end (Firestore session doc written, live record deleted)
**Deletes:** Walk end (live record removed), 15-min TTL expiry (automatic), dog deletion (all walk sessions deleted)

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Owner denies location permission | Manual "Start Walk" button shown; walk can still be tracked with reduced precision; dog does not appear on other users' maps |
| Owner denies motion permission | Auto-detection disabled silently; manual start button always visible |
| GPS signal lost mid-walk | Banner shown; stats pause; route has a gap (no polyline drawn during loss); resumes on signal return |
| App crashes mid-walk | On next app open: a "You have an unsaved walk" banner appears with the option to save or discard the partial session |
| Owner never taps "End Walk" | 15-minute TTL removes the live pin; partial walk data saved automatically when app resumes |
| Two dogs from the same household walking simultaneously | Each dog has its own walk session; only the active dog's session is tracked on this device |
| Owner is in a city with no other dogs walking | Map shows no pins; breed stats panel shows "No active dogs nearby" |
| Walk distance is 0 m (owner taps end immediately) | Walk is discarded silently; no Firestore record written; no summary shown |
| Route polyline is very long (> 1 MB) | GeoJSON is stored in Firebase Storage instead of Firestore if it exceeds 900 KB; Firestore doc stores the Storage URL |

---

## Out of Scope

- Passive background location tracking — never
- Sharing exact GPS coordinates with other users — never
- Walk-together invite (real-time shared session) — v1.0
- AI compatibility hints on map pins — v1.0
- Popular routes heatmap — v2.0
- Integration with Apple Health / HealthKit — not planned
- Turn-by-turn navigation
