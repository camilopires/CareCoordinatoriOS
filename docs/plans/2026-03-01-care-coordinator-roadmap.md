# CareCoordinator iOS — Strategic Roadmap

**Date:** 2026-03-01
**Author:** Camilo Pires
**Developer Profile:** Solo indie, full-time (35-40 hrs/week), strong SwiftUI, learning Supabase
**Companion to:** PRD v1.0, PM Artifacts, Design Document

---

## Strategic Context

### Business Outcomes to Optimize

| # | Outcome | Metric | Target |
|---|---------|--------|--------|
| O1 | Prove product-market fit | Weekly active care groups | 500 within 6 months of launch |
| O2 | Establish trust | App Store rating | 4.5+ stars |
| O3 | Reduce coordination overhead | Time saved per client per week | 3+ hours |
| O4 | Achieve zero privacy violations | Privacy incidents | 0 (ever) |
| O5 | Generate sustainable revenue | MRR | Reach $2K MRR within 12 months |

### Customer Problems (Ranked by Intensity)

| Rank | Problem | Intensity | JTBD Reference |
|---|---------|-----------|----------------|
| 1 | Privacy violations through shared communication channels | Extreme | P1, S3 |
| 2 | Manual scheduling chaos (3-5 hrs/week wasted) | Extreme | P2, E6 |
| 3 | No structured PTO/cover process (days of phone tag) | High | P3, E2 |
| 4 | Inaccessible/outdated care plans during shifts | High | P5, CP4 |
| 5 | No structured handover process between carers | High | P4, CP5 |
| 6 | No visibility into carer availability for cover | High | P6 |
| 7 | No quick way to check schedule without manual lookup | Medium | F8 |
| 8 | No task tracking during shifts | Medium | P7 |

### Technical Constraints

| Constraint | Impact |
|---|---|
| Solo developer — cannot parallelize work | Sequential delivery only; affects timeline |
| New to Supabase — learning curve | Add 2-3 weeks ramp-up to early milestones |
| Apple Foundation Models require iOS 18.1+ | Care-y feature limited to newer devices |
| E2EE adds complexity to every data flow | Each feature touching encrypted data takes ~1.5x longer |
| App Store review for health-adjacent app | May require additional review time; plan buffer |

---

## Epic Definitions with Hypotheses

### Epic 1: Foundation & Auth
**Hypothesis:** We believe that building a secure auth system with invite-gated access will establish trust and enable all other features, because care data requires controlled access from day one.
**Success Metric:** Successful signup + invite + approval flow in < 5 minutes
**Effort:** Medium (3-4 weeks) — includes Supabase learning curve
**Outcome:** O4 (zero privacy violations)

### Epic 2: Scheduling Engine
**Hypothesis:** We believe that auto-generating rotating shift schedules from a client-defined pattern will eliminate 3-5 hours/week of manual scheduling, because the repetitive nature of care rotations is perfectly suited to automation.
**Success Metric:** Time to create 12-week schedule < 5 minutes (vs. hours manually)
**Effort:** Large (4-5 weeks) — rotation logic, shift generation, calendar views
**Outcome:** O1, O3

### Epic 3: Privacy Engine (RLS)
**Hypothesis:** We believe that enforcing carer privacy at the database level (not just the UI) will be our strongest differentiator, because no competing tool offers database-level privacy enforcement for individual care coordinators.
**Success Metric:** Zero data leaks; carers cannot access restricted data even via API
**Effort:** Medium (2-3 weeks) — RLS policies, testing all access patterns
**Outcome:** O4, O2

### Epic 4: Care Plans (E2EE)
**Hypothesis:** We believe that providing encrypted, in-app care plan access will improve care quality and carer confidence, because the #1 care concern is outdated or inaccessible care instructions.
**Success Metric:** Care plan viewed within first shift by 90%+ of carers
**Effort:** Medium (3-4 weeks) — E2EE key management, PDF upload, in-app viewer
**Outcome:** O2, O1

### Epic 5: PTO & Coverage
**Hypothesis:** We believe that streamlining PTO requests with in-app approval and manual cover assignment will reduce cover resolution time from 1-4 days to < 24 hours, because the current process relies on phone chains with no central visibility.
**Success Metric:** Average PTO resolution time < 24 hours
**Effort:** Medium (2-3 weeks)
**Outcome:** O1, O3

### Epic 6: Task System
**Hypothesis:** We believe that structured swapover checklists tied to schedule rotation will improve handover quality, because the current informal process leads to missed information at every carer swap.
**Success Metric:** Checklist completion rate > 80%
**Effort:** Medium (3-4 weeks) — template editor, auto-generation, general tasks, recurring
**Outcome:** O1, O2

### Epic 7: Notifications & Real-time
**Hypothesis:** We believe that push notifications for critical events (PTO requests, shift changes, join requests) will keep all participants informed without requiring them to constantly check the app.
**Success Metric:** Notification delivery rate > 95%; average time-to-action < 4 hours
**Effort:** Medium (2-3 weeks) — APNs setup, Supabase triggers, notification preferences
**Outcome:** O1

### Epic 8: Shift Notes, Reminders & Emergency
**Hypothesis:** We believe that encrypted shift notes, time-based reminders, and emergency contacts will round out the daily care workflow, because carers need to communicate observations, be reminded of critical tasks, and access emergency information quickly.
**Success Metric:** Shift notes created by 50%+ of shifts; reminder acknowledgment rate > 90%
**Effort:** Medium (2-3 weeks)
**Outcome:** O2

### Epic 9: Calendar Integration
**Hypothesis:** We believe that exporting shifts to the device calendar will increase carer adoption, because carers want to see work shifts alongside personal commitments without opening a separate app.
**Success Metric:** Calendar sync enabled by 60%+ of carers
**Effort:** Small (1-2 weeks) — EventKit integration
**Outcome:** O1

### Epic 10: Availability & Broadcasting
**Hypothesis:** We believe that carer availability submission and open shift broadcasting will significantly improve cover resolution, because the client currently has no visibility into who can work extra shifts.
**Success Metric:** Open shifts filled within 12 hours when broadcast
**Effort:** Medium (2-3 weeks)
**Outcome:** O1, O3

### Epic 11: Activity Log & Offline
**Hypothesis:** We believe that an activity timeline and offline mode will give clients confidence in care oversight and ensure the app works in all environments.
**Success Metric:** Activity log checked weekly by 70%+ of clients; app functions offline for core features
**Effort:** Medium (3-4 weeks) — audit logging, SwiftData caching, sync queue
**Outcome:** O1, O2

### Epic 12: Care-y AI Assistant
**Hypothesis:** We believe that an on-device AI assistant powered by Apple Foundation Models will be a unique differentiator, because no competitor offers privacy-preserving natural language queries against care data.
**Success Metric:** Care-y used by 40%+ of users weekly; query accuracy > 85%
**Effort:** Large (4-5 weeks) — Apple Foundation Models integration, context assembly, privacy filtering, PDF text extraction
**Outcome:** O1, O2, O5 (premium feature potential)

### Epic 13: Polish & App Store Launch
**Hypothesis:** We believe that dedicated polish time (onboarding flow, error handling, edge cases, App Store preparation) will significantly improve first impressions and review success.
**Success Metric:** App Store approval on first submission; 4.5+ rating in first month
**Effort:** Medium (2-3 weeks)
**Outcome:** O1, O2

---

## Dependency Map

```
Epic 1 (Foundation & Auth)
  ├──→ Epic 2 (Scheduling Engine)
  │      ├──→ Epic 5 (PTO & Coverage)
  │      │      └──→ Epic 10 (Availability & Broadcasting)
  │      ├──→ Epic 6 (Task System)
  │      ├──→ Epic 8 (Shift Notes, Reminders, Emergency)
  │      ├──→ Epic 9 (Calendar Integration)
  │      └──→ Epic 12 (Care-y AI) — also depends on Epic 4
  ├──→ Epic 3 (Privacy Engine / RLS)
  │      └──→ All other epics (privacy is cross-cutting)
  ├──→ Epic 4 (Care Plans / E2EE)
  │      └──→ Epic 12 (Care-y AI needs care plan data)
  └──→ Epic 7 (Notifications) — parallel with scheduling
        └──→ Epic 5, 10 (PTO and broadcasting need notifications)

Epic 11 (Activity Log & Offline) — depends on Epics 2, 5, 6 (needs data to log)
Epic 13 (Polish & Launch) — depends on all MVP epics being complete
```

---

## Prioritization (Effort-Impact Scoring)

Using a simplified RICE-inspired approach for a solo developer:

| Epic | Impact (1-5) | Confidence | Effort (weeks) | Priority Score | Release |
|---|---|---|---|---|---|
| E1: Foundation & Auth | 5 (enables all) | 95% | 3-4 | Foundational | R1-Alpha |
| E3: Privacy Engine | 5 (core differentiator) | 90% | 2-3 | Foundational | R1-Alpha |
| E2: Scheduling Engine | 5 (core value prop) | 90% | 4-5 | Critical | R1-Alpha |
| E4: Care Plans (E2EE) | 4 (care quality) | 85% | 3-4 | High | R1-Beta |
| E5: PTO & Coverage | 4 (daily operations) | 90% | 2-3 | High | R1-Beta |
| E7: Notifications | 4 (engagement) | 85% | 2-3 | High | R1-Beta |
| E6: Task System | 4 (handover quality) | 85% | 3-4 | High | R1-Beta |
| E8: Shift Notes/Reminders | 3 (daily workflow) | 80% | 2-3 | Medium | R1-RC |
| E9: Calendar Integration | 3 (adoption driver) | 90% | 1-2 | Medium | R1-RC |
| E11: Activity Log & Offline | 3 (oversight + reliability) | 75% | 3-4 | Medium | R1-RC |
| E13: Polish & Launch | 4 (first impression) | 90% | 2-3 | High | R1-Launch |
| E10: Availability & Broadcasting | 3 (cover efficiency) | 80% | 2-3 | Medium | R2 |
| E12: Care-y AI | 4 (differentiation) | 70% | 4-5 | High (strategic) | R2 |

---

## Timeline Roadmap

Based on full-time solo development (35-40 hrs/week), strong SwiftUI skills, learning Supabase.

### Phase 0: Setup & Learning (Weeks 1-2) — March 2026

**Goal:** Establish project foundation and learn Supabase.

| Week | Focus | Deliverables |
|---|---|---|
| 1 | Project setup | Xcode project scaffold (SwiftUI, MVVM), Supabase project creation, database schema design, dev environment |
| 2 | Supabase ramp-up | Complete Supabase Swift SDK tutorials, prototype auth flow, prototype basic CRUD, understand RLS |

**Milestone:** Working prototype of signup + basic data operations with Supabase.

---

### R1-Alpha: Core Engine (Weeks 3-9) — March-April 2026

**Goal:** Working scheduling system with privacy enforcement.

| Week | Epic | Focus | Deliverables |
|---|---|---|---|
| 3-4 | E1: Foundation & Auth | Auth flows, profile creation, care group creation | Email/password signup, Sign in with Apple, care group wizard, invite code generation |
| 5 | E1 + E3: Auth + Privacy | Join request flow, RLS policies | Invite → join → approve flow, RLS policies for all tables, privacy mode enforcement |
| 6-7 | E2: Scheduling Engine (Part 1) | Rotation builder, shift generation | Visual rotation pattern builder, auto-generate shifts from pattern, shift model/storage |
| 8-9 | E2: Scheduling Engine (Part 2) | Schedule views, shift editing | Calendar view, list view, edit individual shifts, schedule dashboard |

**Alpha Milestone (Week 9):** A client can create a care group, invite carers, define a rotation, and auto-generate a privacy-enforced schedule. Carers can sign up, join, and see only their own shifts.

---

### R1-Beta: Daily Operations (Weeks 10-17) — May-June 2026

**Goal:** Full daily workflow — PTO, care plans, tasks, notifications.

| Week | Epic | Focus | Deliverables |
|---|---|---|---|
| 10-11 | E4: Care Plans (E2EE) | E2EE key management, PDF upload/view | CryptoKit key generation/exchange, encrypted PDF upload to Supabase Storage, in-app PDFKit viewer |
| 12-13 | E5: PTO & Coverage | PTO request/approval flow | Carer PTO submission, client review/approve/deny, affected shifts flagging, manual cover assignment |
| 14 | E7: Notifications | Push notification system | APNs setup, notification triggers for PTO/shifts/join requests, in-app notification center |
| 15-17 | E6: Task System | Swapover + general tasks | Checklist template editor, auto-instance generation, general task CRUD, recurring tasks, task completion |

**Beta Milestone (Week 17):** Full daily operations flow. Client can manage PTO, tasks, and care plans. Carers can complete tasks, view care plans, and request time off. All with push notifications.

---

### R1-RC: Polish & Launch Prep (Weeks 18-23) — July-August 2026

**Goal:** Round out the experience for launch.

| Week | Epic | Focus | Deliverables |
|---|---|---|---|
| 18-19 | E8: Shift Notes/Reminders/Emergency | Daily workflow features | Encrypted shift notes, time-based reminders, emergency contacts with one-tap call |
| 20 | E9: Calendar Integration | EventKit export | Shift → calendar event sync, dedicated CareCoordinator calendar, auto-update on changes |
| 21-22 | E11: Activity Log & Offline | Oversight + reliability | Activity timeline, audit logging, SwiftData offline caching, sync queue, offline indicators |
| 23 | E13: Polish & Launch (Part 1) | App Store preparation | Onboarding flow, error handling, edge cases, App Store screenshots/description, TestFlight beta |

**RC Milestone (Week 23):** Feature-complete for v1. Ready for beta testing.

---

### Beta Testing (Weeks 24-26) — August-September 2026

**Goal:** Real-world validation with beta testers.

| Week | Focus | Activities |
|---|---|---|
| 24 | Beta launch | Release via TestFlight to 5-10 real care coordinators (recruit from Facebook groups, care communities) |
| 25 | Feedback collection | Bug reports, UX feedback, privacy verification, performance monitoring |
| 26 | Bug fixes + iteration | Address critical bugs, polish rough edges, iterate on UX based on feedback |

**Beta Milestone (Week 26):** App validated by real users. Critical bugs fixed. Ready for App Store submission.

---

### R1-Launch: App Store (Week 27) — September 2026

| Week | Focus | Activities |
|---|---|---|
| 27 | App Store submission | Final polish, App Store assets, privacy policy, submit for review |
| 28 | Launch! | App Store approval, soft launch, monitor reviews and metrics |

**Launch Target: September 2026** (6 months from start)

---

### R2: Enhanced Experience (Weeks 29-40) — October-December 2026

**Goal:** Differentiation features and growth.

| Week | Epic | Focus | Deliverables |
|---|---|---|---|
| 29-30 | E10: Availability & Broadcasting | Cover efficiency | Carer availability submission, open shift broadcasting, claim flow |
| 31-35 | E12: Care-y AI | AI differentiator | Apple Foundation Models integration, context assembly, privacy-filtered queries, care plan text extraction |
| 36-37 | Biometric unlock | Security convenience | Face ID/Touch ID via LocalAuthentication + Keychain |
| 38-40 | Notification preferences, UX polish, analytics | Retention | Granular notification controls, onboarding improvements, usage analytics |

**R2 Milestone (Week 40):** Care-y AI live, availability broadcasting, biometric unlock. Strong differentiator set.

---

### R3: Intelligence & Scale (Q1 2027)

| Focus | Deliverables |
|---|---|
| Care-y enhancements | Task + availability queries, schedule optimization suggestions |
| E2EE key rotation | Full key lifecycle management on carer removal |
| Export & reporting | Schedule export (PDF/CSV), activity log export |
| Search | Search within shift notes |
| Advanced scheduling | Rotation presets, pattern suggestions, split shifts |

---

### Future (2027+)

| Initiative | Rationale |
|---|---|
| Android app | Expand addressable market |
| Web dashboard for clients | Convenience for desktop management |
| Apple Watch companion | Shift reminders on wrist |
| Multi-care-group support | Carers working for multiple clients |
| Family member read-only access | Siblings who want visibility |
| Premium features / subscription | Revenue model (Care-y, advanced reporting, multiple care plans) |

---

## Now / Next / Later Summary

### NOW (March-September 2026) — Committed

**Theme: "Make care coordination work"**
- Auth + invite system with privacy enforcement
- Auto-generating rotation schedules
- PTO requests and manual cover assignment
- E2E encrypted care plans
- Swapover checklists + general tasks
- Push notifications
- Shift notes, reminders, emergency contacts
- Calendar integration
- Activity log + offline mode
- App Store launch

### NEXT (October-December 2026) — High Confidence

**Theme: "Make it intelligent and efficient"**
- Care-y AI assistant (on-device, privacy-filtered)
- Carer availability + shift broadcasting
- Biometric unlock
- Notification preferences
- UX polish based on beta feedback

### LATER (2027) — Lower Confidence

**Theme: "Scale and expand"**
- Care-y intelligence upgrades
- Advanced scheduling features
- Export and reporting
- Android app
- Web dashboard
- Premium subscription model

---

## Risk Mitigation Timeline

| Risk | When | Mitigation |
|---|---|---|
| Supabase learning curve | Weeks 1-4 | Dedicated ramp-up week; prototype before building features |
| E2EE complexity | Weeks 10-11 | Build proof-of-concept first; use CryptoKit's well-tested primitives only |
| Apple Foundation Models limitations | Weeks 31-35 | Test with real care data early (week 31); have graceful degradation built in |
| App Store review for health-adjacent app | Week 27 | Research Apple's health app guidelines before submission; privacy policy ready |
| Low initial adoption | Weeks 28+ | Pre-launch community building (weeks 20-26); recruit beta testers from care groups |
| Scope creep | Throughout | YAGNI ruthlessly; features not in roadmap get added to "Future" only |
| Burnout (solo developer) | Throughout | Plan for 1 week off every 8 weeks; scope features conservatively |

---

## Revenue Model Considerations

| Model | Pros | Cons | Recommendation |
|---|---|---|---|
| **Free app, paid premium** | Low barrier to entry; grow user base fast | Need clear premium value; risk of "good enough" free tier | Consider for launch |
| **Subscription ($4.99/month)** | Predictable revenue; aligns with ongoing service value | Friction at signup; may slow adoption | Good for post-PMF |
| **Free for carers, paid for client** | Carers have zero friction; client pays for the value they receive | Need strong enough value prop for client to pay | Best model for this product |

**Recommended: Free for carers, paid for client ($4.99-$9.99/month)**
- Carers download for free, enter invite code, use app — zero friction
- Client gets 30-day free trial, then subscription
- Premium features: Care-y AI, advanced analytics, unlimited care plans, priority support
- Basic tier (free forever): 2 carers, 1 care plan, basic scheduling
