# CareCoordinator iOS — Design Document

**Date:** 2026-03-01
**Status:** Approved (brainstorming session)

---

## 1. User Roles & Data Model

### Roles

| Role | Description | Permissions |
|------|-------------|-------------|
| **Client** | Person receiving care (or family member managing care). One per care group. | Full CRUD on all data: schedules, carers, tasks, care plans, settings. Controls privacy. |
| **Carer** | Caregiver in the rotation. Multiple per care group. | View own shifts, own tasks, shared care plans. Submit PTO requests, update availability. Cannot see other carers' data unless client allows it. |

### Core Data Model (Postgres tables)

- **`care_groups`** — Top-level entity. One client owns one care group. Contains settings (privacy mode, shift times, rotation pattern).
- **`profiles`** — User profile linked to Supabase Auth. Has `role` (client/carer) and `care_group_id`.
- **`carers`** — Carer-specific data: display name (can be hidden), contact info, linked to `profiles`.
- **`rotation_patterns`** — Client-defined rotation template. Stores the ordered sequence of carer assignments per week (e.g., `[carer_a, carer_a, carer_b, carer_c]`).
- **`shifts`** — Generated from rotation pattern. Each row = one shift (date, start_time, end_time, carer_id, status: scheduled/covered/cancelled).
- **`pto_requests`** — Carer submits, client approves/denies. Links to affected shifts.
- **`shift_offers`** — When client broadcasts an open shift, available carers can claim it.
- **`care_plans`** — Metadata for uploaded PDFs (title, file_path in Supabase Storage, upload date).
- **`tasks`** — General tasks. Has `type` (swapover_template / swapover_instance / general), `assigned_to` (nullable), `due_date`, `completed`, `care_group_id`.
- **`carer_availability`** — Carer-submitted availability windows.
- **`chat_sessions`** — Care-y conversation history (per-user, on-device only, no server storage for privacy).
- **`invitations`** — `code` (unique), `care_group_id`, `created_by`, `status` (pending/accepted/revoked), `expires_at`.
- **`join_requests`** — `carer_id`, `invitation_code`, `status` (pending/approved/denied), `requested_at`.
- **`notifications`** — `user_id`, `type` (join_request/pto_request/shift_change/task_assigned/reminder), `title`, `body`, `read`, `data` (JSON payload), `created_at`.

### Privacy Controls (care_group settings)

- `privacy_mode`: `full` (carers see only own shifts), `anonymous` (carers see all shifts but names hidden), `open` (carers see everything)
- RLS policies enforce this at the database level — the app never even receives data the user isn't allowed to see

---

## 2. Scheduling Engine

### How Rotation Works

1. **Client defines shift templates**: Sets shift times (e.g., 8am-8pm) per day of the week. Could be the same every day or vary.

2. **Client defines rotation pattern**: An ordered list of carer assignments per week. Example with 3 carers:
   - Week 1: Carer A
   - Week 2: Carer A
   - Week 3: Carer B
   - Week 4: Carer C
   - Then repeats from Week 1

3. **Auto-generation**: When the client saves a rotation, the app generates `shifts` rows for a configurable look-ahead period (e.g., 12 weeks). A background task (or on-demand) extends the schedule as time passes.

4. **Shift statuses**: `scheduled` → `covered` (if reassigned due to PTO) → `completed` / `cancelled`

5. **PTO handling**:
   - Carer submits PTO for specific dates
   - Client is notified, approves/denies
   - On approval, affected shifts are marked and client can: manually reassign OR broadcast to available carers
   - Available carers (those who submitted availability for those dates) get notified
   - First to claim gets the shift (or client picks)

6. **Availability**: Carers can mark dates/times they're available for extra shifts. This feeds into the PTO cover flow and Care-y's knowledge.

### Calendar Export

- Shifts sync to the device calendar via EventKit
- Each shift becomes a calendar event with title, time, and notes
- One-way push: app → calendar. Changes in the app update the calendar events.
- Carer controls whether to enable this (permission prompt)

---

## 3. Task System

### Swapover Checklist

- **Template**: Client creates a checklist template with items (e.g., "Check medication supply", "Update care log", "Brief incoming carer"). This template is persistent.
- **Instances**: When a rotation swap occurs (one carer's week ends, another's begins), the app auto-generates a fresh instance of the checklist from the template.
- **Completion**: The outgoing carer checks off items during handover. Client can see completion status.
- **Trigger**: Instance generated at the start of the last shift before a swap (configurable, or on the swap date itself).

### General Tasks

- Client creates tasks with: title, description, optional due date, priority
- Visible to whoever is currently on shift (determined by schedule)
- Carers check off completed tasks
- Client sees task completion history
- Tasks can be one-off or recurring (daily, weekly, custom)
- When privacy mode is active, completed-by attribution follows the same rules (hidden or anonymous)

### Task Visibility Rules

| Privacy Mode | Swapover Tasks | General Tasks |
|---|---|---|
| Full | Only during your swap period | Only during your shift |
| Anonymous | Visible, completions show "A carer" | Visible, completions show "A carer" |
| Open | Full visibility with names | Full visibility with names |

---

## 4. Care-y AI Assistant

### Architecture

- **On-device only**: Uses Apple Foundation Models (available iOS 18.1+). No data leaves the device for AI processing.
- **Context-aware**: Care-y has access to the current user's permitted data (respects RLS/privacy boundaries).
- **Per-role context**:
  - **Client sees everything**: Can ask "Who's working next Tuesday?", "Has the medication checklist been completed?", "Show me Carer A's PTO requests"
  - **Carer sees only their data**: Can ask "When's my next shift?", "What tasks do I need to complete?", "What does the care plan say about medication?" — but NOT "Who else works here?" in full privacy mode

### How It Works

1. User opens Care-y chat
2. App assembles a context payload from local/cached data: current schedule, tasks, care plans (text extracted from PDFs), availability
3. Context payload is filtered by the user's role and privacy settings BEFORE being sent to the on-device model
4. Apple Foundation Models process the query with the filtered context
5. Response displayed in a chat UI
6. Conversation history stored on-device only (not synced to server)

### Example Queries

| User | Query | Response |
|------|-------|----------|
| Client | "Is Sarah working this Friday?" | "Yes, Sarah is scheduled for a 12-hour shift from 8am to 8pm this Friday." |
| Client | "Who can cover Monday?" | "Based on availability, James and Maria have marked themselves available. James is next in rotation." |
| Carer | "When's my next shift?" | "Your next shift is Monday March 8th, 8am to 8pm." |
| Carer | "What are the medication instructions?" | "According to the care plan: [extracted medication section]" |
| Carer (full privacy) | "Who works after me?" | "I can't share information about other carers' schedules." |

### Limitations

- Requires iOS 18.1+ with Apple Intelligence enabled
- Model capabilities depend on device (may be limited on older supported devices)
- Fallback: If Apple Foundation Models unavailable, Care-y gracefully disables with a message explaining the requirement
- No server-side AI — this is a deliberate privacy choice

---

## 5. Security Architecture

### Authentication
- **Supabase Auth** with email/password + Sign in with Apple
- **Invite-gated access**: No one can access a care group without a valid invite code + client approval
- **Session management**: JWT tokens with short expiry, refresh tokens stored in Keychain
- **Biometric unlock**: Face ID/Touch ID for app re-entry (optional, using Keychain + LocalAuthentication)

### Data Security — Row-Level Security (RLS)

Every Supabase query is filtered by RLS policies BEFORE data reaches the app.

```sql
-- Example: Carers can only see their own shifts (full privacy mode)
CREATE POLICY "carers_own_shifts" ON shifts
  FOR SELECT USING (
    carer_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM care_groups cg
      JOIN profiles p ON p.care_group_id = cg.id
      WHERE p.id = auth.uid()
      AND p.role = 'client'
      AND cg.id = shifts.care_group_id
    )
    OR EXISTS (
      SELECT 1 FROM care_groups cg
      WHERE cg.id = shifts.care_group_id
      AND cg.privacy_mode IN ('anonymous', 'open')
    )
  );
```

**Key principle**: The client ALWAYS sees everything. Carers are filtered by privacy mode. Data they can't see **never leaves Supabase**.

### End-to-End Encryption (E2EE)

**What's E2E encrypted**: Care plans (PDFs), care notes, task descriptions — the sensitive care content.

**How it works:**
1. **Key generation**: When a care group is created, the client's device generates an AES-256 symmetric key (the "group key")
2. **Key distribution**: When a carer is approved, the group key is encrypted with the carer's public key (generated during signup, stored in Supabase) and sent to them. They decrypt it with their private key (stored in Keychain, never leaves device).
3. **Encryption**: Care plans, notes, and sensitive task content are encrypted with the group key before upload. Supabase stores ciphertext.
4. **Decryption**: App decrypts on-device after download. Supabase (and anyone with DB access) sees only encrypted blobs.
5. **Key rotation**: When a carer is removed from the group, the client generates a new group key and re-encrypts. Existing carers receive the new key.

**Implementation**: Apple CryptoKit framework (AES-GCM for symmetric encryption, Curve25519 for key exchange).

### Data at Rest & In Transit
- **In transit**: All Supabase connections are HTTPS/TLS 1.3
- **At rest**: Supabase encrypts data at rest (AES-256). PDFs in Supabase Storage are also encrypted.
- **On device**: Sensitive cached data stored in Keychain or encrypted Core Data (using NSFileProtectionComplete)
- **Care plans**: PDFs stored in Supabase Storage with RLS-gated signed URLs (time-limited, non-guessable)

### Additional Security Measures
- **Rate limiting**: Supabase's built-in rate limiting + invite code brute-force protection (lock after 5 failed attempts)
- **Audit logging**: Key actions logged (shift changes, PTO approvals, data access) in an `audit_log` table
- **Data minimization**: Only cache what's needed on-device. Clear cache on logout.
- **No server-side AI**: Care-y runs on-device, so care data never hits a third-party AI service
- **Invite code expiry**: Codes expire after configurable period (default 7 days) or after single use

---

## 6. App Structure & UI/UX Overview

### Tech Stack

| Component | Technology |
|---|---|
| **UI Framework** | SwiftUI (iOS 17+ minimum) |
| **Backend** | Supabase (Postgres + Auth + Storage + Realtime) |
| **AI** | Apple Foundation Models (iOS 18.1+) |
| **Calendar** | EventKit |
| **Crypto** | CryptoKit (AES-GCM, Curve25519) |
| **Local Storage** | SwiftData for caching, Keychain for secrets |
| **PDF** | PDFKit (built-in) |
| **Push Notifications** | APNs via Supabase (or direct) |
| **Architecture Pattern** | MVVM with repository layer |

### Screen Map

**Client Flow:**
```
Login → Dashboard
  ├── Schedule (calendar view + list view)
  │     ├── Edit Rotation Pattern
  │     ├── View/Edit Individual Shifts
  │     └── Handle PTO Requests
  ├── Carers
  │     ├── Invite Carer
  │     ├── Manage Carers (approve, remove)
  │     └── Privacy Settings
  ├── Tasks
  │     ├── Swapover Checklist (template editor)
  │     ├── General Tasks
  │     └── Task History
  ├── Care Plans
  │     ├── Upload PDF
  │     └── View Plans
  ├── Care-y (AI Chat)
  └── Settings
        ├── Care Group Settings
        ├── Notification Preferences
        └── Calendar Sync
```

**Carer Flow:**
```
Login → Dashboard
  ├── My Schedule (own shifts only / privacy-filtered)
  ├── My Tasks (current tasks for active shift)
  ├── Care Plans (view PDFs)
  ├── Availability (submit available dates)
  ├── PTO (request time off)
  ├── Care-y (AI Chat, privacy-filtered)
  └── Settings
        ├── Profile
        ├── Notification Preferences
        └── Calendar Sync
```

### Additional Features (v1)

1. **Shift notes/handover notes**: Text notes a carer can leave for the next carer (encrypted, visible based on privacy mode).
2. **Medication/appointment reminders**: Time-based push notifications the client sets up. Carers on shift receive them.
3. **Emergency contact quick-dial**: One-tap call to emergency contacts stored in the care group.
4. **Activity log for client**: A timeline view showing what happened (task completed, shift started, PTO requested).
5. **Offline mode**: Cache the current week's schedule, active tasks, and care plans locally. Sync when back online.

---

## 7. Architectural Decision: Approach A — SwiftUI + Supabase Direct

### Why This Approach

Pure SwiftUI app talking directly to Supabase via the official `supabase-swift` SDK. Row-Level Security (RLS) policies on Postgres enforce all privacy rules at the database level. Apple Foundation Models run on-device for Care-y.

### Pros
- No middleware server to build or maintain — RLS does access control
- Supabase Auth handles email/password + Sign in with Apple natively
- Supabase Storage for care plan PDFs with RLS-gated access
- Real-time subscriptions for live schedule/task updates
- On-device AI means no API costs and data stays private
- Single codebase, single deployment target

### Cons
- Business logic lives in RLS policies + database functions (Postgres functions), which can be tricky to test
- If complex server-side logic is needed later (e.g., notification scheduling), can add Supabase Edge Functions

### Rejected Alternatives
- **Approach B (SwiftUI + Supabase + Edge Functions)**: More moving parts, adds TypeScript. Can upgrade to this incrementally if needed.
- **Approach C (SwiftUI + CloudKit + Supabase Hybrid)**: CloudKit's sharing model is clunky for this use case. Two backends to manage.
