# CareCoordinator iOS — Product Management Artifacts

**Date:** 2026-03-01
**Author:** Camilo Pires
**Companion to:** `2026-03-01-care-coordinator-prd.md`

This document contains detailed product management analyses using structured frameworks: Jobs-to-be-Done, Positioning Statement, Customer Journey Map, and User Story Map.

---

## 1. Jobs-to-be-Done Analysis

### 1.1 JTBD — Coordinator Claire (Primary Persona)

**Context:** Managing home care for an aging parent who requires 24/7 care support, coordinating 2-5 rotating carers.

**Current solutions ("hired" today):**
- WhatsApp groups for schedule communication
- Google Sheets or paper calendars for scheduling
- Email/text for PTO requests
- Paper binders for care plans
- Phone calls for finding cover
- Memory/verbal handovers for shift swaps

---

#### Functional Jobs

| # | Job | Intensity |
|---|-----|-----------|
| F1 | Coordinate a rotating schedule of multiple carers across weeks without gaps or double-bookings | Critical |
| F2 | Communicate each carer's shifts to them without exposing other carers' schedules | Critical |
| F3 | Process time-off requests and arrange replacement cover quickly | Critical |
| F4 | Ensure every carer has access to current care plan documents during their shift | High |
| F5 | Manage a structured handover process when carers swap each week | High |
| F6 | Track which tasks have been completed during each shift | Medium |
| F7 | Set up medication and appointment reminders that reach whoever is on shift | Medium |
| F8 | Get a quick answer about who's working on a given date without checking the spreadsheet | Medium |
| F9 | Onboard a new carer into the rotation with minimal friction | Medium |
| F10 | Monitor care quality and activity without being physically present | Low-Medium |

#### Social Jobs

| # | Job | Intensity |
|---|-----|-----------|
| S1 | Be seen by carers as a fair, organized, and respectful employer | High |
| S2 | Demonstrate to family members that care is well-coordinated and reliable | High |
| S3 | Protect carers' privacy so they trust the arrangement and focus on care | Critical |
| S4 | Be perceived by carers as someone who values their time and boundaries | Medium |
| S5 | Show other family members (siblings, spouse) that the coordination burden is under control | Medium |

#### Emotional Jobs

| # | Job | Intensity |
|---|-----|-----------|
| E1 | Feel confident that my loved one is never left without care | Critical |
| E2 | Reduce the anxiety of "what if someone calls in sick?" | High |
| E3 | Stop feeling guilty about care gaps caused by coordination failures | High |
| E4 | Feel in control of the care schedule without it consuming my life | High |
| E5 | Feel pride that I'm managing this well despite it not being my profession | Medium |
| E6 | Avoid the dread of Sunday evening scheduling sessions | Medium |
| E7 | Feel assured that sensitive care information is handled securely | Medium |

---

#### Pains

**Challenges:**
| # | Pain | Severity |
|---|------|----------|
| P1 | WhatsApp groups expose carer names, phone numbers, and schedules to everyone — violating privacy promises | Extreme |
| P2 | Manual schedule updates across multiple channels (spreadsheet + WhatsApp + calendar) lead to missed updates and conflicting information | Extreme |
| P3 | No structured way to handle PTO — results in days of phone tag and hours-long scrambles | High |
| P4 | Handovers are informal and unreliable — critical information (medication changes, incidents) gets lost between shifts | High |
| P5 | Care plan documents are scattered across email, WhatsApp, and paper — carers can't always find them | High |
| P6 | No visibility into who's available for cover when someone requests time off | High |
| P7 | No way to verify that tasks were actually completed during a shift | Medium |

**Costliness:**
| # | Cost | Impact |
|---|------|--------|
| C1 | 3-5 hours/week on manual scheduling and communication | High (15-20 hrs/month of life lost) |
| C2 | Emotional toll of constant worry about coverage gaps | High (affects sleep, relationships) |
| C3 | Phone/data costs from constant messaging coordination | Low |
| C4 | Risk of carer turnover due to privacy breaches or disorganization — rehiring and training costs | Medium |

**Common Mistakes:**
| # | Mistake | Frequency |
|---|---------|-----------|
| M1 | Forgetting to update one carer about a schedule change → carer shows up on the wrong day | Monthly |
| M2 | Sending a message to the group chat that reveals another carer's personal information | Occasional |
| M3 | Outdated care plan left in place → medication given at wrong dose or wrong time | Rare but dangerous |
| M4 | Missing the transition point between carers → 1-2 hour care gap | Occasional |

**Unresolved Problems:**
| # | Problem | Why Current Solutions Fail |
|---|---------|---------------------------|
| U1 | No tool designed for individual care coordinators (not agencies) | Agency software costs $200+/month, designed for 50+ carers |
| U2 | No privacy model for carers within a shared schedule | Every scheduling tool shows all users to all users |
| U3 | No integrated handover process tied to the schedule | Generic task apps don't know when shifts change |
| U4 | No on-device AI that can query care data privately | Cloud AI services would require sending sensitive data to third parties |

---

#### Gains

**Expectations:**
| # | Expectation | Priority |
|---|-------------|----------|
| G1 | Schedule auto-generates from a pattern — no more manual entry | Must-have |
| G2 | Each carer sees only their own schedule (privacy enforced, not just policy) | Must-have |
| G3 | PTO requests and approvals happen in one place with notifications | Must-have |
| G4 | Care plans are always up-to-date and accessible on the carer's phone | Must-have |
| G5 | Handover checklist ensures nothing is forgotten during carer swaps | High |
| G6 | One-tap answers to "who's working when?" without checking spreadsheets | High |

**Savings:**
| # | Saving | Impact |
|---|--------|--------|
| SV1 | Reduce weekly scheduling time from 3-5 hours to < 30 minutes | Transformative |
| SV2 | Eliminate phone tag for PTO cover — resolve in < 24 hours vs 1-4 days | High |
| SV3 | Eliminate Sunday evening scheduling ritual entirely | High (emotional + time) |
| SV4 | Remove need to maintain separate spreadsheet + WhatsApp + calendar | Medium |

**Adoption Factors:**
| # | Factor | Weight |
|---|--------|--------|
| A1 | Simple enough for non-technical carers to use with minimal training | Critical |
| A2 | Privacy and security as a core selling point (not an afterthought) | Critical |
| A3 | Free or affordable for an individual (not enterprise pricing) | High |
| A4 | iPhone-native feel — not a web wrapper or clunky enterprise UI | Medium |
| A5 | Easy invite flow for carers (they won't download something complex) | High |

**Life Improvement:**
| # | Improvement | Impact |
|---|-------------|--------|
| L1 | Reclaim 15-20 hours/month previously spent on manual coordination | Transformative |
| L2 | Sleep better knowing coverage is confirmed and visible | High |
| L3 | Reduce family tension about care coordination quality | Medium |
| L4 | Feel professional about care management — like running a small org well | Medium |
| L5 | More time for own career, family, and self-care | High |

---

### 1.2 JTBD — Carer Casey (Secondary Persona)

**Context:** Professional carer working rotating shifts for a private client, wanting clear information and minimal friction.

#### Functional Jobs

| # | Job | Intensity |
|---|-----|-----------|
| CF1 | Know exactly when my next shifts are, well in advance | Critical |
| CF2 | Request time off and know quickly whether it's approved | High |
| CF3 | Access up-to-date care instructions during my shift | Critical |
| CF4 | Complete handover tasks confidently without needing to contact other carers | High |
| CF5 | Have my shifts appear in my personal calendar automatically | Medium |
| CF6 | Mark my availability for extra shifts if I want more work | Medium |

#### Social Jobs

| # | Job | Intensity |
|---|-----|-----------|
| CS1 | Maintain clear professional boundaries — don't need to know or interact with other carers | High |
| CS2 | Be seen as reliable and competent by the client | High |
| CS3 | Keep personal contact information private from colleagues | High |

#### Emotional Jobs

| # | Job | Intensity |
|---|-----|-----------|
| CE1 | Feel confident I have the right care instructions for my shift | Critical |
| CE2 | Avoid the anxiety of "am I working this week or not?" | High |
| CE3 | Feel respected — my privacy and boundaries are valued | High |
| CE4 | Feel secure that my personal data isn't being shared | Medium |

#### Key Pains (Carer-Specific)

| # | Pain | Severity |
|---|------|----------|
| CP1 | Finding out my schedule via WhatsApp messages that I have to scroll through | High |
| CP2 | Seeing other carers' names and personal information in group chats | High |
| CP3 | PTO requests via text — no tracking, no confirmation, days of uncertainty | High |
| CP4 | Outdated care plan in a physical binder — afraid of making a medication error | Extreme |
| CP5 | No clear handover process — arriving to a shift with no context about what happened | High |

---

## 2. Positioning Statement

### Value Proposition

**For** individual care coordinators (family members managing home care for a loved one)

**that need** to schedule rotating carers, coordinate handovers, and share care plans — without violating carer privacy or spending hours on manual coordination

**CareCoordinator**

**is a** privacy-first care scheduling app for iPhone

**that** auto-generates rotating shift schedules, enforces carer privacy at the database level, and provides encrypted care plan access — replacing the WhatsApp-and-spreadsheet chaos with a secure, structured system that saves 15+ hours per month.

### Differentiation Statement

**Unlike** WhatsApp groups and Google Sheets (the actual tools people use today),

**CareCoordinator**

**provides** privacy-enforced scheduling where carers see only their own data, auto-generated rotations that eliminate manual schedule creation, structured handover checklists tied to shift swaps, encrypted care plan storage accessible during shifts, and an on-device AI assistant that answers care questions without ever sending sensitive data to the cloud.

### Positioning Stress-Test

| Question | Answer |
|---|---|
| Would a customer recognize themselves? | Yes — "individual care coordinator managing home care with rotating carers" is a specific, recognizable role. |
| Is the need defensible? | Yes — validated by care communities, support forums, and the absence of any product in this niche. |
| Does the category help? | "Privacy-first care scheduling app" anchors against scheduling apps but differentiates with privacy and care-specific features. |
| Is differentiation believable? | Yes — RLS-enforced privacy, E2E encryption, and on-device AI are technical differentiators that can be demonstrated. |
| Does this guide decisions? | Yes — any feature request can be tested: "Does this support privacy-first care scheduling?" |

---

## 3. Customer Journey Map

### Persona: Coordinator Claire

**Objective:** Map Claire's journey from realizing she needs a care scheduling solution through becoming a loyal advocate.

---

| Stage | Awareness | Consideration | Decision | Onboarding | Daily Use | Loyalty |
|---|---|---|---|---|---|---|
| **Customer Actions** | Searches "care scheduling app" after a privacy incident in WhatsApp group. Asks in Facebook carer support group. Sees App Store listing. | Downloads app, reads App Store reviews. Watches walkthrough. Compares to generic scheduling apps. Checks privacy features. | Creates account, sets up care group, generates first invite code, invites one carer as a test. | Configures rotation pattern, sets shift times, uploads care plan PDFs, creates swapover checklist template, invites remaining carers. | Views schedule daily. Processes PTO requests. Monitors task completions. Uses Care-y for quick queries. Checks activity log. | Recommends to other families. Leaves App Store review. Suggests features. Upgrades to premium (if freemium). |
| **Touchpoints** | App Store search, Facebook care groups, Google search, word-of-mouth from other families | App Store listing, app screenshots, onboarding walkthrough, privacy policy page | App signup flow, care group creation wizard, invite code system | Rotation builder UI, shift time picker, PDF upload, checklist template editor, carer approval screen | Dashboard, schedule view, PTO notifications, task list, Care-y chat, activity log, calendar sync | App Store review prompt, share feature, feedback form, feature request channel |
| **Customer Experience** | "Finally someone understands this problem. Most scheduling apps don't even think about carer privacy." Relieved but cautious — "Is this actually secure or just marketing?" | "The privacy modes are exactly what I need. Full, anonymous, or open — I can choose." Impressed by E2EE mention. Nervous about whether carers will actually use it. | "The setup was easier than I expected. Let me try it with one carer first before going all-in." Cautiously optimistic. Slight anxiety about tech setup. | "The rotation builder is clever — I define the pattern once and it generates everything. Uploading care plans feels secure." Growing confidence. Relieved when first carer successfully joins. | "I haven't touched my spreadsheet in 3 weeks. PTO requests just come through and I tap approve. The handover checklist actually works." Deep satisfaction. "Sunday evenings are mine again." | "I told my friend Sarah about this — she's been struggling with the same thing. I genuinely want other families to have this." Advocacy born from gratitude. |
| **Emotions** | Hope + skepticism | Trust-building + nervousness about adoption | Cautious optimism + testing anxiety | Growing confidence + relief | Satisfaction + freedom + control | Gratitude + advocacy + belonging |
| **KPIs** | App Store impressions, search ranking for "care scheduling app", Facebook group mentions, website visits | App downloads, onboarding start rate, time on App Store listing, privacy page views | Account creation rate, care group creation rate, first invite sent rate | Rotation pattern saved, first shift auto-generated, first carer joined, first care plan uploaded | DAU/WAU, PTO requests processed, tasks completed, Care-y queries, shifts without gaps | NPS score, App Store rating, referral rate, retention at 3/6/12 months, upgrade rate |
| **Business Goals** | Build awareness in care communities. Rank top 5 for "care scheduling app" in App Store. | Convert awareness to downloads. Demonstrate privacy differentiation. | Convert downloads to active accounts. Minimize setup friction. Get first invite sent. | Drive full setup completion. Ensure first-week "aha moment" (auto-generated schedule). | Drive daily engagement. Prove value (time saved, gaps eliminated). Reduce churn. | Generate organic referrals. Build social proof. Increase LTV through premium features or retention. |
| **Teams/Effort** | App Store Optimization (ASO), content in care communities, social proof (testimonials) | App Store screenshots, onboarding UX, privacy messaging, landing page | Signup flow UX, care group wizard, invite system | Rotation builder UX, PDF upload, checklist editor, carer onboarding flow | Dashboard, notifications, schedule UI, Care-y, task management | Review prompts, share flow, feedback collection, premium features |

---

### Persona: Carer Casey

| Stage | Invitation | Onboarding | First Shift | Daily Use | Ongoing |
|---|---|---|---|---|---|
| **Customer Actions** | Receives invite code from client (text/email). Downloads app from App Store. | Creates account. Enters invite code. Waits for client approval. Explores the app. | Views first shift. Checks care plan. Reviews task list. Enables calendar sync. | Checks schedule. Completes tasks. Views care plans. Leaves shift notes. Uses Care-y. | Submits availability. Requests PTO. Completes swapover checklists. |
| **Touchpoints** | Text/email with invite code, App Store | Signup screen, invite code entry, approval wait screen | Dashboard, schedule view, care plan viewer, task list, calendar sync prompt | Schedule, tasks, care plans, shift notes, Care-y chat, push notifications | Availability calendar, PTO request form, swapover checklist |
| **Customer Experience** | "Another app to download... but at least it's better than the WhatsApp mess." Low expectations, mild reluctance. | "That was quick — signed up, entered the code, and I'm in. I can only see my own shifts. Good." Pleasantly surprised by simplicity and privacy. | "I can see my care plan right here on my phone, and there's a clear task list. I don't see any other carers' names. This feels professional." Relief and confidence. | "I just asked Care-y when my next shift is instead of scrolling through messages. My shifts show up in my calendar automatically." Growing appreciation. | "Requesting time off took 30 seconds and I got approved within hours. The swapover checklist makes handovers so much smoother." Satisfaction and trust. |
| **Emotions** | Mild reluctance → curiosity | Surprise + relief | Confidence + professionalism | Convenience + appreciation | Trust + satisfaction |
| **KPIs** | Invite-to-download rate, time from invite to signup | Signup completion rate, time from signup to approval, first app open after approval | Care plan viewed rate, first task completed, calendar sync enabled rate | DAU, tasks completed per shift, Care-y usage, shift notes created | PTO request frequency, availability submissions, checklist completion rate |

---

### Journey Pain Points & Opportunities

| Stage | Pain Point | Opportunity |
|---|---|---|
| Awareness | Target audience doesn't know this category exists — they don't search for "care scheduling app" | Content marketing in care communities. Search terms like "manage care rota", "carer schedule app", "private carer coordination" |
| Consideration | Carers may resist downloading "yet another app" | Emphasize simplicity: "5 minutes to set up, see only your shifts". Minimize carer-side friction. |
| Decision | Client nervous about committing all carers at once | "Try with one carer first" messaging. Low-risk trial. |
| Onboarding | Rotation pattern builder could be confusing for non-technical users | Guided wizard with examples. "Most common: 2 carers alternating weekly" presets. |
| Daily Use | Push notification fatigue if too many alerts | Smart defaults: critical notifications on, informational ones off. Notification preferences from day 1. |
| Loyalty | No community or peer connection for care coordinators | Future: in-app community, tips, or content. Peer support without breaking privacy. |

---

## 4. User Story Map

### Persona: Coordinator Claire
### Narrative: "Set up and manage a rotating care schedule with full privacy, structured handovers, and encrypted care plans — saving 15+ hours/month of manual coordination."

---

```
BACKBONE (Activities left-to-right):

[1. Set Up Care Group] → [2. Configure Schedule] → [3. Manage Carers] → [4. Handle Day-to-Day] → [5. Monitor & Oversee]
```

---

### Activity 1: Set Up Care Group

| Step | Tasks (MVP / Release 1) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **1.1 Create account** | Sign up with email/password | Sign in with Apple | Biometric re-auth (Face ID) |
| **1.2 Create care group** | Name care group, select privacy mode | Set location/timezone | Multi-care-group support |
| **1.3 Upload care plans** | Upload PDF from device | Add title/category to each PDF | PDF text extraction for Care-y |
| **1.4 Add emergency contacts** | Add name, phone, relationship | Reorder contacts by priority | Emergency SOS flow |
| **1.5 Configure E2EE** | Auto-generate group key on creation | Key recovery via iCloud Keychain | Multi-device key sync |

---

### Activity 2: Configure Schedule

| Step | Tasks (MVP / Release 1) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **2.1 Set shift times** | Set default start/end time | Different times per day of week | Split shifts (morning/evening) |
| **2.2 Define rotation pattern** | Visual rotation builder, add carers to week positions | Pattern presets ("2 alternating", "3 round-robin") | AI-suggested optimal rotations |
| **2.3 Generate shifts** | Auto-generate 12 weeks of shifts | Extend schedule automatically as time passes | Conflict detection with carer availability |
| **2.4 Edit individual shifts** | Reassign, change times, cancel a shift | Bulk edit shifts | Drag-and-drop schedule editing |
| **2.5 View schedule** | Calendar view + list view | Filter by carer, week, month | Export schedule as PDF/CSV |

---

### Activity 3: Manage Carers

| Step | Tasks (MVP / Release 1) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **3.1 Invite carers** | Generate invite code, share via share sheet | Multi-use invite codes with usage limits | QR code invite |
| **3.2 Approve join requests** | View pending requests, approve/deny with notification | Deny with message | Auto-approve trusted domain emails |
| **3.3 Manage privacy** | Select privacy mode (full/anonymous/open) | Change privacy mode with confirmation | Per-carer privacy overrides |
| **3.4 Remove carers** | Remove carer from group, unassign future shifts | Rotate E2EE key on removal | Archive carer (preserve history, revoke access) |
| **3.5 View carer profiles** | See name, role, join date | See shift history, PTO history | Carer performance summary |

---

### Activity 4: Handle Day-to-Day

| Step | Tasks (MVP / Release 1) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **4.1 Process PTO requests** | View request, see affected shifts, approve/deny | Add client message to decision | Auto-suggest available cover carers |
| **4.2 Arrange cover** | Manually assign replacement carer | Broadcast open shift to available carers | Auto-assign based on availability + rotation fairness |
| **4.3 Manage tasks** | Create general tasks with title, description, due date | Recurring tasks (daily/weekly/custom) | Task templates, task categories |
| **4.4 Manage swapover checklist** | Create template, view completion status | Edit template items | Checklist analytics (completion rates) |
| **4.5 Set reminders** | Create time-based reminders (title, time) | Recurring reminders | Smart reminders based on care plan |
| **4.6 Use Care-y** | Ask schedule questions, get answers | Ask care plan questions | Ask task/availability questions, get suggestions |

---

### Activity 5: Monitor & Oversee

| Step | Tasks (MVP / Release 1) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **5.1 View activity log** | Timeline of events, filterable by type | Filter by carer (if privacy allows) | Export activity report |
| **5.2 Receive notifications** | Push for PTO requests, join requests, shift changes | Notification preferences | Smart notification batching |
| **5.3 Check task completion** | See completed/incomplete tasks per shift | Task completion history | Completion rate analytics |
| **5.4 Review shift notes** | Read encrypted shift notes from carers | Notes organized by shift/date | Search within notes |
| **5.5 Calendar integration** | Export own schedule to device calendar | | Shared family calendar integration |

---

### Persona: Carer Casey
### Narrative: "View my shifts, complete my tasks, access care plans, and manage my availability — all without seeing other carers' data."

```
BACKBONE:

[1. Join Care Group] → [2. View My Schedule] → [3. Work My Shift] → [4. Manage My Time] → [5. Handover]
```

---

### Activity 1: Join Care Group

| Step | Tasks (MVP) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **1.1 Create account** | Sign up with email/password | Sign in with Apple | Biometric login |
| **1.2 Enter invite code** | Input code, submit join request | | Join via deep link |
| **1.3 Wait for approval** | See pending status, receive push on approval | | |
| **1.4 First login** | See dashboard with next shift prominently displayed | Guided first-time walkthrough | |

---

### Activity 2: View My Schedule

| Step | Tasks (MVP) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **2.1 See upcoming shifts** | List view of my shifts | Calendar view | |
| **2.2 See shift details** | Date, start/end time, notes | Location, special instructions | |
| **2.3 Sync to calendar** | Export shifts to device calendar via EventKit | Auto-update on changes | |

---

### Activity 3: Work My Shift

| Step | Tasks (MVP) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **3.1 View care plans** | Open PDFs in-app (decrypted on-device) | Offline cached access | |
| **3.2 Complete tasks** | View active tasks, mark complete | See recurring tasks auto-appear | |
| **3.3 Acknowledge reminders** | Receive push, mark acknowledged in-app | | |
| **3.4 Call emergency contacts** | One-tap call from contacts list | | |
| **3.5 Leave shift notes** | Free-form text entry (encrypted) | | Attach photos to notes |
| **3.6 Use Care-y** | Ask about schedule, care plan, tasks (privacy-filtered) | | |

---

### Activity 4: Manage My Time

| Step | Tasks (MVP) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **4.1 Request PTO** | Select dates, submit request | Add reason, view status | |
| **4.2 Track PTO status** | See pending/approved/denied | Receive push on decision | |
| **4.3 Submit availability** | Mark dates available for extra shifts | Recurring availability | |
| **4.4 Claim open shifts** | Receive broadcast notification, accept/decline | | |

---

### Activity 5: Handover

| Step | Tasks (MVP) | Tasks (Release 2) | Tasks (Future) |
|---|---|---|---|
| **5.1 Complete swapover checklist** | View auto-generated checklist, check off items | | |
| **5.2 Leave handover notes** | Write shift notes for next carer | | |
| **5.3 Confirm handover** | All checklist items checked | Client notification on incomplete handover | |

---

### Release Lines

```
═══════════════════════════════════════════════════════
  RELEASE 1 (MVP) — Core Scheduling + Privacy
═══════════════════════════════════════════════════════
  - Auth (email/password)
  - Care group creation with privacy modes
  - Rotation pattern builder + auto-generate shifts
  - Carer invite flow (code + approval)
  - Client: view/edit schedule, process PTO, assign cover
  - Carer: view own schedule, request PTO, view care plans
  - Care plan PDF upload + in-app viewing (E2EE)
  - Push notifications (PTO, shift changes, join requests)
  - Swapover checklist (template + instances)
  - General tasks (create, complete)
  - Emergency contacts
  - Shift notes (encrypted)
  - Activity log (client)

═══════════════════════════════════════════════════════
  RELEASE 2 — Enhanced Experience
═══════════════════════════════════════════════════════
  - Sign in with Apple
  - Calendar integration (EventKit export)
  - Care-y AI assistant (schedule + care plan queries)
  - Broadcast open shifts to available carers
  - Carer availability submission
  - Recurring tasks and reminders
  - Notification preferences
  - Offline mode (cached schedule + care plans + tasks)
  - Biometric unlock (Face ID/Touch ID)

═══════════════════════════════════════════════════════
  RELEASE 3 — Polish + Intelligence
═══════════════════════════════════════════════════════
  - Care-y: task + availability queries + suggestions
  - Rotation presets and pattern suggestions
  - Task/checklist analytics
  - Activity log export
  - Schedule export (PDF/CSV)
  - E2EE key rotation on carer removal
  - Key recovery via iCloud Keychain
  - Search within shift notes

═══════════════════════════════════════════════════════
  FUTURE — Expansion
═══════════════════════════════════════════════════════
  - Android app
  - Web dashboard for clients
  - Apple Watch companion
  - Multi-care-group support for carers
  - Family member read-only access
  - Smart notification batching
  - AI-suggested schedule optimizations
```

---

## 5. Prioritization Rationale

### Why This Release Order?

**Release 1 (MVP)** focuses on the three most critical jobs:
1. **F1 + E1:** Reliable scheduling with no gaps (rotation builder + auto-generate)
2. **P1 + S3:** Privacy enforcement (RLS + privacy modes)
3. **F4 + CP4:** Accessible care plans (E2EE PDF upload + viewing)

These address the most extreme pains (P1: privacy violations, P2: manual scheduling chaos) and the most critical emotional job (E1: confidence in care continuity).

**Release 2** adds the features that transform the experience from "useful tool" to "indispensable":
- Calendar sync (F5 → CF5: shifts in personal calendar)
- Care-y AI (F8: quick answers without checking spreadsheets)
- Availability + broadcasting (P6: visibility into who can cover)
- Offline mode (real-world constraint: intermittent connectivity)

**Release 3** adds polish and intelligence that deepen engagement and increase retention.

### JTBD-to-Feature Traceability

| Job | Feature | Release |
|---|---|---|
| F1 (Schedule without gaps) | Rotation builder + auto-generate | R1 |
| F2 (Communicate without exposing) | Privacy modes + RLS | R1 |
| F3 (Process PTO quickly) | PTO request flow | R1 |
| F4 (Care plan access) | PDF upload + E2EE + viewer | R1 |
| F5 (Structured handover) | Swapover checklist | R1 |
| F6 (Track task completion) | General tasks | R1 |
| F7 (Medication reminders) | Reminders | R2 |
| F8 (Quick schedule answers) | Care-y AI | R2 |
| F9 (Onboard new carer) | Invite flow | R1 |
| F10 (Monitor remotely) | Activity log | R1 |
| S3 (Protect carer privacy) | Privacy modes + RLS + E2EE | R1 |
| E1 (Confidence in coverage) | Auto-generated schedule + notifications | R1 |
| E2 (Reduce sick-day anxiety) | PTO + broadcast cover | R1 + R2 |
| E6 (No Sunday scheduling) | Auto-generate rotation | R1 |
