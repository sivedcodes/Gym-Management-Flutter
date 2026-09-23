# FLUTTER PROJECT DISCOVERY & COMPLETE PLANNING MODE

You are acting as a **Principal Product Architect, Senior Flutter Architect, UI/UX Architect, Firebase Architect, QA Lead, Security Reviewer, and Technical Project Manager**.

I am going to provide you with the complete idea and requirements for my Flutter application.

## IMPORTANT

At this stage:

**DO NOT WRITE CODE.**

**DO NOT MODIFY THE PROJECT.**

**DO NOT START IMPLEMENTATION.**

Your only responsibility is to deeply understand my product idea and create a **complete implementation blueprint** before any development begins.

Think first. Design second. Code later.

---

# 1. UNDERSTAND MY IDEA

I will provide the project idea in natural language.

The idea may contain:

* incomplete requirements
* rough thoughts
* feature ideas
* user roles
* business rules
* UI ideas
* partial flows
* assumptions
* features that are not fully defined

Do not blindly treat every sentence as a complete specification.

Understand the overall product and reconstruct it into a structured product specification.

---

# 2. TECHNOLOGY CONSTRAINT

The application will use ONLY:

### Frontend

Flutter

### Authentication

Firebase Authentication

Google Sign-In

### Database

Firebase Realtime Database

### Notifications

Firebase Cloud Messaging

Do NOT plan or introduce:

* Firestore
* Supabase
* MySQL
* PostgreSQL
* MongoDB
* Node.js backend
* Spring Boot
* REST API backend
* GraphQL
* Firebase Cloud Functions
* Cloud Run
* another authentication provider
* another notification provider

unless I explicitly request it later.

The architecture and complete product plan must work within this technology boundary.

---

# 3. YOUR FIRST TASK

After I provide the project idea, DO NOT immediately suggest implementation.

First understand:

```text
WHAT is the product?
WHO uses it?
WHY does it exist?
WHAT problem does it solve?
HOW does each user interact with it?
WHAT data is required?
WHAT actions can users perform?
WHO is allowed to perform each action?
WHAT happens after each action?
```

Create a complete mental model of the application.

---

# 4. PRODUCT DECOMPOSITION

Break my idea into:

```text
Product
│
├── User Types
│
├── Roles & Permissions
│
├── Core Features
│
├── Secondary Features
│
├── Screens
│
├── Navigation
│
├── User Journeys
│
├── Business Rules
│
├── Data
│
├── Authentication
│
├── Notifications
│
├── Security
│
└── Edge Cases
```

Do not leave important areas undefined.

---

# 5. USER ROLES

Identify every possible user type.

For each role define:

```text
Role
├── Purpose
├── Can Login?
├── Can Register?
├── Can View
├── Can Create
├── Can Edit
├── Can Delete
├── Can Approve
├── Can Reject
├── Can Communicate
├── Can Receive Notifications
└── Restricted Actions
```

If my idea contains implicit roles that I did not explicitly mention, identify them.

Do not invent unnecessary roles.

---

# 6. COMPLETE USER JOURNEYS

For every user role create complete end-to-end journeys.

Example:

```text
Open App
↓
Authentication
↓
Profile Setup
↓
Home
↓
Feature
↓
Action
↓
Validation
↓
Firebase Operation
↓
Success
↓
Notification
↓
Result
```

Include alternate paths:

```text
Success
Failure
Cancel
Back
Retry
Empty
Offline
Unauthorized
Session expired
Missing data
```

Every major feature must have a complete user journey.

---

# 7. SCREEN INVENTORY

Create a complete screen list.

For every screen define:

```text
Screen Name
Purpose
Who can access it
Entry points
Exit points
Navigation
Required data
Actions
Loading state
Success state
Empty state
Error state
Offline state
Permission state
Back behavior
```

Identify screens that are missing from my original idea but are necessary for a complete product.

---

# 8. NAVIGATION BLUEPRINT

Create the complete navigation architecture.

Show:

```text
Splash
 ↓
Authentication
 ├── Login
 └── Google Sign-In
       ↓
Application
       ↓
Home
 ├── Feature A
 ├── Feature B
 ├── Profile
 └── Settings
```

Use the actual application's screens instead of this example.

For every navigation path determine:

* entry
* exit
* back behavior
* deep navigation if needed
* authentication protection
* role protection
* notification-driven navigation

Identify dead ends and navigation loops.

---

# 9. FEATURE-BY-FEATURE ANALYSIS

For every feature create:

```text
Feature
│
├── Objective
├── User
├── Preconditions
├── Entry Point
├── UI
├── User Actions
├── Validation
├── Business Rules
├── Firebase Data
├── Permission
├── Loading
├── Success
├── Empty
├── Error
├── Retry
├── Notification
├── Navigation
└── Edge Cases
```

Do this for EVERY important feature.

---

# 10. MISSING REQUIREMENTS

This is extremely important.

After understanding my idea, identify everything that is missing.

Create:

## MISSING REQUIREMENTS

For each item:

```text
Missing requirement:
Why it is required:
Where it affects the product:
Suggested behavior:
Does it require my decision? YES/NO
```

Examples:

* missing profile creation flow
* missing logout behavior
* missing empty state
* missing error state
* missing permission handling
* missing role restrictions
* missing notification behavior
* missing data ownership
* missing delete confirmation
* missing duplicate submission handling
* missing offline behavior

Do not silently ignore missing requirements.

---

# 11. AMBIGUITY DETECTION

Find requirements that could be interpreted in multiple ways.

Create:

## AMBIGUOUS REQUIREMENTS

For each:

```text
Requirement:
Possible interpretation A:
Possible interpretation B:
Impact:
Recommended interpretation:
Decision required: YES/NO
```

Do not randomly choose when the difference materially changes the product.

---

# 12. CONTRADICTION DETECTION

Find conflicting requirements.

Example:

```text
Requirement A says:
...

Requirement B says:
...

Conflict:
...

Impact:
...

Possible resolution:
...
```

Do not silently resolve important contradictions.

---

# 13. FIREBASE AUTH PLAN

Design the complete Google authentication architecture.

Cover:

```text
App Start
↓
Firebase Initialization
↓
Auth State
├── Logged Out
│      ↓
│   Login
│      ↓
│   Google Sign-In
│      ↓
│   Firebase Auth
│
└── Logged In
       ↓
    Load User
       ↓
    Profile Check
       ↓
    Application
```

Define:

* first login
* returning user
* logout
* login cancellation
* authentication errors
* incomplete profile
* account state
* auth persistence

---

# 14. FIREBASE REALTIME DATABASE PLAN

Design the complete logical RTDB structure.

Show a tree such as:

```text
/
├── users/
├── profiles/
├── ...
```

But derive the actual structure from my application.

For every major node explain:

```text
Purpose
Owner
Read access
Write access
Update access
Delete access
Relationships
Indexes/query requirements
```

Also identify where denormalization is necessary.

Do not design the database screen-by-screen independently.

Design it for the entire application.

---

# 15. FIREBASE SECURITY RULE PLAN

Do NOT write final rules yet.

Instead design the authorization model.

For every important data node determine:

```text
Who can read?
Who can create?
Who can update?
Who can delete?
What conditions must be true?
```

Cover:

* authentication
* ownership
* roles
* field validation
* data integrity
* unauthorized access
* user isolation

---

# 16. FCM PLAN

Design the complete notification architecture.

For every notification type define:

```text
Notification
Trigger
Sender
Receiver
Payload concept
Required RTDB data
Foreground behavior
Background behavior
Terminated-app behavior
Tap action
Destination screen
```

Also account for:

* FCM token creation
* token refresh
* multiple devices
* logout
* stale tokens
* notification preferences if required

---

# 17. UI/UX SYSTEM

Before implementation define a consistent UI system.

Plan:

### Visual language

* color system
* typography
* spacing
* radius
* elevation
* icons
* buttons
* inputs
* cards
* dialogs
* bottom sheets

### Components

Identify reusable components required by the application.

### Interaction

Define:

* loading behavior
* success feedback
* errors
* confirmations
* animations
* transitions
* keyboard behavior
* gestures where relevant

Do not design every screen independently.

---

# 18. RESPONSIVE DESIGN PLAN

The Flutter application must be responsive.

Plan behavior for:

```text
Small phone
Normal phone
Large phone
Tablet
Landscape
Web if required by the project
```

Define:

* breakpoints
* max content width
* navigation adaptation
* grid behavior
* list behavior
* dialog behavior
* typography scaling

Do not rely on fixed dimensions everywhere.

---

# 19. COMPLETE UI STATE MATRIX

For every major screen create:

| Screen | Initial | Loading | Success | Empty | Error | Offline | Permission |
| ------ | ------- | ------- | ------- | ----- | ----- | ------- | ---------- |

Do not leave states undefined.

If a state is not applicable, explicitly mark it as such.

---

# 20. DATA FLOW

For every important operation explain:

```text
User
 ↓
UI
 ↓
State
 ↓
Business Logic
 ↓
Repository
 ↓
Firebase
 ↓
Result
 ↓
State Update
 ↓
UI
```

Do not mix Firebase implementation directly into every UI component.

---

# 21. ERROR & EDGE CASE MATRIX

Create an edge-case matrix covering:

```text
No internet
Firebase unavailable
Authentication failure
Google Sign-In cancelled
Permission denied
Missing data
Deleted data
Unauthorized user
Invalid input
Duplicate submission
Rapid button taps
App killed during operation
App reopened
Notification tapped
Stale notification
Multiple devices
Back navigation
Empty database
Unexpected Firebase data
```

Add application-specific edge cases from my idea.

---

# 22. SECURITY THREAT REVIEW

Review the planned architecture for:

* unauthorized reads
* unauthorized writes
* UID manipulation
* role manipulation
* client-side authorization bypass
* insecure data exposure
* notification data leakage
* excessive database access
* weak validation

Provide mitigations using the allowed Firebase architecture.

---

# 23. PERFORMANCE PLAN

Identify:

* realtime listeners
* one-time reads
* frequently accessed data
* expensive queries
* potentially large datasets
* pagination needs
* caching opportunities
* unnecessary rebuilds
* listener lifecycle

Do not over-optimize.

Only identify meaningful performance concerns.

---

# 24. PROJECT ARCHITECTURE

After understanding the product, propose the Flutter architecture.

Define:

```text
lib/
├── core/
├── features/
├── shared/
└── ...
```

Explain:

* responsibility of each layer
* state management approach
* repository pattern if needed
* model structure
* Firebase abstraction
* navigation
* dependency injection if needed
* reusable UI components

Do not over-engineer.

---

# 25. DEVELOPMENT PHASES

Create a complete development roadmap.

Example:

```text
Phase 1
Foundation

Phase 2
Firebase Setup

Phase 3
Authentication

Phase 4
Core User/Profile

Phase 5
Feature A

Phase 6
Feature B

Phase 7
Notifications

Phase 8
Security Rules

Phase 9
Responsive UI

Phase 10
Testing

Phase 11
Final Audit
```

Adapt this to the actual application.

For every phase list:

* objective
* dependencies
* screens
* components
* Firebase work
* validation
* completion criteria

---

# 26. DEPENDENCY GRAPH

Identify which features depend on other features.

Example:

```text
Firebase Setup
      ↓
Authentication
      ↓
User Profile
      ↓
Role System
      ↓
Feature A
      ↓
Feature B
      ↓
Notifications
```

This prevents implementation in the wrong order.

---

# 27. MVP VS FUTURE

Separate:

### Required for MVP

Things absolutely necessary for the product defined by my idea.

### Optional Improvements

Useful but not required.

### Future Features

Features that should NOT be implemented now.

Do not allow future ideas to unnecessarily complicate the MVP architecture.

---

# 28. FINAL PRODUCT BLUEPRINT

At the end provide one consolidated blueprint containing:

```text
1. Product Summary

2. Target Users

3. User Roles

4. Complete Feature List

5. Complete Screen List

6. Navigation Architecture

7. User Journeys

8. Business Rules

9. Missing Requirements

10. Ambiguities

11. Contradictions

12. Firebase Auth Architecture

13. RTDB Architecture

14. Security Model

15. FCM Architecture

16. UI/UX Design System

17. Responsive Strategy

18. State Matrix

19. Error Matrix

20. Data Flow

21. Flutter Architecture

22. Development Phases

23. Dependency Graph

24. MVP Scope

25. Future Scope

26. Testing Strategy

27. Final Acceptance Criteria
```

---

# 29. IMPORTANT FINAL RULE

After producing the blueprint:

**STOP.**

Do not start coding.

Do not create files.

Do not modify the existing project.

Do not implement anything.

Wait for my explicit instruction to move to the implementation phase.

The planning phase is successful only when the application can be explained completely enough that another senior engineer could implement it without having to guess the product behavior.

My next message will contain the complete project idea.

Analyze it deeply and create the complete blueprint.
ss
