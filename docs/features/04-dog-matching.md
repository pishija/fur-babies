# Feature: Dog Matching

## Overview

Dog Matching lets owners find compatible playmates for their dog using a Tinder-style swipe interface. When two owners both swipe right on each other's dog, it's a match — a conversation thread opens between them so they can arrange a meetup. The feature lives in a dedicated "Social" tab that combines discovery (swiping), the matched friends list, and conversations. Blocking prevents a dog from ever appearing again in discovery.

---

## Screens

All within the **Social tab**:

1. **Discover** — swipeable card stack for finding new dogs
2. **Matches** — list of all mutual matches with last message preview
3. **Conversation** — iMessage-style chat between two matched owners
4. **Match Celebration** — full-screen overlay shown when a mutual match occurs
5. **Filter Sheet** — bottom sheet for adjusting discovery filters

The Social tab has two top-level sections navigated by a segmented control or top tabs: **Discover** and **Matches**.

---

## Discover Screen

### Purpose
Browse candidate dogs and swipe to like or pass. Shows dogs nearby who are public and haven't been swiped on yet.

### UI elements
- **Card stack**: one card visible at a time, with the next card peeking behind it
- **Each card**:
  - Full-bleed primary photo
  - Gradient overlay at the bottom with: dog name, breed, age, distance ("2.3 km away")
  - Size class and sex pills
  - Temperament tags (up to 4 shown; rest hidden)
  - Vaccination status badge ("Vaccinated" green chip if all core vaccines up to date)
- **Action buttons** below the card: ✕ Pass (left) and ♡ Like (right)
- **Filter button** top right → opens Filter Sheet
- **Info button** on card → expands to full dog profile detail (read-only)
- Swipe left gesture = Pass; swipe right gesture = Like

### States
- **Loading**: single card skeleton
- **Populated**: card stack with at least one candidate
- **Empty (no more candidates)**: illustration + "No more dogs nearby right now. Check back later or expand your search radius." + shortcut to open filters
- **Dog is private / not public**: these dogs never appear in discovery (filtered server-side)

### Discovery candidate rules
- `isPublic = true`
- Not the owner's own dogs
- Not previously swiped on (liked or passed) by the active dog
- Not blocked by or blocking the active dog
- Within the active distance filter radius (default: 10 km)
- Matches all active filter settings
- Sorted: nearest distance first by default

---

## Filter Sheet

### Purpose
Narrow discovery to dogs that are a better fit.

### Filters

| Filter | Type | Default |
|---|---|---|
| Distance radius | Slider | 10 km |
| Breed | Multi-select search | Any |
| Size class | Multi-select chips | Any |
| Age range | Dual-handle slider | 0–15 years |
| Sex | Toggle: Male / Female / Any | Any |
| Temperament tags | Multi-select chips | Any |
| Vaccinated only | Boolean toggle | Off |
| Neutered / intact | Toggle: Neutered / Intact / Any | Any |

- "Reset filters" button clears all back to defaults
- Filters are saved per-device (persisted in local storage); they are not dog-specific

---

## Match Celebration Overlay

### Purpose
Celebrate a mutual match with a moment of delight.

### UI elements
- Full-screen overlay with blurred background
- Both dogs' profile photos side by side in circles with a heart between them
- "It's a Match!" headline
- Dog names: "[Your dog] & [Their dog] are a match!"
- Two buttons:
  - "Keep Swiping" → dismisses overlay, returns to Discover
  - "Say Hello" → dismisses overlay, navigates to the new Conversation

### Trigger
Shown immediately when a like results in a mutual match. The overlay is not shown again for the same match if the user navigates away and comes back.

---

## Matches Screen

### Purpose
View all mutual matches and access their conversations.

### UI elements
- List of matched dogs, each row showing:
  - Dog's primary photo (circular)
  - Dog's name and breed
  - Owner's first name (if shared)
  - Distance ("2.3 km away")
  - Last message preview (greyed out if no messages yet: "Say hello to [dog name]!")
  - Unread indicator (blue dot) if there are unread messages
  - Time of last message (right side)
- Empty state: "No matches yet. Start swiping!" with a button to go to Discover

### User actions
- Tap a row → opens Conversation for that match
- Long-press or swipe row left → reveals "Unmatch" / "Block" actions

---

## Conversation Screen

### Purpose
Let two matched owners chat to arrange a playdate or get to know each other.

### UI elements
- Navigation bar: matched dog's photo + name as title
- Small banner at the top (dismissible): "[Dog name]'s profile" link — taps to open the other dog's read-only profile
- iMessage-style message bubbles:
  - Current owner's messages: right side, filled primary colour
  - Other owner's messages: left side, grey
- Text input bar at the bottom + send button
- Timestamps between message groups (gap > 1 hour)
- **"..." menu** in nav bar → "Unmatch" / "Block [dog name]"

### States
- **Loading**: skeleton bubbles
- **Empty** (first time): no messages yet; placeholder text "You matched with [dog]! Send a message to say hello."
- **Populated**: scrollable message history
- **Sending**: optimistic bubble appears immediately; spinner while sending
- **Error sending**: red "!" retry button on the failed bubble
- **Offline**: banner "No connection" at top; input still allowed, queued locally

### User actions
- Type and send messages
- Scroll up for older messages (pagination, batches of 30)
- Tap "..." → Unmatch or Block

---

## Unmatch & Block

### Unmatch (without block)
- Confirmation: "Unmatch [dog name]? Your conversation will be deleted."
- On confirm:
  - Match removed from both owners' Matches lists
  - Conversation and all messages deleted from Firestore
  - The other dog may appear again in the active dog's future discovery swipes

### Block (includes unmatch)
- Confirmation: "Block [dog name]? This will remove the match and [dog name] will never appear in your search again."
- On confirm:
  - All of the above (unmatch)
  - A block record is written so the blocked dog never appears in this dog's discovery
  - The blocked dog's owner is not notified

---

## User Flows

### Flow 1: Swipe and like
1. Owner opens Social tab → Discover
2. Card stack shows candidate dogs
3. Owner swipes right (or taps ♡)
4. Card animates off to the right; next card appears
5. Like is written to Firestore
6. If no mutual match: nothing else happens; continue swiping

### Flow 2: Mutual match
1. Owner swipes right on Dog B
2. Dog B's owner had already swiped right on the active dog
3. Match celebration overlay appears immediately
4. Owner taps "Say Hello" → navigates to the new conversation
   — or taps "Keep Swiping" → overlay dismisses, back to card stack

### Flow 3: View another dog's profile
1. Owner taps the info button on a card
2. Read-only profile view opens (photos, name, breed, age, temperament tags, vaccination status)
3. Swipe actions (Like / Pass) available at the bottom of this detail view too

### Flow 4: Filter discovery
1. Owner taps Filter button
2. Filter sheet slides up
3. Owner adjusts distance radius and selects "Large" size class
4. Taps "Apply" → sheet closes, card stack reloads with filtered candidates

### Flow 5: Send first message after match
1. Owner opens Matches tab
2. Taps on new match row (no messages yet)
3. Conversation opens with empty state prompt
4. Owner types "Hi!" and taps Send
5. Message appears; other owner receives a push notification (Notifications feature)

### Flow 6: Unmatch
1. Owner swipes left on a match row in the Matches list
2. "Unmatch" button revealed
3. Taps Unmatch → confirmation alert
4. Confirms → match and conversation removed from both sides

### Flow 7: Block
1. Owner opens a Conversation
2. Taps "..." → "Block [dog name]"
3. Confirmation alert
4. Confirms → match removed, conversation deleted, dog blocked from future discovery

---

## Business Rules

- **Swiping is per-dog**: the active dog (not the owner account) is the entity that likes or passes. If an owner has 2 dogs, each dog has independent swipe history.
- **A like is permanent**: passing on a dog is also permanent — they won't reappear in discovery unless filters are reset (pass history is kept).
  - Exception: if the owner resets filters (not yet a feature in v1), passed dogs may reappear. To keep this simple, **passed dogs do not reappear** — their pass is stored permanently.
- **Mutual match required for conversation**: owners cannot message each other without a mutual match.
- **One conversation per match**: a match has exactly one conversation thread. Unmatching and rematching is not possible (the block prevents it; an unmatch without block could theoretically be reversed if both swipe right again — create a new conversation, discard the old one).
- **Messages are real-time**: Firestore real-time listeners are used so new messages appear instantly without polling.
- **Read receipts**: not implemented in Day 1. Messages show only sent state.
- **Compatibility score**: AI-powered compatibility rating shown on cards and in conversation *(v1.0 — not in Day 1)*.
- **Friends list** (walk activity, event invites, leaderboard scope) *(v1.0 — not in Day 1)*.

---

## Data (Firestore)

```
matches/{matchId}
  dogAId: string      // always the dog with the lexicographically smaller ID
  dogBId: string
  dogALikedAt: timestamp
  dogBLikedAt: timestamp | null   // null until mutual
  status: "pending" | "matched" | "unmatched"
  matchedAt: timestamp | null
  createdAt: timestamp

swipes/{swipeId}
  fromDogId: string
  toDogId: string
  action: "like" | "pass"
  createdAt: timestamp

blocks/{blockId}
  blockerDogId: string
  blockedDogId: string
  createdAt: timestamp

matches/{matchId}/messages/{messageId}
  senderId: string      // userId of the sender
  content: string
  sentAt: timestamp
  readAt: timestamp | null
```

**Reads:** Discover (swipes + blocks to exclude candidates), Matches list, Conversation
**Writes:** Swipe action (swipe doc), mutual match (match doc updated, match celebration triggered), send message (message doc)
**Deletes:** Unmatch/block (match doc status update, messages deleted, block doc created)

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Both owners swipe right at the exact same moment | Firestore transaction ensures only one match doc is created; both see the celebration overlay |
| Owner deletes a dog that has active matches | All matches, conversations, swipes, and blocks for that dog are deleted |
| Owner sets their dog to `isPublic = false` | Dog disappears from all other users' discovery immediately; existing matches and conversations remain intact |
| No dogs available in the discovery radius | Empty state shown with suggestion to expand radius |
| Owner changes the active dog while on Discover | Card stack reloads with the new dog's swipe history (different candidates) |
| Other owner deletes their account | Conversation shows "This user is no longer available" instead of their messages |
| Card stack runs out mid-swipe | After last card: empty state appears; no crash |
| Owner tries to message a blocked user | Not possible — the match no longer exists after blocking |

---

## Out of Scope

- Voice or video calls
- Sending photos in conversations
- Group chats (more than 2 owners)
- AI compatibility score — v1.0
- Friends list (walk activity visibility, event invites) — v1.0
- Walk-together invite from the map — handled in Live Walk Map feature
