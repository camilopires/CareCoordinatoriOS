# CareCoordinator iOS — Product Requirements Document

**Version:** 1.0
**Date:** 2026-03-01
**Author:** Camilo Pires
**Status:** Draft

---

## 1. Executive Summary

We're building **CareCoordinator**, a privacy-first iOS app for individuals managing home care, to solve the problem of coordinating multiple rotating carers without a dedicated tool — currently done through WhatsApp groups, spreadsheets, and paper schedules that leak private information and create scheduling chaos. The app will enable clients to set up custom rotation patterns with auto-generated shifts, manage PTO and ad-hoc cover, share encrypted care plans, coordinate handover tasks, and provide an on-device AI assistant ("Care-y") — all while enforcing strict privacy boundaries so carers never need to know each other's identities or schedules unless the client chooses otherwise. This will reduce scheduling errors, protect carer privacy, improve handover quality, and give clients confidence that care is coordinated securely.

---

## 2. Problem Statement

### Problem Framing Narrative

**I am:** A family member (adult child, spouse, or guardian) managing home care for a loved one who requires 24/7 or near-constant care support.
- I coordinate 2-5 carers who rotate on a recurring schedule (typically one week on, one week off)
- I am not a care agency — I'm an individual hiring carers directly or through informal arrangements
- I am protective of everyone's privacy and want carers to focus on care, not workplace politics
- I am not technical — I use my iPhone daily but don't want to manage complex systems

**Trying to:**
- Ensure continuous, high-quality care coverage with no gaps or double-bookings
- Keep carers informed of their own schedules without exposing other carers' information
- Handle time-off requests and find cover without last-minute panic
- Maintain up-to-date care plans that every carer can access during their shift
- Track handover tasks so nothing falls through the cracks when carers swap

**But:**
- Current tools (WhatsApp, Google Sheets, paper calendars) expose everyone's information to everyone, creating privacy violations and interpersonal conflicts between carers
- Scheduling changes require manually updating multiple places and notifying multiple people, leading to missed updates and scheduling errors
- There's no secure way to share sensitive care plan documents — they end up in WhatsApp chats or email threads
- Handover quality depends entirely on whether the outgoing carer remembers to brief the incoming one — there's no structured process
- Finding cover for time-off requests involves a chain of phone calls with no central visibility of who's available

**Because:**
- No existing app is designed for the individual care coordinator use case — care agency software is enterprise-grade and expensive, while generic scheduling apps don't understand care-specific needs like privacy between carers, care plan management, or handover checklists

**Which makes me feel:**
- Anxious that a scheduling gap will leave my loved one without care
- Frustrated by the constant manual coordination overhead
- Worried about privacy violations when carers see each other's personal information
- Guilty when handover issues affect care quality
- Overwhelmed managing what feels like a small business with no proper tools

### Context & Constraints

- Must work on iPhone (iOS 17+), the primary device for the target demographic
- Care data is highly sensitive — medical plans, personal schedules, contact information
- Users are non-technical; the app must be intuitive without training
- Indie developer project — architecture must be maintainable by a solo developer
- Carers may have limited tech literacy — their experience must be extremely simple
- Internet connectivity may be intermittent (carers in rural care settings) — offline capability needed
- Regulatory awareness: while not initially targeting HIPAA/GDPR compliance certification, the architecture should respect the spirit of health data protection

### Final Problem Statement

Individual care coordinators need a secure, private way to manage rotating carer schedules, handovers, and care plans because no existing tool is designed for this use case — forcing them into privacy-violating workarounds that create scheduling errors, handover gaps, and constant anxiety about care continuity.

---

## 3. Target Users & Personas

### Primary Persona: Coordinator Claire

**Bio & Demographics:**
- 40-55 years old, managing care for an aging parent or disabled family member
- Lives in urban/suburban areas (UK, US, Australia, Ireland — English-speaking markets)
- Uses iPhone daily (messaging, banking, calendar) but not a power user
- Married with her own family responsibilities; managing care is an additional role
- Works part-time or has adjusted career to accommodate care coordination
- Active in local community, may be part of carer support groups on Facebook

**Quotes:**
- "I spend Sunday evenings updating a spreadsheet and sending WhatsApp messages to confirm next week's schedule. It takes an hour every single week."
- "One of my carers found out another carer's name and phone number from the group chat. It caused a huge problem — I promised them anonymity."
- "When Sarah called in sick on Tuesday, I spent 3 hours calling around to find cover. My mum was alone for 2 hours before I sorted it."
- "I printed the care plan and left it in a folder, but the new carer couldn't find it. The medication was given late."

**Pains:**
- Spends 3-5 hours/week on manual scheduling coordination
- Privacy breaches through shared communication channels cause carer conflicts and trust issues
- No structured handover process — critical information gets lost between shifts
- PTO/sick leave creates emergency scrambles with no visibility of who's available
- Care plan documents are scattered across email, WhatsApp, and paper

**What is This Person Trying to Accomplish?:**
- Maintain 24/7 care coverage with zero gaps
- Protect carer privacy while keeping everyone informed about their own responsibilities
- Reduce personal time spent on coordination so they can focus on their own life
- Ensure every carer has immediate access to current care plans during their shift
- Create a reliable handover process that works even when carers don't communicate directly

**Goals:**
- Short-term: Eliminate the Sunday evening scheduling ritual — automate it
- Medium-term: Feel confident that care is covered even when plans change
- Long-term: Reclaim personal time and reduce the emotional burden of care coordination
- Aspirational: Know that care quality is consistent regardless of which carer is on duty

**Attitudes & Influences:**
- **Decision-Making Authority:** Full authority — they hire and manage carers directly
- **Decision Influencers:** Other family members managing care, online carer communities, word-of-mouth from friends in similar situations
- **Beliefs & Attitudes:** Values privacy highly (has seen the damage of information leaks); skeptical of "enterprise" tools that feel corporate; willing to pay for something that genuinely reduces stress; prefers Apple ecosystem for its privacy reputation

---

### Secondary Persona: Carer Casey

**Bio & Demographics:**
- 25-50 years old, professional carer (home care aide, live-in carer, agency or freelance)
- May work with multiple clients across different care setups
- Uses iPhone or Android (but this app is iOS-only for v1)
- Varying tech literacy — some are very comfortable with apps, others prefer simplicity
- Values clear boundaries between work and personal life

**Quotes:**
- "I just want to know when I'm working and what I need to do. I don't need to know anything about the other carers."
- "Last time I asked for a day off, it took 4 days to get a response. I didn't know if I was covered or not."
- "The care plan was in a binder that was 6 months out of date. I had to call the family at 10pm to check a medication dose."

**Pains:**
- Unclear or late schedule communication
- No structured way to request time off and track approval
- Outdated or inaccessible care plan documents
- Being exposed to other carers' personal information (unwanted)
- No clear handover process — relying on notes left on the kitchen counter

**Goals:**
- Know my schedule clearly and well in advance
- Request time off easily and get a quick response
- Access up-to-date care plans instantly during shifts
- Complete handover tasks confidently without needing to contact other carers directly

---

## 4. Strategic Context

### Business Goals

As an indie developer project, the business goals are:

1. **Build a viable product** that solves a real problem for a clearly defined niche
2. **Reach product-market fit** with individual care coordinators in English-speaking markets
3. **Generate sustainable revenue** through a subscription model (freemium or paid)
4. **Establish trust** as a privacy-first care coordination tool

### Market Opportunity

- **TAM:** ~10M individuals globally who coordinate home care for family members (aging population trend accelerating in UK, US, AU, IE, CA)
- **SAM:** ~3M of these who use iPhones, coordinate 2+ carers, and are tech-comfortable enough to use a dedicated app
- **SOM:** ~50K early adopters in UK/Ireland market (strong home care culture, iPhone penetration) reachable through targeted marketing in carer communities

### Competitive Landscape

| Competitor | Gap |
|---|---|
| **Care agency software** (Birdie, CareLineLive, Homecare.co.uk) | Designed for agencies, not individuals. Enterprise pricing ($200+/month). Overkill features. |
| **Generic scheduling apps** (When I Work, Deputy) | No care-specific features. No privacy model between workers. No care plans. |
| **Shared calendars** (Google Calendar, Apple Calendar) | No privacy between users. No PTO flow. No task management. No care plans. |
| **WhatsApp/messaging groups** | Privacy nightmare. No structure. Information gets buried. No scheduling automation. |

**Gap:** No product exists for the *individual* care coordinator who hires and manages carers directly. This is an underserved niche between "no tool" and "enterprise care agency software."

### Why Now?

- **Aging population:** Demand for home care is growing 5-8% annually in target markets
- **Post-COVID shift:** More families choosing home care over residential facilities
- **Privacy awareness:** Growing concern about personal data in care settings (UK Data Protection Act, GDPR awareness)
- **Apple Foundation Models:** iOS 18.1 enables on-device AI without sending sensitive data to the cloud — a unique privacy advantage
- **Supabase maturity:** Row-level security and real-time capabilities make it feasible for a solo developer to build secure multi-user apps

---

## 5. Solution Overview

### High-Level Description

CareCoordinator is a native iOS app (SwiftUI) backed by Supabase (Postgres + Auth + Storage + Realtime) that provides:

1. **A scheduling engine** that auto-generates shifts from client-defined rotation patterns
2. **Privacy-enforced data access** where carers see only what the client permits (full isolation, anonymous, or open)
3. **PTO and cover management** with approval workflows and availability broadcasting
4. **Encrypted care plan storage** with in-app PDF viewing
5. **Structured task management** including recurring handover checklists and general task lists
6. **An on-device AI assistant (Care-y)** powered by Apple Foundation Models for natural-language queries about schedules, tasks, and care plans
7. **Calendar integration** for one-way shift export to device calendar
8. **Push notifications** for schedule changes, PTO requests, task assignments, and join requests

### Architecture

```
┌─────────────────────────────────────────────┐
│              iOS App (SwiftUI)               │
│  ┌─────────┐ ┌──────────┐ ┌──────────────┐  │
│  │Schedule  │ │Tasks     │ │Care Plans    │  │
│  │Engine    │ │Manager   │ │Viewer (PDF)  │  │
│  ├─────────┤ ├──────────┤ ├──────────────┤  │
│  │PTO &    │ │Care-y AI │ │Calendar      │  │
│  │Coverage  │ │(On-Device)│ │Export        │  │
│  └────┬────┘ └────┬─────┘ └──────┬───────┘  │
│       │           │               │          │
│  ┌────┴───────────┴───────────────┴───────┐  │
│  │     Repository Layer (MVVM)            │  │
│  │     + CryptoKit E2EE Layer             │  │
│  └────────────────┬───────────────────────┘  │
└───────────────────┼──────────────────────────┘
                    │ HTTPS/TLS 1.3
┌───────────────────┼──────────────────────────┐
│              Supabase                        │
│  ┌────────────────┴───────────────────────┐  │
│  │          Row-Level Security            │  │
│  ├────────────┬───────────┬───────────────┤  │
│  │ Postgres   │ Auth      │ Storage       │  │
│  │ (Data)     │ (Users)   │ (PDFs)        │  │
│  ├────────────┼───────────┼───────────────┤  │
│  │ Realtime   │ Push via  │ Audit Log     │  │
│  │ (Sync)     │ APNs      │               │  │
│  └────────────┴───────────┴───────────────┘  │
└──────────────────────────────────────────────┘
```

### Tech Stack

| Component | Technology |
|---|---|
| UI Framework | SwiftUI (iOS 17+ minimum) |
| Backend | Supabase (Postgres + Auth + Storage + Realtime) |
| AI | Apple Foundation Models (iOS 18.1+) |
| Calendar | EventKit |
| Encryption | CryptoKit (AES-GCM, Curve25519) |
| Local Storage | SwiftData for caching, Keychain for secrets |
| PDF | PDFKit (built-in) |
| Push Notifications | APNs via Supabase |
| Architecture Pattern | MVVM with repository layer |

### Key Features

#### 5.1 Scheduling Engine

**Rotation patterns:** Client defines a custom rotation — an ordered list of carer assignments per week. Examples:
- 2 carers: `[A, B, A, B, ...]` (alternating weeks)
- 3 carers: `[A, A, B, C, A, A, B, C, ...]` (custom pattern)
- Any pattern the client defines

**Shift templates:** Client configures shift start/end times per day (e.g., 8am-8pm for 12hr shifts). Can vary by day if needed.

**Auto-generation:** When rotation is saved, app generates shift records for a 12-week look-ahead. Automatically extends as time passes.

**Shift statuses:** `scheduled` → `covered` (reassigned due to PTO) → `completed` / `cancelled`

#### 5.2 Privacy Controls

Three modes, set per care group by the client:

| Mode | Carer sees own shifts | Carer sees other shifts | Carer sees names |
|---|---|---|---|
| **Full** | Yes | No | No |
| **Anonymous** | Yes | Yes (as "Another carer") | No |
| **Open** | Yes | Yes | Yes |

Enforced at the database level via Supabase Row-Level Security. The app never receives data the user isn't authorized to see.

#### 5.3 PTO & Coverage

1. Carer submits PTO request for specific dates
2. Client receives push notification, reviews in-app
3. Client approves or denies
4. On approval, affected shifts are flagged as needing cover
5. Client can: manually assign a replacement OR broadcast to available carers
6. Available carers receive notification and can claim the shift
7. Client confirms the assignment

#### 5.4 Carer Availability

Carers can submit dates/times they're available for extra shifts. This data:
- Feeds into the PTO cover flow (client sees who's available)
- Informs Care-y's responses ("Who can cover Monday?")
- Is visible only to the client (privacy-respecting)

#### 5.5 Care Plans

- Client uploads PDF care plans to Supabase Storage
- PDFs are E2E encrypted before upload (using CryptoKit AES-GCM)
- All carers in the care group can view care plans in-app via PDFKit
- One care plan set per care group (all carers see the same documents)
- Client can upload multiple PDFs (medication, daily routine, emergency procedures)

#### 5.6 Task System

**Swapover Checklist:**
- Client creates a template with handover items (e.g., "Check medication supply", "Update care log")
- When a rotation swap occurs, the app generates a fresh instance from the template
- Outgoing carer checks off items during handover
- Client sees completion status and history

**General Tasks:**
- Client creates tasks with title, description, optional due date, priority
- Visible to whoever is currently on shift (determined by schedule)
- Supports one-off and recurring tasks (daily, weekly, custom)
- Client sees task completion history

**Privacy in tasks:** Task visibility and completion attribution follow the same privacy mode as shifts.

#### 5.7 Care-y AI Assistant

- Powered by Apple Foundation Models (on-device, iOS 18.1+)
- Both client and carers can use it
- Context-aware: queries answered against the user's permitted data only
- Carer queries are privacy-filtered — cannot access other carers' data in full/anonymous mode
- Conversation history stored on-device only (not synced to server)
- Graceful degradation: if Apple Intelligence is unavailable, Care-y disables with an explanatory message

Example queries:
- Client: "Who's working next Tuesday?" → "Sarah is scheduled for 8am-8pm."
- Client: "Who can cover Monday?" → "Based on availability, James and Maria are free."
- Carer: "When's my next shift?" → "Monday March 8th, 8am to 8pm."
- Carer: "What are the medication instructions?" → Extracted from care plan PDF.
- Carer (full privacy): "Who works after me?" → "I can't share other carers' schedules."

#### 5.8 Calendar Integration

- One-way export: shifts sync to device calendar via EventKit
- Each shift becomes a calendar event with title, time, location (if set), and notes
- Changes in-app automatically update calendar events
- Carer controls whether to enable (permission prompt)
- Client can also export the full schedule view

#### 5.9 Shift Notes

- Encrypted free-form text notes a carer can leave for the next carer
- "FYI, patient was feeling unwell today" or "Medication delivered, stored in kitchen cabinet"
- Visibility follows privacy mode (full: only visible to client and next on-shift carer; anonymous/open: visible to relevant carers without attribution in anonymous mode)

#### 5.10 Medication/Appointment Reminders

- Client sets up time-based reminders (e.g., "Medication at 2pm daily", "Physio appointment Thursday 10am")
- Push notification sent to whichever carer is on shift at that time
- Recurring or one-off
- Carer marks reminder as acknowledged/completed

#### 5.11 Emergency Contacts

- Client stores emergency contacts in the care group (doctor, hospital, family members)
- One-tap call from the app
- Visible to all carers during their shifts

#### 5.12 Activity Log

- Client-facing timeline of care group activity
- Shows: shift started/ended, task completed, PTO requested/approved, care plan updated, reminder acknowledged
- Filterable by date, carer (if open mode), event type
- Gives client oversight without micromanaging

#### 5.13 Offline Mode

- Current week's schedule, active tasks, and care plans cached locally (SwiftData)
- App functions offline for viewing schedule, completing tasks, viewing care plans
- Changes queue locally and sync when connectivity returns
- Conflict resolution: server wins for schedule data, merge for task completions

### Invite & Onboarding Flow

1. Client creates account (email/password or Sign in with Apple)
2. Client creates a care group and configures settings (shift times, privacy mode, rotation)
3. Client generates an invite code (unique, time-limited, single or multi-use)
4. Client shares invite code with carer (text, email, in-person)
5. Carer downloads app, creates account, enters invite code
6. Join request appears in client's app with push notification
7. Client approves or denies
8. On approval, carer gains access to their permitted data

---

## 6. Success Metrics

### Primary Metric
**Weekly Active Care Groups** — number of care groups with at least one shift completed per week
- **Target (6 months post-launch):** 500 active care groups
- **Rationale:** This measures real adoption — people using the scheduling engine in their daily care coordination

### Secondary Metrics

| Metric | Current (no app) | Target | Timeline |
|---|---|---|---|
| Time spent on weekly scheduling | ~3-5 hrs (manual) | < 30 min | 3 months post-launch |
| Scheduling errors (missed shifts) | ~2-3/month (anecdotal) | 0 | 3 months post-launch |
| Handover checklist completion rate | 0% (no process) | > 80% | 3 months post-launch |
| PTO request resolution time | 1-4 days (phone tag) | < 24 hours | 3 months post-launch |
| App Store rating | N/A | 4.5+ stars | 6 months post-launch |
| Carer onboarding time (invite to first login) | N/A | < 10 minutes | At launch |

### Guardrail Metrics

- **App crashes:** < 1% of sessions
- **Data sync latency:** < 3 seconds for schedule updates
- **PDF load time:** < 5 seconds for care plan documents
- **Carer privacy violations:** Zero (any privacy leak is a P0 bug)

---

## 7. User Stories & Requirements

### Epic Hypothesis

We believe that building a privacy-first care scheduling app for individual care coordinators will attract 500+ active care groups within 6 months because there is no existing tool designed for this use case — individual coordinators are currently forced to use generic tools that violate carer privacy, create scheduling chaos, and provide no structured handover process.

We'll measure success by weekly active care groups, scheduling error reduction, and handover checklist completion rates.

### User Stories

---

#### Epic 1: Authentication & Onboarding

**Story 1.1: Client account creation**
As a client, I want to create an account with email/password or Sign in with Apple, so I can securely access my care group.

Acceptance Criteria:
- [ ] Sign in with Apple flow works end-to-end
- [ ] Email/password registration with email verification
- [ ] Password requirements: 8+ characters, 1 uppercase, 1 number
- [ ] Account created in Supabase Auth
- [ ] Profile record created with role = 'client'

**Story 1.2: Care group creation**
As a client, I want to create a care group and configure basic settings, so I have a space to manage my care coordination.

Acceptance Criteria:
- [ ] Client can name the care group
- [ ] Client selects privacy mode (full/anonymous/open) with clear explanations of each
- [ ] Client sets default shift times (start/end)
- [ ] Care group record created in database with client as owner
- [ ] E2EE group key generated and stored in client's Keychain

**Story 1.3: Invite code generation**
As a client, I want to generate a unique invite code to share with carers, so they can request to join my care group.

Acceptance Criteria:
- [ ] Client taps "Invite Carer" and a unique code is generated
- [ ] Code has configurable expiry (default 7 days)
- [ ] Client can copy code to clipboard or share via share sheet
- [ ] Code is single-use by default, with option for multi-use
- [ ] Client can revoke unexpired codes

**Story 1.4: Carer join request**
As a carer, I want to enter an invite code after creating my account, so I can request to join a care group.

Acceptance Criteria:
- [ ] Carer creates account (email/password or Sign in with Apple)
- [ ] Carer enters invite code on a dedicated screen
- [ ] Invalid/expired codes show clear error message
- [ ] Valid code creates a join request (status: pending)
- [ ] Client receives push notification of the join request

**Story 1.5: Client approves/denies join request**
As a client, I want to approve or deny carer join requests, so I control who has access to my care group.

Acceptance Criteria:
- [ ] Client sees pending join requests in the Carers section
- [ ] Client can approve (carer gains access) or deny (carer is notified)
- [ ] On approval, E2EE group key is securely shared with the carer
- [ ] On approval, carer appears in the care group's carer list
- [ ] On denial, carer sees a "request denied" message

---

#### Epic 2: Scheduling Engine

**Story 2.1: Define rotation pattern**
As a client, I want to define a custom rotation pattern specifying which carer works each week, so the schedule auto-generates from my pattern.

Acceptance Criteria:
- [ ] Client sees a visual rotation builder
- [ ] Client can add carers from the approved list to specific week positions
- [ ] Pattern length is configurable (2-12 weeks before repeating)
- [ ] Client can reorder the rotation
- [ ] Pattern is saved and can be edited later
- [ ] Clear preview of what the next 4 weeks will look like

**Story 2.2: Configure shift times**
As a client, I want to set shift start and end times, so the auto-generated schedule has the correct hours.

Acceptance Criteria:
- [ ] Client sets default shift start time and end time
- [ ] Supports 12-hour shifts and other durations
- [ ] Can set different times for different days (optional)
- [ ] Times are displayed in the user's local timezone

**Story 2.3: Auto-generate shifts**
As a client, I want shifts to be automatically generated from my rotation pattern, so I don't have to create each shift manually.

Acceptance Criteria:
- [ ] On saving rotation pattern, shifts are generated for 12 weeks ahead
- [ ] Each shift record has: date, start_time, end_time, carer_id, status (scheduled)
- [ ] As time passes, new shifts are auto-generated to maintain 12-week look-ahead
- [ ] Changes to rotation pattern regenerate future shifts (not past ones)
- [ ] Client is warned before regenerating if manual edits exist on future shifts

**Story 2.4: View schedule**
As a client, I want to view the full schedule in calendar and list views, so I can see the complete care coverage picture.

Acceptance Criteria:
- [ ] Calendar view: month view with colored indicators per carer
- [ ] List view: chronological list of shifts with date, time, carer name
- [ ] Tap on a shift shows full details
- [ ] Can filter by carer
- [ ] Shows today clearly highlighted

**Story 2.5: Carer views own schedule**
As a carer, I want to see my upcoming shifts in a clear view, so I know when I'm working.

Acceptance Criteria:
- [ ] Carer sees only their own shifts (or privacy-filtered view per care group settings)
- [ ] Calendar and list view options
- [ ] Next shift prominently displayed on dashboard
- [ ] Shift details show: date, start time, end time, any notes

**Story 2.6: Edit individual shift**
As a client, I want to manually edit a specific shift (change carer, time, or cancel), so I can handle exceptions to the rotation.

Acceptance Criteria:
- [ ] Client can tap a shift and edit: reassign to different carer, change times, cancel
- [ ] Affected carer(s) receive push notification of the change
- [ ] Edit is logged in activity log
- [ ] Manually edited shifts are marked so they're not overwritten by rotation regeneration

---

#### Epic 3: PTO & Coverage

**Story 3.1: Carer requests PTO**
As a carer, I want to request time off for specific dates, so the client knows I need coverage.

Acceptance Criteria:
- [ ] Carer selects date range for PTO request
- [ ] Can add a reason (optional)
- [ ] Request is submitted with status "pending"
- [ ] Client receives push notification
- [ ] Carer sees request status (pending/approved/denied)

**Story 3.2: Client reviews PTO request**
As a client, I want to approve or deny PTO requests and see which shifts are affected, so I can plan coverage.

Acceptance Criteria:
- [ ] Client sees PTO request with affected shifts listed
- [ ] Client can approve or deny with optional message
- [ ] On approval, affected shifts are flagged as "needing cover"
- [ ] Carer is notified of the decision

**Story 3.3: Client manually assigns cover**
As a client, I want to manually assign a specific carer to cover an open shift, so I can directly arrange coverage.

Acceptance Criteria:
- [ ] Client sees list of other carers in the group
- [ ] Client selects a carer and assigns them to the open shift
- [ ] Assigned carer receives push notification
- [ ] Shift status changes from "needing cover" to "covered"

**Story 3.4: Client broadcasts open shift**
As a client, I want to broadcast an open shift to available carers, so they can volunteer to cover it.

Acceptance Criteria:
- [ ] Client taps "Broadcast" on an open shift
- [ ] All carers who have marked availability for that date are notified
- [ ] Carers can accept or decline the offer
- [ ] First to accept gets the shift (or client chooses if multiple accept simultaneously)
- [ ] Shift status updates to "covered"

**Story 3.5: Carer submits availability**
As a carer, I want to submit dates I'm available for extra shifts, so the client knows when I can cover.

Acceptance Criteria:
- [ ] Carer can select date ranges they're available
- [ ] Can set recurring availability (e.g., "available every Tuesday")
- [ ] Availability is visible to the client only
- [ ] Availability feeds into the broadcast/cover flow

---

#### Epic 4: Care Plans

**Story 4.1: Client uploads care plan PDF**
As a client, I want to upload care plan documents as PDFs, so carers can access them during shifts.

Acceptance Criteria:
- [ ] Client can upload PDF files from device or iCloud
- [ ] Multiple PDFs supported (medication, daily routine, emergency, etc.)
- [ ] PDFs are E2E encrypted before upload to Supabase Storage
- [ ] Client can add a title/category to each document
- [ ] Upload progress shown

**Story 4.2: Carer views care plan**
As a carer, I want to view care plan PDFs in the app, so I have immediate access to care instructions during my shift.

Acceptance Criteria:
- [ ] Carer sees list of available care plans with titles
- [ ] Tap to view opens PDF in-app (PDFKit)
- [ ] PDF is decrypted on-device before display
- [ ] Supports zooming and scrolling
- [ ] Available offline (cached locally after first view)

**Story 4.3: Client updates/replaces care plan**
As a client, I want to replace an outdated care plan with a new version, so carers always have current instructions.

Acceptance Criteria:
- [ ] Client can replace an existing PDF
- [ ] All carers' cached copies are invalidated on next sync
- [ ] Activity log records the update
- [ ] Push notification sent to on-shift carer

---

#### Epic 5: Task Management

**Story 5.1: Client creates swapover checklist template**
As a client, I want to create a handover checklist template, so there's a consistent process when carers swap.

Acceptance Criteria:
- [ ] Client can add/remove/reorder checklist items
- [ ] Items have a title and optional description
- [ ] Template is saved and persists
- [ ] Client can edit template at any time

**Story 5.2: Swapover checklist auto-generates**
As a carer, I want to see a fresh handover checklist when my shift ends and another carer's begins, so I complete all handover tasks.

Acceptance Criteria:
- [ ] Checklist instance generated at the start of the last shift before a rotation swap
- [ ] Instance contains all items from the current template
- [ ] Each item starts unchecked
- [ ] Previous instances are preserved for history

**Story 5.3: Carer completes swapover checklist**
As a carer, I want to check off handover items, so the client knows handover was completed properly.

Acceptance Criteria:
- [ ] Carer can tap items to check/uncheck
- [ ] Completion is synced to server in real-time
- [ ] Client can see completion status and who completed each item (respecting privacy mode)
- [ ] Incomplete checklists are flagged for the client

**Story 5.4: Client creates general tasks**
As a client, I want to create tasks for carers to complete during their shifts, so important actions don't get missed.

Acceptance Criteria:
- [ ] Client creates task with: title, description, optional due date, priority (low/medium/high)
- [ ] Task can be one-off or recurring (daily, weekly, custom interval)
- [ ] Task is visible to the carer who is currently on shift
- [ ] Client can edit or delete tasks

**Story 5.5: Carer views and completes tasks**
As a carer, I want to see my active tasks and mark them complete, so the client knows work was done.

Acceptance Criteria:
- [ ] Carer sees tasks relevant to their current shift
- [ ] Can mark tasks as complete
- [ ] Completed tasks show timestamp
- [ ] Recurring tasks reappear at their next interval

---

#### Epic 6: Care-y AI Assistant

**Story 6.1: Open Care-y chat**
As a user (client or carer), I want to open a chat interface with Care-y, so I can ask natural-language questions about my care group.

Acceptance Criteria:
- [ ] Chat UI with message input and conversation history
- [ ] On-device processing via Apple Foundation Models
- [ ] If Apple Intelligence is unavailable, show clear message explaining the requirement
- [ ] Conversation history persisted on-device only

**Story 6.2: Query schedule information**
As a user, I want to ask Care-y schedule questions, so I get quick answers without navigating the app.

Acceptance Criteria:
- [ ] Client can ask: "Who's working [date]?", "When does [carer] work next?"
- [ ] Carer can ask: "When's my next shift?", "Am I working this weekend?"
- [ ] Responses are accurate based on current schedule data
- [ ] Privacy enforced: carer queries cannot expose other carers' data in full/anonymous mode

**Story 6.3: Query care plan information**
As a carer, I want to ask Care-y questions about the care plan, so I get quick answers about care instructions.

Acceptance Criteria:
- [ ] Care-y can answer questions about care plan content (extracted from PDFs)
- [ ] Examples: "What are the medication instructions?", "What's the emergency procedure?"
- [ ] Responses reference the relevant care plan document

**Story 6.4: Query task and availability information**
As a client, I want to ask Care-y about tasks and availability, so I can make quick decisions.

Acceptance Criteria:
- [ ] Client can ask: "Who can cover Monday?", "Are there incomplete tasks?"
- [ ] Responses based on availability data and task completion status

---

#### Epic 7: Calendar & Notifications

**Story 7.1: Export shifts to device calendar**
As a carer, I want my shifts to appear in my iPhone calendar, so I see them alongside my personal events.

Acceptance Criteria:
- [ ] Carer enables calendar sync in settings (EventKit permission prompt)
- [ ] Shifts are created as calendar events with: title, start/end time, notes
- [ ] Changes to shifts update the calendar events
- [ ] Cancelled shifts remove the calendar event
- [ ] Uses a dedicated calendar (e.g., "CareCoordinator") for easy management

**Story 7.2: Receive push notifications**
As a user, I want to receive push notifications for important events, so I don't miss critical updates.

Acceptance Criteria:
- [ ] Notifications for: join requests (client), PTO requests (client), shift changes (affected carer), task assignments (carer), open shift broadcasts (available carers), PTO decisions (requesting carer), reminders (on-shift carer)
- [ ] Notification preferences configurable in settings
- [ ] Tapping a notification navigates to the relevant screen

---

#### Epic 8: Shift Notes, Reminders & Emergency

**Story 8.1: Carer leaves shift notes**
As a carer, I want to leave notes at the end of my shift, so important observations are communicated.

Acceptance Criteria:
- [ ] Free-form text entry at end of shift (or any time during shift)
- [ ] Notes are E2E encrypted
- [ ] Visible to client always; visible to next on-shift carer based on privacy mode
- [ ] Notes appear in activity log

**Story 8.2: Client sets medication/appointment reminders**
As a client, I want to set time-based reminders, so the on-shift carer is prompted for important care tasks.

Acceptance Criteria:
- [ ] Client creates reminder with: title, time, recurrence (one-off, daily, weekly, custom)
- [ ] Push notification sent to whichever carer is on shift at reminder time
- [ ] Carer acknowledges the reminder in-app
- [ ] Client sees acknowledgment status

**Story 8.3: Access emergency contacts**
As a carer, I want to quickly call emergency contacts, so I can reach the right people in an emergency.

Acceptance Criteria:
- [ ] Client stores emergency contacts (name, phone, relationship)
- [ ] Carers see emergency contacts prominently during shifts
- [ ] One-tap to call

---

#### Epic 9: Activity Log & Offline

**Story 9.1: Client views activity log**
As a client, I want to see a timeline of everything that happened in my care group, so I have oversight.

Acceptance Criteria:
- [ ] Timeline shows: shift started/ended, tasks completed, PTO requested/approved, care plans updated, reminders acknowledged, notes added
- [ ] Filterable by date range, event type, carer (if privacy allows)
- [ ] Newest events first

**Story 9.2: Offline mode**
As a carer, I want the app to work when I don't have internet, so I can still view my schedule and care plans.

Acceptance Criteria:
- [ ] Current week's schedule cached locally
- [ ] Active tasks cached locally
- [ ] Care plan PDFs cached after first view
- [ ] Task completions and notes queue locally, sync when online
- [ ] Clear visual indicator when app is offline
- [ ] Conflict resolution: server wins for schedule, merge for task completions

---

### Edge Cases & Constraints

- **Carer in multiple care groups:** Support future ability for one carer account to belong to multiple care groups (different clients)
- **Timezone handling:** All times stored in UTC, displayed in user's local timezone
- **Rotation mid-change:** When client changes rotation pattern mid-week, current week is not affected; changes take effect from next rotation cycle
- **Carer removal:** When a carer is removed from a group, their future shifts are unassigned (need cover), their past data is retained for audit, and the E2EE group key is rotated
- **Device change:** E2EE keys must be recoverable — use iCloud Keychain sync or a recovery flow
- **Concurrent edits:** Supabase Realtime handles concurrent access; last-write-wins for most fields, with conflict UI for critical fields (shift assignments)

---

## 8. Out of Scope

**Not included in v1:**

| Feature | Reason |
|---|---|
| Android app | iOS-first to reduce scope. Android can follow if product-market fit is proven. |
| Web dashboard | Native iOS is the primary experience. Web can be added for client-side convenience later. |
| Agency/multi-client management | This is for individual coordinators, not agencies. Different product. |
| In-app messaging between users | Messaging is complex and carers shouldn't need to communicate through the app (privacy). They have their own channels. |
| Video/photo sharing | Scope creep. Care plans cover documentation needs for v1. |
| Payroll/invoicing | Out of domain. Carers are paid through their own arrangements. |
| AI-generated care plans | v1 uses Care-y for queries only. Generating care content requires medical expertise validation. |
| Apple Watch app | Nice-to-have for shift reminders, but not v1. |
| Automated carer matching/marketplace | This is a coordination tool, not a marketplace. |
| HIPAA/GDPR compliance certification | Architecture respects privacy principles, but formal certification is a v2+ effort requiring legal counsel. |

**Future consideration (v2+):**
- Android app
- Web dashboard for clients
- Apple Watch companion (shift reminders, task completion)
- Multi-care-group support for carers
- Advanced AI: Care-y suggesting schedule optimizations
- Integration with health monitoring devices
- Family member read-only access (e.g., siblings who want visibility but don't manage)

---

## 9. Dependencies & Risks

### Dependencies

| Dependency | Impact | Mitigation |
|---|---|---|
| Supabase account & project | Required for all backend functionality | Free tier sufficient for development and early users |
| Apple Developer account | Required for App Store, push notifications, Sign in with Apple | Already available (indie dev) |
| Apple Foundation Models (iOS 18.1+) | Required for Care-y AI | Graceful degradation — Care-y disabled on older iOS with explanation. Core app works on iOS 17+. |
| APNs certificates | Required for push notifications | Standard Apple Developer setup |

### Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| E2EE key management complexity | Medium | High | Start with well-tested CryptoKit primitives. Key recovery via iCloud Keychain. Extensive testing of key rotation flow. |
| Apple Foundation Models limitations | Medium | Medium | Care-y is an enhancement, not core. App fully functional without it. Test early with real queries to understand model capabilities. |
| Supabase free tier limits | Low (early) | Medium (at scale) | Free tier supports ~500MB database, 1GB storage, 50K monthly active users. Upgrade to Pro ($25/month) when approaching limits. |
| Solo developer bottleneck | High | High | Prioritize ruthlessly. Ship MVP with core scheduling + privacy first. Add features incrementally. |
| User adoption / discovery | High | High | Target carer communities (Facebook groups, forums). Word-of-mouth from early users. Consider content marketing (blog about care coordination). |
| Privacy/security breach | Low | Critical | RLS + E2EE + audit logging + security-first development. Regular security review of RLS policies. Penetration testing before launch. |
| Offline sync conflicts | Medium | Medium | Simple conflict resolution (server wins). Queue operations with timestamps. Test extensively with poor connectivity. |

---

## 10. Open Questions

| Question | Status | Notes |
|---|---|---|
| Pricing model (free, freemium, paid?) | Open | Options: free with premium features, $4.99/month subscription, or free for carers + paid for client |
| Should carers be able to swap shifts directly between themselves? | Open | Could add in v2 if privacy mode allows it. For v1, all changes go through client. |
| Maximum number of carers per care group? | Open | Suggest 10 for v1. Most home care setups have 2-5. |
| Should the app require iOS 17 or iOS 18 minimum? | Open | iOS 17 for broader reach (no Care-y). iOS 18.1 needed only for Care-y. Recommend iOS 17 min with Care-y as iOS 18.1+ feature. |
| Care plan PDF text extraction method for Care-y | Open | Options: Vision framework OCR on-device, or require text-based PDFs. Investigate Apple Foundation Models' document understanding capabilities. |
| Push notification delivery via Supabase webhooks or direct APNs? | Open | Supabase can trigger webhooks on DB changes → send via APNs. Evaluate Supabase's push notification support vs. custom APNs integration. |
| App Store review considerations for health-adjacent app | Open | Apple may have specific review guidelines for health/care apps. Research before submission. |

---

## Appendix A: Data Model Reference

### Tables

```
care_groups
├── id (uuid, PK)
├── name (text)
├── privacy_mode (enum: full/anonymous/open)
├── default_shift_start (time)
├── default_shift_end (time)
├── owner_id (uuid, FK → profiles)
├── encrypted_group_key (bytea) -- E2EE group key, encrypted per-user
├── created_at (timestamptz)
└── updated_at (timestamptz)

profiles
├── id (uuid, PK, matches auth.users.id)
├── role (enum: client/carer)
├── care_group_id (uuid, FK → care_groups)
├── display_name (text)
├── email (text)
├── public_key (bytea) -- for E2EE key exchange
├── created_at (timestamptz)
└── updated_at (timestamptz)

rotation_patterns
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── pattern (jsonb) -- ordered array of carer_ids per week
├── created_at (timestamptz)
└── updated_at (timestamptz)

shifts
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── carer_id (uuid, FK → profiles)
├── date (date)
├── start_time (time)
├── end_time (time)
├── status (enum: scheduled/needing_cover/covered/completed/cancelled)
├── is_manually_edited (boolean)
├── original_carer_id (uuid, nullable) -- if covered, who was originally assigned
├── created_at (timestamptz)
└── updated_at (timestamptz)

pto_requests
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── carer_id (uuid, FK → profiles)
├── start_date (date)
├── end_date (date)
├── reason (text, encrypted)
├── status (enum: pending/approved/denied)
├── client_message (text, nullable)
├── created_at (timestamptz)
└── updated_at (timestamptz)

shift_offers
├── id (uuid, PK)
├── shift_id (uuid, FK → shifts)
├── offered_to (uuid, FK → profiles, nullable) -- null = broadcast
├── status (enum: open/accepted/declined/expired)
├── accepted_by (uuid, FK → profiles, nullable)
├── created_at (timestamptz)
└── updated_at (timestamptz)

carer_availability
├── id (uuid, PK)
├── carer_id (uuid, FK → profiles)
├── care_group_id (uuid, FK → care_groups)
├── date (date)
├── start_time (time, nullable) -- null = all day
├── end_time (time, nullable)
├── is_recurring (boolean)
├── recurrence_rule (text, nullable) -- e.g., "WEEKLY:TUE,THU"
├── created_at (timestamptz)
└── updated_at (timestamptz)

care_plans
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── title (text)
├── category (text, nullable) -- medication, routine, emergency, etc.
├── storage_path (text) -- Supabase Storage path
├── file_size (bigint)
├── uploaded_by (uuid, FK → profiles)
├── created_at (timestamptz)
└── updated_at (timestamptz)

tasks
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── type (enum: swapover_template/swapover_instance/general)
├── parent_template_id (uuid, FK → tasks, nullable) -- for instances
├── title (text)
├── description (text, encrypted)
├── priority (enum: low/medium/high)
├── due_date (date, nullable)
├── is_recurring (boolean)
├── recurrence_rule (text, nullable)
├── completed (boolean)
├── completed_by (uuid, FK → profiles, nullable)
├── completed_at (timestamptz, nullable)
├── sort_order (integer)
├── created_at (timestamptz)
└── updated_at (timestamptz)

shift_notes
├── id (uuid, PK)
├── shift_id (uuid, FK → shifts)
├── carer_id (uuid, FK → profiles)
├── content (text, encrypted) -- E2EE
├── created_at (timestamptz)
└── updated_at (timestamptz)

reminders
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── title (text)
├── time (time)
├── is_recurring (boolean)
├── recurrence_rule (text, nullable)
├── created_by (uuid, FK → profiles)
├── created_at (timestamptz)
└── updated_at (timestamptz)

emergency_contacts
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── name (text)
├── phone (text)
├── relationship (text)
├── sort_order (integer)
├── created_at (timestamptz)
└── updated_at (timestamptz)

invitations
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── code (text, unique)
├── created_by (uuid, FK → profiles)
├── max_uses (integer, default 1)
├── times_used (integer, default 0)
├── status (enum: active/revoked/expired)
├── expires_at (timestamptz)
├── created_at (timestamptz)
└── updated_at (timestamptz)

join_requests
├── id (uuid, PK)
├── invitation_id (uuid, FK → invitations)
├── carer_id (uuid, FK → profiles)
├── status (enum: pending/approved/denied)
├── reviewed_at (timestamptz, nullable)
├── created_at (timestamptz)
└── updated_at (timestamptz)

notifications
├── id (uuid, PK)
├── user_id (uuid, FK → profiles)
├── type (enum: join_request/pto_request/shift_change/task_assigned/open_shift/pto_decision/reminder/care_plan_update)
├── title (text)
├── body (text)
├── data (jsonb) -- payload for deep linking
├── read (boolean, default false)
├── created_at (timestamptz)
└── updated_at (timestamptz)

audit_log
├── id (uuid, PK)
├── care_group_id (uuid, FK → care_groups)
├── user_id (uuid, FK → profiles)
├── action (text) -- e.g., "shift.created", "pto.approved", "care_plan.uploaded"
├── details (jsonb)
├── created_at (timestamptz)
└── (no updated_at — audit logs are immutable)
```

### Key RLS Policies (Summary)

| Table | Client Access | Carer Access |
|---|---|---|
| care_groups | Own group: full CRUD | Own group: read only |
| profiles | All in own group | Own profile only (unless privacy=open) |
| shifts | All in own group: full CRUD | Own shifts (full privacy), all shifts anonymized (anonymous), all shifts (open) |
| pto_requests | All in own group: full CRUD | Own requests only |
| tasks | All in own group: full CRUD | Tasks for current shift: read + complete |
| care_plans | Own group: full CRUD | Own group: read only |
| shift_notes | All in own group: read | Own notes: write. Privacy-filtered: read. |
| notifications | Own notifications | Own notifications |
| audit_log | Own group: read | No access |

---

## Appendix B: Security Architecture

### Authentication Flow
1. User signs up via Supabase Auth (email/password or Sign in with Apple)
2. JWT access token (short-lived, 1hr) + refresh token (long-lived)
3. Tokens stored in iOS Keychain (NSFileProtectionComplete)
4. Optional biometric unlock (Face ID/Touch ID) via LocalAuthentication framework
5. On logout: clear Keychain tokens, clear cached data, clear SwiftData store

### E2EE Key Exchange Flow
1. On signup, device generates Curve25519 key pair (CryptoKit)
2. Public key stored in `profiles.public_key` (Supabase)
3. Private key stored in device Keychain (never leaves device)
4. When client creates care group, AES-256 group key generated
5. When carer is approved, group key encrypted with carer's public key → stored in a `key_shares` table
6. Carer decrypts group key with their private key
7. All E2EE content encrypted/decrypted with the group key locally
8. On carer removal: new group key generated, re-shared with remaining carers, future content re-encrypted

### Data Classification

| Classification | Examples | Protection |
|---|---|---|
| **Critical (E2EE)** | Care plan PDFs, shift notes, task descriptions, PTO reasons | End-to-end encrypted. Server stores ciphertext only. |
| **Sensitive (RLS)** | Shift assignments, carer names, availability, contact info | Row-level security. Only authorized users can query. |
| **Operational** | Shift dates/times, task due dates, notification metadata | RLS-protected but not E2EE (needed for server-side queries). |
| **Public** | App configuration, feature flags | No special protection needed. |
