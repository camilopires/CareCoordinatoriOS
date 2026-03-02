# CareCoordinator iOS — AI Strategy & Readiness Assessment

**Date:** 2026-03-01
**Author:** Camilo Pires
**Framework:** AI-Shaped Readiness Advisor

---

## 1. AI-Shaped Readiness Assessment

### Context

- **AI tools in use:** Claude Code (planning, product thinking, code generation)
- **Usage pattern:** One-off assisted sessions (not yet orchestrated workflows)
- **Team size:** Solo indie developer
- **Stage:** Pre-launch startup
- **Decision-making:** Centralized (solo)
- **Competitive advantage sought:** On-device, privacy-preserving AI that no competitor offers for individual care coordination
- **Biggest bottleneck:** Solo developer capacity — can't parallelize work

### Maturity Profile

```
┌─────────────────────────────┬───────┬──────────────────┐
│ Competency                  │ Level │ Maturity          │
├─────────────────────────────┼───────┼──────────────────┤
│ 1. Context Design           │   2   │ Emerging          │
│ 2. Agent Orchestration      │   1   │ AI-First          │
│ 3. Outcome Acceleration     │   2   │ Emerging          │
│ 4. Team-AI Facilitation     │  N/A  │ Solo (not needed) │
│ 5. Strategic Differentiation│   3   │ Transitioning     │
└─────────────────────────────┴───────┴──────────────────┘

Overall Assessment: Emerging (with strong strategic intent)
```

### Assessment Rationale

**Context Design (Level 2 — Emerging):**
- You have product docs (PRD, design doc, PM artifacts) but they're being created right now
- No structured CLAUDE.md project instructions yet for the codebase
- No constraints registry or operational glossary for AI agents to reference
- **Gap:** Need to set up project-level CLAUDE.md, coding conventions, and architecture context so AI (Claude Code) can assist effectively throughout development

**Agent Orchestration (Level 1 — AI-First):**
- Using Claude Code in conversational mode (this session)
- No saved workflows, templates, or repeatable AI processes
- **Gap:** Need repeatable workflows for common development tasks (e.g., "implement a new feature" → research → plan → test → implement → verify)

**Outcome Acceleration (Level 2 — Emerging):**
- This session demonstrates acceleration: product strategy that would take weeks done in hours
- Using AI for research synthesis (PM frameworks applied systematically)
- **Gap:** Not yet applied to development cycles (e.g., AI-assisted testing, automated code review)

**Team-AI Facilitation (N/A):**
- Solo developer — no team to facilitate. Skip this competency.
- **When relevant:** If you hire or collaborate later, establish review norms then

**Strategic Differentiation (Level 3 — Transitioning):**
- Care-y (on-device AI) is a genuine differentiator — competitors can't replicate without redesigning their architecture
- Privacy-preserving AI (Apple Foundation Models, no cloud) is a defensible advantage
- E2EE + on-device AI combination is a moat
- **Gap:** Need to validate that Apple Foundation Models can actually deliver useful answers for care-related queries

---

## 2. Priority Recommendation: Context Design

**Why:** Context Design is foundational. If Claude Code has proper project context (architecture decisions, coding patterns, data model, conventions), every future development session is dramatically more productive. For a solo developer, this is a force multiplier.

### Action Plan

**Phase 1: Project-Level CLAUDE.md (Week 1)**
Create `/CareCoordinatoriOS/CLAUDE.md` with:

```markdown
# CareCoordinator iOS

## Architecture
- SwiftUI + MVVM with repository layer
- Supabase backend (Postgres + Auth + Storage + Realtime)
- supabase-swift SDK for all backend communication
- CryptoKit for E2EE (AES-GCM symmetric, Curve25519 key exchange)
- Apple Foundation Models for Care-y AI (iOS 18.1+)
- EventKit for calendar integration
- PDFKit for care plan viewing
- SwiftData for local caching
- Keychain for secrets and crypto keys

## Data Model
- See docs/plans/2026-03-01-care-coordinator-prd.md Appendix A

## Conventions
- Swift 6 with strict concurrency
- SwiftUI views are thin — business logic in ViewModels
- Repository pattern for Supabase data access
- All Supabase queries go through repository layer (never direct from ViewModel)
- RLS policies enforce privacy — app code should NOT re-implement access control
- E2EE: encrypt before sending to Supabase, decrypt after receiving
- Error handling: Result types for repository methods, alerts for user-facing errors
- Navigation: NavigationStack with typed destinations

## Security Rules
- Never log sensitive data (care plans, shift notes, personal info)
- Never store unencrypted sensitive data on device
- Always validate user role before showing UI (defense in depth with RLS)
- Keychain for all secrets (tokens, crypto keys)
- NSFileProtectionComplete for cached files

## Testing
- Unit tests for ViewModels and repositories
- Integration tests for Supabase RLS policies
- UI tests for critical flows (signup, invite, schedule creation)
```

**Phase 2: Constraints Registry (Week 1)**
Create `/docs/constraints.md`:

| # | Constraint | Type | Impact |
|---|-----------|------|--------|
| C1 | iOS 17+ minimum deployment target | Technical | Limits APIs available; Care-y requires iOS 18.1+ |
| C2 | Supabase free tier: 500MB DB, 1GB storage, 50K MAU | Technical | Sufficient for development and early users |
| C3 | Apple Foundation Models run on-device only | Technical | No server-side AI; context must fit on-device model limits |
| C4 | E2EE means server cannot query encrypted content | Technical | Schedule metadata must remain unencrypted for server queries |
| C5 | Solo developer — no parallelization of work | Operational | Sequential delivery; one feature at a time |
| C6 | App Store review for health-adjacent content | Regulatory | May need privacy policy, health disclaimers |
| C7 | Privacy modes enforced at DB level (RLS) | Architectural | App must never implement its own access control layer |
| C8 | CryptoKit only — no third-party crypto libraries | Technical | Reduces supply chain risk |
| C9 | Supabase Swift SDK is the only backend client | Architectural | No direct REST calls; all queries through SDK |
| C10 | Care-y conversations are on-device only | Privacy | No server storage of AI chat history |

**Phase 3: Operational Glossary (Week 2)**

| Term | Definition |
|---|---|
| **Care Group** | The top-level entity. One client owns one care group. Contains all carers, schedules, tasks, and care plans for one care recipient. |
| **Client** | The person managing care (family member, guardian). Has full CRUD access. One per care group. |
| **Carer** | A caregiver in the rotation. Has limited access based on privacy mode. Multiple per care group. |
| **Privacy Mode** | Care group setting controlling data visibility: `full` (own data only), `anonymous` (all data, names hidden), `open` (full visibility). |
| **Rotation Pattern** | Client-defined ordered sequence of carer assignments per week. Repeats cyclically. |
| **Shift** | A single work period for a carer. Has date, start time, end time, carer assignment, and status. |
| **Shift Status** | `scheduled` → `needing_cover` → `covered` → `completed` / `cancelled` |
| **Swapover** | The transition point when one carer's rotation ends and another's begins. |
| **Swapover Checklist** | Template-based recurring checklist auto-generated at each swapover. |
| **PTO Request** | Carer's request for time off. Submitted → approved/denied by client. |
| **Shift Offer** | An open shift broadcast to available carers when cover is needed. |
| **Shift Note** | Free-form text a carer leaves at the end of their shift. E2E encrypted. |
| **Care Plan** | PDF document containing care instructions. E2E encrypted in Supabase Storage. |
| **Group Key** | AES-256 symmetric key used for E2EE within a care group. Shared via public key exchange. |
| **Care-y** | On-device AI assistant powered by Apple Foundation Models. Privacy-filtered per user role. |
| **Invite Code** | Unique, time-limited code generated by client for carers to request access. |
| **Join Request** | Carer's request to join a care group after entering an invite code. Requires client approval. |
| **Activity Log** | Client-facing timeline of all events in the care group (immutable audit trail). |
| **RLS** | Row-Level Security. Supabase/Postgres feature that filters data at query time based on user identity and policies. |
| **Repository** | Swift layer that encapsulates all Supabase data operations. ViewModels never call Supabase directly. |

---

## 3. Care-y AI — Deep Technical Strategy

### What Makes Care-y AI-Shaped (Not Just AI-First)

| Dimension | AI-First Version | Care-y (AI-Shaped) |
|---|---|---|
| Data privacy | Send data to cloud AI → get answers | On-device only. Care data never leaves the phone. |
| Access control | App-level filtering (trust the client code) | Privacy-filtered context assembly BEFORE model sees data. DB-level enforcement. |
| Competitive moat | Any app can add ChatGPT | Requires Apple ecosystem commitment, on-device model expertise, privacy-first architecture. Can't be replicated by "adding AI" to a web app. |
| User trust | "We promise not to share your data" | "Your data literally cannot leave your device for AI processing." |

### Architecture

```
┌──────────────────────────────────────────────┐
│                  User Query                   │
│          "Who's working next Tuesday?"        │
└────────────────────┬─────────────────────────┘
                     │
┌────────────────────▼─────────────────────────┐
│            Role & Privacy Check               │
│  • What role is this user? (client/carer)     │
│  • What privacy mode is the care group in?    │
│  • What data is this user permitted to see?   │
└────────────────────┬─────────────────────────┘
                     │
┌────────────────────▼─────────────────────────┐
│         Context Assembly (Privacy-Filtered)    │
│  • Fetch permitted schedule data (local cache) │
│  • Fetch permitted task data                   │
│  • Extract text from permitted care plans      │
│  • Assemble structured context payload         │
│  • FILTER OUT anything user isn't allowed to   │
│    see BEFORE sending to model                 │
└────────────────────┬─────────────────────────┘
                     │
┌────────────────────▼─────────────────────────┐
│      Apple Foundation Models (On-Device)       │
│  System prompt:                                │
│  "You are Care-y, a care coordination          │
│   assistant. Answer questions using ONLY the   │
│   provided context. If the information isn't   │
│   in the context, say you don't have that      │
│   information. Never guess or hallucinate.     │
│   Never reveal information about other carers  │
│   if the user is a carer in full/anonymous     │
│   privacy mode."                               │
│                                                │
│  Context: [privacy-filtered data payload]      │
│  Query: [user's question]                      │
└────────────────────┬─────────────────────────┘
                     │
┌────────────────────▼─────────────────────────┐
│              Response Display                  │
│  • Show answer in chat UI                      │
│  • Store conversation on-device only           │
│  • No server sync of chat history              │
└──────────────────────────────────────────────┘
```

### Context Assembly Strategy

The key challenge is fitting relevant data within the on-device model's context window while respecting privacy. Strategy:

**Always included (for all users):**
- Current date/time
- Care group name
- User's role and name
- Privacy mode

**Client context:**
- Full schedule (next 4 weeks)
- All carer names and assignments
- Pending PTO requests
- Incomplete tasks
- Recent shift notes (last 2 weeks)
- Carer availability data
- Care plan text summaries (extracted from PDFs, not full PDFs)

**Carer context (full privacy mode):**
- Own shifts only (next 4 weeks)
- Own tasks
- Own PTO requests and status
- Care plan text summaries
- Own shift notes

**Carer context (anonymous mode):**
- All shifts (carer names replaced with "Another carer")
- Own tasks
- Own PTO requests
- Care plan text summaries
- Shift notes from own shifts + anonymous notes from others

**Carer context (open mode):**
- Full schedule with names
- All tasks
- Own PTO requests
- Care plan text summaries
- All shift notes

### PDF Text Extraction for Care-y

Options for extracting text from care plan PDFs:

| Method | Pros | Cons | Recommendation |
|---|---|---|---|
| **PDFKit text extraction** | Built-in, fast, no dependencies | Only works on text-based PDFs, not scanned images | Primary method |
| **Vision framework OCR** | Handles scanned PDFs | Slower, may be less accurate | Fallback for image PDFs |
| **Pre-extraction on upload** | Extract once, cache text | Need to store extracted text (encrypted) | Best for performance |

**Recommended approach:** Extract text on upload using PDFKit, fall back to Vision OCR for image-based PDFs, store encrypted text summary alongside the PDF. Care-y queries the pre-extracted text, not the PDF itself.

### Apple Foundation Models — Technical Considerations

| Consideration | Detail |
|---|---|
| **Availability** | iOS 18.1+ with Apple Intelligence enabled. Not available on all devices. |
| **API** | Foundation framework (`FoundationModels`). Structured generation support. |
| **Context limits** | On-device models have smaller context windows than cloud models. Must be efficient. |
| **Latency** | On-device inference is fast but depends on device (A17 Pro+ recommended). |
| **Capabilities** | Good for structured queries, question answering, summarization. May struggle with complex reasoning. |
| **Privacy guarantee** | Data never leaves device. Apple's core selling point. |

### Care-y Query Categories

| Category | Example Queries | Context Needed | Complexity |
|---|---|---|---|
| **Schedule queries** | "Who's working Tuesday?", "When's my next shift?" | Schedule data (small) | Low |
| **Availability queries** | "Who can cover Monday?", "Is anyone free this weekend?" | Availability + schedule (medium) | Low |
| **Task queries** | "Are there incomplete tasks?", "What's on the swapover checklist?" | Task data (small) | Low |
| **Care plan queries** | "What are the medication instructions?", "What's the emergency procedure?" | Extracted PDF text (large) | Medium |
| **Compound queries** | "Show me Sarah's schedule and any PTO conflicts" | Schedule + PTO (medium) | Medium |
| **Analytical queries** | "How many shifts has each carer worked this month?" | Historical schedule (medium) | Medium |

### Care-y Graceful Degradation

```
If Apple Intelligence available:
  → Full Care-y experience

If Apple Intelligence NOT available (older device, disabled):
  → Show message: "Care-y requires Apple Intelligence (iOS 18.1+).
     Enable it in Settings > Apple Intelligence & Siri."
  → Offer alternative: Quick-look buttons for common queries
     (e.g., "View next shift", "Open care plan", "See PTO status")
  → These buttons navigate to the relevant app screens
```

---

## 4. AI in the Development Process

### How to Use Claude Code AI-Shapedly During Development

Beyond Care-y as a product feature, here's how to use AI strategically in your development workflow:

**Context Design (do this first):**
- Create the project-level CLAUDE.md (Section 2 above)
- Commit constraints registry and glossary to the repo
- Every Claude Code session starts with structured context, not "from scratch"

**Development Workflow (repeatable):**
1. **Research phase:** Ask Claude Code to explore Supabase docs, SwiftUI patterns, CryptoKit APIs for the current epic
2. **Plan phase:** Use writing-plans skill to create implementation plan for the epic
3. **Reset:** Start fresh session with plan as context (avoid context rot)
4. **Implement:** Use TDD skill — write tests first, then implement
5. **Verify:** Use verification skill before claiming anything is done

**Testing with AI:**
- Use Claude Code to generate RLS policy test cases (critical for privacy)
- Generate edge case scenarios for the scheduling engine
- Create mock data for different rotation patterns

**Code Review with AI:**
- After each epic, use code-reviewer to check against PRD requirements
- Security-focused review of all RLS policies
- Privacy audit: verify no data leakage paths

---

## 5. AI Differentiation Moat Analysis

### Why Care-y is a Defensible Moat

**Test: "Can a competitor replicate this by throwing bodies at it?"**

| Capability | Can competitors copy? | Why/Why not |
|---|---|---|
| On-device AI for care queries | Hard | Requires Apple ecosystem commitment, on-device model expertise, and privacy-first data architecture. Web-based competitors can't do on-device. Android competitors need different tech. |
| Privacy-filtered AI context | Hard | Requires deep integration between privacy engine (RLS) and AI context assembly. Can't bolt this onto an existing app. |
| E2EE + AI combination | Very hard | E2EE means the server can't assemble AI context. Must be done on-device. This architectural constraint IS the moat. |
| Care plan understanding | Medium | PDF text extraction is standard. But combining it with privacy filtering and on-device processing is unique. |
| "Data never leaves device" promise | Hard for cloud-based competitors | Any competitor using cloud AI (GPT, Claude API) can't make this promise. On-device is structurally different. |

**Moat Verdict: Strong.** The combination of on-device AI + E2EE + privacy-filtered context creates a moat that requires fundamental architectural redesign to replicate. Competitors using cloud backends would need to rebuild from scratch to match this.

### AI Feature Expansion Roadmap

| Phase | Feature | Description |
|---|---|---|
| **R2 (launch)** | Schedule + care plan queries | Core Care-y: answer questions about who's working, what the care plan says |
| **R3** | Task + availability queries | "Are there incomplete tasks?", "Who can cover Monday?" |
| **R3** | Proactive suggestions | "Reminder: Sarah's PTO starts Monday, no cover assigned yet" |
| **Future** | Schedule optimization | "Based on availability, here's a suggested rotation that minimizes conflicts" |
| **Future** | Care plan summarization | Auto-summarize long care plans into key points for quick reference |
| **Future** | Anomaly detection | "Shift notes mention increased pain 3 days in a row — flag for client?" |

---

## 6. Summary: AI-Shaped CareCoordinator

CareCoordinator is positioned as an **AI-shaped product** because:

1. **AI is not a bolt-on** — Care-y is architecturally integrated with the privacy engine and E2EE system. It's not "ChatGPT in a sidebar."
2. **Privacy IS the AI strategy** — On-device processing isn't a limitation, it's the competitive advantage. "Your care data never leaves your phone" is a trust statement no cloud-AI competitor can make.
3. **The combination is the moat** — RLS + E2EE + on-device AI is a three-layer defense that can't be replicated by adding a feature. It requires fundamental architecture alignment.
4. **AI enhances the core job** — Care-y answers the question "Is X working on this date?" in 2 seconds instead of 5 minutes of spreadsheet/WhatsApp searching. It directly accelerates the functional job (F8).
5. **Graceful degradation preserves value** — The app is fully functional without Care-y. AI is a differentiator, not a dependency. This is the right posture for a v1 product.
