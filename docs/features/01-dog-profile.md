# Feature: Dog Profile

## Overview

The dog profile is the central entity of the entire app. Every other feature — the AI friend, health calendar, matching, walk map, gamification — reads from and writes to this profile. It acts as a living health passport for each dog. An owner can manage multiple dog profiles under one account. The profile is created during onboarding and can be edited at any time.

---

## Screens

1. **Onboarding** — welcome + feature highlights shown on first launch only
2. **Create Dog Profile** — step-by-step form to add a new dog
3. **Dog Profile View** — the main profile page for the active dog
4. **Edit Dog Profile** — same form as create, pre-filled, for updating details
5. **Photo Gallery** — manage all photos for the active dog
6. **Document Vault** — manage uploaded health and identity documents

The **dog switcher** is a persistent UI component (avatar row at the top of the home screen), not a standalone screen.

---

## Onboarding

### Purpose
Introduce the app to a first-time user before they create their dog profile. Shown once, never again after a dog has been created.

### Screens in sequence
1. **Welcome** — App name, tagline, hero image
2. **Feature highlight 1** — AI friend (breed-aware companion)
3. **Feature highlight 2** — Health calendar + reminders
4. **Feature highlight 3** — Dog matching + community
5. **CTA** — "Add your first dog" button → navigates to Create Dog Profile

### States
- Only shown when the authenticated user has zero dog profiles
- Skip button available on highlights (goes straight to CTA screen)
- Back navigation allowed between highlight screens

---

## Create Dog Profile

### Purpose
Collect the dog's identity information and create the profile. On save, the AI friend is automatically created in the background.

### Required fields
| Field | Type | Validation |
|---|---|---|
| Name | Text | Non-empty, max 50 characters |
| Breed | Text | Non-empty, autocomplete suggestions from a breed list, free-text allowed |
| Sex | Toggle | Male / Female — must be selected |
| Birthday | Date picker | Must be in the past, max 30 years ago |
| Weight | Decimal (kg) | Must be between 0.1 and 200 |

### Optional fields (can be filled later in Edit)
| Field | Type | Notes |
|---|---|---|
| Size class | Enum | Auto-suggested from weight (see business rules), owner can override |
| Coat colour | Text | Free text |
| Microchip number | Text | Free text |
| Neutered | Boolean toggle | Defaults to false |
| Temperament tags | Multi-select | Friendly, Playful, Calm, Protective, Trained, Good with kids, Good with dogs, Anxious |
| Is public | Boolean toggle | Defaults to true — controls matching + map visibility |
| Profile photo | Image | Optional at creation, prompted again on first view |

### UI elements
- Progress indicator at top (step X of Y) if split across multiple steps
- "Save" / "Create Profile" CTA button — disabled until all required fields are valid
- Breed field shows a searchable dropdown with common breeds; if no match, accepts free text
- Birthday shown as a date wheel picker
- Weight shown with a kg label and a numeric keyboard

### States
- **Idle** — form ready to fill
- **Saving** — spinner on the Save button, form inputs disabled
- **Error** — inline error messages per field (e.g. "Birthday can't be in the future"), toast for network errors
- **Success** — navigates to Dog Profile View; AI friend creation runs in the background silently

### User actions
- Fill required fields
- Optionally fill additional fields
- Tap Save → profile created, AI friend auto-generated

---

## Dog Profile View

### Purpose
The main overview page for the active dog. Entry point for all dog-specific features.

### UI elements
- **Header**: Profile photo (or placeholder avatar), dog's name, breed, age (calculated from birthday)
- **Quick stats row**: Weight, size class, sex, neutered status
- **Photo gallery strip**: Horizontal scroll of photos, tap to open full gallery
- **Temperament tags**: Displayed as pills/chips
- **Document vault section**: Count of uploaded documents, tap to open vault
- **Health status summary**: Quick view of upcoming/overdue health events (links to Health Calendar feature)
- **Privacy badge**: Shows current visibility (Public / Friends only / Private)
- **Edit button**: Opens Edit Dog Profile
- **Delete dog option**: Accessible via a "..." menu or settings icon

### States
- **Loading**: skeleton placeholders for photo strip, stats row
- **Populated**: full profile displayed
- **No photo**: placeholder avatar shown with a soft "Add a photo" prompt (non-blocking)
- **Error loading**: "Couldn't load profile" message with retry button

### User actions
- Tap profile photo → opens Photo Gallery
- Tap a photo in the strip → opens Photo Gallery at that photo
- Tap Edit → opens Edit Dog Profile
- Tap Health summary → navigates to Health Calendar
- Tap Document vault → opens Document Vault
- Tap "..." → contextual menu with Delete option

---

## Edit Dog Profile

### Purpose
Update any field on an existing dog profile.

### Behaviour
- Same form as Create Dog Profile, pre-filled with current values
- All required fields remain required
- Saving updates the Firestore document immediately
- Changes to weight do NOT automatically log a weight history entry (weight history is logged separately in the Health Calendar feature)

### States
- Same as Create Dog Profile (idle / saving / error / success)
- Success: returns to Dog Profile View with updated values

---

## Photo Gallery

### Purpose
Manage all photos for a dog. Photos appear on the matching card, public profile, and walk map pin.

### UI elements
- Grid of all photos (3-column)
- Primary photo marked with a star badge
- Add photo button (always visible, e.g. "+" tile in the grid)
- Long-press or edit mode to reorder, set as primary, or delete

### Business rules
- Maximum 10 photos per dog
- The primary photo is shown everywhere (matching card, map pin, profile header)
- If no primary is explicitly set, the first uploaded photo is used
- Deleting the current primary photo: the next photo in sort order becomes primary automatically
- Photos are stored in Firebase Storage

### States
- **Empty**: "Add your first photo" illustration + add button
- **Loading**: skeleton grid
- **Populated**: photo grid with edit/reorder controls
- **At limit (10 photos)**: Add button is hidden; a message explains the limit

### User actions
- Tap "+" → opens system image picker (camera or library)
- Tap a photo → full-screen preview
- Long-press → enter edit mode (reorder handles, delete button, set-as-primary option)
- Set as primary → star moves to selected photo

---

## Document Vault

### Purpose
Store official documents tied to the dog — vaccination cards, pedigree, insurance, vet letters, etc.

### Supported document types
- Vaccination card
- Pedigree certificate
- Insurance policy
- Vet letter
- Breed registration
- Import / export papers

### UI elements
- List of uploaded documents, grouped by type
- Each row: document type icon, document name, upload date, delete button
- "Upload document" button at the top or bottom

### Business rules
- Documents are uploaded as PDFs or images (JPEG/PNG)
- Maximum file size: 20 MB per document
- No limit on number of documents
- Documents stored in Firebase Storage under the dog's path
- Document names default to the type name + upload date (e.g. "Vaccination Card – 12 Apr 2026")

### States
- **Empty**: "No documents yet" illustration + upload button
- **Loading**: list skeleton
- **Populated**: grouped document list
- **Uploading**: progress indicator on the new row while uploading
- **Error uploading**: inline error on the failed row with a retry option

### User actions
- Tap "Upload document" → select type from a sheet, then pick file from Files app or Photos
- Tap a document row → opens the document in a full-screen viewer (PDF viewer or image)
- Tap delete on a row → confirmation alert → document removed from Firestore + Storage

---

## Dog Switcher (Component)

### Purpose
Let owners with multiple dogs switch the active dog without leaving the current screen.

### Behaviour
- Displayed as a horizontal row of small circular avatars at the top of the home/tab bar area
- The active dog's avatar is highlighted (ring or larger size)
- A "+" avatar at the end of the row opens Create Dog Profile
- Tapping a different avatar switches the active dog — all screens reload data for the new dog
- Maximum display: shows up to 5 avatars; if more than 5, shows "..." which opens a list

### States
- **Single dog**: switcher is hidden (no need to switch)
- **Multiple dogs**: switcher visible at the top

---

## User Flows

### Flow 1: First launch — create first dog
1. App opens → user is authenticated (auth handled separately)
2. No dogs exist → Onboarding screen 1 shown
3. User pages through highlights (or skips)
4. Taps "Add your first dog"
5. Create Dog Profile form opens
6. User fills required fields (name, breed, sex, birthday, weight)
7. Taps Save
8. Profile created in Firestore; AI friend auto-created in background
9. App navigates to Dog Profile View for the new dog

### Flow 2: Add a second dog
1. User taps "+" in the dog switcher
2. Create Dog Profile form opens
3. User fills required fields and saves
4. New dog appears in switcher; becomes the active dog

### Flow 3: Switch active dog
1. User taps a different avatar in the dog switcher
2. Active dog changes instantly
3. All screens now show data for the newly selected dog

### Flow 4: Edit dog profile
1. User opens Dog Profile View
2. Taps Edit
3. Edit form opens pre-filled
4. User changes one or more fields
5. Taps Save → changes written to Firestore
6. Returns to Dog Profile View with updated data

### Flow 5: Add a photo
1. User opens Photo Gallery (from profile photo or gallery strip)
2. Taps "+" tile
3. System image picker opens
4. User selects a photo
5. Photo uploads to Firebase Storage; appears in grid on completion

### Flow 6: Set profile photo
1. User long-presses a photo in the gallery → edit mode
2. Taps "Set as profile photo"
3. Star badge moves to that photo; header on Dog Profile View updates

### Flow 7: Upload a document
1. User opens Document Vault
2. Taps "Upload document"
3. Sheet appears asking for document type
4. User selects type, then picks a file
5. File uploads; appears in the list under its type group

### Flow 8: Delete a dog
1. User taps "..." on Dog Profile View → "Delete [dog name]"
2. Alert: "This will permanently delete [dog name] and all their data including health records, matches, and walk history. This cannot be undone." with Cancel / Delete buttons
3. User confirms → dog deleted from Firestore, all subcollections removed, Storage files deleted
4. If this was the last dog: app returns to Onboarding (empty state)
5. If other dogs exist: switcher removes this avatar; next dog becomes active

---

## Business Rules

- **Size class auto-suggestion from weight:**
  - Toy: < 4 kg
  - Small: 4–10 kg
  - Medium: 10–25 kg
  - Large: 25–45 kg
  - Giant: > 45 kg
  - Owner can always override the suggestion manually

- **Age calculation**: Displayed as "X years" or "X months" (use months when under 1 year)

- **Breed field**: Backed by a static list of ~200 common breeds for autocomplete. If the user's breed isn't in the list, any free text is accepted.

- **Neutered field default**: false. If dog sex is Male, the label reads "Neutered". If Female, the label reads "Spayed".

- **Is public default**: true. Setting to false hides the dog from matching candidates, the live walk map, and place reviews (their posts still exist but won't show their dog).

- **Weight edits do not create weight log entries.** Weight history is a separate log in the Health Calendar feature.

- **AI friend creation**: Triggered automatically when a dog profile is saved for the first time. It runs server-side (Firebase Cloud Function) and does not block the UI. If it fails, it retries silently — the user is not shown an error.

---

## Data (Firestore)

```
users/{userId}/dogs/{dogId}
  name: string
  breed: string
  sex: "male" | "female"
  birthday: timestamp
  weightKg: number
  sizeClass: "toy" | "small" | "medium" | "large" | "giant"
  coatColour: string
  microchip: string
  isNeutered: boolean
  isPublic: boolean
  temperamentTags: string[]
  primaryPhotoUrl: string
  createdAt: timestamp
  updatedAt: timestamp

users/{userId}/dogs/{dogId}/photos/{photoId}
  url: string
  isPrimary: boolean
  sortOrder: number
  uploadedAt: timestamp

users/{userId}/dogs/{dogId}/documents/{documentId}
  type: "vaccination_card" | "pedigree" | "insurance" | "vet_letter" | "breed_registration" | "import_export"
  fileUrl: string
  name: string
  uploadedAt: timestamp
```

**Reads:** Dog Profile View, Edit form, Dog Switcher, all other features
**Writes:** Create form (new doc), Edit form (update doc), Photo Gallery (photos subcollection), Document Vault (documents subcollection)
**Deletes:** Delete dog flow (dog doc + all subcollections + Storage files)

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| User closes the app mid-onboarding | Onboarding resumes from the beginning next launch (no progress saved) |
| User closes the Create form without saving | Form is discarded, no partial data saved |
| Network drops during profile save | Error toast shown, form stays open, user can retry |
| User uploads a photo > 10 MB | Warning shown before upload: "This photo is large and may take a while" — upload still allowed |
| User tries to add an 11th photo | Add button hidden when 10 photos exist; message explains the limit |
| File upload fails (document) | Inline retry button on the failed row |
| User deletes the only dog | Returns to Onboarding state; AI friend, health events, matches etc. are all deleted with the dog |
| Two dogs have the same name | Allowed — no uniqueness requirement on dog names |
| Breed autocomplete has no match | Free text accepted as-is |
| Birthday entered as today | Validation error: "Birthday must be in the past" |

---

## Out of Scope

- Authentication (sign in / sign up) — separate feature
- Weight history logging — handled in Health Calendar feature
- AI friend chat — handled in AI Friend feature
- Health calendar events — handled in Health Calendar feature
- Matching visibility logic — handled in Dog Matching feature
- Walk map visibility logic — handled in Live Walk Map feature
