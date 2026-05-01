# Feature: Gamification

## Overview

Gamification rewards owners for walking their dog, building social connections, and keeping health records up to date. Badges, streaks, and walk stats all live directly on the dog's profile screen — no separate tab needed. When a badge is earned, a full-screen celebration overlay appears (mirroring the match moment). Badge evaluation always happens asynchronously after the triggering action (walk ended, match formed, health event completed) — never blocking the main flow.

---

## Screens

1. **Badges & Stats section** — embedded on the Dog Profile View screen (not a separate screen)
2. **Badge Detail** — a modal or sheet showing a single badge's name, description, and earned date (or progress toward earning it)
3. **Badge Earned Overlay** — full-screen celebration shown when a new badge is unlocked

---

## Badges & Stats Section (on Dog Profile)

### Purpose
Give the owner a quick view of their dog's achievements and activity without leaving the profile.

### UI elements
- **Streak counter**: flame icon + number of consecutive days walked (e.g. "🔥 7-day streak")
- **Total distance**: cumulative km walked (e.g. "42.3 km total")
- **Badges strip**: horizontal scroll of earned badge icons (filled, coloured); unearned badges shown as greyed-out / locked
- **"See all badges" link**: expands to show all badges in a full-screen sheet grouped by category (Walking, Social, Health)
- Each badge icon tappable → opens Badge Detail sheet

### States
- **No walks yet / no badges**: streak shows "0 days", distance shows "0 km", badges strip shows all locked with a prompt "Start your first walk to earn badges!"
- **Some badges earned**: mix of earned (coloured) and locked (grey) badges in the strip
- **Loading**: skeleton for the section

---

## Badge Detail Sheet

### Purpose
Show what a badge is, how it's earned, and if not earned yet — show progress.

### UI elements
- Badge icon (large, colour or greyed)
- Badge name
- Description of the requirement (e.g. "Walk a cumulative total of 10 km with your dog")
- **If earned**: "Earned on [date]" label
- **If not earned**: progress indicator (e.g. "6.2 / 10 km" for distance badges; "2 / 5 matches" for social badges; "n/a" for one-off badges)

---

## Badge Earned Overlay

### Purpose
Celebrate a new badge with a moment of delight — mirrors the match celebration in impact.

### UI elements
- Full-screen overlay with blurred/dark background
- Large animated badge icon (scales in, sparkle animation)
- Badge name headline
- One-line description of what was achieved
- "Awesome!" dismiss button

### Trigger
- Appears immediately when the async badge evaluation completes and finds a new badge earned
- If multiple badges are earned from one action (e.g. a long walk earns both "10km Club" and "First Steps"), show them one after another
- If the owner is mid-action elsewhere in the app, the overlay queues and shows when they return to an idle screen

---

## Badge Catalogue

### Walking Badges

| Badge | Slug | Requirement | Progress trackable? |
|---|---|---|---|
| First Steps | `first_steps` | Complete first walk | No (binary) |
| 10km Club | `10km_club` | Cumulative 10 km walked | Yes |
| 50km Explorer | `50km_explorer` | Cumulative 50 km walked | Yes |
| 100km Champion | `100km_champion` | Cumulative 100 km walked | Yes |
| 500km Legend | `500km_legend` | Cumulative 500 km walked | Yes |
| Early Bird | `early_bird` | Complete a walk that starts before 07:00 | No (binary) |
| Night Owl | `night_owl` | Complete a walk that starts after 21:00 | No (binary) |

> **Rainy Day Walker** (walk in rain) is excluded from v1 — requires weather API integration. Add in v2.

### Social Badges

| Badge | Slug | Requirement | Progress trackable? |
|---|---|---|---|
| First Match | `first_match` | Get first mutual match | No (binary) |
| Growing Pack | `growing_pack` | 5 mutual matches | Yes |
| Social Butterfly | `social_butterfly` | 25 mutual matches | Yes |
| Pack Leader | `pack_leader` | 100 mutual matches | Yes |

> **Most Friendly** (most matches in city in a week) is a leaderboard badge — excluded from v1.

### Health Badges

| Badge | Slug | Requirement | Type |
|---|---|---|---|
| Health Champion | `health_champion` | All health events currently up to date (none overdue) | State — re-earnable |
| Vet Loyalist | `vet_loyalist` | 3 annual vet checkup events marked complete | Milestone |
| Zero Overdue | `zero_overdue` | No overdue health events for 12 consecutive months | Progress |
| Worm Free | `worm_free` | Deworming always current (no overdue deworming events) | State — re-earnable |
| Flea Fighter | `flea_fighter` | Flea & tick prevention always current | State — re-earnable |
| Heart Guard | `heart_guard` | Heartworm prevention always current | State — re-earnable |
| Fully Vaccinated | `fully_vaccinated` | All core vaccinations (DHPP, Rabies, Leptospirosis) currently up to date | State — re-earnable |
| Dental Star | `dental_star` | Dental cleaning currently up to date | State — re-earnable |
| Healthy Weight | `healthy_weight` | At least one weight entry logged in the past 30 days | State — re-earnable |

**State badges** (Worm Free, Flea Fighter, Heart Guard, Fully Vaccinated, Dental Star, Healthy Weight, Health Champion) follow the same rules as Health Champion: awarded when the condition is met, silently revoked when it lapses, and re-awarded when the owner catches up. No overlay is shown on revocation — only on earning.

---

## Streak Rules

- A **daily walk streak** counts consecutive calendar days on which at least one walk was completed and saved
- The streak increments at the end of a walk if the previous walk was completed within the last 36 hours
- If more than 36 hours pass between walks, the streak resets to 0 (not 1 — the next walk starts a new streak at 1)
- The streak counter shown on the profile is always up to date (checked against the last walk session timestamp at load time)
- Streak is per-dog — each dog tracks its own streak independently

---

## Walk Stats

Displayed in the Badges & Stats section on the Dog Profile:

| Stat | Description |
|---|---|
| Current streak | Consecutive days walked |
| Total distance | Lifetime cumulative km across all walk sessions |
| Total walks | Lifetime count of completed walk sessions |
| This week | Distance walked in the current calendar week (Mon–Sun) |
| This month | Distance walked in the current calendar month |

Stats are calculated by aggregating the dog's walk session documents. They are not pre-computed — calculated on profile load. If performance becomes an issue, a summary document can be maintained, but this is an implementation decision for the agent.

---

## User Flows

### Flow 1: Earn a walking badge during a walk
1. Owner ends a walk
2. Walk session saved to Firestore
3. Badge evaluation runs asynchronously: checks cumulative distance across all sessions
4. "10km Club" threshold crossed → badge earned
5. Owner is on the Walk Summary screen → overlay appears: large badge icon, "10km Club — You've walked 10 km with Luna!"
6. Owner taps "Awesome!" → overlay dismisses; returns to Walk Summary
7. Dog Profile's badge strip now shows the 10km Club badge in colour

### Flow 2: View all badges
1. Owner opens Dog Profile
2. Sees badge strip in the Badges & Stats section
3. Taps "See all badges"
4. Full sheet opens with badges grouped by category
5. Earned badges are coloured; locked badges are grey with a progress indicator
6. Taps a locked badge → Badge Detail sheet shows requirement + current progress

### Flow 3: Earn a social badge after a match
1. Mutual match occurs → Match Celebration overlay shown (Matching feature)
2. Badge evaluation runs in background → 5th match detected → "Growing Pack" earned
3. After the match celebration is dismissed, the Badge Earned overlay queues
4. When the owner reaches an idle screen (e.g. back on the Discover tab), the overlay appears

### Flow 4: Check streak on profile
1. Owner opens Dog Profile
2. Sees "🔥 5-day streak" in the Badges & Stats section
3. Owner hasn't walked today → streak shows 5; if they don't walk within 36 hours it will reset
4. Owner starts a walk → completes it → streak updates to 6

---

## Business Rules

- **Badge evaluation is always asynchronous** — triggered after a walk is saved, a match is formed, or a health event is marked complete; never in the synchronous request path
- **Badges are per-dog**, not per-owner account. Each dog earns its own badges independently.
- **Most badges are earned once** (permanent milestones). **State badges** are the exception — they can be earned, lost, and re-earned:
  - **Health Champion**: all health events up to date; revoked when any event becomes overdue
  - **Worm Free**: deworming event current; revoked when overdue
  - **Flea Fighter**: flea & tick event current; revoked when overdue
  - **Heart Guard**: heartworm event current; revoked when overdue
  - **Fully Vaccinated**: DHPP, Rabies, and Leptospirosis all current; revoked when any of the three becomes overdue
  - **Dental Star**: dental cleaning event current; revoked when overdue
  - **Healthy Weight**: a weight entry exists within the past 30 days; revoked when 30 days pass with no new entry
- **Zero Overdue badge**: tracks a 12-month window. If any event becomes overdue during the window, the counter resets. Progress = months since last overdue event.
- **Cumulative distance** for walking badges counts only sessions where `endedAt` is set (completed walks) and `distanceKm > 0`
- **Streak reset threshold**: 36 hours (not midnight-to-midnight) to accommodate owners who walk at different times each day
- **Multiple badges from one action**: all are awarded, shown as sequential overlays

---

## Data (Firestore)

Badge definitions are stored as a static collection (seeded by the team, not user-generated):

```
badges/{badgeSlug}
  name: string
  category: "walking" | "social" | "health"
  description: string
  requirementDescription: string   // human-readable, shown in Badge Detail
  progressMax: number | null        // null for binary badges
```

Earned badges are stored per dog:

```
users/{userId}/dogs/{dogId}/earnedBadges/{badgeSlug}
  earnedAt: timestamp
  isActive: boolean    // false only for Health Champion when revoked
```

Walk stats are derived from walk sessions (no separate aggregation document in v1):

```
users/{userId}/dogs/{dogId}/walkSessions/{sessionId}
  // same as defined in Live Walk Map feature
  startedAt: timestamp
  endedAt: timestamp
  distanceKm: number
```

**Reads:** Dog Profile (earned badges + walk session aggregation for stats), Badge Detail (badge definition doc + earned badge doc)
**Writes:** Badge evaluation function (earnedBadges doc on unlock, isActive update for Health Champion)
**Deletes:** Dog deletion (all earnedBadges deleted with the dog)

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Owner earns a badge while the app is closed | Badge is written to Firestore by the Cloud Function; overlay shows the next time the owner opens the app and reaches an idle screen |
| Health Champion earned then immediately lost (event becomes overdue same day) | Badge is revoked (`isActive = false`); overlay does not appear for the revocation — badge silently disappears from the strip |
| Walk session saved with 0 km (owner ended immediately) | Session is discarded — does not count toward any badge or streak |
| Owner completes a walk but GPS was unavailable (0 km logged) | Same as above — discarded walk |
| Cumulative distance crosses multiple thresholds in one walk (e.g. goes from 8 km to 55 km total in one very long walk) | All crossed thresholds evaluated: both "10km Club" and "50km Explorer" awarded; shown as two sequential overlays |
| Badge evaluation Cloud Function fails | Silently retried up to 3 times; badge may appear slightly delayed; no user-facing error |
| Dog profile is deleted | All earned badges deleted with the dog — no orphaned records |

---

## Out of Scope

- Leaderboards (friends / neighbourhood / city) — v2.0
- Rainy Day Walker badge (requires weather API) — v2.0
- Most Friendly badge (city-weekly leaderboard) — v2.0
- Sharing badges to social media — not in v1
- Weekly or monthly distance summary cards (shareable) — not in v1
