# FurBabies — Agent Instructions

You are building **FurBabies**, an iOS companion app for dog owners. Read this file fully before writing any code. Every feature has its own detailed spec in `docs/features/` — always read the relevant feature doc before implementing anything.

---

## What this app is

FurBabies is an iOS-only application that serves as a complete digital companion for dog owners. It combines:
- A living health passport for each dog
- A breed-aware AI virtual friend
- Tinder-style dog matching and owner messaging
- A live GPS walk map with pet-friendly place discovery
- Health calendar with smart reminders
- Gamification (badges, streaks)
- Community events and professional dog show directory

**Core principle:** Every feature is personalised to the specific dog — breed, age, weight, sex, health history. Nothing is generic.

---

## Tech stack

| Layer | Technology |
|---|---|
| iOS app | Swift 5.9+, SwiftUI |
| Maps | MapKit, CoreLocation, CoreMotion |
| Local persistence | SwiftData |
| Current backend | Firebase (Firestore, Auth, Storage, Cloud Functions) |
| Real-time | Firestore real-time listeners |
| AI | Anthropic Claude API (via Cloud Function) |
| Push notifications | Firebase Cloud Messaging (FCM) → APNS |
| Media storage | Firebase Storage |

### Firebase is temporary

**Firebase is the current data layer implementation — not a permanent dependency.**

The entire network and persistence layer is abstracted behind Repository Protocols defined in the Domain layer. Firebase repositories are one set of implementations of those protocols. In the future the backend can be replaced (e.g. with a custom REST API) by writing new repository implementations without touching a single line of Domain or Presentation code.

**Rules that enforce this:**
- Never import Firebase in a ViewModel, Use Case, or Entity
- Never import Firebase in the Presentation layer at all
- All Firebase-specific code lives exclusively in `Data/Repositories/Firebase/`
- ViewModels call Use Cases; Use Cases call Repository Protocols; the protocol implementation decides whether that means a Firestore call, a REST call, or a local cache read

---

## App navigation

The app has **5 tabs** in the tab bar:

| Tab | Contents |
|---|---|
| **Profile** | Dog profile, photo gallery, document vault, health calendar, badges & stats |
| **AI Friend** | Virtual AI friend chat for the active dog |
| **Map** | Live walk map + pet-friendly places (layered on the same map) |
| **Social** | Discover (matching), Matches & conversations, Events, Exhibitions |
| **Me** | Owner account, settings, privacy controls |

The **dog switcher** (avatar row) is persistent at the top of the Profile tab and visible whenever switching context is relevant. The active dog determines the data shown across all tabs.

---

## Project structure (to be created)

Follows Clean Architecture. See `docs/ios-architecture.md` for the full architecture spec.

```
FurBabies/
├── App/
│   └── FurBabiesApp.swift
│
├── Features/                      # One folder per feature
│   └── DogProfile/
│       ├── Presentation/
│       │   ├── Views/             # SwiftUI views — no business logic
│       │   └── ViewModels/        # ObservableObject, @Published state
│       ├── Domain/
│       │   ├── Entities/          # Pure Swift value types — no frameworks
│       │   ├── UseCases/          # Single-responsibility business operations
│       │   └── Protocols/         # Repository protocols (the contracts)
│       └── Data/
│           └── Repositories/      # Implementations of domain protocols
│               └── Firebase/      # Current Firebase implementation
│
│   (same structure for AIFriend, HealthCalendar, Matching,
│    WalkMap, Places, Gamification, Events, Exhibitions)
│
├── Core/
│   ├── ActiveDog/                 # ActiveDogStore — shared active dog state
│   ├── DI/                        # Dependency injection container
│   └── Extensions/                # Swift + SwiftUI extensions
│
├── Shared/
│   ├── Components/                # Reusable SwiftUI components
│   └── Theme/                     # Colours, typography, spacing constants
│
└── Resources/
    └── Assets.xcassets
```

**New backend, zero refactoring:** to swap Firebase for a REST API on any feature, add a `REST/` folder alongside `Firebase/` inside that feature's `Data/Repositories/`, implement the same protocol, and swap the injection. No other files change.

---

## Architecture pattern

**Clean Architecture + MVVM + Unidirectional Data Flow.** Full spec in `docs/ios-architecture.md`.
**Navigation system** — full spec in `docs/navigation.md`.

```
View → ViewModel → Use Case → Repository Protocol ← (Firebase impl | REST impl | Local impl)
```

### Layers

| Layer | Contents | Rule |
|---|---|---|
| **Presentation** | SwiftUI Views, ViewModels | No business logic. No Firebase imports. State flows down, events flow up. |
| **Domain** | Entities, Use Cases, Repository Protocols | Pure Swift. Zero dependencies on frameworks or outer layers. This is the stable core. |
| **Data** | Repository implementations, data sources | Only layer that imports Firebase / URLSession / SwiftData. Implements Domain protocols. Maps DTOs ↔ Entities. |

### Key rules
- **Domain depends on nothing.** Entities and Use Cases are plain Swift structs and classes.
- **Repository Protocols live in Domain.** The Data layer implements them. This is what makes the backend swappable.
- **ViewModels call Use Cases, never repositories directly.**
- **Firebase imports are banned outside `Data/Repositories/Firebase/`.**
- Use `async/await` for sequential operations. Use `Combine` only for multi-stream reactive work (e.g. live chat listeners).
- All ViewModel updates happen on `@MainActor`.

---

## Navigation

FurBabies uses a custom type-safe router — **never use `NavigationLink` or SwiftUI's native navigation directly**. All navigation goes through `AppRouter`. Full spec and patterns in `docs/navigation.md`.

### URL scheme
```
furbabies://[route-path]?[params]
```

### How to navigate

```swift
// Push a screen onto the stack
router.push(DogProfileRoute(dogId: "abc"))

// Present a modal sheet
router.present(CreateDogRoute())

// Present a modal and wait for a result
let result = await router.presentForResult(HealthEventRoute(), expecting: HealthEventResult.self)

// Deep link / push notification tap
router.open(URL(string: "furbabies://dog-profile?dogId=abc")!)
```

### Route requirements

Protected routes declare their requirements in their `RouteRegistry`. Two requirement types apply across FurBabies:

| Requirement | When triggered |
|---|---|
| `RequiresAuth` | Any route that needs a logged-in user — applied to all main tab routes |
| `RequiresOnboarding` | Routes that need at least one dog profile — applied to all feature routes |

If requirements are not met, `AppRouter` silently blocks navigation and the auth / onboarding flow is shown instead.

### One registry per feature

Each feature defines its own `RouteRegistry` and registers its routes there. The `AppRouteRegistry` composes them all:

```swift
AppRouteRegistry(registries: [
    AuthRouteRegistry(),
    DogProfileRouteRegistry(),
    AIFriendRouteRegistry(),
    HealthCalendarRouteRegistry(),
    MatchingRouteRegistry(),
    WalkMapRouteRegistry(),
    PlacesRouteRegistry(),
    GamificationRouteRegistry(),
    EventsRouteRegistry(),
    ExhibitionsRouteRegistry(),
])
```

### Route file location

Routes, registries, and route result types for each feature live in:
```
Features/{FeatureName}/Presentation/Navigation/
```

### AppView states

The root `AppView` switches on `AppViewModel.applicationState`:
- `.initializing` → splash screen
- `.unauthenticated` → onboarding + auth screens (no router active)
- `.authenticated` → `NavigationStack` with tab bar as root + `.sheet` for modals

---

## Firebase / Firestore conventions

- All Firestore document IDs are auto-generated unless specified otherwise in the feature doc.
- Timestamps are stored as Firestore `Timestamp`, decoded as Swift `Date`.
- Use Firestore's `@DocumentID` property wrapper for document IDs in models.
- Never fetch entire collections — always scope queries to the active user (`users/{userId}/...`).
- Real-time listeners (`addSnapshotListener`) are used for chat messages and live walk pins. Everything else uses one-time `getDocument` / `getDocuments` fetches.
- Firestore security rules are not defined here — assume authenticated users can only read/write their own data.

### Top-level collections

```
users/                    owner accounts
users/{uid}/dogs/         dog profiles (central entity)
users/{uid}/dogs/{id}/photos/
users/{uid}/dogs/{id}/documents/
users/{uid}/dogs/{id}/healthEvents/
users/{uid}/dogs/{id}/healthReminders/
users/{uid}/dogs/{id}/weightLogs/
users/{uid}/dogs/{id}/heatCycles/
users/{uid}/dogs/{id}/virtualFriend/{id}/messages/
users/{uid}/dogs/{id}/earnedBadges/
users/{uid}/dogs/{id}/walkSessions/
users/{uid}/watchlist/    saved exhibitions (per user, not per dog)
matches/                  mutual match records
matches/{id}/messages/    owner-to-owner conversation
swipes/                   like / pass records
blocks/                   blocked dog records
places/                   team-curated pet-friendly venues
places/{id}/reviews/
placeSuggestions/         user suggestions (internal queue)
placeReports/
events/                   community events (pending + approved)
events/{id}/rsvps/
eventReports/
exhibitions/              team-curated show directory
badges/                   badge definitions (static, seeded by team)
liveWalks/                ephemeral live GPS records (Firebase Realtime Database, not Firestore)
```

---

## Key design rules

1. **The dog is the central entity.** Almost everything belongs to a dog, not a user. When in doubt, scope data to `users/{uid}/dogs/{dogId}/`.

2. **Active dog context.** The app always has one "active dog" selected. ViewModels read the active dog ID from a shared `ActiveDogStore` (a singleton `ObservableObject`). Never hardcode a dog ID.

3. **No passive location sharing.** The owner must explicitly confirm before their location is shared. Live GPS data lives in Firebase Realtime Database with a 15-minute TTL and is fuzzed ~50m before being written.

4. **Badge evaluation is always async.** Never check badge conditions in the request path. Trigger a Cloud Function after walk sessions end, matches form, or health events complete.

5. **AI context is always rebuilt at call time.** The virtual friend's system prompt is assembled fresh on every message send — it reads the dog's live profile + last 5 health events + upcoming reminders within 30 days. Never cache or store the assembled context.

6. **State badges can be revoked silently.** Health Champion, Worm Free, Flea Fighter, Heart Guard, Fully Vaccinated, Dental Star, and Healthy Weight are revoked without showing the user a notification when the condition lapses.

7. **Team-curated content.** Places and Exhibitions are maintained by the FurBabies team. Do not build self-service publish flows for these — only suggestion/report forms that feed an internal queue.

---

## Coding conventions

- **No comments** unless the logic would genuinely surprise a reader. Name things clearly instead.
- **No force unwraps** (`!`). Use `guard let`, `if let`, or `??`.
- **Errors are always surfaced to the user** via a `@Published var errorMessage: String?` on the ViewModel, shown as a toast or alert in the View.
- **Loading states** are always represented by a `@Published var isLoading: Bool` on the ViewModel.
- **Strings are not hardcoded** in views — use a `Strings` enum or constant file (implementation detail: keep it simple, no localisation system needed in v1).
- **Colours and fonts** come from the `Theme` constants — never use raw hex values in views.
- **SwiftUI previews** are written for every View component.

---

## Feature documentation

Read the relevant doc before building any feature. Each doc defines screens, user flows, business rules, data shape, and edge cases.

| Feature | Doc |
|---|---|
| Authentication | `docs/features/00-auth.md` |
| Dog Profile + Onboarding | `docs/features/01-dog-profile.md` |
| Virtual AI Friend | `docs/features/02-ai-friend.md` |
| Health Calendars | `docs/features/03-health-calendars.md` |
| Dog Matching | `docs/features/04-dog-matching.md` |
| Live Walk Map | `docs/features/05-live-walk-map.md` |
| Pet-Friendly Places | `docs/features/06-pet-friendly-places.md` |
| Gamification | `docs/features/07-gamification.md` |
| Events | `docs/features/08-events.md` |
| Exhibitions | `docs/features/09-exhibitions.md` |
| Me / Owner Account | `docs/features/10-me-owner.md` |
| Push Notifications | `docs/features/11-notifications.md` |

The product overview and build priorities (Day 1 core → v1.0 → v2.0) are in `FurBabies_Specification.md`.

---

## Day 1 build priorities

Build these first — nothing else works without them:

1. Firebase project setup + Auth
2. Dog profile creation and viewing
3. Onboarding flow (first launch)
4. Virtual AI friend creation and chat
5. Health calendar (core event types + escalating reminders)
6. Walk tracking (distance + route)
7. Live walk map (browse + walk mode)
8. Swipe matching with mutual match detection
9. Owner-to-owner conversation
