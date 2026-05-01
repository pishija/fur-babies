# Feature: Authentication

## Overview

Auth covers sign-up, sign-in, sign-out, and account deletion for dog owners. The flow is: **onboarding welcome screens → auth → owner profile step (first name + city) → create first dog**. Sign in with Apple is the primary method; email & password is the alternative. Auth is fully abstracted behind an `AuthServiceProtocol` in the Domain layer — the current Firebase Auth implementation can be swapped for a custom API backend without changing a single line of Presentation or Domain code.

---

## Architecture: Auth as a swappable protocol

```
Presentation (Views, ViewModels)
    ↓ calls
Domain (AuthServiceProtocol, AuthUseCase, AuthUser entity)
    ↓ implemented by
Data/Auth/Firebase/   ← current implementation
Data/Auth/CustomAPI/  ← future implementation (drop-in replacement)
```

### `AuthServiceProtocol` (Domain layer)

```swift
protocol AuthServiceProtocol {
    var currentUser: AuthUser? { get }
    var authStateStream: AsyncStream<AuthUser?> { get }

    func signInWithApple(credential: AppleCredential) async throws -> AuthUser
    func signInWithEmail(email: String, password: String) async throws -> AuthUser
    func signUpWithEmail(email: String, password: String) async throws -> AuthUser
    func signOut() throws
    func deleteAccount() async throws
}
```

### `AuthUser` entity (Domain layer)

```swift
struct AuthUser {
    let id: String        // stable user ID — used as Firestore userId
    let email: String?
    let displayName: String?
}
```

**Rule:** Nothing above the Data layer ever imports `FirebaseAuth` or references any Firebase type. `AuthUser` is a plain Swift struct. The ViewModel receives an `AuthUser` and never knows how it was obtained.

---

## Screens

1. **Onboarding** — welcome + feature highlights (defined in Dog Profile feature; shown to unauthenticated users only)
2. **Auth Screen** — sign in / sign up choice (Sign in with Apple + email/password)
3. **Owner Profile Setup** — first name + city (shown once, immediately after first successful sign-up)
4. **Forgot Password** — email entry to trigger a password reset email

Auth screens are presented modally or as a full-screen cover when no authenticated session exists. Once authenticated, the main tab bar is shown.

---

## App Launch Flow

```
App opens
  ↓
Is there a valid auth session?
  ├── YES → Has the owner completed profile setup (first name saved)?
  │             ├── YES → Has owner created at least one dog?
  │             │             ├── YES → Main tab bar
  │             │             └── NO  → Onboarding → Create Dog Profile
  │             └── NO  → Owner Profile Setup → Create Dog Profile
  └── NO  → Onboarding screens → Auth Screen
```

The auth state is observed via `authStateStream` — a continuous `AsyncStream<AuthUser?>` that the root coordinator listens to. When it emits `nil`, the app shows the auth flow. When it emits a user, the app shows the main tab bar.

---

## Auth Screen

### Purpose
Let returning users sign in and new users create an account. Sign in with Apple is shown first and most prominently.

### UI elements
- App logo / name at the top
- **"Sign in with Apple" button** — full-width, Apple-styled, shown first
- A divider: "or"
- **Email field** — keyboard type: email address, autocorrect off
- **Password field** — secure text entry, show/hide toggle
- **"Continue" button** — below the email/password fields; disabled until both fields are non-empty
- **"Forgot password?" link** — below the Continue button
- **Toggle link** at the bottom: "Don't have an account? Sign up" ↔ "Already have an account? Sign in" — switches between sign-in and sign-up mode in place (no separate screen)
- In sign-up mode: a **"Confirm password" field** appears between password and the Continue button

### States
- **Sign-in mode** (default for returning users): email + password + forgot password link
- **Sign-up mode**: email + password + confirm password
- **Loading**: Continue button shows spinner; all inputs disabled; Apple button disabled
- **Error**: inline message below the relevant field or a general error banner (e.g. "Incorrect email or password", "This email is already registered", "Passwords don't match")
- **Apple auth in progress**: system sheet shown by iOS; no additional loading state needed

### Validation (sign-up)
- Email: must be a valid email format
- Password: minimum 8 characters
- Confirm password: must match password exactly
- All validated on tap of Continue, not on each keystroke

---

## Owner Profile Setup

### Purpose
Collect a display name and city immediately after a new account is created. Shown exactly once — never shown again once saved.

### UI elements
- Heading: "Tell us about yourself"
- **First name field** — text, max 50 characters
- **City field** — text, max 100 characters (free text; no autocomplete in v1)
- **"Continue" button** — disabled until first name is non-empty (city is optional)

### Business rules
- This screen appears only for newly created accounts (not on subsequent sign-ins)
- City is optional — owner can skip by leaving it blank and tapping Continue
- First name is required — the app uses it for personalisation throughout
- On save: owner document created in Firestore at `users/{userId}` with `name`, `city`, and `createdAt`
- After save: navigates to Dog Profile onboarding (Create First Dog)

### States
- **Idle**: empty fields
- **Saving**: spinner on Continue; fields disabled
- **Error**: toast for network failure; fields remain filled

---

## Forgot Password

### Purpose
Let owners who signed up with email/password reset their password via email.

### UI elements
- Email field (pre-filled if the user had already typed their email on the Auth screen)
- "Send reset link" button
- Back/cancel link

### Behaviour
- On submit: Firebase Auth (or future custom API) sends a password reset email
- Success state: "Check your inbox — we've sent a reset link to [email]" — no navigation away; user goes back manually
- The reset itself happens outside the app (in the email client / browser)
- Error: "No account found with that email" if the address is not registered

### States
- **Idle**: email field, send button
- **Sending**: button spinner
- **Success**: confirmation message shown in place of the form
- **Error**: inline error below the email field

---

## Sign Out

### Where it lives
Sign out is accessible from the **Me tab** (owner account settings) — not part of the auth screens. It is a destructive-feeling action and requires a single confirmation: "Sign out? You'll need to sign in again to access your dogs." with Cancel / Sign Out buttons.

### Behaviour
- Calls `authService.signOut()`
- Clears all in-memory session state
- App returns to the Onboarding → Auth Screen flow
- All local data (SwiftData cache) is cleared on sign-out

---

## Account Deletion

### Where it lives
Also in the **Me tab**, under a "Danger zone" or advanced settings section.

### Behaviour
1. Owner taps "Delete account"
2. Alert: "This will permanently delete your account and all your dogs' data — health records, matches, walk history, and everything else. This cannot be undone."
3. Owner confirms by typing "DELETE" into a text field (extra friction for an irreversible action)
4. On confirm:
   - All Firestore data for the user and their dogs is deleted (via a Cloud Function to handle cascading deletes)
   - Firebase Storage files (photos, documents) are deleted
   - Firebase Auth account is deleted
   - App returns to the Onboarding → Auth Screen flow
5. If the deletion Cloud Function fails: show an error and tell the owner to try again; do not leave the account in a half-deleted state

---

## User Flows

### Flow 1: New user — sign up with Apple
1. App opens → no auth session → Onboarding screens shown
2. Owner pages through highlights → taps "Get Started"
3. Auth Screen appears
4. Owner taps "Sign in with Apple"
5. iOS system sheet appears; owner authenticates with Face ID / Touch ID
6. Apple credential passed to `AuthServiceProtocol.signInWithApple()`
7. Firebase Auth creates account; `AuthUser` returned
8. First-time user detected → Owner Profile Setup screen shown
9. Owner enters first name (and optionally city) → taps Continue
10. Owner document created in Firestore
11. Navigates to Onboarding (dog creation) → Create Dog Profile

### Flow 2: New user — sign up with email
1. Steps 1–3 same as above
2. Owner taps "Don't have an account? Sign up"
3. Fills email, password, confirm password → taps Continue
4. `AuthServiceProtocol.signUpWithEmail()` called
5. Account created → `AuthUser` returned
6. Continues from step 8 above (Owner Profile Setup)

### Flow 3: Returning user — sign in
1. App opens → no auth session → Onboarding screens shown
2. Owner taps "Get Started" → Auth Screen
3. Auth Screen shows in sign-in mode (default)
4. Owner signs in via Apple or email/password
5. `AuthUser` returned → owner profile already exists → dog(s) already exist
6. Navigates directly to Main tab bar

### Flow 4: Returning user — app reopen with active session
1. App opens → valid auth session found via `authStateStream`
2. Owner profile exists; dogs exist
3. Main tab bar shown immediately — no auth screen, no onboarding

### Flow 5: Forgot password
1. Owner on Auth Screen → taps "Forgot password?"
2. Forgot Password screen shown (email pre-filled if typed)
3. Taps "Send reset link"
4. Confirmation message shown
5. Owner exits to email client, clicks link, resets password in browser
6. Returns to app, signs in with new password

---

## Business Rules

- **Sign in with Apple is the primary method** — shown first, larger, no extra steps
- **Email/password is the alternative** — available but secondary in visual hierarchy
- **Google Sign-In is not supported in v1**
- **Owner profile setup is shown exactly once** — gated by the absence of a `users/{userId}` document in Firestore; if the document exists, this screen is skipped
- **Session persistence**: Firebase Auth persists the session on-device. The `authStateStream` emits the current user immediately on app launch if a session exists.
- **Token management is handled by the Auth implementation**, not the app. When Firebase is replaced by a custom API, the custom implementation is responsible for token refresh, storage, and expiry — the rest of the app does not change.
- **The `userId` from `AuthUser.id` is used as the Firestore document ID** (`users/{userId}`). This ID must remain stable for the lifetime of the account. When migrating from Firebase Auth to a custom API, the same user IDs must be preserved or a migration strategy for Firestore paths must be defined.

---

## Data (Firestore)

```
users/{userId}
  name: string            // from Owner Profile Setup
  city: string            // from Owner Profile Setup (optional)
  email: string           // snapshotted from auth provider at account creation
  createdAt: timestamp
```

Auth session state (tokens, credentials) is managed entirely by the `AuthServiceProtocol` implementation — never stored in Firestore.

**Reads:** App launch (check if `users/{userId}` exists to determine if profile setup is needed), Me tab (display owner name/city)
**Writes:** Owner Profile Setup (creates `users/{userId}` doc)
**Deletes:** Account deletion (Cloud Function deletes `users/{userId}` + all subcollections + Storage files)

---

## Protocol migration path (Firebase → custom API)

When the time comes to move off Firebase Auth:

1. Create `Data/Auth/CustomAPI/CustomAPIAuthService.swift` implementing `AuthServiceProtocol`
2. The custom implementation handles: token acquisition, refresh, secure storage (Keychain), and the `authStateStream` AsyncStream
3. Swap the injected implementation in the DI container — one line change
4. `AuthUser.id` must map to the same stable user ID used in Firestore paths

No changes to ViewModels, Use Cases, Views, or any feature code.

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| Apple returns a nil email (user chose to hide email) | Use Apple's private relay email; store it in the user doc as-is; treat it as a valid email |
| Owner signs up with Apple, then tries email sign-in with the same email | Firebase Auth will reject — "account exists with different credentials". Show: "This email is linked to Sign in with Apple. Use that instead." |
| Network drops during sign-up | Error shown; no partial account created (Firebase Auth is atomic) |
| Owner deletes account then reinstalls app | Account is gone; treated as a new user; goes through full sign-up flow |
| Session token expires mid-session | `authStateStream` emits `nil`; app transitions to auth screen; owner must sign in again |
| Owner Profile Setup crashes before saving | On next launch, `users/{userId}` doc still doesn't exist → Owner Profile Setup shown again |
| Owner types wrong confirm password | Inline error: "Passwords don't match" — shown on Continue tap, not on keystroke |

---

## Out of Scope

- Google Sign-In — not in v1
- Phone number / SMS auth — not in v1
- Two-factor authentication — not in v1
- Social account linking (connecting Apple + email to the same account) — not in v1
- Owner profile photo — not in v1 (name + city only)
- Email verification flow — Firebase Auth handles this silently if enabled; no custom UI needed
