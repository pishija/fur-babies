# FurBabies — Product Specification

> The complete companion platform for dogs and their owners.
> iOS application covering health tracking, AI companionship, social matching, live maps, gamification, and events.

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Feature Pillars](#2-feature-pillars)
   - 2.1 [Dog Profile](#21-dog-profile)
   - 2.2 [Virtual AI Friend](#22-virtual-ai-friend)
   - 2.3 [Health Calendars](#23-health-calendars)
   - 2.4 [Dog Matching](#24-dog-matching)
   - 2.5 [Live Walk Map](#25-live-walk-map)
   - 2.6 [Pet-Friendly Places](#26-pet-friendly-places)
   - 2.7 [Gamification](#27-gamification)
   - 2.8 [Events](#28-events)
   - 2.9 [Exhibitions](#29-exhibitions)
3. [Build Priorities](#3-build-priorities)

---

## 1. Product Overview

FurBabies is an iOS application that serves as a complete digital companion for dog owners. It combines a health passport for each dog, a breed-aware AI virtual friend, Tinder-style social matching between dogs, a live GPS walk map, pet-friendly place discovery, gamification, and community events — all built around a rich per-dog profile that powers every feature.

**Core proposition:** Every feature in the app is personalised to the specific dog — breed, age, weight, sex, and health history — rather than offering generic dog advice.

---

## 2. Feature Pillars

### 2.1 Dog Profile

The dog profile is the central data entity of the app. It acts as a living health passport that the AI friend reads, the health calendar writes to, and the matching feature queries for breed and size compatibility.

#### Fields

| Field | Type | Notes |
|---|---|---|
| Name | string | Display name |
| Breed | string | Used for AI context and matching |
| Sex | enum | Male / Female |
| Birthday | date | Age auto-calculated |
| Weight | decimal (kg) | Used for dose calculations and AI advice |
| Size class | enum | Toy / Small / Medium / Large / Giant |
| Coat colour | string | |
| Microchip number | string | |
| Neutered | boolean | Affects health calendar (heat cycle) |
| Temperament tags | array | Friendly, Playful, Calm, Protective, Trained, Good with kids, Good with dogs, Anxious |
| Is public | boolean | Controls visibility in matching and maps |

#### Photo Gallery
- Multiple photos per dog
- Set a primary profile photo
- Custom sort order
- Photos used on matching cards and public profile

#### Document Vault
Supported document types:
- Vaccination card
- Pedigree certificate
- Insurance policy
- Vet letters
- Breed registration
- Import / export papers

#### Multi-Dog Households
One owner account can manage multiple dog profiles. Each dog has its own virtual friend, health calendar, and social presence.

#### Privacy Controls
- Public profile, friends only, or private
- Granular control over appearance in search, matching, and the live walk map

---

### 2.2 Virtual AI Friend

The virtual AI friend is the app's key differentiator. It is automatically created and assigned to each dog at the moment the profile is saved.

#### How It Works

1. Owner creates a dog profile (name, breed, sex, birthday, weight)
2. On save, the backend generates a virtual friend with a name and personality derived from the dog's breed temperament
3. A welcome message is sent from the virtual friend immediately
4. Every subsequent conversation is context-aware — the AI always knows the specific dog's details
5. Every response is personalised using the dog's current profile, recent health events, and upcoming reminders

#### Personality Assignment

| Breed type | Generated personality |
|---|---|
| High-energy (Border Collie, Husky) | Energetic, curious, playful |
| Gentle giant (Great Dane, Newfoundland) | Calm, wise, reassuring |
| Companion breeds (Cavalier, Poodle) | Warm, sociable, encouraging |
| Working breeds (German Shepherd, Rottweiler) | Confident, structured, protective |

#### What Owners Can Ask

- **Nutrition:** Daily portion sizes, toxic foods to avoid, breed-specific dietary needs
- **Health:** Symptom checking, what to watch for by breed, seasonal care
- **Training:** Breed-specific training methods, common behavioural problems
- **Heat cycles:** What to expect, fertile window, false pregnancy warning signs
- **Travel:** Regulations, preparation, calming advice
- **General:** Any free-form question about the specific dog

#### Proactive Health Nudges

The virtual friend reads the health calendar and initiates messages unprompted:
> *"Luna's rabies booster is due in 3 weeks — want me to help you prepare for the vet visit?"*

#### Vet-Share Summary (v2.0)
Generate a clean PDF health summary from the AI conversation history and health calendar, ready to hand to a vet at appointments.

#### Persistent Memory (v2.0)
The virtual friend references past conversations: *"Last time you asked about Luna's diet — she's 6 months older now, here's what changes."*

---

### 2.3 Health Calendars

The health calendar is the engine behind smart reminders. It tracks all recurring and one-off health events for a dog's lifetime.

#### Calendar Types

| Calendar | Frequency | Notes |
|---|---|---|
| Vaccination — DHPP | Annual | Core vaccine: Distemper, Hepatitis, Parvovirus, Parainfluenza |
| Vaccination — Rabies | 1–3 years | Interval varies by country law |
| Vaccination — Leptospirosis | Annual | Recommended in most regions |
| Vaccination — Bordetella (Kennel Cough) | Annual | Required for kennels and dog shows |
| Vaccination — Canine Influenza | Annual | Recommended for social dogs |
| Vaccination — Lyme Disease | Annual | Recommended in tick-prevalent regions |
| Deworming | Every 3–6 months | |
| Flea & tick prevention | Monthly | |
| Heartworm prevention | Monthly | |
| Heat cycle tracker | Every ~6 months | Female intact dogs only |
| Annual vet checkup | Annual | |
| Dental cleaning | Every 6–12 months | |
| Grooming | Breed-specific | |
| Nail trim | Monthly | |
| Medications | Custom | Ongoing prescriptions with refill reminders |

#### Heat Cycle Tracking (Female Dogs)
- Log cycle start and end dates
- Predict next cycle based on history
- Track symptoms during cycle
- Alert for fertile window
- Warn about false pregnancy symptoms

#### Escalating Reminders

| Timing | Level | Action |
|---|---|---|
| 4 weeks before | Gentle | Soft push notification |
| 1 week before | Standard | Push notification with details |
| 1 day before | Urgent | Prominent push notification |
| Overdue | Alert | Red flag on profile, AI friend message |

#### Weight History
- Log weight entries over time
- Trend chart with ideal range overlay (breed and sex specific)
- AI flags unusual gain or loss patterns

---

### 2.4 Dog Matching

Tinder-style swipe matching so dogs can find compatible playmates.

#### Swipe Cards
Each candidate card shows:
- Primary photo
- Name, breed, age, distance
- Size class
- Temperament tags
- Vaccination status badge

#### Match Filters
- Distance radius
- Breed
- Size class
- Age range
- Sex
- Temperament tags
- Vaccinated only toggle
- Neutered / intact preference

#### Mutual Match Flow
1. Owner A swipes right on Dog B
2. Owner B swipes right on Dog A
3. Both receive a match notification with a celebratory animation
4. A conversation thread opens between the two owners

#### Compatibility Score (v1.0, AI-powered)
The AI rates match compatibility based on:
- Breed energy level pairing (e.g. two high-energy breeds = great match)
- Size difference (flagged if very large vs very small)
- Overlapping temperament tags
- Example: *"Great match — both love fetch and are great with other dogs!"*

#### Friends List (v1.0)
- Matched dogs appear as friends
- See when friends are actively walking nearby
- Invite friends directly to events
- Friends-only leaderboard scope

---

### 2.5 Live Walk Map

Real-time map showing dogs currently out on walks, with breed statistics and walk-together functionality.

#### Live Dog Pins
- Dogs appear as pins on the map only when walking mode is manually enabled
- Location is **never** shared passively — always an explicit owner action
- Pin shows dog's profile photo, name, breed, and distance from you

#### Privacy Architecture
- Live GPS coordinates are stored temporarily and automatically expire after 15 minutes
- Coordinates are **fuzzed by ~50 metres** before being served to nearby users
- Exact routes are only saved when the owner manually ends the walk session
- No passive background location tracking

#### Walk Together (v1.0)
1. Tap a nearby dog's pin
2. Send a "Walk together?" invite
3. If accepted, both owners see each other's live position and a shared walk session begins

#### Nearby Breed Stats
- Bar chart showing active breeds within chosen radius
- Small vs large dog split
- Trend data: which breeds are most popular in this neighbourhood over time

#### AI Compatibility Hint (v1.0)
When a nearby dog is a strong match for your dog's breed and size, a subtle indicator appears on their map pin: *"Luna would love this one!"*

#### Walk Tracking
- Records distance, duration, and route as a polyline
- Feeds into gamification streaks and badge progress
- Weekly and monthly distance summaries

#### Popular Routes Heatmap (v2.0)
- Aggregated heatmap of where dogs walk most in the city
- Highlights dog-friendly parks and recommended safe walking zones
- Built from anonymised historical walk session data

---

### 2.6 Pet-Friendly Places

Map and search for dog-welcoming venues, community-rated and community-maintained.

#### Place Categories
- Restaurants
- Cafes
- Bars
- Parks and green spaces
- Dog beaches
- Off-leash zones
- Pet shops
- Grooming salons
- Veterinary clinics
- Dog-friendly hotels
- Hiking trails

#### Place Filters
- Outdoor seating available
- Water bowl provided
- Off-leash zone
- Indoor dogs allowed
- Large dogs welcome
- Currently open

#### Community Reviews
- Star rating (1–5)
- Short text review
- Optional photo
- Reviewer's dog breed is shown alongside the review — useful context for suitability by size

#### User-Submitted Places
- Any verified user can submit a new place
- Place starts as unverified
- Becomes publicly visible after 2 independent community confirmations
- Moderation flag available for incorrect listings

#### Saved Places & Lists (v2.0)
- Save places to named personal lists (e.g. "Sunday walk spots", "Dog-friendly brunch")
- Share lists with matched friends

---

### 2.7 Gamification

Badges, streaks, leaderboards, and shareable achievements designed to drive daily engagement and organic sharing.

#### Walking Badges

| Badge | Requirement |
|---|---|
| First Steps | Complete first walk |
| 10km Club | Cumulative 10km walked |
| 50km Explorer | Cumulative 50km walked |
| 100km Champion | Cumulative 100km walked |
| 500km Legend | Cumulative 500km walked |
| Rainy Day Walker | Complete a walk in rain |
| Early Bird | Walk before 7am |
| Night Owl | Walk after 9pm |

#### Social Badges

| Badge | Requirement |
|---|---|
| First Match | Get first mutual match |
| Growing Pack | 5 matched friends |
| Social Butterfly | 25 matched friends |
| Pack Leader | 100 matched friends |
| Most Friendly | Most matches in city in a given week |

#### Health Badges

| Badge | Requirement |
|---|---|
| Health Champion | All health calendar events up to date |
| Vet Loyalist | 3 annual checkups logged |
| Zero Overdue | No missed reminders for 12 consecutive months |

#### Streaks
- Daily walk streak counter
- Streak resets if no walk logged within 36 hours
- Weekly distance chart
- Monthly summary card

#### Leaderboards (v2.0)
- Weekly reset every Monday
- Scoped to: friends only / neighbourhood / city
- Categories: most distance walked, most new matches, most events attended

---

### 2.8 Events

Create and discover dog-specific events in the local community.

#### Event Types
- Birthday party
- Breed meetup (e.g. "Golden Retriever Day in Ljubljana")
- Puppy playdate
- Dog training session
- Charity walk
- Costume contest
- Agility fun day

#### Event Creation Fields
- Title
- Date and time
- Location (map pin)
- Event type
- Breed restrictions (open to all, or specific breeds)
- Maximum attendees
- Cover photo
- RSVP options: Going / Interested / Not going

#### Event Discovery
- Browse by map view or list view
- Filter: upcoming date range, distance, event type, breed relevance
- Smart suggestions: *"Events for large dogs this weekend near you"*

#### Event Memories (v2.0)
- Shared photo album opens for all attendees after the event
- Auto-generated recap card: *"Luna attended 3 events this month!"*
- Shareable to owner's social media

---

### 2.9 Exhibitions

Browse and track upcoming professional dog shows and kennel club competitions.

#### Exhibition Directory
- Official conformation shows
- Agility competitions
- Obedience trials
- Breed-specific speciality shows
- Sourced from: FCI, AKC, UKC, and national kennel club calendars

#### Search & Filters
- Date range
- Country and city
- Breed eligibility
- Show type (conformation / agility / obedience)
- Map view of venues

#### Save & Notify
- Save exhibitions to a personal watchlist
- Set reminder: number of days before the event
- Deep link to the official registration page
- Community notes from attendees of previous years (v2.0)

---

## 3. Build Priorities

### Core — Ship on Day 1

These features form the minimum viable product. Without them, no other pillar has a foundation.

- Dog profile creation with all identity fields
- Photo upload and document vault
- Virtual AI friend creation and chat
- Vaccination and health calendar (core event types)
- Escalating reminder notifications via APNS
- Walk tracking (distance + route)
- Live walk map with walking mode toggle
- Swipe matching with mutual match detection
- Conversation between matched owners

### v1.0 — Complete the Experience

These features turn occasional users into daily ones.

- Multi-dog household support
- Privacy controls (public / friends only / private)
- Heat cycle tracker
- Medication log
- Weight history with chart
- Breed compatibility score in matching
- Friends list with walk activity
- Walk-together invite from map
- AI compatibility hint on map pins
- Nearby breed stats panel
- Community place submission and reviews
- Pet-friendly places map with filters
- Event creation and RSVP
- Event discovery by map and list
- Health and social badges
- Walk streaks and activity stats
- Exhibition directory with search

### v2.0 — Engagement and Retention

These features are best prioritised once real usage data is available.

- AI persistent memory across conversations
- Vet-share PDF health summary
- Popular routes heatmap
- Weekly leaderboards (friends / neighbourhood / city)
- Event photo album and recap card
- Saved place lists and friend sharing
- Community notes on exhibitions

---

*Document generated from the FurBabies product design session.*
