# Total Fit Gym — PROJECT BLUEPRINT / SRS

Source idea: `Project-detail.txt`. Tech boundary: Flutter + Firebase Auth (Google) + RTDB + FCM only.
App: `total_fit_gym` (`com.totalfitgym`), Android + Web (iOS served via Web). Theme: Black `#0A0A0A` + Yellow `#FFC400`.

## 1. Product Summary
Owner-centric gym management app. Owner manages registrations, plans, memberships, expiries, approvals. Members self-register via gym QR → Google login → mobile → plan select → owner approves/denies payment → membership activates. Existing members renew/switch plans the same way. Fully responsive (small phone → desktop), smooth animated, Inter font.

## 2. Target Users
- **Owner/Admin** (1–2 people): manages everything.
- **Member (new)**: registers via QR.
- **Member (existing)**: renews/switches plan, views status/expiry.
- Implicit: **Visitor** (unauthenticated, QR link opener).

## 3. Roles & Permissions
| Action | Visitor | Pending user | Member | Owner |
|---|---|---|---|---|
| Open /join QR link | Y | Y | Y | Y |
| Google login | Y | – | Y | Y |
| Add/edit own phone | – | Y | Y | – |
| View active plans | – | Y | Y | Y |
| Create registration/renewal | – | Y | Y | – |
| View own membership/status | – | – | Y | – |
| Create/edit/deactivate plans | – | – | – | Y |
| View all members/memberships/expiry | – | – | – | Y |
| Approve/deny registration | – | – | – | Y |
| Edit role field | – | – | – | Y (owner-only) |

`role` lives at `users/{uid}/role` and is **owner-writable only** (RTDB rules). Client never trusts its own role.

## 4. Feature List (MVP)
1. Google Sign-In + auth-state routing (F1)
2. Phone capture + validation (F2)
3. Plans: owner CRUD, member read-active (F3)
4. Registration: new + renew/switch → `pending` (F4)
5. Owner approvals: approve → membership window created; deny with reason (F5)
6. Owner dashboard: expiring-soon (≤7d), expired, pending, search (F6)
7. Join QR: owner shows QR (`/join?gym=ID`), visitor opens on any device (F7)
8. FCM: approval/denial, expiry reminders (3d/1d/expired), token mgmt (F8)
9. Responsive shell + black/yellow system + loading/empty/error states (F9)

Future (NOT MVP): online payment gateway, attendance, diet/workout plans, multi-branch, Hindi/i18n, analytics.

## 5. Screens
`/ (splash)` → `/login` → `/phone` → `/home (member)` | `/owner` → expiring, approvals, plans, members, QR dialog; `/join?gym=` public. Each screen defines loading/success/empty/error/offline states (see `lib/core/widgets/state_views.dart`).

## 6. Navigation
```
Splash → Login → Phone → Home(member) / Owner(owner)
         ↑                ↕
         +── /join?gym= (public, preserves gymId through login)
FCM tap → /home (member) or /owner (owner, approvals/expiry)
```
Back: splash never returns; login→exit; phone→login (sign-out choice); home/owner→system back exits tab. Guards: auth + role (go_router `redirect` in `lib/core/routing/app_router.dart`).

## 7. User Journeys
**New member:** Scan QR → Join → Google → Phone → Plans → Select → Confirm → `registrations/{id}=pending` → wait → FCM approved → Home shows active + endAt. Denied path shows reason + retry.
**Renew:** Home → Renew/Switch → plan → pending → approved → new window (old window preserved in history via `lastRegId`).
**Owner:** Login (owner-flagged account) → Owner dash → Pending → Approve (multi-path update: registration + membership atomically) → member gets FCM. Expiry card → WhatsApp/call member (phone visible to owner only).
Alt paths: cancel Google, offline queue message, duplicate-tap guard (disable button while submitting), stale notification → re-read RTDB on open.

## 8. Business Rules
- Plans are owner-created; inactive plans never shown to members.
- One `pending` registration per user at a time (second submit blocked with message).
- Approve sets `memberships/{uid} = {planId, startAt=now, endAt=now+durationDays, status=active, lastRegId}` + `registrations/{id}={approved, decidedAt, decidedBy}` in one multi-path update.
- `status` derived: `endAt-now ≤0 → expired`, `≤7d → expiring_soon`, else `active`. Owner list sorts by `endAt`.
- Payment is **offline/manual** in MVP (owner verifies cash/UPI, then taps approve). No gateway.

## 9. Missing / Ambiguity / Contradiction log
- Missing (added): logout, delete-account note, empty/error/offline states, duplicate-submit guard, token-on-logout cleanup, owner seed bootstrap (first owner UID set manually in RTDB/rules).
- Ambiguous → decided: "approve payment" = manual verify + approve tap (no gateway in MVP); "mobile add" = mandatory once, editable by re-verify later; expiry window default 7d for "expiring".
- Contradiction: `AGENTS.md` describes a monorepo web project — **not applicable**; this repo is single Flutter app. `PROJECT_DISCOVERY_MASTER_PLAN.md` says "do not code" — superseded by explicit "create flutter project" instruction.

## 10. Firebase Auth
Google-only. First login creates `users/{uid}` (displayName/email/photoUrl/role=pending). Returning loads profile → phone==null → `/phone`; role==owner → `/owner`; else `/home`. Handles cancel, failure, sign-out (clears FCM token), restart persistence.

## 11. RTDB Architecture
See `lib/core/constants/rtdb_schema.dart`. Nodes: `meta/gym`, `users/{uid}`, `plans/{planId}`, `registrations/{regId}`, `memberships/{uid}`, `devices/{uid}/{tokenId}`. `memberships/{uid}` denormalized for expiry queries.

## 12. Security Model (rules, console-side)
- Authed required everywhere. `users/{uid}`: self read/write except `role`; owner reads all, writes `role`.
- `plans`: authed read active; owner full write.
- `registrations`: member create-own/read-own; owner all.
- `memberships`: member read-own; owner all.
- `devices/{uid}`: self write, self+owner read.
- Validate: phone regex, price>0, durationDays 1–1825, status enums, `decidedBy == auth.uid` + owner role.

## 13. FCM
Token stored `devices/{uid}/{tokenId}`, refresh + multi-device, delete on logout. Types: approved, denied, expiring_3d/1d, expired. Payload = IDs only (no PII); app re-reads RTDB on tap. Foreground = Snackbar; background/terminated = tap routes correctly.

## 14. UI/UX + Responsive
Black/yellow (`lib/core/theme/app_theme.dart`), Inter via google_fonts, radius 8/14/22, shared Loading/Empty/Error views. Breakpoints 600/1024/1440, `MaxWidth(1120)`, grid 1→2→3→4, no fixed w/h, adaptive dialogs/bottom-sheets, keyboard-safe forms.

## 15. Flutter Architecture
```
lib/ main.dart
 core/{constants,theme,routing,utils,widgets}
 features/{splash,auth,dashboard,plans,members,registration}/presentation (+data/domain in M3+)
```
Riverpod (authStatus + streams), go_router, repository-per-feature isolates Firebase. Milestones: M1 foundation ✅ | M2 app complete on FakeDb ✅ (Firebase last) | M3 UI 2026 ✅ | M4 dynamic programs ✅ | M5 member nav + music ✅ (Audius full songs) | M6 home content + spacing ✅ | M7 design-system overhaul ✅ | M8 Firebase plug-in (pending).

## 21. Centralized design system overhaul (16-phase UI audit)

## 19. Member bottom nav + gym music (F11/F12)
Member shell `/home` → Home · Programs · Music · Profile (`lib/features/member/`). Home: Explore grid (All plans, Training, Diet, Music) + Featured programs carousel + My programs; Training/Diet tiles deep-link `/services?kind=`, Music tile jumps to Music tab. Profile holds identity, phone edit, full history, logout. Music streams REAL FULL-LENGTH songs via **Audius** free API (search + stream, verified live: 200 audio/mpeg), auto-fallback to iTunes 30s previews (`lib/features/music/`, `just_audio` + `http`). Researched: Jamendo needs client_id (future), Spotify needs login (skip).

## 20. Spacing + chips system
`tokens.dart` (cardGap 12, sectionGap 24, list bottom 24), single-line scroll chip rows with equal 16px start/end margins (`AppChoice`), yellow-bold AppBar titles, compact-then-breathe card rhythm across all screens.

## 17. Dynamic programs (F10)
Owner-managed catalog: personal training (muscle gain, weight loss, weight gain, strength…), diet plans (free/paid) + ANY new category (cardio, physio…) via "+ New category" — zero code change, kind is data not enum. Members browse/search/filter → request → owner approve/deny in Approvals tab, active programs on member home. Models `ServiceItem`/`ServiceBooking` (`lib/core/models/app_models.dart`), engine `FakeDb` (`lib/core/data/fake_db.dart`), UI `/services` + `/services/book` (`lib/features/services/`). Future RTDB nodes: `services/{id}`, `bookings/{id}` (rules mirror registrations).

## 18. Firebase-last plan (user decision)
Firebase Auth/RTDB/FCM **nahi** jude — poori app `FakeDb` par chalti hai. Baad me sirf ye files badlegi, UI same rahegi:
- `lib/core/data/fake_db.dart` → RTDB data-source (nodes same naam se)
- `lib/core/auth/session.dart` → Google Sign-In + FirebaseAuth stream
- `lib/main.dart:11` → `Firebase.initializeApp` uncomment
- Notices → FCM service. Rules/security model §12 console me lagega.

## 16. Acceptance (MVP)
`flutter analyze` clean, `flutter test` pass, login→phone→register→approve→active works Android+Web, expiry list correct, QR join works from fresh browser, FCM foreground+tap works, no overflow at 320px/768px/1440px.

## 22. Gym timing + rush analytics (F13)
Members declare training window (Morning/Evening + from/to hour, 5 AM–10 PM) via nudge card on home / edit in profile / `showSlotDialog`. `FakeDb.rushByHour()` aggregates headcount per hour; `peakHour()` finds busiest slot. Member home shows "Gym rush hours" bar chart (peak glows yellow, tap-a-bar for exact count) + peak summary; owner Home tab shows the same analytics + response count. Models: `AppUser.slotSession/slotFrom/slotTo`; future RTDB: `users/{uid}/slot{Session,From,To}`.

## 23. Music library: search + playlists + albums (F14)
Music tab rebuilt: search bar (debounced) + Songs | Playlists | Albums modes, mood chips for browsing. Playlists via `/v1/playlists/search|trending`, tracks via `/v1/playlists/{id}/tracks`; albums = artist collections via `/v1/users/search` + `/v1/users/{id}/tracks` (Audius exposes no album entities — verified live). Collection detail route `/music/collection?kind=&id=` with header, play-all and shared `TrackRow`. All endpoints verified live with curl before coding.

## 24. Music lifecycle audit (perfect-playback pass)
`GymPlayer` hardened: lazy platform init, generation guard against rapid-tap races, try/catch on every platform call with one-shot snackbar errors (`consumeError`), `stop()` clears queue on logout (no ghost playback), auto-advance through queue preserved. All play entries (rows, play-all) surface errors. Liked toggle is pure + unit-tested. Coverage: `test/music_logic_test.dart` (likes, mix-flag, player no-platform safety, rush math, membership status).

## 25. Post-login profile setup + workout splits (F15)
Google login → `/setup` (router-enforced for profile-less users): editable name, read-only email, 10-digit mobile, weight, height in feet + inches (stored canonically as cm), goal (Gain/Lose/Maintain) with conditional target-kg, live BMI + category, split picker with weekly chart preview. `FakeDb.saveProfile`, `AppUser.bmi`, `AppUser.ftInToCm`/`cmToFtIn`, 6 seeded splits (PPL, Bro, Upper/Lower, FullBody, Arnold, 5-Day) with 7-day charts; `/splits` browse + follow + owner CRUD incl. day editor. Profile shows stats + split rows (edit entry points); home shows today's workout banner. Coverage: `test/setup_test.dart` (live BMI, phone validation, height conversion) + `test/login_flow_test.dart` (Google → setup end-to-end). Suite: 17/17 green, analyze clean.

## 26. UI polish + web branding
Typography scale reduced through the centralized `AppText`/Material theme (hero 24px, headings 16px, body 13px, metadata 12px) and direct screen overrides were removed where tokens already existed. Profile height is displayed in ft/in. Setup fields include example hints (name, phone, weight, feet, inches, target kg). The public web shell now has Total Fit Gym black/yellow dumbbell favicon and PWA icons, author metadata (`sived.codes`), and a shared developer credit shown on login, owner home, and member profile.
