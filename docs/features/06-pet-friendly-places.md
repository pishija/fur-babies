# Feature: Pet-Friendly Places

## Overview

Pet-Friendly Places lets owners discover dog-welcoming venues near them — cafes, vets, parks, grooming salons, off-leash zones, and more. The place database is **team-curated**: the FurBabies team manages and maintains the list of places. Users can suggest a place via a simple form, which is reviewed by the team before being added. Places appear as pins on the Map tab and in a swipeable bottom sheet list beneath the map. Tapping a pin or list row opens the Place Detail screen. Owners can write reviews that show their dog's breed, giving other owners useful size and temperament context.

---

## Screens

1. **Places Bottom Sheet** — swipeable list of nearby places, lives beneath the map on the Map tab
2. **Place Detail** — full information, amenities, and reviews for a single place
3. **Write a Review** — form to submit a star rating, text, and optional photo
4. **Suggest a Place** — form for users to suggest a missing venue to the FurBabies team

---

## Places Bottom Sheet

### Purpose
Let owners browse nearby places without leaving the map view. Complements the map pins.

### UI elements
- A bottom sheet anchored below the map, draggable between three states:
  - **Collapsed** (peek): shows only a drag handle and the top ~1 row
  - **Half-expanded** (default): shows ~4–5 rows of the list
  - **Full-expanded**: sheet fills most of the screen; map shrinks to a small strip or is hidden
- **Search bar** at the top of the sheet: search places by name
- **Filter chips** below the search bar (horizontal scroll): category shortcuts (All, Vets, Cafes, Parks, Off-Leash, Grooming…) — synced with the map layer category toggles
- **Place list**: each row shows:
  - Category icon
  - Place name
  - Category label
  - Star rating (e.g. ★ 4.2) and review count
  - Distance ("320 m away")
  - Key amenity tags as small chips (e.g. "Off-leash", "Water bowl")
- **"Suggest a Place" button** at the bottom of the list

### States
- **Loading**: skeleton rows
- **Empty** (no places in area): "No places in this area yet." + Suggest a Place button
- **Populated**: list sorted by distance
- **Search active**: filtered by search term; "No results" state if nothing matches

### Interaction with the map
- Tapping a place row highlights the corresponding pin on the map and centres the map on it
- Tapping a map pin highlights the corresponding row in the sheet (scrolls to it)
- Filtering by category hides/shows pins on the map simultaneously

---

## Place Detail

### Purpose
Show everything about a specific place so the owner can decide if it's right for their dog.

### UI elements
- **Header**: place name, category, distance
- **Star rating summary**: large average rating + total review count
- **Amenity tags**: chips for each applicable tag:
  - Outdoor seating
  - Water bowl provided
  - Off-leash zone
  - Indoor dogs allowed
  - Large dogs welcome
- **Photo strip**: horizontal scroll of photos from user reviews
- **Map snippet**: small static map showing the place pin + an "Open in Maps" button (opens Apple Maps)
- **Reviews section**: list of reviews
- **"Write a Review" button**
- **"Report incorrect info" button** → small form (issue type + optional note) sent to the team

### Review row design
- Star rating (1–5 stars)
- Reviewer's dog breed (e.g. "Labrador owner")
- Review text
- Optional photo thumbnail
- Date posted

### States
- **Loading**: skeleton
- **Populated**: full detail
- **No reviews yet**: "No reviews yet — be the first!" + Write a Review button

---

## Write a Review

### Purpose
Let an owner share their experience at a place, with their dog's breed shown for context.

### Form fields
| Field | Required | Notes |
|---|---|---|
| Star rating | Yes | 1–5 stars, tap to select |
| Review text | No | Max 500 characters |
| Photo | No | One photo per review; from camera or library |

### Business rules
- One review per dog per place (each dog the owner manages can review independently)
- The reviewer's **active dog's breed** is shown automatically — the owner does not choose it
- Breed is snapshotted at review time and does not change if the dog profile is later edited
- Reviews cannot be edited after submission; the owner can delete their own review
- A star-rating-only review (no text, no photo) is allowed

### States
- **Idle**: empty form
- **Submitting**: button spinner
- **Success**: returns to Place Detail with the new review at the top
- **Error**: toast for network failure; form preserved

---

## Suggest a Place

### Purpose
Let users flag a missing venue to the FurBabies team for review and addition.

### Form fields
| Field | Required | Notes |
|---|---|---|
| Place name | Yes | Max 100 characters |
| Category | Yes | Picker from the standard category list |
| Address or location hint | Yes | Free text (street address, Google Maps link, or description) |
| Amenity tags | No | Multi-select from the standard tag list |
| Notes | No | Any extra info for the team, max 300 characters |

### Business rules
- Suggestions go into a review queue visible only to the FurBabies team
- The suggesting user is **not** shown in the app as the submitter — this is an internal team queue
- The user receives no in-app notification when/if the place is added — suggestions are best-effort
- The suggestion form is not a guarantee of addition; the team decides what to include

### States
- **Idle**: empty form
- **Submitting**: spinner
- **Success**: "Thanks for the suggestion! We'll review it and add it if it's a good fit."
- **Error**: toast for network failure

---

## User Flows

### Flow 1: Discover a nearby vet
1. Owner opens Map tab
2. Vet pin visible on map (Vets layer on)
3. Taps pin → popup with name, rating, distance
4. Taps popup → Place Detail opens
5. Reads reviews, sees "Large dogs welcome" tag
6. Taps "Open in Maps" → Apple Maps opens with directions

### Flow 2: Browse places from the list
1. Owner drags bottom sheet up
2. Taps "Parks" chip → list and map filter to parks only
3. Taps a row → map centres on pin; Place Detail opens

### Flow 3: Write a review
1. Owner opens Place Detail for a cafe they visited
2. Taps "Write a Review"
3. Selects 4 stars, writes a short note, attaches a photo
4. Taps Submit → review appears with "Border Collie owner" label

### Flow 4: Suggest a missing place
1. Owner notices a dog-friendly beach isn't listed
2. Taps "Suggest a Place" at the bottom of the sheet
3. Fills in name, category (Dog Beach), address
4. Taps Submit → success message shown
5. FurBabies team receives the suggestion in their queue and adds it if appropriate

### Flow 5: Report incorrect info
1. Owner sees a place with a wrong address
2. Opens Place Detail → taps "Report incorrect info"
3. Selects "Wrong address", optionally adds a note
4. Submits → report sent to the team

---

## Business Rules

- **Place database is team-managed**: only the FurBabies team can add or remove places from the live database
- **Sorting**: by distance by default
- **Distance display**: metres (< 1 km) or kilometres (≥ 1 km)
- **Category filter chips** are synced with the Map tab layer toggles
- **Place photos** are aggregated from review photos — there is no separate team-uploaded photo per place in v1
- **Review deletion**: owner can delete their own review; average rating recalculates immediately
- **One review per dog per place**: enforced in Firestore

---

## Data (Firestore)

```
places/{placeId}
  name: string
  category: string          // "vet" | "cafe" | "restaurant" | "bar" | "park" | "beach" | "off_leash" | "pet_shop" | "grooming" | "hotel" | "hiking"
  lat: number
  lng: number
  amenityTags: string[]     // "outdoor_seating" | "water_bowl" | "off_leash" | "indoor_allowed" | "large_dogs"
  description: string
  averageRating: number     // updated on each review write/delete
  reviewCount: number
  createdAt: timestamp      // set by team when adding the place

places/{placeId}/reviews/{reviewId}
  dogId: string
  dogBreed: string          // snapshotted at review time
  rating: number            // 1–5
  text: string
  photoUrl: string | null
  createdAt: timestamp

placeSuggestions/{suggestionId}    // internal team queue, not user-facing
  suggestedByUserId: string
  name: string
  category: string
  locationHint: string
  amenityTags: string[]
  notes: string
  createdAt: timestamp

placeReports/{reportId}
  reportedByUserId: string
  placeId: string
  issueType: string
  note: string
  createdAt: timestamp
```

**Reads:** Bottom sheet list (geo query on places), Place Detail (place doc + reviews)
**Writes:** Write a Review (review doc + update averageRating + reviewCount), Suggest a Place (suggestion doc), Report (report doc)
**Deletes:** Review deletion (review doc removed, averageRating + reviewCount updated)

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Place has no reviews yet | Shows "No ratings yet" — not 0 stars |
| Owner has 2 dogs — which breed on a review? | The active dog at time of writing; snapshotted, does not change |
| Place has 50+ reviews | Paginated (20 per page); load more on scroll |
| Owner taps "Open in Maps" with no Apple Maps | Falls back to opening coordinates in Safari |
| User deletes their account | Their reviews remain but show "Deleted user" |

---

## Out of Scope

- Self-service place submission that goes live automatically — team review required for all additions
- Community confirmation / voting system — removed
- "Currently open" from live API — not in v1
- Saved place lists and friend sharing — v2.0
- Moderation UI for the team — managed outside the app (e.g. Firebase console or a future admin panel)
