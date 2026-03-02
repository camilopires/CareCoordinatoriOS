# CareCoordinator iOS — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a privacy-first iOS care scheduling app with auto-rotating shifts, E2E encrypted care plans, PTO management, task checklists, and an on-device AI assistant — all powered by Supabase backend with Row-Level Security.

**Architecture:** SwiftUI + MVVM with repository layer talking directly to Supabase via `supabase-swift` SDK. Row-Level Security (RLS) enforces all privacy rules at the database level. CryptoKit provides E2EE for sensitive content. Apple Foundation Models power the on-device AI assistant "Care-y".

**Tech Stack:** SwiftUI (iOS 17+), Supabase (Postgres + Auth + Storage + Realtime), CryptoKit (AES-GCM, Curve25519), EventKit, PDFKit, Apple Foundation Models (iOS 26+), SwiftData, Keychain

**Reference Docs:**
- `docs/plans/2026-03-01-care-coordinator-prd.md` — Full PRD with user stories
- `docs/plans/2026-03-01-care-coordinator-design.md` — Architecture & data model
- `docs/plans/2026-03-01-care-coordinator-roadmap.md` — Epic ordering & timeline
- `docs/plans/2026-03-01-care-coordinator-pm-artifacts.md` — JTBD, positioning, journey map
- `docs/plans/2026-03-01-care-coordinator-ai-strategy.md` — Care-y architecture & AI strategy

---

## Phase 0: Project Setup & Supabase Foundation (Weeks 1-2)

### Task 0.1: Create Xcode Project

**Files:**
- Create: `CareCoordinator.xcodeproj` (via Xcode)
- Create: `CareCoordinator/CareCoordinatorApp.swift`
- Create: `CareCoordinator/ContentView.swift`

**Step 1: Create Xcode project**

Create a new Xcode project:
- Template: App
- Product Name: `CareCoordinator`
- Team: Your Apple Developer account
- Organization Identifier: `com.carecoordinator`
- Interface: SwiftUI
- Language: Swift
- Storage: None (we'll add SwiftData later)
- Testing System: Swift Testing
- Minimum deployment target: iOS 17.0

**Step 2: Verify project builds and runs**

Run: `Cmd+R` in Xcode (or `xcodebuild -scheme CareCoordinator -destination 'platform=iOS Simulator,name=iPhone 16'`)
Expected: App launches in simulator with default "Hello, world!" view.

**Step 3: Set up folder structure**

Create these group folders in Xcode (and on disk):

```
CareCoordinator/
├── App/
│   ├── CareCoordinatorApp.swift
│   └── ContentView.swift
├── Models/
├── ViewModels/
├── Views/
│   ├── Auth/
│   ├── Dashboard/
│   ├── Schedule/
│   ├── Tasks/
│   ├── CarePlans/
│   ├── Carers/
│   ├── Carey/
│   └── Settings/
├── Repositories/
├── Services/
│   ├── Auth/
│   ├── Crypto/
│   ├── Calendar/
│   └── Notifications/
├── Utilities/
└── Resources/
```

Run: Build project to verify structure doesn't break anything.

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: scaffold Xcode project with MVVM folder structure"
```

---

### Task 0.2: Add Supabase Swift Package

**Files:**
- Modify: `CareCoordinator.xcodeproj` (via Xcode Package Manager)
- Create: `CareCoordinator/Services/SupabaseManager.swift`

**Step 1: Add supabase-swift via SPM**

In Xcode:
1. File → Add Package Dependencies
2. URL: `https://github.com/supabase/supabase-swift`
3. Version rule: Up to Next Major from `2.0.0`
4. Add `Supabase` product to `CareCoordinator` target

**Step 2: Create SupabaseManager singleton**

```swift
// CareCoordinator/Services/SupabaseManager.swift
import Supabase
import Foundation

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://YOUR_PROJECT_REF.supabase.co")!,
        supabaseKey: "YOUR_ANON_KEY"
    )
}
```

**Step 3: Verify it compiles**

Run: Build project (`Cmd+B`)
Expected: Compiles with no errors. The placeholder URL/key will be replaced in Task 0.3.

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: add supabase-swift SDK dependency and manager singleton"
```

---

### Task 0.3: Create Supabase Project & Configure

**Files:**
- Modify: `CareCoordinator/Services/SupabaseManager.swift`
- Create: `CareCoordinator/Resources/Secrets.swift` (add to .gitignore)
- Modify: `.gitignore`

**Step 1: Create Supabase project**

1. Go to https://supabase.com/dashboard
2. Create new project: "CareCoordinator"
3. Choose region closest to you
4. Set a strong database password (save it securely)
5. Wait for project to provision
6. Copy: Project URL and anon key from Settings → API

**Step 2: Create secrets file (not committed)**

```swift
// CareCoordinator/Resources/Secrets.swift
import Foundation

enum Secrets {
    static let supabaseURL = "https://YOUR_ACTUAL_PROJECT_REF.supabase.co"
    static let supabaseAnonKey = "YOUR_ACTUAL_ANON_KEY"
}
```

**Step 3: Add to .gitignore**

```
# CareCoordinator/.gitignore
# Secrets
CareCoordinator/Resources/Secrets.swift

# Xcode
*.xcuserdata/
DerivedData/
*.xcworkspace/xcuserdata/

# Swift Package Manager
.build/
Packages/

# OS
.DS_Store
```

**Step 4: Update SupabaseManager to use Secrets**

```swift
// CareCoordinator/Services/SupabaseManager.swift
import Supabase
import Foundation

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: Secrets.supabaseURL)!,
        supabaseKey: Secrets.supabaseAnonKey
    )
}
```

**Step 5: Verify connection works**

Add a temporary test in `ContentView.swift`:

```swift
import SwiftUI
import Supabase

struct ContentView: View {
    @State private var connectionStatus = "Testing..."

    var body: some View {
        Text(connectionStatus)
            .task {
                do {
                    // Simple health check — try to query a non-existent table
                    // This will fail with a 404 (table not found), but proves the connection works
                    let _: [EmptyRow] = try await SupabaseManager.client
                        .from("_health_check")
                        .select()
                        .execute()
                        .value
                    connectionStatus = "Connected!"
                } catch {
                    if error.localizedDescription.contains("relation") {
                        connectionStatus = "Connected! (table not found is expected)"
                    } else {
                        connectionStatus = "Error: \(error.localizedDescription)"
                    }
                }
            }
    }
}

private struct EmptyRow: Codable {}
```

Run: Build and run in simulator.
Expected: Shows "Connected! (table not found is expected)" — proving Supabase connectivity works.

**Step 6: Remove the test code from ContentView**

Revert `ContentView.swift` back to a simple placeholder.

**Step 7: Commit**

```bash
git add .gitignore CareCoordinator/Services/SupabaseManager.swift CareCoordinator/App/ContentView.swift
git commit -m "feat: configure Supabase project connection with secrets management"
```

---

### Task 0.4: Create Database Schema (Core Tables)

**Files:**
- Create: `supabase/migrations/001_core_schema.sql`

**Step 1: Create the SQL migration file**

Create a `supabase/` folder at the project root for SQL migrations (version-controlled reference):

```sql
-- supabase/migrations/001_core_schema.sql
-- CareCoordinator Core Schema
-- Run this in Supabase Dashboard → SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ENUMS
-- ============================================

CREATE TYPE privacy_mode AS ENUM ('full', 'anonymous', 'open');
CREATE TYPE user_role AS ENUM ('client', 'carer');
CREATE TYPE shift_status AS ENUM ('scheduled', 'needing_cover', 'covered', 'completed', 'cancelled');
CREATE TYPE pto_status AS ENUM ('pending', 'approved', 'denied');
CREATE TYPE shift_offer_status AS ENUM ('open', 'accepted', 'declined', 'expired');
CREATE TYPE task_type AS ENUM ('swapover_template', 'swapover_instance', 'general');
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high');
CREATE TYPE invitation_status AS ENUM ('active', 'revoked', 'expired');
CREATE TYPE join_request_status AS ENUM ('pending', 'approved', 'denied');
CREATE TYPE notification_type AS ENUM (
    'join_request', 'pto_request', 'shift_change', 'task_assigned',
    'open_shift', 'pto_decision', 'reminder', 'care_plan_update'
);

-- ============================================
-- TABLES
-- ============================================

-- Profiles (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    care_group_id UUID,  -- FK added after care_groups created
    display_name TEXT NOT NULL,
    email TEXT NOT NULL,
    public_key BYTEA,  -- Curve25519 public key for E2EE
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Care Groups
CREATE TABLE care_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    privacy_mode privacy_mode NOT NULL DEFAULT 'full',
    default_shift_start TIME NOT NULL DEFAULT '08:00',
    default_shift_end TIME NOT NULL DEFAULT '20:00',
    owner_id UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add FK from profiles to care_groups
ALTER TABLE profiles
    ADD CONSTRAINT fk_profiles_care_group
    FOREIGN KEY (care_group_id) REFERENCES care_groups(id);

-- Key Shares (E2EE group key encrypted per-user)
CREATE TABLE key_shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    encrypted_group_key BYTEA NOT NULL,  -- AES group key encrypted with user's public key
    sender_public_key BYTEA NOT NULL,    -- Public key of who encrypted it (for ECDH)
    key_version INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(care_group_id, user_id, key_version)
);

-- Rotation Patterns
CREATE TABLE rotation_patterns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    pattern JSONB NOT NULL,  -- ordered array of carer_ids per week
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Shifts
CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    carer_id UUID REFERENCES profiles(id),
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status shift_status NOT NULL DEFAULT 'scheduled',
    is_manually_edited BOOLEAN NOT NULL DEFAULT FALSE,
    original_carer_id UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shifts_care_group_date ON shifts(care_group_id, date);
CREATE INDEX idx_shifts_carer_date ON shifts(carer_id, date);

-- PTO Requests
CREATE TABLE pto_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    carer_id UUID NOT NULL REFERENCES profiles(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,  -- encrypted client-side
    status pto_status NOT NULL DEFAULT 'pending',
    client_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Shift Offers (for broadcasting open shifts)
CREATE TABLE shift_offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    offered_to UUID REFERENCES profiles(id),  -- null = broadcast to all
    status shift_offer_status NOT NULL DEFAULT 'open',
    accepted_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Carer Availability
CREATE TABLE carer_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    carer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME,  -- null = all day
    end_time TIME,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule TEXT,  -- e.g. "WEEKLY:TUE,THU"
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Care Plans
CREATE TABLE care_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT,
    storage_path TEXT NOT NULL,
    file_size BIGINT NOT NULL DEFAULT 0,
    uploaded_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Tasks
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    type task_type NOT NULL,
    parent_template_id UUID REFERENCES tasks(id),
    title TEXT NOT NULL,
    description TEXT,  -- encrypted client-side for sensitive content
    priority task_priority NOT NULL DEFAULT 'medium',
    due_date DATE,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule TEXT,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    completed_by UUID REFERENCES profiles(id),
    completed_at TIMESTAMPTZ,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Shift Notes
CREATE TABLE shift_notes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    carer_id UUID NOT NULL REFERENCES profiles(id),
    content TEXT NOT NULL,  -- encrypted client-side
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Reminders
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    time TIME NOT NULL,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule TEXT,
    created_by UUID NOT NULL REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Emergency Contacts
CREATE TABLE emergency_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    relationship TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Invitations
CREATE TABLE invitations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    created_by UUID NOT NULL REFERENCES profiles(id),
    max_uses INTEGER NOT NULL DEFAULT 1,
    times_used INTEGER NOT NULL DEFAULT 0,
    status invitation_status NOT NULL DEFAULT 'active',
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invitations_code ON invitations(code);

-- Join Requests
CREATE TABLE join_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invitation_id UUID NOT NULL REFERENCES invitations(id),
    carer_id UUID NOT NULL REFERENCES profiles(id),
    status join_request_status NOT NULL DEFAULT 'pending',
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, read) WHERE read = FALSE;

-- Audit Log (immutable)
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    care_group_id UUID NOT NULL REFERENCES care_groups(id),
    user_id UUID NOT NULL REFERENCES profiles(id),
    action TEXT NOT NULL,
    details JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_log_care_group ON audit_log(care_group_id, created_at DESC);

-- ============================================
-- AUTO-UPDATE TIMESTAMPS
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER set_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON care_groups FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON rotation_patterns FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON shifts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON pto_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON shift_offers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON carer_availability FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON care_plans FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON shift_notes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON reminders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON emergency_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================
-- AUTO-CREATE PROFILE ON SIGNUP
-- ============================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, role, display_name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'role', 'client')::user_role,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

**Step 2: Run migration in Supabase**

1. Go to Supabase Dashboard → SQL Editor
2. Paste the entire SQL file
3. Click "Run"
Expected: All tables created successfully with no errors.

**Step 3: Verify tables exist**

In Supabase Dashboard → Table Editor, confirm all 16 tables are listed:
`profiles`, `care_groups`, `key_shares`, `rotation_patterns`, `shifts`, `pto_requests`, `shift_offers`, `carer_availability`, `care_plans`, `tasks`, `shift_notes`, `reminders`, `emergency_contacts`, `invitations`, `join_requests`, `notifications`, `audit_log`

**Step 4: Commit**

```bash
git add supabase/
git commit -m "feat: add core database schema migration (16 tables, enums, triggers)"
```

---

### Task 0.5: Create Swift Data Models

**Files:**
- Create: `CareCoordinator/Models/CareGroup.swift`
- Create: `CareCoordinator/Models/Profile.swift`
- Create: `CareCoordinator/Models/Shift.swift`
- Create: `CareCoordinator/Models/Enums.swift`

**Step 1: Create shared enums**

```swift
// CareCoordinator/Models/Enums.swift
import Foundation

enum PrivacyMode: String, Codable, CaseIterable {
    case full
    case anonymous
    case open
}

enum UserRole: String, Codable {
    case client
    case carer
}

enum ShiftStatus: String, Codable {
    case scheduled
    case needingCover = "needing_cover"
    case covered
    case completed
    case cancelled
}

enum PTOStatus: String, Codable {
    case pending
    case approved
    case denied
}

enum TaskType: String, Codable {
    case swapoverTemplate = "swapover_template"
    case swapoverInstance = "swapover_instance"
    case general
}

enum TaskPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

enum InvitationStatus: String, Codable {
    case active
    case revoked
    case expired
}

enum JoinRequestStatus: String, Codable {
    case pending
    case approved
    case denied
}

enum NotificationType: String, Codable {
    case joinRequest = "join_request"
    case ptoRequest = "pto_request"
    case shiftChange = "shift_change"
    case taskAssigned = "task_assigned"
    case openShift = "open_shift"
    case ptoDecision = "pto_decision"
    case reminder
    case carePlanUpdate = "care_plan_update"
}
```

**Step 2: Create Profile model**

```swift
// CareCoordinator/Models/Profile.swift
import Foundation

struct Profile: Codable, Identifiable, Equatable {
    let id: UUID
    var role: UserRole
    var careGroupId: UUID?
    var displayName: String
    var email: String
    var publicKey: Data?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, role, email
        case careGroupId = "care_group_id"
        case displayName = "display_name"
        case publicKey = "public_key"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

**Step 3: Create CareGroup model**

```swift
// CareCoordinator/Models/CareGroup.swift
import Foundation

struct CareGroup: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var privacyMode: PrivacyMode
    var defaultShiftStart: String  // TIME as string "HH:mm"
    var defaultShiftEnd: String
    let ownerId: UUID
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name
        case privacyMode = "privacy_mode"
        case defaultShiftStart = "default_shift_start"
        case defaultShiftEnd = "default_shift_end"
        case ownerId = "owner_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

**Step 4: Create Shift model**

```swift
// CareCoordinator/Models/Shift.swift
import Foundation

struct Shift: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var carerId: UUID?
    var date: String  // DATE as "yyyy-MM-dd"
    var startTime: String  // TIME as "HH:mm"
    var endTime: String
    var status: ShiftStatus
    var isManuallyEdited: Bool
    var originalCarerId: UUID?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, date, status
        case careGroupId = "care_group_id"
        case carerId = "carer_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case isManuallyEdited = "is_manually_edited"
        case originalCarerId = "original_carer_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

**Step 5: Verify all models compile**

Run: Build project (`Cmd+B`)
Expected: No compilation errors.

**Step 6: Commit**

```bash
git add CareCoordinator/Models/
git commit -m "feat: add core Swift data models (Profile, CareGroup, Shift, Enums)"
```

---

### Task 0.6: Create Remaining Swift Models

**Files:**
- Create: `CareCoordinator/Models/PTORequest.swift`
- Create: `CareCoordinator/Models/Task+Care.swift`
- Create: `CareCoordinator/Models/CarePlan.swift`
- Create: `CareCoordinator/Models/Invitation.swift`
- Create: `CareCoordinator/Models/JoinRequest.swift`
- Create: `CareCoordinator/Models/Notification+Care.swift`
- Create: `CareCoordinator/Models/ShiftNote.swift`
- Create: `CareCoordinator/Models/Reminder.swift`
- Create: `CareCoordinator/Models/EmergencyContact.swift`
- Create: `CareCoordinator/Models/RotationPattern.swift`
- Create: `CareCoordinator/Models/CarerAvailability.swift`
- Create: `CareCoordinator/Models/ShiftOffer.swift`
- Create: `CareCoordinator/Models/KeyShare.swift`
- Create: `CareCoordinator/Models/AuditLogEntry.swift`

**Step 1: Create all remaining models**

Each model follows the same pattern: `Codable`, `Identifiable`, `Equatable`, with `CodingKeys` mapping snake_case DB columns to camelCase Swift properties.

```swift
// CareCoordinator/Models/RotationPattern.swift
import Foundation

struct RotationPattern: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var pattern: [UUID]  // ordered carer IDs per week
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, pattern
        case careGroupId = "care_group_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/PTORequest.swift
import Foundation

struct PTORequest: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    let carerId: UUID
    var startDate: String
    var endDate: String
    var reason: String?
    var status: PTOStatus
    var clientMessage: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, reason, status
        case careGroupId = "care_group_id"
        case carerId = "carer_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case clientMessage = "client_message"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/ShiftOffer.swift
import Foundation

struct ShiftOffer: Codable, Identifiable, Equatable {
    let id: UUID
    let shiftId: UUID
    var offeredTo: UUID?
    var status: String
    var acceptedBy: UUID?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, status
        case shiftId = "shift_id"
        case offeredTo = "offered_to"
        case acceptedBy = "accepted_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/CarerAvailability.swift
import Foundation

struct CarerAvailability: Codable, Identifiable, Equatable {
    let id: UUID
    let carerId: UUID
    let careGroupId: UUID
    var date: String
    var startTime: String?
    var endTime: String?
    var isRecurring: Bool
    var recurrenceRule: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, date
        case carerId = "carer_id"
        case careGroupId = "care_group_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/CarePlan.swift
import Foundation

struct CarePlan: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var title: String
    var category: String?
    var storagePath: String
    var fileSize: Int64
    let uploadedBy: UUID
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, category
        case careGroupId = "care_group_id"
        case storagePath = "storage_path"
        case fileSize = "file_size"
        case uploadedBy = "uploaded_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/CareTask.swift
import Foundation

struct CareTask: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var type: TaskType
    var parentTemplateId: UUID?
    var title: String
    var description: String?
    var priority: TaskPriority
    var dueDate: String?
    var isRecurring: Bool
    var recurrenceRule: String?
    var completed: Bool
    var completedBy: UUID?
    var completedAt: Date?
    var sortOrder: Int
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, type, title, description, priority, completed
        case careGroupId = "care_group_id"
        case parentTemplateId = "parent_template_id"
        case dueDate = "due_date"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case completedBy = "completed_by"
        case completedAt = "completed_at"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/ShiftNote.swift
import Foundation

struct ShiftNote: Codable, Identifiable, Equatable {
    let id: UUID
    let shiftId: UUID
    let carerId: UUID
    var content: String  // encrypted client-side
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, content
        case shiftId = "shift_id"
        case carerId = "carer_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/Reminder.swift
import Foundation

struct Reminder: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var title: String
    var time: String
    var isRecurring: Bool
    var recurrenceRule: String?
    let createdBy: UUID
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, time
        case careGroupId = "care_group_id"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/EmergencyContact.swift
import Foundation

struct EmergencyContact: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var name: String
    var phone: String
    var relationship: String
    var sortOrder: Int
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, phone, relationship
        case careGroupId = "care_group_id"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

```swift
// CareCoordinator/Models/Invitation.swift
import Foundation

struct Invitation: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var code: String
    let createdBy: UUID
    var maxUses: Int
    var timesUsed: Int
    var status: InvitationStatus
    var expiresAt: Date
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, code, status
        case careGroupId = "care_group_id"
        case createdBy = "created_by"
        case maxUses = "max_uses"
        case timesUsed = "times_used"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}
```

```swift
// CareCoordinator/Models/JoinRequest.swift
import Foundation

struct JoinRequest: Codable, Identifiable, Equatable {
    let id: UUID
    let invitationId: UUID
    let carerId: UUID
    var status: JoinRequestStatus
    var reviewedAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, status
        case invitationId = "invitation_id"
        case carerId = "carer_id"
        case reviewedAt = "reviewed_at"
        case createdAt = "created_at"
    }
}
```

```swift
// CareCoordinator/Models/CareNotification.swift
import Foundation

struct CareNotification: Codable, Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    var type: NotificationType
    var title: String
    var body: String
    var data: [String: String]?
    var read: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, type, title, body, data, read
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
```

```swift
// CareCoordinator/Models/KeyShare.swift
import Foundation

struct KeyShare: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    let userId: UUID
    var encryptedGroupKey: Data
    var senderPublicKey: Data
    var keyVersion: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case careGroupId = "care_group_id"
        case userId = "user_id"
        case encryptedGroupKey = "encrypted_group_key"
        case senderPublicKey = "sender_public_key"
        case keyVersion = "key_version"
        case createdAt = "created_at"
    }
}
```

```swift
// CareCoordinator/Models/AuditLogEntry.swift
import Foundation

struct AuditLogEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    let userId: UUID
    var action: String
    var details: [String: String]?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, action, details
        case careGroupId = "care_group_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
```

**Step 2: Verify all models compile**

Run: Build project (`Cmd+B`)
Expected: No compilation errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Models/
git commit -m "feat: add all remaining Swift data models (14 models total)"
```

---

### Task 0.7: Create RLS Policies (Privacy Engine Foundation)

**Files:**
- Create: `supabase/migrations/002_rls_policies.sql`

**Step 1: Write RLS policies**

```sql
-- supabase/migrations/002_rls_policies.sql
-- Enable RLS on ALL tables

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE care_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE key_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE rotation_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE pto_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE shift_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE carer_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE care_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE shift_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE join_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Check if current user is the client (owner) of a care group
CREATE OR REPLACE FUNCTION is_care_group_owner(group_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM care_groups
        WHERE id = group_id AND owner_id = auth.uid()
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Check if current user is a member of a care group
CREATE OR REPLACE FUNCTION is_care_group_member(group_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid() AND care_group_id = group_id
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Get the privacy mode of a care group
CREATE OR REPLACE FUNCTION get_privacy_mode(group_id UUID)
RETURNS privacy_mode AS $$
    SELECT privacy_mode FROM care_groups WHERE id = group_id;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================
-- PROFILES
-- ============================================

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
ON profiles FOR SELECT
TO authenticated
USING (id = auth.uid());

-- Clients can read all profiles in their care group
CREATE POLICY "Clients can read care group profiles"
ON profiles FOR SELECT
TO authenticated
USING (
    care_group_id IS NOT NULL
    AND is_care_group_owner(care_group_id)
);

-- Carers can see other profiles based on privacy mode
CREATE POLICY "Carers can read profiles per privacy mode"
ON profiles FOR SELECT
TO authenticated
USING (
    care_group_id IS NOT NULL
    AND is_care_group_member(care_group_id)
    AND get_privacy_mode(care_group_id) = 'open'
);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- ============================================
-- CARE GROUPS
-- ============================================

-- Owner has full access
CREATE POLICY "Owner can do anything with care group"
ON care_groups FOR ALL
TO authenticated
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

-- Members can read their care group
CREATE POLICY "Members can read care group"
ON care_groups FOR SELECT
TO authenticated
USING (is_care_group_member(id));

-- ============================================
-- SHIFTS
-- ============================================

-- Client sees all shifts in their care group
CREATE POLICY "Client sees all shifts"
ON shifts FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Carer sees own shifts always
CREATE POLICY "Carer sees own shifts"
ON shifts FOR SELECT
TO authenticated
USING (carer_id = auth.uid());

-- Carer sees all shifts in anonymous/open mode
CREATE POLICY "Carer sees shifts per privacy mode"
ON shifts FOR SELECT
TO authenticated
USING (
    is_care_group_member(care_group_id)
    AND get_privacy_mode(care_group_id) IN ('anonymous', 'open')
);

-- ============================================
-- PTO REQUESTS
-- ============================================

-- Client manages all PTO in their group
CREATE POLICY "Client manages PTO requests"
ON pto_requests FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Carer can create and view own PTO requests
CREATE POLICY "Carer manages own PTO"
ON pto_requests FOR SELECT
TO authenticated
USING (carer_id = auth.uid());

CREATE POLICY "Carer can create PTO"
ON pto_requests FOR INSERT
TO authenticated
WITH CHECK (carer_id = auth.uid());

-- ============================================
-- TASKS
-- ============================================

-- Client manages all tasks
CREATE POLICY "Client manages tasks"
ON tasks FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Carer can read tasks in their care group
CREATE POLICY "Carer reads tasks"
ON tasks FOR SELECT
TO authenticated
USING (is_care_group_member(care_group_id));

-- Carer can update tasks (mark complete)
CREATE POLICY "Carer updates tasks"
ON tasks FOR UPDATE
TO authenticated
USING (is_care_group_member(care_group_id))
WITH CHECK (is_care_group_member(care_group_id));

-- ============================================
-- CARE PLANS
-- ============================================

-- Client manages care plans
CREATE POLICY "Client manages care plans"
ON care_plans FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Members can read care plans
CREATE POLICY "Members read care plans"
ON care_plans FOR SELECT
TO authenticated
USING (is_care_group_member(care_group_id));

-- ============================================
-- INVITATIONS
-- ============================================

-- Client manages invitations
CREATE POLICY "Client manages invitations"
ON invitations FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- Anyone authenticated can read invitations by code (for join flow)
CREATE POLICY "Anyone can lookup invitation by code"
ON invitations FOR SELECT
TO authenticated
USING (status = 'active');

-- ============================================
-- JOIN REQUESTS
-- ============================================

-- Client sees join requests for their group
CREATE POLICY "Client manages join requests"
ON join_requests FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM invitations i
        WHERE i.id = join_requests.invitation_id
        AND is_care_group_owner(i.care_group_id)
    )
);

-- Carer can create and view own join requests
CREATE POLICY "Carer manages own join requests"
ON join_requests FOR SELECT
TO authenticated
USING (carer_id = auth.uid());

CREATE POLICY "Carer creates join request"
ON join_requests FOR INSERT
TO authenticated
WITH CHECK (carer_id = auth.uid());

-- ============================================
-- NOTIFICATIONS
-- ============================================

-- Users see only their own notifications
CREATE POLICY "Users see own notifications"
ON notifications FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users update own notifications"
ON notifications FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- System can insert notifications (via service role or triggers)
CREATE POLICY "System inserts notifications"
ON notifications FOR INSERT
TO authenticated
WITH CHECK (TRUE);  -- Controlled by application logic

-- ============================================
-- KEY SHARES
-- ============================================

-- Users see their own key shares
CREATE POLICY "Users see own key shares"
ON key_shares FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Client can manage key shares in their group
CREATE POLICY "Client manages key shares"
ON key_shares FOR ALL
TO authenticated
USING (is_care_group_owner(care_group_id))
WITH CHECK (is_care_group_owner(care_group_id));

-- ============================================
-- REMAINING TABLES (similar patterns)
-- ============================================

-- Rotation Patterns
CREATE POLICY "Client manages rotation" ON rotation_patterns FOR ALL TO authenticated
USING (is_care_group_owner(care_group_id)) WITH CHECK (is_care_group_owner(care_group_id));
CREATE POLICY "Members read rotation" ON rotation_patterns FOR SELECT TO authenticated
USING (is_care_group_member(care_group_id));

-- Shift Notes
CREATE POLICY "Client reads shift notes" ON shift_notes FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM shifts s WHERE s.id = shift_notes.shift_id AND is_care_group_owner(s.care_group_id)));
CREATE POLICY "Carer manages own notes" ON shift_notes FOR ALL TO authenticated
USING (carer_id = auth.uid()) WITH CHECK (carer_id = auth.uid());

-- Shift Offers
CREATE POLICY "Client manages offers" ON shift_offers FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM shifts s WHERE s.id = shift_offers.shift_id AND is_care_group_owner(s.care_group_id)))
WITH CHECK (EXISTS (SELECT 1 FROM shifts s WHERE s.id = shift_offers.shift_id AND is_care_group_owner(s.care_group_id)));
CREATE POLICY "Carer sees relevant offers" ON shift_offers FOR SELECT TO authenticated
USING (offered_to IS NULL OR offered_to = auth.uid());

-- Carer Availability
CREATE POLICY "Client reads availability" ON carer_availability FOR SELECT TO authenticated
USING (is_care_group_owner(care_group_id));
CREATE POLICY "Carer manages own availability" ON carer_availability FOR ALL TO authenticated
USING (carer_id = auth.uid()) WITH CHECK (carer_id = auth.uid());

-- Reminders
CREATE POLICY "Client manages reminders" ON reminders FOR ALL TO authenticated
USING (is_care_group_owner(care_group_id)) WITH CHECK (is_care_group_owner(care_group_id));
CREATE POLICY "Members read reminders" ON reminders FOR SELECT TO authenticated
USING (is_care_group_member(care_group_id));

-- Emergency Contacts
CREATE POLICY "Client manages contacts" ON emergency_contacts FOR ALL TO authenticated
USING (is_care_group_owner(care_group_id)) WITH CHECK (is_care_group_owner(care_group_id));
CREATE POLICY "Members read contacts" ON emergency_contacts FOR SELECT TO authenticated
USING (is_care_group_member(care_group_id));

-- Audit Log
CREATE POLICY "Client reads audit log" ON audit_log FOR SELECT TO authenticated
USING (is_care_group_owner(care_group_id));
CREATE POLICY "System writes audit log" ON audit_log FOR INSERT TO authenticated
WITH CHECK (is_care_group_member(care_group_id));
```

**Step 2: Run migration in Supabase**

1. Supabase Dashboard → SQL Editor
2. Paste and run
Expected: All policies created. No errors.

**Step 3: Commit**

```bash
git add supabase/
git commit -m "feat: add Row-Level Security policies for all tables (privacy engine)"
```

---

## Phase 1: Authentication & Onboarding (Weeks 3-5) — Epic 1

### Task 1.1: Auth Service & Email/Password Signup

**Files:**
- Create: `CareCoordinator/Services/Auth/AuthService.swift`
- Create: `CareCoordinator/ViewModels/AuthViewModel.swift`

**Step 1: Create AuthService**

```swift
// CareCoordinator/Services/Auth/AuthService.swift
import Foundation
import Supabase

final class AuthService {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func signUp(email: String, password: String, displayName: String, role: UserRole) async throws -> Profile {
        let session = try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "display_name": .string(displayName),
                "role": .string(role.rawValue)
            ]
        )

        // Profile is auto-created by the DB trigger handle_new_user()
        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .single()
            .execute()
            .value

        return profile
    }

    func signIn(email: String, password: String) async throws -> Profile {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )

        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .single()
            .execute()
            .value

        return profile
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func currentSession() async throws -> Session {
        try await client.auth.session
    }

    func currentProfile() async throws -> Profile {
        let session = try await client.auth.session
        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .single()
            .execute()
            .value
        return profile
    }
}
```

**Step 2: Create AuthViewModel**

```swift
// CareCoordinator/ViewModels/AuthViewModel.swift
import Foundation
import Observation

@Observable
final class AuthViewModel {
    var isAuthenticated = false
    var currentProfile: Profile?
    var isLoading = false
    var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }

    func signUp(email: String, password: String, displayName: String, role: UserRole) async {
        isLoading = true
        errorMessage = nil
        do {
            let profile = try await authService.signUp(
                email: email, password: password,
                displayName: displayName, role: role
            )
            currentProfile = profile
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let profile = try await authService.signIn(email: email, password: password)
            currentProfile = profile
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() async {
        do {
            try await authService.signOut()
            currentProfile = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func checkExistingSession() async {
        do {
            let profile = try await authService.currentProfile()
            currentProfile = profile
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }
}
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Services/Auth/ CareCoordinator/ViewModels/
git commit -m "feat: add AuthService and AuthViewModel for email/password auth"
```

---

### Task 1.2: Login & Signup Views

**Files:**
- Create: `CareCoordinator/Views/Auth/LoginView.swift`
- Create: `CareCoordinator/Views/Auth/SignUpView.swift`
- Modify: `CareCoordinator/App/ContentView.swift`
- Modify: `CareCoordinator/App/CareCoordinatorApp.swift`

**Step 1: Create LoginView**

```swift
// CareCoordinator/Views/Auth/LoginView.swift
import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("CareCoordinator")
                    .font(.largeTitle.bold())

                Text("Secure care scheduling")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.fill.tertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(.fill.tertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await authVM.signIn(email: email, password: password) }
                } label: {
                    if authVM.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)

                Spacer()

                Button("Don't have an account? Sign Up") {
                    showSignUp = true
                }
            }
            .padding()
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
```

**Step 2: Create SignUpView**

```swift
// CareCoordinator/Views/Auth/SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var role: UserRole = .client

    var body: some View {
        Form {
            Section("Your Details") {
                TextField("Display Name", text: $displayName)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("Password (8+ characters)", text: $password)
                    .textContentType(.newPassword)
            }

            Section("I am a...") {
                Picker("Role", selection: $role) {
                    Text("Client (managing care)").tag(UserRole.client)
                    Text("Carer (providing care)").tag(UserRole.carer)
                }
                .pickerStyle(.inline)
            }

            if let error = authVM.errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task {
                        await authVM.signUp(
                            email: email, password: password,
                            displayName: displayName, role: role
                        )
                        if authVM.isAuthenticated { dismiss() }
                    }
                } label: {
                    if authVM.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(email.isEmpty || password.count < 8 || displayName.isEmpty || authVM.isLoading)
            }
        }
        .navigationTitle("Sign Up")
    }
}
```

**Step 3: Wire up in App entry point**

```swift
// CareCoordinator/App/CareCoordinatorApp.swift
import SwiftUI

@main
struct CareCoordinatorApp: App {
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authViewModel)
                .task {
                    await authViewModel.checkExistingSession()
                }
        }
    }
}
```

```swift
// CareCoordinator/App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authVM

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                DashboardPlaceholderView()
            } else {
                LoginView()
            }
        }
    }
}

struct DashboardPlaceholderView: View {
    @Environment(AuthViewModel.self) private var authVM

    var body: some View {
        VStack {
            Text("Welcome, \(authVM.currentProfile?.displayName ?? "User")")
                .font(.title)
            Text("Role: \(authVM.currentProfile?.role.rawValue ?? "unknown")")
            Button("Sign Out") {
                Task { await authVM.signOut() }
            }
            .padding(.top)
        }
    }
}
```

**Step 4: Test the flow**

Run: Build and run in simulator.
Expected: Login screen shows. Can navigate to Sign Up. After signup, redirects to dashboard placeholder showing display name and role.

**Step 5: Commit**

```bash
git add CareCoordinator/Views/Auth/ CareCoordinator/App/
git commit -m "feat: add Login and SignUp views with auth flow"
```

---

### Task 1.3: Sign in with Apple

**Files:**
- Create: `CareCoordinator/Services/Auth/AppleSignInService.swift`
- Modify: `CareCoordinator/Views/Auth/LoginView.swift`

**Step 1: Create Apple Sign-In service**

```swift
// CareCoordinator/Services/Auth/AppleSignInService.swift
import AuthenticationServices
import CryptoKit
import Foundation
import Supabase

final class AppleSignInService {
    private let client: SupabaseClient
    private var currentNonce: String?

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }

    func hashedNonce(from nonce: String) -> String {
        let data = Data(nonce.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func handleAuthorization(_ authorization: ASAuthorization) async throws -> Profile {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            throw AppleSignInError.missingCredentials
        }

        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: identityToken,
                nonce: nonce
            )
        )

        // Update profile with Apple-provided name if available
        if let fullName = credential.fullName {
            let name = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            if !name.isEmpty {
                try await client
                    .from("profiles")
                    .update(["display_name": name])
                    .eq("id", value: session.user.id.uuidString)
                    .execute()
            }
        }

        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .single()
            .execute()
            .value

        return profile
    }

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    enum AppleSignInError: Error {
        case missingCredentials
    }
}
```

**Step 2: Add Sign in with Apple button to LoginView**

Add to `LoginView` after the "Sign In" button and before Spacer:

```swift
// Add inside LoginView body, after the Sign In button

Divider()
    .padding(.vertical)

SignInWithAppleButton(.signIn) { request in
    let nonce = appleSignInService.generateNonce()
    request.requestedScopes = [.fullName, .email]
    request.nonce = appleSignInService.hashedNonce(from: nonce)
} onCompletion: { result in
    Task {
        do {
            let authorization = try result.get()
            let profile = try await appleSignInService.handleAuthorization(authorization)
            authVM.currentProfile = profile
            authVM.isAuthenticated = true
        } catch {
            authVM.errorMessage = error.localizedDescription
        }
    }
}
.signInWithAppleButtonStyle(.black)
.frame(height: 50)
```

Add property to LoginView:

```swift
@State private var appleSignInService = AppleSignInService()
```

**Step 3: Enable Sign in with Apple in Supabase**

1. Supabase Dashboard → Authentication → Providers → Apple
2. Enable Apple provider
3. Configure with your Apple Services ID and team info

**Step 4: Test**

Run: Build and run.
Expected: Apple Sign In button visible. Tapping starts Apple auth flow.

**Step 5: Commit**

```bash
git add CareCoordinator/Services/Auth/ CareCoordinator/Views/Auth/
git commit -m "feat: add Sign in with Apple authentication"
```

---

### Task 1.4: Care Group Creation (Client Flow)

**Files:**
- Create: `CareCoordinator/Repositories/CareGroupRepository.swift`
- Create: `CareCoordinator/ViewModels/CareGroupViewModel.swift`
- Create: `CareCoordinator/Views/Dashboard/CreateCareGroupView.swift`

**Step 1: Create CareGroupRepository**

```swift
// CareCoordinator/Repositories/CareGroupRepository.swift
import Foundation
import Supabase

final class CareGroupRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func create(name: String, privacyMode: PrivacyMode, shiftStart: String, shiftEnd: String) async throws -> CareGroup {
        let userId = try await client.auth.session.user.id

        struct Insert: Encodable {
            let name: String
            let privacy_mode: String
            let default_shift_start: String
            let default_shift_end: String
            let owner_id: String
        }

        let careGroup: CareGroup = try await client
            .from("care_groups")
            .insert(Insert(
                name: name,
                privacy_mode: privacyMode.rawValue,
                default_shift_start: shiftStart,
                default_shift_end: shiftEnd,
                owner_id: userId.uuidString
            ))
            .select()
            .single()
            .execute()
            .value

        // Update profile with care_group_id
        try await client
            .from("profiles")
            .update(["care_group_id": careGroup.id.uuidString])
            .eq("id", value: userId.uuidString)
            .execute()

        return careGroup
    }

    func fetchForCurrentUser() async throws -> CareGroup? {
        let userId = try await client.auth.session.user.id

        let groups: [CareGroup] = try await client
            .from("care_groups")
            .select()
            .eq("owner_id", value: userId.uuidString)
            .execute()
            .value

        return groups.first
    }
}
```

**Step 2: Create CareGroupViewModel**

```swift
// CareCoordinator/ViewModels/CareGroupViewModel.swift
import Foundation
import Observation

@Observable
final class CareGroupViewModel {
    var careGroup: CareGroup?
    var isLoading = false
    var errorMessage: String?

    private let repository: CareGroupRepository

    init(repository: CareGroupRepository = CareGroupRepository()) {
        self.repository = repository
    }

    func createCareGroup(name: String, privacyMode: PrivacyMode, shiftStart: String, shiftEnd: String) async {
        isLoading = true
        errorMessage = nil
        do {
            careGroup = try await repository.create(
                name: name, privacyMode: privacyMode,
                shiftStart: shiftStart, shiftEnd: shiftEnd
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadCareGroup() async {
        do {
            careGroup = try await repository.fetchForCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

**Step 3: Create CreateCareGroupView**

```swift
// CareCoordinator/Views/Dashboard/CreateCareGroupView.swift
import SwiftUI

struct CreateCareGroupView: View {
    @Environment(CareGroupViewModel.self) private var careGroupVM
    @State private var name = ""
    @State private var privacyMode: PrivacyMode = .full
    @State private var shiftStart = Calendar.current.date(from: DateComponents(hour: 8)) ?? Date()
    @State private var shiftEnd = Calendar.current.date(from: DateComponents(hour: 20)) ?? Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Care Group Name") {
                    TextField("e.g., Dad's Care Team", text: $name)
                }

                Section {
                    Picker("Privacy Mode", selection: $privacyMode) {
                        ForEach(PrivacyMode.allCases, id: \.self) { mode in
                            VStack(alignment: .leading) {
                                Text(mode.rawValue.capitalized)
                            }
                            .tag(mode)
                        }
                    }
                } header: {
                    Text("Privacy")
                } footer: {
                    Text(privacyDescription)
                }

                Section("Default Shift Times") {
                    DatePicker("Start", selection: $shiftStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $shiftEnd, displayedComponents: .hourAndMinute)
                }

                if let error = careGroupVM.errorMessage {
                    Section { Text(error).foregroundStyle(.red) }
                }

                Section {
                    Button {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        Task {
                            await careGroupVM.createCareGroup(
                                name: name,
                                privacyMode: privacyMode,
                                shiftStart: formatter.string(from: shiftStart),
                                shiftEnd: formatter.string(from: shiftEnd)
                            )
                        }
                    } label: {
                        if careGroupVM.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Create Care Group").frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(name.isEmpty || careGroupVM.isLoading)
                }
            }
            .navigationTitle("New Care Group")
        }
    }

    private var privacyDescription: String {
        switch privacyMode {
        case .full: "Carers see only their own shifts and data. Maximum privacy."
        case .anonymous: "Carers see all shifts but carer names are hidden."
        case .open: "Carers see everything including each other's names."
        }
    }
}
```

**Step 4: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 5: Commit**

```bash
git add CareCoordinator/Repositories/ CareCoordinator/ViewModels/ CareCoordinator/Views/Dashboard/
git commit -m "feat: add care group creation flow (repository, viewmodel, view)"
```

---

### Task 1.5: Invite Code Generation & Join Flow

**Files:**
- Create: `CareCoordinator/Repositories/InvitationRepository.swift`
- Create: `CareCoordinator/ViewModels/InvitationViewModel.swift`
- Create: `CareCoordinator/Views/Carers/InviteCarerView.swift`
- Create: `CareCoordinator/Views/Auth/JoinCareGroupView.swift`

**Step 1: Create InvitationRepository**

```swift
// CareCoordinator/Repositories/InvitationRepository.swift
import Foundation
import Supabase

final class InvitationRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func createInvitation(careGroupId: UUID, expiresInDays: Int = 7) async throws -> Invitation {
        let userId = try await client.auth.session.user.id
        let code = generateInviteCode()
        let expiresAt = Calendar.current.date(byAdding: .day, value: expiresInDays, to: Date())!

        struct Insert: Encodable {
            let care_group_id: String
            let code: String
            let created_by: String
            let expires_at: String
        }

        let formatter = ISO8601DateFormatter()

        let invitation: Invitation = try await client
            .from("invitations")
            .insert(Insert(
                care_group_id: careGroupId.uuidString,
                code: code,
                created_by: userId.uuidString,
                expires_at: formatter.string(from: expiresAt)
            ))
            .select()
            .single()
            .execute()
            .value

        return invitation
    }

    func lookupInvitation(code: String) async throws -> Invitation? {
        let invitations: [Invitation] = try await client
            .from("invitations")
            .select()
            .eq("code", value: code)
            .eq("status", value: "active")
            .execute()
            .value

        return invitations.first
    }

    func createJoinRequest(invitationId: UUID) async throws -> JoinRequest {
        let userId = try await client.auth.session.user.id

        struct Insert: Encodable {
            let invitation_id: String
            let carer_id: String
        }

        let request: JoinRequest = try await client
            .from("join_requests")
            .insert(Insert(
                invitation_id: invitationId.uuidString,
                carer_id: userId.uuidString
            ))
            .select()
            .single()
            .execute()
            .value

        return request
    }

    func fetchPendingJoinRequests(careGroupId: UUID) async throws -> [JoinRequest] {
        // Fetch join requests for invitations belonging to this care group
        let requests: [JoinRequest] = try await client
            .from("join_requests")
            .select("*, invitations!inner(care_group_id)")
            .eq("status", value: "pending")
            .execute()
            .value

        return requests
    }

    func approveJoinRequest(requestId: UUID, carerId: UUID, careGroupId: UUID) async throws {
        // Update join request status
        try await client
            .from("join_requests")
            .update(["status": "approved", "reviewed_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: requestId.uuidString)
            .execute()

        // Update carer's profile with care_group_id
        try await client
            .from("profiles")
            .update(["care_group_id": careGroupId.uuidString])
            .eq("id", value: carerId.uuidString)
            .execute()
    }

    func denyJoinRequest(requestId: UUID) async throws {
        try await client
            .from("join_requests")
            .update(["status": "denied", "reviewed_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: requestId.uuidString)
            .execute()
    }

    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // No I/O/0/1 for clarity
        return String((0..<8).map { _ in chars.randomElement()! })
    }
}
```

**Step 2: Create InviteCarerView**

```swift
// CareCoordinator/Views/Carers/InviteCarerView.swift
import SwiftUI

struct InviteCarerView: View {
    let careGroupId: UUID
    @State private var invitation: Invitation?
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let repository = InvitationRepository()

    var body: some View {
        VStack(spacing: 24) {
            if let invitation {
                VStack(spacing: 16) {
                    Text("Invite Code")
                        .font(.headline)
                    Text(invitation.code)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .padding()
                        .background(.fill.tertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Share this code with your carer. It expires in 7 days.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    ShareLink(item: "Join my CareCoordinator group with code: \(invitation.code)") {
                        Label("Share Code", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Copy to Clipboard") {
                        UIPasteboard.general.string = invitation.code
                    }
                }
            } else {
                Button {
                    Task { await generateCode() }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Label("Generate Invite Code", systemImage: "person.badge.plus")
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if let error = errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .padding()
        .navigationTitle("Invite Carer")
    }

    private func generateCode() async {
        isLoading = true
        do {
            invitation = try await repository.createInvitation(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

**Step 3: Create JoinCareGroupView (for carers)**

```swift
// CareCoordinator/Views/Auth/JoinCareGroupView.swift
import SwiftUI

struct JoinCareGroupView: View {
    @State private var code = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var isError = false
    private let repository = InvitationRepository()

    var body: some View {
        VStack(spacing: 24) {
            Text("Join a Care Group")
                .font(.title2.bold())

            Text("Enter the invite code your client shared with you")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("Invite Code", text: $code)
                .font(.system(size: 24, design: .monospaced))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding()
                .background(.fill.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if let message {
                Text(message)
                    .foregroundStyle(isError ? .red : .green)
                    .font(.caption)
            }

            Button {
                Task { await submitCode() }
            } label: {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Request to Join").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(code.count < 8 || isLoading)
        }
        .padding()
        .navigationTitle("Join Group")
    }

    private func submitCode() async {
        isLoading = true
        message = nil
        do {
            guard let invitation = try await repository.lookupInvitation(code: code.uppercased()) else {
                message = "Invalid or expired invite code"
                isError = true
                isLoading = false
                return
            }
            _ = try await repository.createJoinRequest(invitationId: invitation.id)
            message = "Request sent! Waiting for client approval."
            isError = false
        } catch {
            message = error.localizedDescription
            isError = true
        }
        isLoading = false
    }
}
```

**Step 4: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 5: Commit**

```bash
git add CareCoordinator/Repositories/ CareCoordinator/Views/
git commit -m "feat: add invite code generation, join request flow for carers"
```

---

### Task 1.6: E2EE Key Generation on Signup

**Files:**
- Create: `CareCoordinator/Services/Crypto/KeychainService.swift`
- Create: `CareCoordinator/Services/Crypto/CryptoService.swift`
- Modify: `CareCoordinator/Services/Auth/AuthService.swift`

**Step 1: Create KeychainService**

```swift
// CareCoordinator/Services/Crypto/KeychainService.swift
import Foundation
import Security
import CryptoKit

enum KeychainService {
    private static let service = "com.carecoordinator.keys"

    static func save(data: Data, account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    static func load(account: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.loadFailed(status)
        }
        return data
    }

    static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }

    enum KeychainError: Error {
        case saveFailed(OSStatus)
        case loadFailed(OSStatus)
    }
}
```

**Step 2: Create CryptoService**

```swift
// CareCoordinator/Services/Crypto/CryptoService.swift
import Foundation
import CryptoKit

enum CryptoService {

    // MARK: - Key Pair Management

    static func generateKeyPair() -> Curve25519.KeyAgreement.PrivateKey {
        Curve25519.KeyAgreement.PrivateKey()
    }

    static func savePrivateKey(_ key: Curve25519.KeyAgreement.PrivateKey, userId: String) throws {
        try KeychainService.save(data: key.rawRepresentation, account: "private-key-\(userId)")
    }

    static func loadPrivateKey(userId: String) throws -> Curve25519.KeyAgreement.PrivateKey {
        let data = try KeychainService.load(account: "private-key-\(userId)")
        return try Curve25519.KeyAgreement.PrivateKey(rawRepresentation: data)
    }

    // MARK: - Group Key Management

    static func generateGroupKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    static func saveGroupKey(_ key: SymmetricKey, groupId: String) throws {
        let data = key.withUnsafeBytes { Data($0) }
        try KeychainService.save(data: data, account: "group-key-\(groupId)")
    }

    static func loadGroupKey(groupId: String) throws -> SymmetricKey {
        let data = try KeychainService.load(account: "group-key-\(groupId)")
        return SymmetricKey(data: data)
    }

    // MARK: - AES-GCM Encryption/Decryption

    static func encrypt(data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }
        return combined
    }

    static func decrypt(data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - Key Exchange (share group key with a carer)

    static func encryptGroupKey(
        groupKey: SymmetricKey,
        senderPrivateKey: Curve25519.KeyAgreement.PrivateKey,
        recipientPublicKey: Curve25519.KeyAgreement.PublicKey
    ) throws -> Data {
        let sharedSecret = try senderPrivateKey.sharedSecretFromKeyAgreement(with: recipientPublicKey)
        let derivedKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "CareCoordinator-GroupKeyExchange".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        let groupKeyData = groupKey.withUnsafeBytes { Data($0) }
        return try encrypt(data: groupKeyData, using: derivedKey)
    }

    static func decryptGroupKey(
        encryptedGroupKey: Data,
        recipientPrivateKey: Curve25519.KeyAgreement.PrivateKey,
        senderPublicKey: Curve25519.KeyAgreement.PublicKey
    ) throws -> SymmetricKey {
        let sharedSecret = try recipientPrivateKey.sharedSecretFromKeyAgreement(with: senderPublicKey)
        let derivedKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "CareCoordinator-GroupKeyExchange".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        let groupKeyData = try decrypt(data: encryptedGroupKey, using: derivedKey)
        return SymmetricKey(data: groupKeyData)
    }

    enum CryptoError: Error {
        case encryptionFailed
    }
}
```

**Step 3: Integrate key generation into auth flow**

Modify `AuthService.signUp` to generate and store a key pair, and upload the public key:

Add after the profile fetch in `signUp`:

```swift
// Generate E2EE key pair
let privateKey = CryptoService.generateKeyPair()
try CryptoService.savePrivateKey(privateKey, userId: session.user.id.uuidString)

// Upload public key to profile
try await client
    .from("profiles")
    .update(["public_key": privateKey.publicKey.rawRepresentation.base64EncodedString()])
    .eq("id", value: session.user.id.uuidString)
    .execute()
```

**Step 4: Verify compilation and test**

Run: Build and run.
Expected: Signup still works. Private key stored in Keychain. Public key uploaded to Supabase.

**Step 5: Commit**

```bash
git add CareCoordinator/Services/Crypto/ CareCoordinator/Services/Auth/
git commit -m "feat: add E2EE key generation (CryptoKit) and Keychain storage"
```

---

## Phase 2: Scheduling Engine (Weeks 6-9) — Epic 2

### Task 2.1: Rotation Pattern Builder (Repository + ViewModel)

**Files:**
- Create: `CareCoordinator/Repositories/RotationRepository.swift`
- Create: `CareCoordinator/Repositories/ShiftRepository.swift`
- Create: `CareCoordinator/ViewModels/ScheduleViewModel.swift`

**Step 1: Create RotationRepository**

```swift
// CareCoordinator/Repositories/RotationRepository.swift
import Foundation
import Supabase

final class RotationRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func save(careGroupId: UUID, pattern: [UUID]) async throws -> RotationPattern {
        struct Upsert: Encodable {
            let care_group_id: String
            let pattern: [String]
        }

        // Delete existing pattern first (one pattern per group)
        try await client
            .from("rotation_patterns")
            .delete()
            .eq("care_group_id", value: careGroupId.uuidString)
            .execute()

        let result: RotationPattern = try await client
            .from("rotation_patterns")
            .insert(Upsert(
                care_group_id: careGroupId.uuidString,
                pattern: pattern.map(\.uuidString)
            ))
            .select()
            .single()
            .execute()
            .value

        return result
    }

    func fetch(careGroupId: UUID) async throws -> RotationPattern? {
        let patterns: [RotationPattern] = try await client
            .from("rotation_patterns")
            .select()
            .eq("care_group_id", value: careGroupId.uuidString)
            .execute()
            .value

        return patterns.first
    }
}
```

**Step 2: Create ShiftRepository**

```swift
// CareCoordinator/Repositories/ShiftRepository.swift
import Foundation
import Supabase

final class ShiftRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func generateShifts(
        careGroupId: UUID,
        pattern: [UUID],
        shiftStart: String,
        shiftEnd: String,
        startDate: Date,
        weeksAhead: Int = 12
    ) async throws -> [Shift] {
        // Delete future auto-generated shifts (not manually edited)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateStr = formatter.string(from: startDate)

        try await client
            .from("shifts")
            .delete()
            .eq("care_group_id", value: careGroupId.uuidString)
            .gte("date", value: startDateStr)
            .eq("is_manually_edited", value: false)
            .execute()

        // Generate new shifts
        var shifts: [ShiftInsert] = []
        let calendar = Calendar.current
        let patternLength = pattern.count

        guard patternLength > 0 else { return [] }

        for weekOffset in 0..<weeksAhead {
            let carerIndex = weekOffset % patternLength
            let carerId = pattern[carerIndex]

            // Generate 7 days of shifts for this week
            for dayOffset in 0..<7 {
                let totalDayOffset = (weekOffset * 7) + dayOffset
                guard let shiftDate = calendar.date(byAdding: .day, value: totalDayOffset, to: startDate) else { continue }
                let dateStr = formatter.string(from: shiftDate)

                shifts.append(ShiftInsert(
                    care_group_id: careGroupId.uuidString,
                    carer_id: carerId.uuidString,
                    date: dateStr,
                    start_time: shiftStart,
                    end_time: shiftEnd,
                    status: "scheduled"
                ))
            }
        }

        // Batch insert
        try await client
            .from("shifts")
            .insert(shifts)
            .execute()

        // Fetch back the created shifts
        let created: [Shift] = try await client
            .from("shifts")
            .select()
            .eq("care_group_id", value: careGroupId.uuidString)
            .gte("date", value: startDateStr)
            .order("date", ascending: true)
            .execute()
            .value

        return created
    }

    func fetchShifts(careGroupId: UUID, from startDate: String? = nil, to endDate: String? = nil) async throws -> [Shift] {
        var query = client
            .from("shifts")
            .select()
            .eq("care_group_id", value: careGroupId.uuidString)

        if let start = startDate {
            query = query.gte("date", value: start)
        }
        if let end = endDate {
            query = query.lte("date", value: end)
        }

        let shifts: [Shift] = try await query
            .order("date", ascending: true)
            .execute()
            .value

        return shifts
    }

    func updateShift(id: UUID, carerId: UUID?, status: ShiftStatus?) async throws -> Shift {
        var updates: [String: String] = [:]
        if let carerId { updates["carer_id"] = carerId.uuidString }
        if let status { updates["status"] = status.rawValue }
        updates["is_manually_edited"] = "true"

        let shift: Shift = try await client
            .from("shifts")
            .update(updates)
            .eq("id", value: id.uuidString)
            .select()
            .single()
            .execute()
            .value

        return shift
    }
}

private struct ShiftInsert: Encodable {
    let care_group_id: String
    let carer_id: String
    let date: String
    let start_time: String
    let end_time: String
    let status: String
}
```

**Step 3: Create ScheduleViewModel**

```swift
// CareCoordinator/ViewModels/ScheduleViewModel.swift
import Foundation
import Observation

@Observable
final class ScheduleViewModel {
    var shifts: [Shift] = []
    var rotationPattern: RotationPattern?
    var isLoading = false
    var errorMessage: String?

    private let shiftRepo: ShiftRepository
    private let rotationRepo: RotationRepository

    init(shiftRepo: ShiftRepository = ShiftRepository(),
         rotationRepo: RotationRepository = RotationRepository()) {
        self.shiftRepo = shiftRepo
        self.rotationRepo = rotationRepo
    }

    func loadSchedule(careGroupId: UUID) async {
        isLoading = true
        do {
            rotationPattern = try await rotationRepo.fetch(careGroupId: careGroupId)
            shifts = try await shiftRepo.fetchShifts(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func saveRotationAndGenerate(careGroupId: UUID, pattern: [UUID], shiftStart: String, shiftEnd: String) async {
        isLoading = true
        errorMessage = nil
        do {
            rotationPattern = try await rotationRepo.save(careGroupId: careGroupId, pattern: pattern)
            shifts = try await shiftRepo.generateShifts(
                careGroupId: careGroupId,
                pattern: pattern,
                shiftStart: shiftStart,
                shiftEnd: shiftEnd,
                startDate: Date()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

**Step 4: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 5: Commit**

```bash
git add CareCoordinator/Repositories/ CareCoordinator/ViewModels/
git commit -m "feat: add rotation pattern and shift generation repositories"
```

---

### Task 2.2: Schedule Calendar View

**Files:**
- Create: `CareCoordinator/Views/Schedule/ScheduleView.swift`
- Create: `CareCoordinator/Views/Schedule/ShiftListView.swift`
- Create: `CareCoordinator/Views/Schedule/ShiftDetailView.swift`

**Step 1: Create ScheduleView with tab toggle (calendar/list)**

```swift
// CareCoordinator/Views/Schedule/ScheduleView.swift
import SwiftUI

struct ScheduleView: View {
    @Environment(ScheduleViewModel.self) private var scheduleVM
    let careGroupId: UUID
    @State private var selectedDate = Date()
    @State private var viewMode: ViewMode = .list

    enum ViewMode: String, CaseIterable {
        case list = "List"
        case calendar = "Calendar"
    }

    var body: some View {
        VStack {
            Picker("View", selection: $viewMode) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch viewMode {
            case .calendar:
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)

                shiftsForSelectedDate
            case .list:
                ShiftListView(shifts: scheduleVM.shifts)
            }
        }
        .navigationTitle("Schedule")
        .task {
            await scheduleVM.loadSchedule(careGroupId: careGroupId)
        }
    }

    @ViewBuilder
    private var shiftsForSelectedDate: some View {
        let formatter = DateFormatter()
        let _ = formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: selectedDate)
        let dayShifts = scheduleVM.shifts.filter { $0.date == dateStr }

        if dayShifts.isEmpty {
            ContentUnavailableView("No Shifts", systemImage: "calendar.badge.exclamationmark",
                                   description: Text("No shifts scheduled for this date"))
        } else {
            List(dayShifts) { shift in
                NavigationLink(value: shift) {
                    ShiftRowView(shift: shift)
                }
            }
        }
    }
}

struct ShiftRowView: View {
    let shift: Shift

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(shift.date)
                    .font(.headline)
                Text("\(shift.startTime) - \(shift.endTime)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(shift.status.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .clipShape(Capsule())
        }
    }

    private var statusColor: Color {
        switch shift.status {
        case .scheduled: .blue
        case .needingCover: .orange
        case .covered: .green
        case .completed: .gray
        case .cancelled: .red
        }
    }
}
```

**Step 2: Create ShiftListView**

```swift
// CareCoordinator/Views/Schedule/ShiftListView.swift
import SwiftUI

struct ShiftListView: View {
    let shifts: [Shift]

    var body: some View {
        List(shifts) { shift in
            NavigationLink(value: shift) {
                ShiftRowView(shift: shift)
            }
        }
        .overlay {
            if shifts.isEmpty {
                ContentUnavailableView("No Shifts", systemImage: "calendar",
                                       description: Text("Set up a rotation pattern to generate shifts"))
            }
        }
    }
}
```

**Step 3: Create ShiftDetailView**

```swift
// CareCoordinator/Views/Schedule/ShiftDetailView.swift
import SwiftUI

struct ShiftDetailView: View {
    let shift: Shift

    var body: some View {
        List {
            Section("Shift Details") {
                LabeledContent("Date", value: shift.date)
                LabeledContent("Time", value: "\(shift.startTime) - \(shift.endTime)")
                LabeledContent("Status", value: shift.status.rawValue.capitalized)
            }

            if shift.isManuallyEdited {
                Section {
                    Label("This shift was manually edited", systemImage: "pencil.circle")
                        .foregroundStyle(.orange)
                }
            }
        }
        .navigationTitle("Shift")
    }
}
```

**Step 4: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 5: Commit**

```bash
git add CareCoordinator/Views/Schedule/
git commit -m "feat: add schedule views (calendar, list, detail)"
```

---

## Phase 3: Care Plans & E2EE (Weeks 7-9)

### Task 3.1: Care Plan Repository & E2E Encrypted Upload

**Files:**
- Create: `CareCoordinator/Repositories/CarePlanRepository.swift`

**Step 1: Write CarePlanRepository**

```swift
// CareCoordinator/Repositories/CarePlanRepository.swift
import Foundation
import Supabase

@Observable
final class CarePlanRepository {
    private let supabase = SupabaseManager.shared.client
    private let cryptoService = CryptoService()

    func uploadCarePlan(
        title: String,
        pdfData: Data,
        careGroupId: UUID,
        groupKey: SymmetricKey
    ) async throws -> CarePlan {
        // 1. Encrypt the PDF data
        let encryptedData = try cryptoService.encrypt(data: pdfData, using: groupKey)

        // 2. Upload encrypted blob to Supabase Storage
        let fileName = "\(careGroupId.uuidString)/\(UUID().uuidString).enc"
        try await supabase.storage
            .from("care-plans")
            .upload(
                path: fileName,
                file: encryptedData,
                options: FileOptions(contentType: "application/octet-stream")
            )

        // 3. Insert metadata row
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let file_path: String
        }

        let carePlan: CarePlan = try await supabase
            .from("care_plans")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                title: title,
                file_path: fileName
            ))
            .select()
            .single()
            .execute()
            .value

        return carePlan
    }

    func fetchCarePlans(careGroupId: UUID) async throws -> [CarePlan] {
        try await supabase
            .from("care_plans")
            .select()
            .eq("care_group_id", value: careGroupId)
            .order("uploaded_at", ascending: false)
            .execute()
            .value
    }

    func downloadAndDecrypt(
        carePlan: CarePlan,
        groupKey: SymmetricKey
    ) async throws -> Data {
        let encryptedData = try await supabase.storage
            .from("care-plans")
            .download(path: carePlan.filePath)

        return try cryptoService.decrypt(data: encryptedData, using: groupKey)
    }

    func deleteCarePlan(_ carePlan: CarePlan) async throws {
        // Delete from storage
        try await supabase.storage
            .from("care-plans")
            .remove(paths: [carePlan.filePath])

        // Delete metadata row
        try await supabase
            .from("care_plans")
            .delete()
            .eq("id", value: carePlan.id)
            .execute()
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors. (Requires CryptoService from Task 1.6 and CarePlan model from Task 0.6)

**Step 3: Commit**

```bash
git add CareCoordinator/Repositories/CarePlanRepository.swift
git commit -m "feat: add CarePlanRepository with E2E encrypted upload/download"
```

---

### Task 3.2: Care Plan ViewModel

**Files:**
- Create: `CareCoordinator/ViewModels/CarePlanViewModel.swift`

**Step 1: Write CarePlanViewModel**

```swift
// CareCoordinator/ViewModels/CarePlanViewModel.swift
import Foundation
import SwiftUI
import CryptoKit
import UniformTypeIdentifiers

@Observable
final class CarePlanViewModel {
    var carePlans: [CarePlan] = []
    var isLoading = false
    var errorMessage: String?
    var decryptedPDFData: Data?
    var showingDocumentPicker = false
    var isUploading = false

    private let repository = CarePlanRepository()
    private let cryptoService = CryptoService()
    private let keychainService = KeychainService()

    var careGroupId: UUID?

    func loadCarePlans() async {
        guard let careGroupId else { return }
        isLoading = true
        errorMessage = nil

        do {
            carePlans = try await repository.fetchCarePlans(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func uploadPDF(title: String, data: Data) async {
        guard let careGroupId else { return }
        isUploading = true
        errorMessage = nil

        do {
            let groupKey = try loadGroupKey()
            let newPlan = try await repository.uploadCarePlan(
                title: title,
                pdfData: data,
                careGroupId: careGroupId,
                groupKey: groupKey
            )
            carePlans.insert(newPlan, at: 0)
        } catch {
            errorMessage = "Upload failed: \(error.localizedDescription)"
        }

        isUploading = false
    }

    func openCarePlan(_ carePlan: CarePlan) async {
        isLoading = true
        errorMessage = nil

        do {
            let groupKey = try loadGroupKey()
            decryptedPDFData = try await repository.downloadAndDecrypt(
                carePlan: carePlan,
                groupKey: groupKey
            )
        } catch {
            errorMessage = "Failed to open: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func deleteCarePlan(_ carePlan: CarePlan) async {
        errorMessage = nil

        do {
            try await repository.deleteCarePlan(carePlan)
            carePlans.removeAll { $0.id == carePlan.id }
        } catch {
            errorMessage = "Delete failed: \(error.localizedDescription)"
        }
    }

    private func loadGroupKey() throws -> SymmetricKey {
        guard let careGroupId else {
            throw CryptoError.keyNotFound
        }
        guard let keyData = keychainService.load(key: "groupKey_\(careGroupId.uuidString)") else {
            throw CryptoError.keyNotFound
        }
        return SymmetricKey(data: keyData)
    }
}

enum CryptoError: LocalizedError {
    case keyNotFound
    case encryptionFailed
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .keyNotFound: return "Encryption key not found. Please rejoin the care group."
        case .encryptionFailed: return "Failed to encrypt data."
        case .decryptionFailed: return "Failed to decrypt data."
        }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/ViewModels/CarePlanViewModel.swift
git commit -m "feat: add CarePlanViewModel with upload, decrypt, delete"
```

---

### Task 3.3: Care Plan Views (List, Upload, PDF Viewer)

**Files:**
- Create: `CareCoordinator/Views/CarePlans/CarePlanListView.swift`
- Create: `CareCoordinator/Views/CarePlans/UploadCarePlanView.swift`
- Create: `CareCoordinator/Views/CarePlans/PDFViewerView.swift`

**Step 1: Write CarePlanListView**

```swift
// CareCoordinator/Views/CarePlans/CarePlanListView.swift
import SwiftUI

struct CarePlanListView: View {
    @State private var viewModel = CarePlanViewModel()
    let careGroupId: UUID
    let isClient: Bool

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.carePlans.isEmpty {
                ProgressView("Loading care plans...")
            }

            ForEach(viewModel.carePlans) { plan in
                Button {
                    Task { await viewModel.openCarePlan(plan) }
                } label: {
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(plan.title)
                                .font(.headline)
                            Text(plan.uploadedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .swipeActions(edge: .trailing) {
                    if isClient {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteCarePlan(plan) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Care Plans")
        .toolbar {
            if isClient {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: UploadCarePlanView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(item: Binding(
            get: { viewModel.decryptedPDFData.map { PDFDataWrapper(data: $0) } },
            set: { _ in viewModel.decryptedPDFData = nil }
        )) { wrapper in
            NavigationStack {
                PDFViewerView(pdfData: wrapper.data)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { viewModel.decryptedPDFData = nil }
                        }
                    }
            }
        }
        .task {
            viewModel.careGroupId = careGroupId
            await viewModel.loadCarePlans()
        }
    }
}

struct PDFDataWrapper: Identifiable {
    let id = UUID()
    let data: Data
}
```

**Step 2: Write UploadCarePlanView**

```swift
// CareCoordinator/Views/CarePlans/UploadCarePlanView.swift
import SwiftUI
import UniformTypeIdentifiers

struct UploadCarePlanView: View {
    @Bindable var viewModel: CarePlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedPDFData: Data?
    @State private var showingFilePicker = false

    var body: some View {
        Form {
            Section("Plan Details") {
                TextField("Title", text: $title)

                Button {
                    showingFilePicker = true
                } label: {
                    HStack {
                        Image(systemName: selectedPDFData != nil ? "checkmark.circle.fill" : "doc.badge.plus")
                            .foregroundStyle(selectedPDFData != nil ? .green : .blue)
                        Text(selectedPDFData != nil ? "PDF Selected" : "Choose PDF File")
                    }
                }
            }

            if viewModel.isUploading {
                Section {
                    HStack {
                        ProgressView()
                        Text("Encrypting and uploading...")
                            .padding(.leading, 8)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Upload Care Plan")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Upload") {
                    guard let data = selectedPDFData else { return }
                    Task {
                        await viewModel.uploadPDF(title: title, data: data)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(title.isEmpty || selectedPDFData == nil || viewModel.isUploading)
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType.pdf]
        ) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                selectedPDFData = try? Data(contentsOf: url)
            case .failure:
                viewModel.errorMessage = "Failed to read file"
            }
        }
    }
}
```

**Step 3: Write PDFViewerView**

```swift
// CareCoordinator/Views/CarePlans/PDFViewerView.swift
import SwiftUI
import PDFKit

struct PDFViewerView: UIViewRepresentable {
    let pdfData: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(data: pdfData) {
            pdfView.document = document
        }
    }
}
```

**Step 4: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 5: Commit**

```bash
git add CareCoordinator/Views/CarePlans/
git commit -m "feat: add care plan views (list, upload, PDF viewer with E2EE)"
```

---

## Phase 4: PTO & Coverage (Weeks 9-11)

### Task 4.1: PTO Repository & Shift Offer Repository

**Files:**
- Create: `CareCoordinator/Repositories/PTORepository.swift`
- Create: `CareCoordinator/Repositories/ShiftOfferRepository.swift`

**Step 1: Write PTORepository**

```swift
// CareCoordinator/Repositories/PTORepository.swift
import Foundation
import Supabase

@Observable
final class PTORepository {
    private let supabase = SupabaseManager.shared.client

    func createPTORequest(
        carerId: UUID,
        careGroupId: UUID,
        startDate: Date,
        endDate: Date,
        reason: String?
    ) async throws -> PTORequest {
        struct InsertPayload: Encodable {
            let carer_id: UUID
            let care_group_id: UUID
            let start_date: String
            let end_date: String
            let reason: String?
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return try await supabase
            .from("pto_requests")
            .insert(InsertPayload(
                carer_id: carerId,
                care_group_id: careGroupId,
                start_date: formatter.string(from: startDate),
                end_date: formatter.string(from: endDate),
                reason: reason
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func fetchPTORequests(careGroupId: UUID) async throws -> [PTORequest] {
        try await supabase
            .from("pto_requests")
            .select()
            .eq("care_group_id", value: careGroupId)
            .order("start_date", ascending: true)
            .execute()
            .value
    }

    func fetchMyPTORequests(carerId: UUID) async throws -> [PTORequest] {
        try await supabase
            .from("pto_requests")
            .select()
            .eq("carer_id", value: carerId)
            .order("start_date", ascending: true)
            .execute()
            .value
    }

    func approvePTO(requestId: UUID) async throws {
        try await supabase
            .from("pto_requests")
            .update(["status": "approved"])
            .eq("id", value: requestId)
            .execute()
    }

    func denyPTO(requestId: UUID) async throws {
        try await supabase
            .from("pto_requests")
            .update(["status": "denied"])
            .eq("id", value: requestId)
            .execute()
    }
}
```

**Step 2: Write ShiftOfferRepository**

```swift
// CareCoordinator/Repositories/ShiftOfferRepository.swift
import Foundation
import Supabase

@Observable
final class ShiftOfferRepository {
    private let supabase = SupabaseManager.shared.client

    /// Client broadcasts open shifts after PTO approval
    func createShiftOffer(shiftId: UUID, careGroupId: UUID) async throws -> ShiftOffer {
        struct InsertPayload: Encodable {
            let shift_id: UUID
            let care_group_id: UUID
        }

        return try await supabase
            .from("shift_offers")
            .insert(InsertPayload(
                shift_id: shiftId,
                care_group_id: careGroupId
            ))
            .select()
            .single()
            .execute()
            .value
    }

    /// Fetch open shift offers for the care group
    func fetchOpenOffers(careGroupId: UUID) async throws -> [ShiftOffer] {
        try await supabase
            .from("shift_offers")
            .select("*, shifts(*)")
            .eq("care_group_id", value: careGroupId)
            .eq("status", value: "open")
            .execute()
            .value
    }

    /// Carer claims an open shift
    func claimShift(offerId: UUID, carerId: UUID) async throws {
        try await supabase
            .from("shift_offers")
            .update([
                "claimed_by": carerId.uuidString,
                "status": "claimed"
            ])
            .eq("id", value: offerId)
            .execute()
    }

    /// Client confirms the claim and updates the shift's carer
    func confirmClaim(offerId: UUID, shiftId: UUID, newCarerId: UUID) async throws {
        // Update shift to new carer
        try await supabase
            .from("shifts")
            .update([
                "carer_id": newCarerId.uuidString,
                "status": "covered"
            ])
            .eq("id", value: shiftId)
            .execute()

        // Close the offer
        try await supabase
            .from("shift_offers")
            .update(["status": "confirmed"])
            .eq("id", value: offerId)
            .execute()
    }
}
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Repositories/PTORepository.swift CareCoordinator/Repositories/ShiftOfferRepository.swift
git commit -m "feat: add PTO and ShiftOffer repositories"
```

---

### Task 4.2: PTO ViewModel

**Files:**
- Create: `CareCoordinator/ViewModels/PTOViewModel.swift`

**Step 1: Write PTOViewModel**

```swift
// CareCoordinator/ViewModels/PTOViewModel.swift
import Foundation

@Observable
final class PTOViewModel {
    var ptoRequests: [PTORequest] = []
    var openShiftOffers: [ShiftOffer] = []
    var isLoading = false
    var errorMessage: String?

    // Form fields for new request
    var startDate = Date()
    var endDate = Date()
    var reason = ""

    private let ptoRepository = PTORepository()
    private let shiftOfferRepository = ShiftOfferRepository()
    private let shiftRepository = ShiftRepository()

    var careGroupId: UUID?
    var currentUserId: UUID?
    var isClient: Bool = false

    // MARK: - Load Data

    func loadPTORequests() async {
        guard let careGroupId else { return }
        isLoading = true
        errorMessage = nil

        do {
            if isClient {
                ptoRequests = try await ptoRepository.fetchPTORequests(careGroupId: careGroupId)
            } else if let userId = currentUserId {
                ptoRequests = try await ptoRepository.fetchMyPTORequests(carerId: userId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadOpenOffers() async {
        guard let careGroupId else { return }
        do {
            openShiftOffers = try await shiftOfferRepository.fetchOpenOffers(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Carer Actions

    func submitPTORequest() async {
        guard let currentUserId, let careGroupId else { return }
        isLoading = true
        errorMessage = nil

        do {
            let newRequest = try await ptoRepository.createPTORequest(
                carerId: currentUserId,
                careGroupId: careGroupId,
                startDate: startDate,
                endDate: endDate,
                reason: reason.isEmpty ? nil : reason
            )
            ptoRequests.append(newRequest)
            // Reset form
            reason = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func claimShift(offer: ShiftOffer) async {
        guard let currentUserId else { return }
        do {
            try await shiftOfferRepository.claimShift(offerId: offer.id, carerId: currentUserId)
            await loadOpenOffers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Client Actions

    func approvePTO(request: PTORequest) async {
        do {
            try await ptoRepository.approvePTO(requestId: request.id)

            // Mark affected shifts as needing cover
            let affectedShifts = try await shiftRepository.fetchShifts(
                careGroupId: request.careGroupId,
                from: request.startDate,
                to: request.endDate
            ).filter { $0.carerId == request.carerId }

            for shift in affectedShifts {
                try await shiftRepository.updateShift(
                    shiftId: shift.id,
                    status: .needingCover
                )
            }

            await loadPTORequests()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func denyPTO(request: PTORequest) async {
        do {
            try await ptoRepository.denyPTO(requestId: request.id)
            await loadPTORequests()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func broadcastOpenShift(shiftId: UUID) async {
        guard let careGroupId else { return }
        do {
            _ = try await shiftOfferRepository.createShiftOffer(
                shiftId: shiftId,
                careGroupId: careGroupId
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmClaim(offer: ShiftOffer) async {
        guard let claimedBy = offer.claimedBy else { return }
        do {
            try await shiftOfferRepository.confirmClaim(
                offerId: offer.id,
                shiftId: offer.shiftId,
                newCarerId: claimedBy
            )
            await loadOpenOffers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/ViewModels/PTOViewModel.swift
git commit -m "feat: add PTOViewModel with request, approve, deny, and shift offer handling"
```

---

### Task 4.3: PTO Views (Request, List, Open Shifts)

**Files:**
- Create: `CareCoordinator/Views/PTO/PTORequestView.swift`
- Create: `CareCoordinator/Views/PTO/PTOListView.swift`
- Create: `CareCoordinator/Views/PTO/OpenShiftsView.swift`

**Step 1: Write PTORequestView (carer submits PTO)**

```swift
// CareCoordinator/Views/PTO/PTORequestView.swift
import SwiftUI

struct PTORequestView: View {
    @Bindable var viewModel: PTOViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Dates") {
                DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
            }

            Section("Reason (Optional)") {
                TextField("Why do you need time off?", text: $viewModel.reason, axis: .vertical)
                    .lineLimit(3...6)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }

            Section {
                Button("Submit Request") {
                    Task {
                        await viewModel.submitPTORequest()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Request Time Off")
    }
}
```

**Step 2: Write PTOListView (client sees all requests)**

```swift
// CareCoordinator/Views/PTO/PTOListView.swift
import SwiftUI

struct PTOListView: View {
    @State var viewModel = PTOViewModel()
    let careGroupId: UUID
    let isClient: Bool
    let currentUserId: UUID

    var body: some View {
        List {
            if viewModel.ptoRequests.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No PTO Requests", systemImage: "calendar.badge.clock")
            }

            ForEach(viewModel.ptoRequests) { request in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(request.startDate.formatted(date: .abbreviated, time: .omitted)) – \(request.endDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                        Spacer()
                        StatusBadge(status: request.status)
                    }

                    if let reason = request.reason {
                        Text(reason)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if isClient && request.status == .pending {
                        HStack {
                            Button("Approve") {
                                Task { await viewModel.approvePTO(request: request) }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)

                            Button("Deny") {
                                Task { await viewModel.denyPTO(request: request) }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("PTO Requests")
        .toolbar {
            if !isClient {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: PTORequestView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            viewModel.careGroupId = careGroupId
            viewModel.currentUserId = currentUserId
            viewModel.isClient = isClient
            await viewModel.loadPTORequests()
        }
    }
}

struct StatusBadge: View {
    let status: PTOStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .pending: return .yellow.opacity(0.2)
        case .approved: return .green.opacity(0.2)
        case .denied: return .red.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .denied: return .red
        }
    }
}
```

**Step 3: Write OpenShiftsView (carers see available shifts to claim)**

```swift
// CareCoordinator/Views/PTO/OpenShiftsView.swift
import SwiftUI

struct OpenShiftsView: View {
    @State var viewModel = PTOViewModel()
    let careGroupId: UUID
    let currentUserId: UUID
    let isClient: Bool

    var body: some View {
        List {
            if viewModel.openShiftOffers.isEmpty {
                ContentUnavailableView("No Open Shifts", systemImage: "calendar.badge.exclamationmark",
                    description: Text("No shifts currently need coverage."))
            }

            ForEach(viewModel.openShiftOffers) { offer in
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.shiftId.uuidString.prefix(8) + "...")
                        .font(.headline)

                    Text("Status: \(offer.status.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let claimedBy = offer.claimedBy {
                        Text("Claimed by: \(claimedBy.uuidString.prefix(8))...")
                            .font(.caption)
                    }

                    HStack {
                        if !isClient && offer.status == .open {
                            Button("Claim This Shift") {
                                Task { await viewModel.claimShift(offer: offer) }
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        if isClient && offer.status == .claimed {
                            Button("Confirm") {
                                Task { await viewModel.confirmClaim(offer: offer) }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Open Shifts")
        .task {
            viewModel.careGroupId = careGroupId
            viewModel.currentUserId = currentUserId
            viewModel.isClient = isClient
            await viewModel.loadOpenOffers()
        }
    }
}
```

**Step 4: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 5: Commit**

```bash
git add CareCoordinator/Views/PTO/
git commit -m "feat: add PTO views (request, list with approve/deny, open shifts)"
```

---

## Phase 5: Task System (Weeks 11-13)

### Task 5.1: Task Repository

**Files:**
- Create: `CareCoordinator/Repositories/TaskRepository.swift`

**Step 1: Write TaskRepository**

```swift
// CareCoordinator/Repositories/TaskRepository.swift
import Foundation
import Supabase

@Observable
final class TaskRepository {
    private let supabase = SupabaseManager.shared.client

    // MARK: - Swapover Template

    func fetchSwapoverTemplate(careGroupId: UUID) async throws -> [CareTask] {
        try await supabase
            .from("tasks")
            .select()
            .eq("care_group_id", value: careGroupId)
            .eq("type", value: "swapover_template")
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    func createSwapoverTemplateItem(
        careGroupId: UUID,
        title: String,
        description: String?,
        sortOrder: Int
    ) async throws -> CareTask {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let description: String?
            let type: String
            let sort_order: Int
        }

        return try await supabase
            .from("tasks")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                title: title,
                description: description,
                type: "swapover_template",
                sort_order: sortOrder
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func deleteTemplateItem(taskId: UUID) async throws {
        try await supabase
            .from("tasks")
            .delete()
            .eq("id", value: taskId)
            .execute()
    }

    // MARK: - Swapover Instances

    /// Auto-generate swapover instance from template for a specific shift swap date
    func generateSwapoverInstance(
        careGroupId: UUID,
        templateItems: [CareTask],
        assignedTo: UUID?,
        dueDate: Date
    ) async throws -> [CareTask] {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let description: String?
            let type: String
            let assigned_to: UUID?
            let due_date: String
            let sort_order: Int
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let payloads = templateItems.map { item in
            InsertPayload(
                care_group_id: careGroupId,
                title: item.title,
                description: item.description,
                type: "swapover_instance",
                assigned_to: assignedTo,
                due_date: formatter.string(from: dueDate),
                sort_order: item.sortOrder ?? 0
            )
        }

        return try await supabase
            .from("tasks")
            .insert(payloads)
            .select()
            .execute()
            .value
    }

    // MARK: - General Tasks

    func fetchGeneralTasks(careGroupId: UUID) async throws -> [CareTask] {
        try await supabase
            .from("tasks")
            .select()
            .eq("care_group_id", value: careGroupId)
            .eq("type", value: "general")
            .order("due_date", ascending: true)
            .execute()
            .value
    }

    func createGeneralTask(
        careGroupId: UUID,
        title: String,
        description: String?,
        assignedTo: UUID?,
        dueDate: Date?,
        priority: TaskPriority,
        isRecurring: Bool,
        recurrencePattern: String?
    ) async throws -> CareTask {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let description: String?
            let type: String
            let assigned_to: UUID?
            let due_date: String?
            let priority: String
            let is_recurring: Bool
            let recurrence_pattern: String?
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return try await supabase
            .from("tasks")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                title: title,
                description: description,
                type: "general",
                assigned_to: assignedTo,
                due_date: dueDate.map { formatter.string(from: $0) },
                priority: priority.rawValue,
                is_recurring: isRecurring,
                recurrence_pattern: recurrencePattern
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func toggleTaskCompletion(taskId: UUID, completed: Bool, completedBy: UUID?) async throws {
        struct UpdatePayload: Encodable {
            let completed: Bool
            let completed_by: UUID?
            let completed_at: String?
        }

        let formatter = ISO8601DateFormatter()

        try await supabase
            .from("tasks")
            .update(UpdatePayload(
                completed: completed,
                completed_by: completed ? completedBy : nil,
                completed_at: completed ? formatter.string(from: Date()) : nil
            ))
            .eq("id", value: taskId)
            .execute()
    }

    func deleteTask(taskId: UUID) async throws {
        try await supabase
            .from("tasks")
            .delete()
            .eq("id", value: taskId)
            .execute()
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Repositories/TaskRepository.swift
git commit -m "feat: add TaskRepository with template, instance generation, and general tasks"
```

---

### Task 5.2: Task ViewModel

**Files:**
- Create: `CareCoordinator/ViewModels/TaskViewModel.swift`

**Step 1: Write TaskViewModel**

```swift
// CareCoordinator/ViewModels/TaskViewModel.swift
import Foundation

@Observable
final class TaskViewModel {
    var swapoverTemplate: [CareTask] = []
    var swapoverInstances: [CareTask] = []
    var generalTasks: [CareTask] = []
    var isLoading = false
    var errorMessage: String?

    // Form fields
    var newTaskTitle = ""
    var newTaskDescription = ""
    var newTaskDueDate = Date()
    var newTaskPriority: TaskPriority = .medium
    var newTaskIsRecurring = false
    var newTaskRecurrencePattern: String?

    private let repository = TaskRepository()

    var careGroupId: UUID?
    var currentUserId: UUID?
    var isClient: Bool = false

    // MARK: - Swapover Template

    func loadSwapoverTemplate() async {
        guard let careGroupId else { return }
        do {
            swapoverTemplate = try await repository.fetchSwapoverTemplate(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addTemplateItem(title: String, description: String?) async {
        guard let careGroupId else { return }
        do {
            let item = try await repository.createSwapoverTemplateItem(
                careGroupId: careGroupId,
                title: title,
                description: description,
                sortOrder: swapoverTemplate.count
            )
            swapoverTemplate.append(item)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTemplateItem(_ item: CareTask) async {
        do {
            try await repository.deleteTemplateItem(taskId: item.id)
            swapoverTemplate.removeAll { $0.id == item.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generateSwapoverInstance(assignedTo: UUID?, dueDate: Date) async {
        guard let careGroupId else { return }
        do {
            let instances = try await repository.generateSwapoverInstance(
                careGroupId: careGroupId,
                templateItems: swapoverTemplate,
                assignedTo: assignedTo,
                dueDate: dueDate
            )
            swapoverInstances.append(contentsOf: instances)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - General Tasks

    func loadGeneralTasks() async {
        guard let careGroupId else { return }
        isLoading = true
        do {
            generalTasks = try await repository.fetchGeneralTasks(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createGeneralTask() async {
        guard let careGroupId else { return }
        do {
            let task = try await repository.createGeneralTask(
                careGroupId: careGroupId,
                title: newTaskTitle,
                description: newTaskDescription.isEmpty ? nil : newTaskDescription,
                assignedTo: nil,
                dueDate: newTaskDueDate,
                priority: newTaskPriority,
                isRecurring: newTaskIsRecurring,
                recurrencePattern: newTaskRecurrencePattern
            )
            generalTasks.append(task)
            // Reset form
            newTaskTitle = ""
            newTaskDescription = ""
            newTaskPriority = .medium
            newTaskIsRecurring = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompletion(task: CareTask) async {
        do {
            let newState = !task.completed
            try await repository.toggleTaskCompletion(
                taskId: task.id,
                completed: newState,
                completedBy: newState ? currentUserId : nil
            )
            // Update local state
            if let index = generalTasks.firstIndex(where: { $0.id == task.id }) {
                generalTasks[index].completed = newState
            }
            if let index = swapoverInstances.firstIndex(where: { $0.id == task.id }) {
                swapoverInstances[index].completed = newState
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(_ task: CareTask) async {
        do {
            try await repository.deleteTask(taskId: task.id)
            generalTasks.removeAll { $0.id == task.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/ViewModels/TaskViewModel.swift
git commit -m "feat: add TaskViewModel with template management and general task CRUD"
```

---

### Task 5.3: Task Views (Template Editor, Task List, Create Task)

**Files:**
- Create: `CareCoordinator/Views/Tasks/SwapoverTemplateView.swift`
- Create: `CareCoordinator/Views/Tasks/GeneralTaskListView.swift`
- Create: `CareCoordinator/Views/Tasks/CreateTaskView.swift`
- Create: `CareCoordinator/Views/Tasks/TaskRowView.swift`

**Step 1: Write SwapoverTemplateView (client edits checklist template)**

```swift
// CareCoordinator/Views/Tasks/SwapoverTemplateView.swift
import SwiftUI

struct SwapoverTemplateView: View {
    @State var viewModel = TaskViewModel()
    @State private var newItemTitle = ""
    let careGroupId: UUID

    var body: some View {
        List {
            Section("Checklist Items") {
                ForEach(viewModel.swapoverTemplate) { item in
                    HStack {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                        Text(item.title)
                    }
                }
                .onDelete { indices in
                    for index in indices {
                        let item = viewModel.swapoverTemplate[index]
                        Task { await viewModel.deleteTemplateItem(item) }
                    }
                }
            }

            Section("Add Item") {
                HStack {
                    TextField("Checklist item", text: $newItemTitle)
                    Button("Add") {
                        guard !newItemTitle.isEmpty else { return }
                        Task {
                            await viewModel.addTemplateItem(title: newItemTitle, description: nil)
                            newItemTitle = ""
                        }
                    }
                    .disabled(newItemTitle.isEmpty)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Swapover Checklist")
        .task {
            viewModel.careGroupId = careGroupId
            await viewModel.loadSwapoverTemplate()
        }
    }
}
```

**Step 2: Write TaskRowView**

```swift
// CareCoordinator/Views/Tasks/TaskRowView.swift
import SwiftUI

struct TaskRowView: View {
    let task: CareTask
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.completed ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .strikethrough(task.completed)
                    .foregroundStyle(task.completed ? .secondary : .primary)

                if let dueDate = task.dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(dueDate < Date() && !task.completed ? .red : .secondary)
                }
            }

            Spacer()

            if let priority = task.priority {
                PriorityBadge(priority: priority)
            }
        }
    }
}

struct PriorityBadge: View {
    let priority: TaskPriority

    var body: some View {
        Text(priority.rawValue.capitalized)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        case .urgent: return .purple
        }
    }
}
```

**Step 3: Write GeneralTaskListView**

```swift
// CareCoordinator/Views/Tasks/GeneralTaskListView.swift
import SwiftUI

struct GeneralTaskListView: View {
    @State var viewModel = TaskViewModel()
    let careGroupId: UUID
    let currentUserId: UUID
    let isClient: Bool

    var body: some View {
        List {
            if viewModel.generalTasks.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No Tasks", systemImage: "checklist",
                    description: Text("Create a task to get started."))
            }

            Section("Active") {
                ForEach(viewModel.generalTasks.filter { !$0.completed }) { task in
                    TaskRowView(task: task) {
                        Task { await viewModel.toggleCompletion(task: task) }
                    }
                }
                .onDelete { indices in
                    let activeTasks = viewModel.generalTasks.filter { !$0.completed }
                    for index in indices {
                        Task { await viewModel.deleteTask(activeTasks[index]) }
                    }
                }
            }

            let completed = viewModel.generalTasks.filter { $0.completed }
            if !completed.isEmpty {
                Section("Completed") {
                    ForEach(completed) { task in
                        TaskRowView(task: task) {
                            Task { await viewModel.toggleCompletion(task: task) }
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Section { Text(error).foregroundStyle(.red) }
            }
        }
        .navigationTitle("Tasks")
        .toolbar {
            if isClient {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: CreateTaskView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            viewModel.careGroupId = careGroupId
            viewModel.currentUserId = currentUserId
            viewModel.isClient = isClient
            await viewModel.loadGeneralTasks()
        }
    }
}
```

**Step 4: Write CreateTaskView**

```swift
// CareCoordinator/Views/Tasks/CreateTaskView.swift
import SwiftUI

struct CreateTaskView: View {
    @Bindable var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Task Details") {
                TextField("Title", text: $viewModel.newTaskTitle)
                TextField("Description (optional)", text: $viewModel.newTaskDescription, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Priority & Date") {
                Picker("Priority", selection: $viewModel.newTaskPriority) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue.capitalized).tag(priority)
                    }
                }
                DatePicker("Due Date", selection: $viewModel.newTaskDueDate, displayedComponents: .date)
            }

            Section {
                Toggle("Recurring", isOn: $viewModel.newTaskIsRecurring)
                if viewModel.newTaskIsRecurring {
                    Picker("Frequency", selection: Binding(
                        get: { viewModel.newTaskRecurrencePattern ?? "daily" },
                        set: { viewModel.newTaskRecurrencePattern = $0 }
                    )) {
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                        Text("Monthly").tag("monthly")
                    }
                }
            }

            Section {
                Button("Create Task") {
                    Task {
                        await viewModel.createGeneralTask()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.newTaskTitle.isEmpty)
            }
        }
        .navigationTitle("New Task")
    }
}
```

**Step 5: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 6: Commit**

```bash
git add CareCoordinator/Views/Tasks/
git commit -m "feat: add task views (swapover template editor, general task list, create task)"
```

---

## Phase 6: Notifications (Weeks 13-14)

### Task 6.1: Notification Repository & In-App Notification Center

**Files:**
- Create: `CareCoordinator/Repositories/NotificationRepository.swift`
- Create: `CareCoordinator/ViewModels/NotificationViewModel.swift`

**Step 1: Write NotificationRepository**

```swift
// CareCoordinator/Repositories/NotificationRepository.swift
import Foundation
import Supabase

@Observable
final class NotificationRepository {
    private let supabase = SupabaseManager.shared.client

    func fetchNotifications(userId: UUID) async throws -> [CareNotification] {
        try await supabase
            .from("notifications")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()
            .value
    }

    func fetchUnreadCount(userId: UUID) async throws -> Int {
        let notifications: [CareNotification] = try await supabase
            .from("notifications")
            .select()
            .eq("user_id", value: userId)
            .eq("read", value: false)
            .execute()
            .value
        return notifications.count
    }

    func markAsRead(notificationId: UUID) async throws {
        try await supabase
            .from("notifications")
            .update(["read": true])
            .eq("id", value: notificationId)
            .execute()
    }

    func markAllAsRead(userId: UUID) async throws {
        try await supabase
            .from("notifications")
            .update(["read": true])
            .eq("user_id", value: userId)
            .eq("read", value: false)
            .execute()
    }

    func createNotification(
        userId: UUID,
        type: NotificationType,
        title: String,
        body: String,
        data: [String: String]? = nil
    ) async throws {
        struct InsertPayload: Encodable {
            let user_id: UUID
            let type: String
            let title: String
            let body: String
            let data: [String: String]?
        }

        try await supabase
            .from("notifications")
            .insert(InsertPayload(
                user_id: userId,
                type: type.rawValue,
                title: title,
                body: body,
                data: data
            ))
            .execute()
    }
}
```

**Step 2: Write NotificationViewModel**

```swift
// CareCoordinator/ViewModels/NotificationViewModel.swift
import Foundation

@Observable
final class NotificationViewModel {
    var notifications: [CareNotification] = []
    var unreadCount: Int = 0
    var isLoading = false
    var errorMessage: String?

    private let repository = NotificationRepository()
    var currentUserId: UUID?

    func loadNotifications() async {
        guard let userId = currentUserId else { return }
        isLoading = true
        do {
            notifications = try await repository.fetchNotifications(userId: userId)
            unreadCount = notifications.filter { !$0.read }.count
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func markAsRead(_ notification: CareNotification) async {
        guard !notification.read else { return }
        do {
            try await repository.markAsRead(notificationId: notification.id)
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].read = true
                unreadCount = max(0, unreadCount - 1)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllAsRead() async {
        guard let userId = currentUserId else { return }
        do {
            try await repository.markAllAsRead(userId: userId)
            for i in notifications.indices {
                notifications[i].read = true
            }
            unreadCount = 0
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Repositories/NotificationRepository.swift CareCoordinator/ViewModels/NotificationViewModel.swift
git commit -m "feat: add NotificationRepository and NotificationViewModel"
```

---

### Task 6.2: Notification Views

**Files:**
- Create: `CareCoordinator/Views/Notifications/NotificationListView.swift`
- Create: `CareCoordinator/Views/Notifications/NotificationRowView.swift`

**Step 1: Write NotificationRowView**

```swift
// CareCoordinator/Views/Notifications/NotificationRowView.swift
import SwiftUI

struct NotificationRowView: View {
    let notification: CareNotification

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(.title3)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(notification.read ? .regular : .semibold)

                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(notification.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if !notification.read {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch notification.type {
        case .joinRequest: return "person.badge.plus"
        case .ptoRequest: return "calendar.badge.clock"
        case .shiftChange: return "arrow.triangle.2.circlepath"
        case .taskAssigned: return "checklist"
        case .reminder: return "bell.fill"
        }
    }

    private var iconColor: Color {
        switch notification.type {
        case .joinRequest: return .blue
        case .ptoRequest: return .orange
        case .shiftChange: return .purple
        case .taskAssigned: return .green
        case .reminder: return .red
        }
    }
}
```

**Step 2: Write NotificationListView**

```swift
// CareCoordinator/Views/Notifications/NotificationListView.swift
import SwiftUI

struct NotificationListView: View {
    @State var viewModel = NotificationViewModel()
    let currentUserId: UUID

    var body: some View {
        List {
            if viewModel.notifications.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No Notifications", systemImage: "bell.slash",
                    description: Text("You're all caught up."))
            }

            ForEach(viewModel.notifications) { notification in
                NotificationRowView(notification: notification)
                    .onTapGesture {
                        Task { await viewModel.markAsRead(notification) }
                    }
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.unreadCount > 0 {
                    Button("Mark All Read") {
                        Task { await viewModel.markAllAsRead() }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadNotifications()
        }
        .task {
            viewModel.currentUserId = currentUserId
            await viewModel.loadNotifications()
        }
    }
}
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Views/Notifications/
git commit -m "feat: add notification views (list with mark-read, typed icons)"
```

---

### Task 6.3: Push Notification Setup (APNs)

**Files:**
- Create: `CareCoordinator/Services/Notifications/PushNotificationService.swift`
- Modify: `CareCoordinator/App/CareCoordinatorApp.swift`

**Step 1: Write PushNotificationService**

```swift
// CareCoordinator/Services/Notifications/PushNotificationService.swift
import Foundation
import UserNotifications
import UIKit

final class PushNotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PushNotificationService()

    private override init() {
        super.init()
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            return false
        }
    }

    func saveDeviceToken(_ deviceToken: Data) async {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        // Store token in Supabase for server-side push (via Edge Function or direct)
        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id
            try await SupabaseManager.shared.client
                .from("profiles")
                .update(["device_token": token])
                .eq("id", value: userId)
                .execute()
        } catch {
            print("Failed to save device token: \(error)")
        }
    }

    // Handle foreground notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        // Handle deep linking based on notification type
        if let type = userInfo["type"] as? String {
            NotificationCenter.default.post(
                name: .didTapNotification,
                object: nil,
                userInfo: ["type": type, "data": userInfo]
            )
        }
    }
}

extension Notification.Name {
    static let didTapNotification = Notification.Name("didTapNotification")
}
```

**Step 2: Register in CareCoordinatorApp**

Add to `CareCoordinatorApp.swift`:

```swift
// Add to CareCoordinatorApp body:
.onAppear {
    UNUserNotificationCenter.current().delegate = PushNotificationService.shared
}
```

And add an `AppDelegate` adapter for device token handling:

```swift
// Add to CareCoordinator/App/AppDelegate.swift
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            await PushNotificationService.shared.saveDeviceToken(deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }
}
```

In `CareCoordinatorApp.swift`, wire the delegate:

```swift
@main
struct CareCoordinatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // ... existing code
}
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Services/Notifications/PushNotificationService.swift CareCoordinator/App/AppDelegate.swift CareCoordinator/App/CareCoordinatorApp.swift
git commit -m "feat: add push notification service with APNs registration and foreground handling"
```

---

## Phase 7: Shift Notes, Reminders & Emergency Contacts (Weeks 14-16)

### Task 7.1: Shift Notes Repository (E2E Encrypted)

**Files:**
- Create: `CareCoordinator/Repositories/ShiftNoteRepository.swift`

**Step 1: Write ShiftNoteRepository**

```swift
// CareCoordinator/Repositories/ShiftNoteRepository.swift
import Foundation
import Supabase
import CryptoKit

@Observable
final class ShiftNoteRepository {
    private let supabase = SupabaseManager.shared.client
    private let cryptoService = CryptoService()

    func createNote(
        shiftId: UUID,
        careGroupId: UUID,
        authorId: UUID,
        content: String,
        groupKey: SymmetricKey
    ) async throws -> ShiftNote {
        // Encrypt the note content
        let contentData = Data(content.utf8)
        let encryptedData = try cryptoService.encrypt(data: contentData, using: groupKey)
        let encryptedBase64 = encryptedData.base64EncodedString()

        struct InsertPayload: Encodable {
            let shift_id: UUID
            let care_group_id: UUID
            let author_id: UUID
            let encrypted_content: String
        }

        return try await supabase
            .from("shift_notes")
            .insert(InsertPayload(
                shift_id: shiftId,
                care_group_id: careGroupId,
                author_id: authorId,
                encrypted_content: encryptedBase64
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func fetchNotes(shiftId: UUID) async throws -> [ShiftNote] {
        try await supabase
            .from("shift_notes")
            .select()
            .eq("shift_id", value: shiftId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    func decryptNote(note: ShiftNote, groupKey: SymmetricKey) throws -> String {
        guard let encryptedData = Data(base64Encoded: note.encryptedContent) else {
            throw CryptoError.decryptionFailed
        }
        let decryptedData = try cryptoService.decrypt(data: encryptedData, using: groupKey)
        guard let text = String(data: decryptedData, encoding: .utf8) else {
            throw CryptoError.decryptionFailed
        }
        return text
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Repositories/ShiftNoteRepository.swift
git commit -m "feat: add ShiftNoteRepository with E2E encrypted notes"
```

---

### Task 7.2: Shift Notes View

**Files:**
- Create: `CareCoordinator/Views/Schedule/ShiftNotesView.swift`

**Step 1: Write ShiftNotesView**

```swift
// CareCoordinator/Views/Schedule/ShiftNotesView.swift
import SwiftUI
import CryptoKit

struct ShiftNotesView: View {
    let shiftId: UUID
    let careGroupId: UUID
    let currentUserId: UUID

    @State private var notes: [(note: ShiftNote, decryptedContent: String)] = []
    @State private var newNoteText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let repository = ShiftNoteRepository()
    private let keychainService = KeychainService()

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(notes, id: \.note.id) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.note.authorId == currentUserId ? "You" : "Carer")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(item.note.createdAt.formatted(.relative(presentation: .named)))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            Text(item.decryptedContent)
                                .font(.body)
                        }
                        .padding()
                        .background(
                            item.note.authorId == currentUserId
                                ? Color.blue.opacity(0.1)
                                : Color(.systemGray6)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }

            // Compose bar
            HStack {
                TextField("Leave a note for the next carer...", text: $newNoteText, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await sendNote() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Shift Notes")
        .task { await loadNotes() }
    }

    private func loadNotes() async {
        isLoading = true
        do {
            let groupKey = try loadGroupKey()
            let rawNotes = try await repository.fetchNotes(shiftId: shiftId)
            notes = rawNotes.compactMap { note in
                guard let decrypted = try? repository.decryptNote(note: note, groupKey: groupKey) else {
                    return nil
                }
                return (note: note, decryptedContent: decrypted)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func sendNote() async {
        let content = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        do {
            let groupKey = try loadGroupKey()
            let note = try await repository.createNote(
                shiftId: shiftId,
                careGroupId: careGroupId,
                authorId: currentUserId,
                content: content,
                groupKey: groupKey
            )
            notes.append((note: note, decryptedContent: content))
            newNoteText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadGroupKey() throws -> SymmetricKey {
        guard let keyData = keychainService.load(key: "groupKey_\(careGroupId.uuidString)") else {
            throw CryptoError.keyNotFound
        }
        return SymmetricKey(data: keyData)
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Views/Schedule/ShiftNotesView.swift
git commit -m "feat: add encrypted shift notes view with compose bar"
```

---

### Task 7.3: Reminders & Emergency Contacts Repository

**Files:**
- Create: `CareCoordinator/Repositories/ReminderRepository.swift`
- Create: `CareCoordinator/Repositories/EmergencyContactRepository.swift`

**Step 1: Write ReminderRepository**

```swift
// CareCoordinator/Repositories/ReminderRepository.swift
import Foundation
import Supabase

@Observable
final class ReminderRepository {
    private let supabase = SupabaseManager.shared.client

    func createReminder(
        careGroupId: UUID,
        title: String,
        body: String?,
        reminderTime: Date,
        isRecurring: Bool,
        recurrencePattern: String?
    ) async throws -> Reminder {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let body: String?
            let reminder_time: String
            let is_recurring: Bool
            let recurrence_pattern: String?
        }

        let formatter = ISO8601DateFormatter()

        return try await supabase
            .from("reminders")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                title: title,
                body: body,
                reminder_time: formatter.string(from: reminderTime),
                is_recurring: isRecurring,
                recurrence_pattern: recurrencePattern
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func fetchReminders(careGroupId: UUID) async throws -> [Reminder] {
        try await supabase
            .from("reminders")
            .select()
            .eq("care_group_id", value: careGroupId)
            .order("reminder_time", ascending: true)
            .execute()
            .value
    }

    func deleteReminder(reminderId: UUID) async throws {
        try await supabase
            .from("reminders")
            .delete()
            .eq("id", value: reminderId)
            .execute()
    }
}
```

**Step 2: Write EmergencyContactRepository**

```swift
// CareCoordinator/Repositories/EmergencyContactRepository.swift
import Foundation
import Supabase

@Observable
final class EmergencyContactRepository {
    private let supabase = SupabaseManager.shared.client

    func createContact(
        careGroupId: UUID,
        name: String,
        phone: String,
        relationship: String?,
        sortOrder: Int
    ) async throws -> EmergencyContact {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let name: String
            let phone: String
            let relationship: String?
            let sort_order: Int
        }

        return try await supabase
            .from("emergency_contacts")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                name: name,
                phone: phone,
                relationship: relationship,
                sort_order: sortOrder
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func fetchContacts(careGroupId: UUID) async throws -> [EmergencyContact] {
        try await supabase
            .from("emergency_contacts")
            .select()
            .eq("care_group_id", value: careGroupId)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    func deleteContact(contactId: UUID) async throws {
        try await supabase
            .from("emergency_contacts")
            .delete()
            .eq("id", value: contactId)
            .execute()
    }
}
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Repositories/ReminderRepository.swift CareCoordinator/Repositories/EmergencyContactRepository.swift
git commit -m "feat: add Reminder and EmergencyContact repositories"
```

---

### Task 7.4: Reminder & Emergency Contact Views

**Files:**
- Create: `CareCoordinator/Views/Settings/RemindersView.swift`
- Create: `CareCoordinator/Views/Settings/EmergencyContactsView.swift`

**Step 1: Write RemindersView**

```swift
// CareCoordinator/Views/Settings/RemindersView.swift
import SwiftUI

struct RemindersView: View {
    @State private var reminders: [Reminder] = []
    @State private var showingAddSheet = false
    @State private var errorMessage: String?

    // Add form state
    @State private var newTitle = ""
    @State private var newBody = ""
    @State private var newTime = Date()
    @State private var newIsRecurring = false
    @State private var newRecurrencePattern = "daily"

    let careGroupId: UUID
    private let repository = ReminderRepository()

    var body: some View {
        List {
            if reminders.isEmpty {
                ContentUnavailableView("No Reminders", systemImage: "bell.slash",
                    description: Text("Set up medication or appointment reminders."))
            }

            ForEach(reminders) { reminder in
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.title)
                        .font(.headline)
                    Text(reminder.reminderTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if reminder.isRecurring {
                        Label(reminder.recurrencePattern ?? "Recurring", systemImage: "repeat")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .onDelete { indices in
                for index in indices {
                    let reminder = reminders[index]
                    Task {
                        try? await repository.deleteReminder(reminderId: reminder.id)
                        reminders.remove(at: index)
                    }
                }
            }
        }
        .navigationTitle("Reminders")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    TextField("Title (e.g., Medication)", text: $newTitle)
                    TextField("Details (optional)", text: $newBody, axis: .vertical)
                    DatePicker("Time", selection: $newTime)
                    Toggle("Recurring", isOn: $newIsRecurring)
                    if newIsRecurring {
                        Picker("Frequency", selection: $newRecurrencePattern) {
                            Text("Daily").tag("daily")
                            Text("Weekly").tag("weekly")
                        }
                    }
                }
                .navigationTitle("Add Reminder")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                if let reminder = try? await repository.createReminder(
                                    careGroupId: careGroupId,
                                    title: newTitle,
                                    body: newBody.isEmpty ? nil : newBody,
                                    reminderTime: newTime,
                                    isRecurring: newIsRecurring,
                                    recurrencePattern: newIsRecurring ? newRecurrencePattern : nil
                                ) {
                                    reminders.append(reminder)
                                    showingAddSheet = false
                                    newTitle = ""
                                    newBody = ""
                                }
                            }
                        }
                        .disabled(newTitle.isEmpty)
                    }
                }
            }
        }
        .task {
            reminders = (try? await repository.fetchReminders(careGroupId: careGroupId)) ?? []
        }
    }
}
```

**Step 2: Write EmergencyContactsView**

```swift
// CareCoordinator/Views/Settings/EmergencyContactsView.swift
import SwiftUI

struct EmergencyContactsView: View {
    @State private var contacts: [EmergencyContact] = []
    @State private var showingAddSheet = false

    @State private var newName = ""
    @State private var newPhone = ""
    @State private var newRelationship = ""

    let careGroupId: UUID
    let isClient: Bool
    private let repository = EmergencyContactRepository()

    var body: some View {
        List {
            if contacts.isEmpty {
                ContentUnavailableView("No Emergency Contacts", systemImage: "phone.badge.plus",
                    description: Text("Add emergency contacts for quick access."))
            }

            ForEach(contacts) { contact in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name)
                            .font(.headline)
                        if let relationship = contact.relationship {
                            Text(relationship)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Quick-dial button
                    Link(destination: URL(string: "tel:\(contact.phone)")!) {
                        Image(systemName: "phone.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
            .onDelete { indices in
                guard isClient else { return }
                for index in indices {
                    let contact = contacts[index]
                    Task {
                        try? await repository.deleteContact(contactId: contact.id)
                        contacts.remove(at: index)
                    }
                }
            }
        }
        .navigationTitle("Emergency Contacts")
        .toolbar {
            if isClient {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    TextField("Name", text: $newName)
                    TextField("Phone", text: $newPhone)
                        .keyboardType(.phonePad)
                    TextField("Relationship (optional)", text: $newRelationship)
                }
                .navigationTitle("Add Contact")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                if let contact = try? await repository.createContact(
                                    careGroupId: careGroupId,
                                    name: newName,
                                    phone: newPhone,
                                    relationship: newRelationship.isEmpty ? nil : newRelationship,
                                    sortOrder: contacts.count
                                ) {
                                    contacts.append(contact)
                                    showingAddSheet = false
                                    newName = ""
                                    newPhone = ""
                                    newRelationship = ""
                                }
                            }
                        }
                        .disabled(newName.isEmpty || newPhone.isEmpty)
                    }
                }
            }
        }
        .task {
            contacts = (try? await repository.fetchContacts(careGroupId: careGroupId)) ?? []
        }
    }
}
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Views/Settings/RemindersView.swift CareCoordinator/Views/Settings/EmergencyContactsView.swift
git commit -m "feat: add reminder and emergency contact views with quick-dial"
```

---

## Phase 8: Calendar Integration (Weeks 16-17)

### Task 8.1: Calendar Sync Service (EventKit)

**Files:**
- Create: `CareCoordinator/Services/Calendar/CalendarSyncService.swift`

**Step 1: Write CalendarSyncService**

```swift
// CareCoordinator/Services/Calendar/CalendarSyncService.swift
import Foundation
import EventKit

final class CalendarSyncService {
    private let eventStore = EKEventStore()
    private let calendarTitle = "CareCoordinator"

    // MARK: - Permission

    func requestAccess() async -> Bool {
        do {
            return try await eventStore.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    var hasAccess: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    // MARK: - Calendar Management

    /// Get or create the dedicated CareCoordinator calendar
    func getOrCreateCalendar() throws -> EKCalendar {
        // Check if it already exists
        if let existing = eventStore.calendars(for: .event).first(where: { $0.title == calendarTitle }) {
            return existing
        }

        // Create new calendar
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = calendarTitle
        calendar.cgColor = UIColor.systemBlue.cgColor

        // Use the default calendar source (iCloud or local)
        if let source = eventStore.defaultCalendarForNewEvents?.source {
            calendar.source = source
        } else if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            calendar.source = localSource
        } else {
            throw CalendarSyncError.noCalendarSource
        }

        try eventStore.saveCalendar(calendar, commit: true)
        return calendar
    }

    // MARK: - Sync Shifts

    func syncShifts(_ shifts: [Shift], carerNames: [UUID: String]?) async throws {
        guard hasAccess else { throw CalendarSyncError.noPermission }

        let calendar = try getOrCreateCalendar()

        // Fetch existing CareCoordinator events in the shift range
        guard let minDate = shifts.map(\.date).min(),
              let maxDate = shifts.map(\.date).max() else { return }

        let predicate = eventStore.predicateForEvents(
            withStart: minDate,
            end: Calendar.current.date(byAdding: .day, value: 1, to: maxDate)!,
            calendars: [calendar]
        )
        let existingEvents = eventStore.events(matching: predicate)

        // Build a lookup by shift ID stored in notes
        var existingByShiftId: [UUID: EKEvent] = [:]
        for event in existingEvents {
            if let notes = event.notes,
               let shiftId = UUID(uuidString: notes) {
                existingByShiftId[shiftId] = event
            }
        }

        // Sync each shift
        for shift in shifts {
            let event: EKEvent
            if let existing = existingByShiftId[shift.id] {
                event = existing
                existingByShiftId.removeValue(forKey: shift.id)
            } else {
                event = EKEvent(eventStore: eventStore)
                event.calendar = calendar
            }

            // Build title based on shift info
            let carerName = shift.carerId.flatMap { carerNames?[$0] } ?? "Unassigned"
            event.title = "Shift: \(carerName)"
            event.startDate = shift.startTime
            event.endDate = shift.endTime
            event.notes = shift.id.uuidString // Store shift ID for future sync

            if shift.status == .cancelled {
                event.title = "[Cancelled] \(event.title ?? "")"
            }

            try eventStore.save(event, span: .thisEvent)
        }

        // Remove events for shifts no longer in the list
        for (_, orphanEvent) in existingByShiftId {
            try eventStore.remove(orphanEvent, span: .thisEvent)
        }

        try eventStore.commit()
    }

    // MARK: - Remove All Events

    func removeAllEvents() throws {
        guard let calendar = eventStore.calendars(for: .event).first(where: { $0.title == calendarTitle }) else {
            return
        }

        let predicate = eventStore.predicateForEvents(
            withStart: Date.distantPast,
            end: Date.distantFuture,
            calendars: [calendar]
        )
        let events = eventStore.events(matching: predicate)
        for event in events {
            try eventStore.remove(event, span: .thisEvent)
        }
        try eventStore.commit()
    }
}

enum CalendarSyncError: LocalizedError {
    case noPermission
    case noCalendarSource

    var errorDescription: String? {
        switch self {
        case .noPermission: return "Calendar access not granted. Enable in Settings."
        case .noCalendarSource: return "No calendar source available on this device."
        }
    }
}
```

**Step 2: Add Info.plist entry**

Ensure `Info.plist` includes:
```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>CareCoordinator syncs your shifts to your calendar so you never miss one.</string>
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Services/Calendar/CalendarSyncService.swift
git commit -m "feat: add CalendarSyncService with EventKit shift-to-event mapping"
```

---

### Task 8.2: Calendar Sync Settings View

**Files:**
- Create: `CareCoordinator/Views/Settings/CalendarSyncView.swift`

**Step 1: Write CalendarSyncView**

```swift
// CareCoordinator/Views/Settings/CalendarSyncView.swift
import SwiftUI

struct CalendarSyncView: View {
    @State private var isSyncEnabled = false
    @State private var hasPermission = false
    @State private var isSyncing = false
    @State private var lastSyncDate: Date?
    @State private var errorMessage: String?

    let careGroupId: UUID
    let shifts: [Shift]
    let carerNames: [UUID: String]?

    private let calendarService = CalendarSyncService()

    var body: some View {
        Form {
            Section {
                Toggle("Sync Shifts to Calendar", isOn: $isSyncEnabled)
                    .onChange(of: isSyncEnabled) { _, newValue in
                        if newValue {
                            Task { await enableSync() }
                        } else {
                            Task { await disableSync() }
                        }
                    }
            } footer: {
                Text("Creates a 'CareCoordinator' calendar with your scheduled shifts. Changes in the app automatically update your calendar.")
            }

            if isSyncEnabled && hasPermission {
                Section("Sync Status") {
                    if isSyncing {
                        HStack {
                            ProgressView()
                            Text("Syncing...")
                                .padding(.leading, 8)
                        }
                    } else if let lastSync = lastSyncDate {
                        HStack {
                            Text("Last synced")
                            Spacer()
                            Text(lastSync.formatted(.relative(presentation: .named)))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Sync Now") {
                        Task { await performSync() }
                    }
                    .disabled(isSyncing)
                }
            }

            if !hasPermission && isSyncEnabled {
                Section {
                    Label("Calendar access required", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }

            if let error = errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Calendar Sync")
        .onAppear {
            hasPermission = calendarService.hasAccess
        }
    }

    private func enableSync() async {
        hasPermission = await calendarService.requestAccess()
        if hasPermission {
            await performSync()
        } else {
            isSyncEnabled = false
        }
    }

    private func disableSync() async {
        do {
            try calendarService.removeAllEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performSync() async {
        isSyncing = true
        errorMessage = nil
        do {
            try await calendarService.syncShifts(shifts, carerNames: carerNames)
            lastSyncDate = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSyncing = false
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Views/Settings/CalendarSyncView.swift
git commit -m "feat: add calendar sync settings view with permission handling"
```

---

## Phase 9: Activity Log & Offline Mode (Weeks 17-19)

### Task 9.1: Audit Log Repository

**Files:**
- Create: `CareCoordinator/Repositories/AuditLogRepository.swift`

**Step 1: Write AuditLogRepository**

```swift
// CareCoordinator/Repositories/AuditLogRepository.swift
import Foundation
import Supabase

@Observable
final class AuditLogRepository {
    private let supabase = SupabaseManager.shared.client

    func fetchLogs(careGroupId: UUID, limit: Int = 50) async throws -> [AuditLogEntry] {
        try await supabase
            .from("audit_log")
            .select()
            .eq("care_group_id", value: careGroupId)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    func logAction(
        careGroupId: UUID,
        userId: UUID,
        action: String,
        entityType: String,
        entityId: UUID?,
        metadata: [String: String]? = nil
    ) async throws {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let user_id: UUID
            let action: String
            let entity_type: String
            let entity_id: UUID?
            let metadata: [String: String]?
        }

        try await supabase
            .from("audit_log")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                user_id: userId,
                action: action,
                entity_type: entityType,
                entity_id: entityId,
                metadata: metadata
            ))
            .execute()
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Repositories/AuditLogRepository.swift
git commit -m "feat: add AuditLogRepository for activity timeline"
```

---

### Task 9.2: Activity Log View

**Files:**
- Create: `CareCoordinator/Views/Dashboard/ActivityLogView.swift`

**Step 1: Write ActivityLogView**

```swift
// CareCoordinator/Views/Dashboard/ActivityLogView.swift
import SwiftUI

struct ActivityLogView: View {
    @State private var logs: [AuditLogEntry] = []
    @State private var isLoading = false

    let careGroupId: UUID
    private let repository = AuditLogRepository()

    var body: some View {
        List {
            if isLoading && logs.isEmpty {
                ProgressView("Loading activity...")
            }

            if logs.isEmpty && !isLoading {
                ContentUnavailableView("No Activity", systemImage: "clock",
                    description: Text("Activity will appear here as events happen."))
            }

            ForEach(logs) { log in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: iconForAction(log.action))
                        .foregroundStyle(colorForAction(log.action))
                        .frame(width: 24)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(descriptionForLog(log))
                            .font(.subheadline)

                        Text(log.createdAt.formatted(.relative(presentation: .named)))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Activity")
        .refreshable {
            await loadLogs()
        }
        .task {
            await loadLogs()
        }
    }

    private func loadLogs() async {
        isLoading = true
        logs = (try? await repository.fetchLogs(careGroupId: careGroupId)) ?? []
        isLoading = false
    }

    private func iconForAction(_ action: String) -> String {
        switch action {
        case "shift_created", "shift_updated": return "calendar"
        case "pto_requested": return "calendar.badge.clock"
        case "pto_approved": return "checkmark.circle"
        case "pto_denied": return "xmark.circle"
        case "task_completed": return "checkmark.square"
        case "carer_joined": return "person.badge.plus"
        case "carer_removed": return "person.badge.minus"
        case "care_plan_uploaded": return "doc.badge.plus"
        default: return "circle"
        }
    }

    private func colorForAction(_ action: String) -> Color {
        switch action {
        case "pto_approved", "task_completed", "carer_joined": return .green
        case "pto_denied", "carer_removed": return .red
        case "pto_requested": return .orange
        default: return .blue
        }
    }

    private func descriptionForLog(_ log: AuditLogEntry) -> String {
        switch log.action {
        case "shift_created": return "New shift created"
        case "shift_updated": return "Shift updated"
        case "pto_requested": return "PTO request submitted"
        case "pto_approved": return "PTO request approved"
        case "pto_denied": return "PTO request denied"
        case "task_completed": return "Task completed"
        case "carer_joined": return "New carer joined"
        case "carer_removed": return "Carer removed"
        case "care_plan_uploaded": return "Care plan uploaded"
        default: return log.action.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Views/Dashboard/ActivityLogView.swift
git commit -m "feat: add activity log timeline view"
```

---

### Task 9.3: Offline Mode with SwiftData Caching

**Files:**
- Create: `CareCoordinator/Services/OfflineCacheService.swift`
- Create: `CareCoordinator/Models/CachedModels.swift`

**Step 1: Write CachedModels (SwiftData models for offline cache)**

```swift
// CareCoordinator/Models/CachedModels.swift
import Foundation
import SwiftData

@Model
final class CachedShift {
    @Attribute(.unique) var id: UUID
    var careGroupId: UUID
    var carerId: UUID?
    var date: Date
    var startTime: Date
    var endTime: Date
    var status: String
    var lastSynced: Date

    init(from shift: Shift) {
        self.id = shift.id
        self.careGroupId = shift.careGroupId
        self.carerId = shift.carerId
        self.date = shift.date
        self.startTime = shift.startTime
        self.endTime = shift.endTime
        self.status = shift.status.rawValue
        self.lastSynced = Date()
    }

    func toShift() -> Shift {
        Shift(
            id: id,
            careGroupId: careGroupId,
            carerId: carerId,
            date: date,
            startTime: startTime,
            endTime: endTime,
            status: ShiftStatus(rawValue: status) ?? .scheduled,
            isManuallyEdited: false,
            createdAt: lastSynced
        )
    }
}

@Model
final class CachedTask {
    @Attribute(.unique) var id: UUID
    var careGroupId: UUID
    var title: String
    var taskDescription: String?
    var type: String
    var completed: Bool
    var dueDate: Date?
    var priority: String?
    var lastSynced: Date

    init(from task: CareTask) {
        self.id = task.id
        self.careGroupId = task.careGroupId
        self.title = task.title
        self.taskDescription = task.description
        self.type = task.type.rawValue
        self.completed = task.completed
        self.dueDate = task.dueDate
        self.priority = task.priority?.rawValue
        self.lastSynced = Date()
    }
}

@Model
final class PendingSyncAction {
    @Attribute(.unique) var id: UUID
    var entityType: String  // "task", "shift", etc.
    var entityId: UUID
    var action: String      // "update", "create", "delete"
    var payload: Data       // JSON-encoded changes
    var createdAt: Date

    init(entityType: String, entityId: UUID, action: String, payload: Data) {
        self.id = UUID()
        self.entityType = entityType
        self.entityId = entityId
        self.action = action
        self.payload = payload
        self.createdAt = Date()
    }
}
```

**Step 2: Write OfflineCacheService**

```swift
// CareCoordinator/Services/OfflineCacheService.swift
import Foundation
import SwiftData
import Network

@Observable
final class OfflineCacheService {
    var isOnline = true

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                if path.status == .satisfied {
                    Task { await self?.syncPendingActions() }
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Cache Shifts

    func cacheShifts(_ shifts: [Shift], context: ModelContext) {
        for shift in shifts {
            let cached = CachedShift(from: shift)
            context.insert(cached)
        }
        try? context.save()
    }

    func loadCachedShifts(careGroupId: UUID, context: ModelContext) -> [Shift] {
        let predicate = #Predicate<CachedShift> { $0.careGroupId == careGroupId }
        let descriptor = FetchDescriptor<CachedShift>(predicate: predicate)
        let cached = (try? context.fetch(descriptor)) ?? []
        return cached.map { $0.toShift() }
    }

    // MARK: - Cache Tasks

    func cacheTasks(_ tasks: [CareTask], context: ModelContext) {
        for task in tasks {
            let cached = CachedTask(from: task)
            context.insert(cached)
        }
        try? context.save()
    }

    // MARK: - Pending Sync Queue

    func queueAction(
        entityType: String,
        entityId: UUID,
        action: String,
        payload: Encodable,
        context: ModelContext
    ) {
        guard let data = try? JSONEncoder().encode(AnyEncodable(payload)) else { return }
        let pending = PendingSyncAction(
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: data
        )
        context.insert(pending)
        try? context.save()
    }

    func syncPendingActions() async {
        // This would process the PendingSyncAction queue
        // when the device comes back online.
        // Implementation depends on ModelContainer access pattern.
        // Each action is replayed against the appropriate repository.
    }

    // MARK: - Clear Cache (on logout)

    func clearCache(context: ModelContext) {
        try? context.delete(model: CachedShift.self)
        try? context.delete(model: CachedTask.self)
        try? context.delete(model: PendingSyncAction.self)
        try? context.save()
    }
}

// Helper for encoding arbitrary Encodable values
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        _encode = { encoder in try value.encode(to: encoder) }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
```

**Step 3: Register SwiftData models in app entry point**

Add to `CareCoordinatorApp.swift`:

```swift
@main
struct CareCoordinatorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CachedShift.self, CachedTask.self, PendingSyncAction.self])
    }
}
```

**Step 4: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 5: Commit**

```bash
git add CareCoordinator/Models/CachedModels.swift CareCoordinator/Services/OfflineCacheService.swift CareCoordinator/App/CareCoordinatorApp.swift
git commit -m "feat: add offline mode with SwiftData caching and pending sync queue"
```

---

## Phase 10: Care-y AI Assistant (Weeks 19-21)

### Task 10.1: Care-y Context Builder

**Files:**
- Create: `CareCoordinator/Services/Carey/CareyContextBuilder.swift`

**Step 1: Write CareyContextBuilder**

This service assembles a privacy-filtered context payload from local/cached data for the on-device AI model.

```swift
// CareCoordinator/Services/Carey/CareyContextBuilder.swift
import Foundation

struct CareyContext {
    let systemPrompt: String
    let contextData: String
}

final class CareyContextBuilder {
    func buildContext(
        profile: Profile,
        careGroup: CareGroup,
        shifts: [Shift],
        tasks: [CareTask],
        carerNames: [UUID: String]?,
        carePlanTexts: [String]?
    ) -> CareyContext {
        let isClient = profile.role == .client
        let privacyMode = careGroup.privacyMode

        var systemPrompt = """
        You are Care-y, a helpful assistant for a home care coordination app called CareCoordinator.
        You help \(isClient ? "clients manage their care group" : "carers manage their shifts and tasks").

        Important rules:
        - Only answer questions about care coordination, scheduling, tasks, and care plans.
        - Be warm, helpful, and concise.
        - If you don't have enough information to answer, say so clearly.
        """

        if !isClient {
            switch privacyMode {
            case .full:
                systemPrompt += "\n- PRIVACY: You must NOT reveal information about other carers, their schedules, or their names."
            case .anonymous:
                systemPrompt += "\n- PRIVACY: You may reference other carers' schedules but must NOT reveal their names."
            case .open:
                break // No restrictions
            }
        }

        var contextParts: [String] = []

        // Schedule context
        let relevantShifts = filterShifts(shifts, for: profile, privacyMode: privacyMode)
        if !relevantShifts.isEmpty {
            contextParts.append("## Current Schedule")
            for shift in relevantShifts.prefix(20) {
                let carerLabel: String
                if isClient || privacyMode == .open {
                    carerLabel = shift.carerId.flatMap { carerNames?[$0] } ?? "Unassigned"
                } else if privacyMode == .anonymous {
                    carerLabel = "A carer"
                } else {
                    carerLabel = shift.carerId == profile.id ? "You" : "Another carer"
                }
                contextParts.append("- \(shift.date.formatted(date: .abbreviated, time: .omitted)): \(carerLabel) (\(shift.startTime.formatted(date: .omitted, time: .shortened)) - \(shift.endTime.formatted(date: .omitted, time: .shortened))) [Status: \(shift.status.rawValue)]")
            }
        }

        // Tasks context
        let activeTasks = tasks.filter { !$0.completed }
        if !activeTasks.isEmpty {
            contextParts.append("\n## Active Tasks")
            for task in activeTasks.prefix(15) {
                let dueStr = task.dueDate.map { " (due: \($0.formatted(date: .abbreviated, time: .omitted)))" } ?? ""
                contextParts.append("- \(task.title)\(dueStr)")
            }
        }

        // Care plan text context (if available)
        if let planTexts = carePlanTexts, !planTexts.isEmpty {
            contextParts.append("\n## Care Plan Information")
            for text in planTexts.prefix(3) {
                contextParts.append(String(text.prefix(2000))) // Limit per plan
            }
        }

        contextParts.append("\n## Today's Date: \(Date().formatted(date: .complete, time: .omitted))")

        return CareyContext(
            systemPrompt: systemPrompt,
            contextData: contextParts.joined(separator: "\n")
        )
    }

    private func filterShifts(_ shifts: [Shift], for profile: Profile, privacyMode: PrivacyMode) -> [Shift] {
        if profile.role == .client || privacyMode == .open || privacyMode == .anonymous {
            return shifts
        }
        // Full privacy: only show own shifts
        return shifts.filter { $0.carerId == profile.id }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Services/Carey/CareyContextBuilder.swift
git commit -m "feat: add CareyContextBuilder with privacy-filtered context assembly"
```

---

### Task 10.2: Care-y Chat Service (Apple Foundation Models)

**Files:**
- Create: `CareCoordinator/Services/Carey/CareyChatService.swift`

**Step 1: Write CareyChatService**

```swift
// CareCoordinator/Services/Carey/CareyChatService.swift
import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: ChatRole
    let content: String
    let timestamp: Date

    init(role: ChatRole, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

enum ChatRole: String, Codable {
    case user
    case assistant
    case system
}

@Observable
final class CareyChatService {
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return true
        }
        #endif
        return false
    }

    var messages: [ChatMessage] = []
    var isGenerating = false
    var errorMessage: String?

    private var context: CareyContext?

    func configure(context: CareyContext) {
        self.context = context
    }

    func sendMessage(_ userMessage: String) async {
        guard let context else {
            errorMessage = "Care-y is not configured. Please try again."
            return
        }

        let userChat = ChatMessage(role: .user, content: userMessage)
        messages.append(userChat)
        isGenerating = true
        errorMessage = nil

        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            await generateWithFoundationModels(userMessage: userMessage, context: context)
        } else {
            appendFallbackMessage()
        }
        #else
        appendFallbackMessage()
        #endif

        isGenerating = false
    }

    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func generateWithFoundationModels(userMessage: String, context: CareyContext) async {
        do {
            let session = LanguageModelSession(
                instructions: context.systemPrompt + "\n\n" + context.contextData
            )

            let response = try await session.respond(to: userMessage)
            let assistantMessage = ChatMessage(role: .assistant, content: response.content)
            messages.append(assistantMessage)
        } catch {
            errorMessage = "Care-y couldn't process your request: \(error.localizedDescription)"
            let errorChat = ChatMessage(role: .assistant, content: "I'm sorry, I couldn't process that request. Please try again.")
            messages.append(errorChat)
        }
    }
    #endif

    private func appendFallbackMessage() {
        let fallback = ChatMessage(
            role: .assistant,
            content: "Care-y requires iOS 26 or later with Apple Intelligence enabled. Please update your device to use this feature."
        )
        messages.append(fallback)
    }

    func clearHistory() {
        messages.removeAll()
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors. (FoundationModels import is guarded with `#if canImport`.)

**Step 3: Commit**

```bash
git add CareCoordinator/Services/Carey/CareyChatService.swift
git commit -m "feat: add CareyChatService with Apple Foundation Models integration"
```

---

### Task 10.3: Care-y Chat View

**Files:**
- Create: `CareCoordinator/Views/Carey/CareyChatView.swift`

**Step 1: Write CareyChatView**

```swift
// CareCoordinator/Views/Carey/CareyChatView.swift
import SwiftUI

struct CareyChatView: View {
    @State private var chatService = CareyChatService()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    let profile: Profile
    let careGroup: CareGroup
    let shifts: [Shift]
    let tasks: [CareTask]
    let carerNames: [UUID: String]?

    private let contextBuilder = CareyContextBuilder()

    var body: some View {
        VStack(spacing: 0) {
            if !chatService.isAvailable {
                unavailableView
            } else {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatService.messages) { message in
                                ChatBubble(message: message, isCurrentUser: message.role == .user)
                                    .id(message.id)
                            }

                            if chatService.isGenerating {
                                HStack {
                                    ProgressView()
                                    Text("Care-y is thinking...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .id("generating")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatService.messages.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo(chatService.messages.last?.id ?? "generating", anchor: .bottom)
                        }
                    }
                }

                Divider()

                // Input bar
                HStack(spacing: 8) {
                    TextField("Ask Care-y anything...", text: $inputText, axis: .vertical)
                        .lineLimit(1...4)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatService.isGenerating)
                }
                .padding()
            }
        }
        .navigationTitle("Care-y")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Clear History", systemImage: "trash") {
                        chatService.clearHistory()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            let context = contextBuilder.buildContext(
                profile: profile,
                careGroup: careGroup,
                shifts: shifts,
                tasks: tasks,
                carerNames: carerNames,
                carePlanTexts: nil
            )
            chatService.configure(context: context)
        }
    }

    private var unavailableView: some View {
        ContentUnavailableView {
            Label("Care-y Unavailable", systemImage: "brain")
        } description: {
            Text("Care-y requires iOS 26 or later with Apple Intelligence enabled. Please update your device to use this feature.")
        }
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        Task {
            await chatService.sendMessage(text)
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(isCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !isCurrentUser { Spacer() }
        }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Views/Carey/CareyChatView.swift
git commit -m "feat: add Care-y chat view with message bubbles and streaming"
```

---

## Phase 11: Dashboard & Navigation (Weeks 21-23)

### Task 11.1: Client Dashboard

**Files:**
- Create: `CareCoordinator/Views/Dashboard/ClientDashboardView.swift`

**Step 1: Write ClientDashboardView**

```swift
// CareCoordinator/Views/Dashboard/ClientDashboardView.swift
import SwiftUI

struct ClientDashboardView: View {
    let profile: Profile
    let careGroup: CareGroup

    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var notificationViewModel = NotificationViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Welcome header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(profile.displayName ?? "Client")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()

                        NavigationLink(destination: NotificationListView(currentUserId: profile.id)) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.title3)
                                if notificationViewModel.unreadCount > 0 {
                                    Text("\(notificationViewModel.unreadCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Today's shift card
                    DashboardCard(title: "Today's Shift", icon: "calendar") {
                        if let todayShift = scheduleViewModel.todayShift {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(todayShift.startTime.formatted(date: .omitted, time: .shortened)) - \(todayShift.endTime.formatted(date: .omitted, time: .shortened))")
                                    .font(.headline)
                                Text("Status: \(todayShift.status.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("No shift today")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Quick actions grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickActionCard(
                            title: "Schedule",
                            icon: "calendar",
                            color: .blue,
                            destination: AnyView(ScheduleView(
                                careGroupId: careGroup.id,
                                isClient: true
                            ))
                        )

                        QuickActionCard(
                            title: "Carers",
                            icon: "person.2",
                            color: .green,
                            destination: AnyView(InviteCarerView(careGroupId: careGroup.id))
                        )

                        QuickActionCard(
                            title: "Tasks",
                            icon: "checklist",
                            color: .orange,
                            destination: AnyView(GeneralTaskListView(
                                careGroupId: careGroup.id,
                                currentUserId: profile.id,
                                isClient: true
                            ))
                        )

                        QuickActionCard(
                            title: "Care Plans",
                            icon: "doc.text",
                            color: .purple,
                            destination: AnyView(CarePlanListView(
                                careGroupId: careGroup.id,
                                isClient: true
                            ))
                        )

                        QuickActionCard(
                            title: "PTO",
                            icon: "calendar.badge.clock",
                            color: .red,
                            destination: AnyView(PTOListView(
                                careGroupId: careGroup.id,
                                isClient: true,
                                currentUserId: profile.id
                            ))
                        )

                        QuickActionCard(
                            title: "Care-y",
                            icon: "brain",
                            color: .pink,
                            destination: AnyView(CareyChatView(
                                profile: profile,
                                careGroup: careGroup,
                                shifts: scheduleViewModel.shifts,
                                tasks: [],
                                carerNames: nil
                            ))
                        )
                    }
                    .padding(.horizontal)

                    // Recent activity
                    DashboardCard(title: "Recent Activity", icon: "clock") {
                        NavigationLink(destination: ActivityLogView(careGroupId: careGroup.id)) {
                            Text("View activity log")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .task {
                scheduleViewModel.careGroupId = careGroup.id
                await scheduleViewModel.loadShifts()
                notificationViewModel.currentUserId = profile.id
                await notificationViewModel.loadNotifications()
            }
        }
    }
}

struct DashboardCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Views/Dashboard/ClientDashboardView.swift
git commit -m "feat: add client dashboard with today's shift, quick actions, and notifications"
```

---

### Task 11.2: Carer Dashboard

**Files:**
- Create: `CareCoordinator/Views/Dashboard/CarerDashboardView.swift`

**Step 1: Write CarerDashboardView**

```swift
// CareCoordinator/Views/Dashboard/CarerDashboardView.swift
import SwiftUI

struct CarerDashboardView: View {
    let profile: Profile
    let careGroup: CareGroup

    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var notificationViewModel = NotificationViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Welcome header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(profile.displayName ?? "Carer")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()

                        NavigationLink(destination: NotificationListView(currentUserId: profile.id)) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.title3)
                                if notificationViewModel.unreadCount > 0 {
                                    Text("\(notificationViewModel.unreadCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Next shift card
                    DashboardCard(title: "Your Next Shift", icon: "calendar") {
                        if let nextShift = scheduleViewModel.nextShift {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(nextShift.date.formatted(date: .complete, time: .omitted))
                                    .font(.headline)
                                Text("\(nextShift.startTime.formatted(date: .omitted, time: .shortened)) - \(nextShift.endTime.formatted(date: .omitted, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("No upcoming shifts")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Quick actions
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickActionCard(
                            title: "My Schedule",
                            icon: "calendar",
                            color: .blue,
                            destination: AnyView(ScheduleView(
                                careGroupId: careGroup.id,
                                isClient: false
                            ))
                        )

                        QuickActionCard(
                            title: "My Tasks",
                            icon: "checklist",
                            color: .orange,
                            destination: AnyView(GeneralTaskListView(
                                careGroupId: careGroup.id,
                                currentUserId: profile.id,
                                isClient: false
                            ))
                        )

                        QuickActionCard(
                            title: "Care Plans",
                            icon: "doc.text",
                            color: .purple,
                            destination: AnyView(CarePlanListView(
                                careGroupId: careGroup.id,
                                isClient: false
                            ))
                        )

                        QuickActionCard(
                            title: "Request PTO",
                            icon: "calendar.badge.clock",
                            color: .red,
                            destination: AnyView(PTOListView(
                                careGroupId: careGroup.id,
                                isClient: false,
                                currentUserId: profile.id
                            ))
                        )

                        QuickActionCard(
                            title: "Open Shifts",
                            icon: "hand.raised",
                            color: .green,
                            destination: AnyView(OpenShiftsView(
                                careGroupId: careGroup.id,
                                currentUserId: profile.id,
                                isClient: false
                            ))
                        )

                        QuickActionCard(
                            title: "Care-y",
                            icon: "brain",
                            color: .pink,
                            destination: AnyView(CareyChatView(
                                profile: profile,
                                careGroup: careGroup,
                                shifts: scheduleViewModel.shifts,
                                tasks: [],
                                carerNames: nil
                            ))
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .task {
                scheduleViewModel.careGroupId = careGroup.id
                await scheduleViewModel.loadShifts()
                notificationViewModel.currentUserId = profile.id
                await notificationViewModel.loadNotifications()
            }
        }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Views/Dashboard/CarerDashboardView.swift
git commit -m "feat: add carer dashboard with next shift, quick actions"
```

---

### Task 11.3: Main ContentView Router

**Files:**
- Modify: `CareCoordinator/App/ContentView.swift`

**Step 1: Update ContentView with role-based routing**

Replace the existing ContentView with:

```swift
// CareCoordinator/App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .loading:
                ProgressView("Loading...")

            case .unauthenticated:
                LoginView(viewModel: authViewModel)

            case .authenticated(let profile):
                if let careGroup = authViewModel.careGroup {
                    // Route to role-specific dashboard
                    switch profile.role {
                    case .client:
                        ClientDashboardView(profile: profile, careGroup: careGroup)
                    case .carer:
                        CarerDashboardView(profile: profile, careGroup: careGroup)
                    }
                } else {
                    // No care group yet — show create/join
                    NoCareGroupView(profile: profile, authViewModel: authViewModel)
                }

            case .needsCareGroup(let profile):
                NoCareGroupView(profile: profile, authViewModel: authViewModel)
            }
        }
        .task {
            await authViewModel.checkSession()
        }
    }
}

struct NoCareGroupView: View {
    let profile: Profile
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.3")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Welcome to CareCoordinator")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("You need to create or join a care group to get started.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                if profile.role == .client {
                    NavigationLink("Create Care Group") {
                        CreateCareGroupView()
                    }
                    .buttonStyle(.borderedProminent)
                }

                NavigationLink("Join with Invite Code") {
                    JoinCareGroupView()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/App/ContentView.swift
git commit -m "feat: add role-based routing in ContentView (client vs carer dashboards)"
```

---

## Phase 12: Settings & Polish (Weeks 23-25)

### Task 12.1: Settings View

**Files:**
- Create: `CareCoordinator/Views/Settings/SettingsView.swift`

**Step 1: Write SettingsView**

```swift
// CareCoordinator/Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    let profile: Profile
    let careGroup: CareGroup
    let isClient: Bool
    let onSignOut: () -> Void

    var body: some View {
        Form {
            Section("Profile") {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading) {
                        Text(profile.displayName ?? "User")
                            .font(.headline)
                        Text(profile.role.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if isClient {
                Section("Care Group") {
                    HStack {
                        Text("Privacy Mode")
                        Spacer()
                        Text(careGroup.privacyMode.rawValue.capitalized)
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink("Manage Carers") {
                        InviteCarerView(careGroupId: careGroup.id)
                    }

                    NavigationLink("Swapover Checklist Template") {
                        SwapoverTemplateView(careGroupId: careGroup.id)
                    }
                }

                Section("Care") {
                    NavigationLink("Emergency Contacts") {
                        EmergencyContactsView(careGroupId: careGroup.id, isClient: true)
                    }

                    NavigationLink("Reminders") {
                        RemindersView(careGroupId: careGroup.id)
                    }
                }
            }

            Section("Sync") {
                NavigationLink("Calendar Sync") {
                    CalendarSyncView(
                        careGroupId: careGroup.id,
                        shifts: [],
                        carerNames: nil
                    )
                }

                NavigationLink("Notification Preferences") {
                    NotificationPreferencesView()
                }
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    onSignOut()
                }
            }

            Section {
                HStack {
                    Spacer()
                    Text("CareCoordinator v1.0")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct NotificationPreferencesView: View {
    @State private var shiftReminders = true
    @State private var ptoAlerts = true
    @State private var taskAssignments = true

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Shift Reminders", isOn: $shiftReminders)
                Toggle("PTO Request Alerts", isOn: $ptoAlerts)
                Toggle("Task Assignments", isOn: $taskAssignments)
            }
        }
        .navigationTitle("Notifications")
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Views/Settings/SettingsView.swift
git commit -m "feat: add settings view with profile, care group config, sync options"
```

---

### Task 12.2: Carer Availability View

**Files:**
- Create: `CareCoordinator/Repositories/AvailabilityRepository.swift`
- Create: `CareCoordinator/Views/Schedule/AvailabilityView.swift`

**Step 1: Write AvailabilityRepository**

```swift
// CareCoordinator/Repositories/AvailabilityRepository.swift
import Foundation
import Supabase

@Observable
final class AvailabilityRepository {
    private let supabase = SupabaseManager.shared.client

    func submitAvailability(
        carerId: UUID,
        careGroupId: UUID,
        date: Date,
        startTime: Date,
        endTime: Date
    ) async throws -> CarerAvailability {
        struct InsertPayload: Encodable {
            let carer_id: UUID
            let care_group_id: UUID
            let date: String
            let start_time: String
            let end_time: String
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        return try await supabase
            .from("carer_availability")
            .insert(InsertPayload(
                carer_id: carerId,
                care_group_id: careGroupId,
                date: dateFormatter.string(from: date),
                start_time: timeFormatter.string(from: startTime),
                end_time: timeFormatter.string(from: endTime)
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func fetchMyAvailability(carerId: UUID) async throws -> [CarerAvailability] {
        try await supabase
            .from("carer_availability")
            .select()
            .eq("carer_id", value: carerId)
            .order("date", ascending: true)
            .execute()
            .value
    }

    func deleteAvailability(id: UUID) async throws {
        try await supabase
            .from("carer_availability")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
```

**Step 2: Write AvailabilityView**

```swift
// CareCoordinator/Views/Schedule/AvailabilityView.swift
import SwiftUI

struct AvailabilityView: View {
    @State private var availability: [CarerAvailability] = []
    @State private var showingAddSheet = false
    @State private var newDate = Date()
    @State private var newStartTime = Date()
    @State private var newEndTime = Date()

    let carerId: UUID
    let careGroupId: UUID
    private let repository = AvailabilityRepository()

    var body: some View {
        List {
            if availability.isEmpty {
                ContentUnavailableView("No Availability Set", systemImage: "calendar.badge.plus",
                    description: Text("Mark dates you're available for extra shifts."))
            }

            ForEach(availability) { slot in
                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.date.formatted(date: .complete, time: .omitted))
                        .font(.headline)
                    Text("\(slot.startTime.formatted(date: .omitted, time: .shortened)) - \(slot.endTime.formatted(date: .omitted, time: .shortened))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { indices in
                for index in indices {
                    let slot = availability[index]
                    Task {
                        try? await repository.deleteAvailability(id: slot.id)
                        availability.remove(at: index)
                    }
                }
            }
        }
        .navigationTitle("My Availability")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    DatePicker("Date", selection: $newDate, displayedComponents: .date)
                    DatePicker("Start Time", selection: $newStartTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $newEndTime, displayedComponents: .hourAndMinute)
                }
                .navigationTitle("Add Availability")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                if let slot = try? await repository.submitAvailability(
                                    carerId: carerId,
                                    careGroupId: careGroupId,
                                    date: newDate,
                                    startTime: newStartTime,
                                    endTime: newEndTime
                                ) {
                                    availability.append(slot)
                                    showingAddSheet = false
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            availability = (try? await repository.fetchMyAvailability(carerId: carerId)) ?? []
        }
    }
}
```

**Step 3: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 4: Commit**

```bash
git add CareCoordinator/Repositories/AvailabilityRepository.swift CareCoordinator/Views/Schedule/AvailabilityView.swift
git commit -m "feat: add carer availability repository and view"
```

---

### Task 12.3: Supabase Realtime Subscriptions

**Files:**
- Create: `CareCoordinator/Services/RealtimeService.swift`

**Step 1: Write RealtimeService**

```swift
// CareCoordinator/Services/RealtimeService.swift
import Foundation
import Supabase
import Realtime

@Observable
final class RealtimeService {
    private let supabase = SupabaseManager.shared.client
    private var channels: [RealtimeChannelV2] = []

    var onShiftChange: ((Shift) -> Void)?
    var onTaskChange: ((CareTask) -> Void)?
    var onNotification: ((CareNotification) -> Void)?

    func subscribeToShifts(careGroupId: UUID) async {
        let channel = supabase.realtimeV2.channel("shifts_\(careGroupId)")

        let changes = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "shifts",
            filter: "care_group_id=eq.\(careGroupId)"
        )

        await channel.subscribe()

        Task {
            for await change in changes {
                if let shift = try? change.decodeRecord(as: Shift.self, decoder: JSONDecoder()) {
                    await MainActor.run {
                        onShiftChange?(shift)
                    }
                }
            }
        }

        channels.append(channel)
    }

    func subscribeToTasks(careGroupId: UUID) async {
        let channel = supabase.realtimeV2.channel("tasks_\(careGroupId)")

        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "tasks",
            filter: "care_group_id=eq.\(careGroupId)"
        )

        await channel.subscribe()

        Task {
            for await change in changes {
                if let task = try? change.decodeRecord(as: CareTask.self, decoder: JSONDecoder()) {
                    await MainActor.run {
                        onTaskChange?(task)
                    }
                }
            }
        }

        channels.append(channel)
    }

    func subscribeToNotifications(userId: UUID) async {
        let channel = supabase.realtimeV2.channel("notifications_\(userId)")

        let inserts = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "notifications",
            filter: "user_id=eq.\(userId)"
        )

        await channel.subscribe()

        Task {
            for await insert in inserts {
                if let notification = try? insert.decodeRecord(as: CareNotification.self, decoder: JSONDecoder()) {
                    await MainActor.run {
                        onNotification?(notification)
                    }
                }
            }
        }

        channels.append(channel)
    }

    func unsubscribeAll() async {
        for channel in channels {
            await channel.unsubscribe()
        }
        channels.removeAll()
    }
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Services/RealtimeService.swift
git commit -m "feat: add RealtimeService for live shift, task, and notification updates"
```

---

## Phase 13: Final Polish & App Store Preparation (Weeks 25-27)

### Task 13.1: App Icon & Launch Screen

**Files:**
- Modify: `CareCoordinator/Resources/Assets.xcassets/AppIcon.appiconset/`
- Create: `CareCoordinator/App/LaunchScreenView.swift`

**Step 1: Create LaunchScreenView**

```swift
// CareCoordinator/App/LaunchScreenView.swift
import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)

                Text("CareCoordinator")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Privacy-first care management")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { isAnimating = true }
    }
}
```

**Step 2: Add app icon**

Add your app icon files to `CareCoordinator/Resources/Assets.xcassets/AppIcon.appiconset/`. You need a 1024x1024 icon.

**Step 3: Commit**

```bash
git add CareCoordinator/App/LaunchScreenView.swift CareCoordinator/Resources/
git commit -m "feat: add launch screen and app icon placeholder"
```

---

### Task 13.2: Error Handling & Empty States

**Files:**
- Create: `CareCoordinator/Utilities/ErrorView.swift`

**Step 1: Write reusable error handling components**

```swift
// CareCoordinator/Utilities/ErrorView.swift
import SwiftUI

struct ErrorBanner: View {
    let message: String
    let onDismiss: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(message)
                .font(.subheadline)
            Spacer()
            if let onDismiss {
                Button { onDismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

struct RetryView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") { onRetry() }
                .buttonStyle(.borderedProminent)
        }
    }
}
```

**Step 2: Commit**

```bash
git add CareCoordinator/Utilities/ErrorView.swift
git commit -m "feat: add reusable error banner and retry view components"
```

---

### Task 13.3: Onboarding Flow for First Launch

**Files:**
- Create: `CareCoordinator/Views/Onboarding/OnboardingView.swift`

**Step 1: Write OnboardingView**

```swift
// CareCoordinator/Views/Onboarding/OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "heart.circle.fill",
            title: "Welcome to CareCoordinator",
            description: "The privacy-first app for managing home care with rotating carers.",
            color: .blue
        ),
        OnboardingPage(
            icon: "calendar.badge.clock",
            title: "Smart Scheduling",
            description: "Auto-rotating shift schedules, PTO management, and availability tracking — all in one place.",
            color: .green
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Privacy Built In",
            description: "End-to-end encryption for care plans. Row-level security. Your data stays yours.",
            color: .purple
        ),
        OnboardingPage(
            icon: "brain",
            title: "Meet Care-y",
            description: "Your on-device AI assistant. Ask about schedules, tasks, and care plans — nothing leaves your device.",
            color: .pink
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: pages[index].icon)
                            .font(.system(size: 80))
                            .foregroundStyle(pages[index].color)

                        Text(pages[index].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(pages[index].description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
```

**Step 2: Verify compilation**

Run: Build (`Cmd+B`)
Expected: No errors.

**Step 3: Commit**

```bash
git add CareCoordinator/Views/Onboarding/OnboardingView.swift
git commit -m "feat: add onboarding flow for first-time users"
```

---

### Task 13.4: Final Integration & App Store Preparation

**Step 1: Verify all views are wired in navigation**

Manually walk through the app flow:
1. Launch → OnboardingView (first launch) → LoginView
2. LoginView → SignUpView → CreateCareGroupView or JoinCareGroupView
3. ClientDashboardView → All navigation links work
4. CarerDashboardView → All navigation links work
5. Settings → All sub-views accessible

**Step 2: Run full build**

Run: `xcodebuild -scheme CareCoordinator -destination 'platform=iOS Simulator,name=iPhone 16' build`
Expected: BUILD SUCCEEDED

**Step 3: Prepare App Store metadata**

- App name: CareCoordinator
- Subtitle: Privacy-first care scheduling
- Category: Health & Fitness
- Age Rating: 4+
- Privacy Policy URL: (create and host)
- Description: Write based on PRD executive summary

**Step 4: Final commit**

```bash
git add -A
git commit -m "chore: final integration check and App Store preparation"
```

---

## Summary: All Phases

| Phase | Description | Tasks | Weeks |
|-------|-------------|-------|-------|
| 0 | Project Setup & Supabase Foundation | 0.1-0.7 | 1-2 |
| 1 | Authentication & Onboarding | 1.1-1.6 | 3-4 |
| 2 | Scheduling Engine | 2.1-2.2 | 5-6 |
| 3 | Care Plans & E2EE | 3.1-3.3 | 7-9 |
| 4 | PTO & Coverage | 4.1-4.3 | 9-11 |
| 5 | Task System | 5.1-5.3 | 11-13 |
| 6 | Notifications | 6.1-6.3 | 13-14 |
| 7 | Shift Notes, Reminders & Emergency | 7.1-7.4 | 14-16 |
| 8 | Calendar Integration (EventKit) | 8.1-8.2 | 16-17 |
| 9 | Activity Log & Offline Mode | 9.1-9.3 | 17-19 |
| 10 | Care-y AI Assistant | 10.1-10.3 | 19-21 |
| 11 | Dashboard & Navigation | 11.1-11.3 | 21-23 |
| 12 | Settings & Polish | 12.1-12.3 | 23-25 |
| 13 | Final Polish & App Store | 13.1-13.4 | 25-27 |

**Total: 42 tasks across 13 phases over ~27 weeks.**
