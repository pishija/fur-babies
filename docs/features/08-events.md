# Feature: Events

## Overview

Events lets owners discover and create dog-specific community events — birthday parties, breed meetups, puppy playdates, charity walks, and more. Events live inside the Social tab alongside Matching and Conversations. Discovery is a vertical Instagram-style feed of event cards. Any user can submit an event, but it goes live only after the FurBabies team approves it. Owners RSVP with Going / Interested / Not Going. Events are tied to the active dog, so each dog has its own RSVP history.

---

## Screens

1. **Events Feed** — vertical feed of upcoming approved events (within the Social tab)
2. **Event Detail** — full information, attendee list, and RSVP for a single event
3. **Create Event** — form to submit a new event for team review
4. **My Events** — list of events the active dog has RSVPd to or created

All screens live within the **Social tab**, navigated alongside Discover (matching) and Matches (conversations) via a top segmented control or top tab bar: **Discover | Matches | Events**.

---

## Events Feed

### Purpose
Let owners scroll through upcoming local events and find something relevant for their dog.

### UI elements
- **Vertical feed** of event cards, each card showing:
  - Cover photo (full-width, aspect ratio ~16:9)
  - Event type badge (e.g. "Breed Meetup", "Charity Walk")
  - Event title
  - Date and time (e.g. "Sat, 10 May · 10:00")
  - Location name + distance (e.g. "Central Park · 1.2 km away")
  - Attendee count ("14 going")
  - RSVP quick-action buttons inline on the card: Going / Interested / Not Going (highlight the active choice)
- **Filter bar** above the feed: horizontal chip scroll — All, This Weekend, Breed Relevant, Nearby, by event type
- **"Create Event" button** — top right of the screen
- **"My Events" button** — top left or accessible from a profile/menu area

### Breed Relevant filter
Shows events that have no breed restriction OR are specifically for the active dog's breed. Highlighted as a smart filter.

### States
- **Loading**: skeleton cards
- **Empty** (no events match filters): "No events nearby right now. Check back soon or create one!" + Create Event button
- **Populated**: scrollable feed, newest/soonest date first within the same distance radius
- **Default radius**: 25 km; owner cannot change this in v1 (may be surfaced in v2)

---

## Event Detail

### Purpose
Show everything about a specific event and let the owner RSVP.

### UI elements
- **Cover photo** — full-width at top
- **Event type badge**
- **Event title** (large)
- **Date & time**
- **Location**: venue name + address + a small map snippet with an "Open in Maps" button
- **Description**: free text from the creator
- **Breed restriction**: "Open to all breeds" or "Golden Retrievers only" (for example)
- **Max attendees**: "14 / 30 going"
- **RSVP buttons**: Going / Interested / Not Going (one selected at a time; tapping the active one deselects it / removes RSVP)
- **Attendees section**: horizontal strip of dog profile photos for "Going" attendees; tap to view a dog's public read-only profile
- **Created by**: the creator's active dog name + breed ("Created by Max the Labrador")
- **"Report event" link** at the bottom → sends a report to the team

### States
- **Loading**: skeleton
- **Populated**: full detail
- **Past event**: date label shows "This event has passed"; RSVP buttons are disabled

---

## Create Event

### Purpose
Let any owner submit a new event for the FurBabies team to review and approve.

### Form fields

| Field | Required | Notes |
|---|---|---|
| Title | Yes | Max 100 characters |
| Event type | Yes | Picker: Birthday Party, Breed Meetup, Puppy Playdate, Training Session, Charity Walk, Costume Contest, Agility Fun Day |
| Date and time | Yes | Must be in the future |
| Location | Yes | Search by address or drop a pin on a map |
| Description | No | Free text, max 1000 characters |
| Cover photo | No | From camera or library; strongly encouraged |
| Breed restriction | No | "Open to all" (default) or specify a breed |
| Max attendees | No | Numeric; no limit if left blank |

### Business rules
- Submitted events enter a **pending review** state — not visible to other users until the team approves
- The creator can see their own pending event in "My Events" with a "Pending review" label
- The team approves or rejects via an external tool (Firebase console or admin panel — not in-app)
- If rejected, the event is deleted silently (no in-app notification in v1)
- The creator's active dog is recorded as the host dog
- Once approved, the event appears in the feed for nearby users

### States
- **Idle**: empty form
- **Submitting**: spinner
- **Success**: "Your event has been submitted for review. We'll add it to the feed once approved." — navigates back to the feed
- **Error**: toast for network failure; form preserved

---

## My Events

### Purpose
Let the owner see all events they've RSVPd to or created, in one place.

### UI elements
- Two sections:
  - **Going / Interested**: events where the active dog has an RSVP of Going or Interested, sorted by soonest date
  - **Created by me**: events the active dog's owner submitted, including pending ones
- Each row: event title, date, RSVP status or "Pending review" label
- Tap a row → opens Event Detail

### States
- **Empty**: "No events yet. Discover events in the feed or create your own!"
- **Populated**: two sections as described

---

## User Flows

### Flow 1: Discover and RSVP to an event
1. Owner opens Social tab → taps "Events" segment
2. Scrollable feed loads with upcoming events
3. Owner taps "Breed Relevant" filter chip → feed filters to events open to their dog's breed
4. Owner taps an event card → Event Detail opens
5. Reads the details, taps "Going"
6. RSVP saved; attendee count increments; owner's dog appears in the attendees strip
7. Returns to feed; the card now shows their RSVP highlighted

### Flow 2: Quick RSVP from the feed
1. Owner sees an event card in the feed
2. Taps "Interested" directly on the card (without opening Event Detail)
3. RSVP saved immediately; button highlights

### Flow 3: Create an event
1. Owner taps "Create Event" button
2. Form opens; fills in title, type, date, location, cover photo
3. Leaves max attendees blank (unlimited)
4. Taps Submit → success message
5. Owner opens "My Events" → sees the new event with "Pending review" label
6. Team approves → event appears in the feed for other users

### Flow 4: Change RSVP
1. Owner opens Event Detail for an event they marked "Going"
2. Taps "Interested" → RSVP changes from Going to Interested
3. Taps the "Interested" button again → RSVP removed entirely

### Flow 5: View who's going
1. Owner opens Event Detail
2. Scrolls to Attendees section
3. Sees horizontal strip of dog photos
4. Taps a dog's photo → read-only dog profile opens

### Flow 6: Report an event
1. Owner sees an event that seems inappropriate
2. Opens Event Detail → taps "Report event"
3. Selects a reason (Inappropriate content / Spam / Incorrect information / Other)
4. Optionally adds a note → submits
5. Report sent to the team queue

---

## Business Rules

- **Events are per active dog**: RSVPs are recorded for the active dog, not the owner account. If an owner switches to a different dog, that dog's RSVP state is independent.
- **Past events**: events whose date has passed are no longer shown in the main feed but remain accessible in My Events if the dog RSVPd to them.
- **Max attendees enforcement**: if a max attendee count is set and "Going" RSVPs reach that number, the "Going" button is disabled for new users. "Interested" and "Not Going" remain available.
- **Breed restriction display only**: the breed restriction field is informational — the app does not technically prevent a dog of the wrong breed from RSVPing. It is the creator's responsibility to manage attendance.
- **One RSVP per dog per event**: tapping a different RSVP option replaces the previous one; tapping the current option removes it.
- **Attendee count**: shows the count of "Going" RSVPs only (not Interested).
- **Creator cannot delete their own event** once submitted — they can request deletion via reporting it or contacting the team (v1 limitation).
- **No push notification on approval** in v1 — the event simply appears in My Events and the feed.

---

## Data (Firestore)

```
events/{eventId}
  title: string
  type: string               // "birthday_party" | "breed_meetup" | "puppy_playdate" | "training" | "charity_walk" | "costume_contest" | "agility"
  status: "pending" | "approved"
  creatorDogId: string
  creatorUserId: string
  date: timestamp
  locationName: string
  locationAddress: string
  lat: number
  lng: number
  description: string
  coverPhotoUrl: string
  breedRestriction: string | null   // null = open to all
  maxAttendees: number | null
  goingCount: number                // maintained as a counter
  createdAt: timestamp

events/{eventId}/rsvps/{dogId}
  status: "going" | "interested" | "not_going"
  userId: string
  rsvpAt: timestamp

eventReports/{reportId}
  eventId: string
  reportedByUserId: string
  reason: string
  note: string
  createdAt: timestamp
```

**Reads:** Events feed (approved events, geo-filtered, date-filtered), Event Detail (event doc + rsvps subcollection), My Events (events where creatorUserId = me OR rsvps/{myDogId} exists)
**Writes:** RSVP (rsvp doc upsert + goingCount increment/decrement), Create event (event doc with status = pending), Report (report doc)
**Deletes:** Team-managed (via admin tool); RSVP removal (rsvp doc deleted + goingCount updated)

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Owner RSVPs to an event that reaches max capacity simultaneously | Firestore transaction on goingCount; if count is at max when the transaction runs, the "Going" RSVP is rejected and the button shown as disabled |
| Creator's event is rejected by the team | Event doc deleted; disappears from creator's My Events silently |
| Owner switches dogs mid-RSVP | The RSVP is saved for the dog that was active at the time of tapping; switching dogs changes whose RSVP state is shown on the card |
| Event date passes while the owner has a pending RSVP | Event moves to past; shown in My Events history; no action needed |
| Owner submits an event with a past date | Validation error on the date field: "Event date must be in the future" |
| No cover photo submitted | Event card uses a default illustration based on the event type |
| Owner tries to create an event for a dog that is not public | Allowed — the creator's dog is shown as "host" but the event itself is public |

---

## Out of Scope

- In-app push notification when an event is approved — not in v1
- Creator editing or deleting their own event after submission — not in v1
- Event photo album / recap card for attendees — v2.0
- Auto-generated recap card ("Luna attended 3 events this month!") — v2.0
- Inviting matched friends directly to events — v2.0
